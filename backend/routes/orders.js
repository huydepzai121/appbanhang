const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const { successResponse, errorResponse, generateOrderNumber } = require('../utils/helpers');

const router = express.Router();

// Create new order
router.post('/', authenticateToken, [
    body('shipping_name').trim().isLength({ min: 2 }).withMessage('Shipping name is required'),
    body('shipping_phone').isMobilePhone('vi-VN').withMessage('Valid phone number is required'),
    body('shipping_address').trim().isLength({ min: 10 }).withMessage('Shipping address is required'),
    body('payment_method').isIn(['cod', 'bank_transfer', 'credit_card']).withMessage('Invalid payment method')
], async (req, res) => {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { shipping_name, shipping_phone, shipping_address, payment_method, notes } = req.body;
        const userId = req.user.id;

        // Get cart items
        const [cartItems] = await connection.execute(`
            SELECT c.*, p.name, p.price, p.stock_quantity
            FROM cart c
            JOIN products p ON c.product_id = p.id
            WHERE c.user_id = ? AND p.is_active = 1
        `, [userId]);

        if (cartItems.length === 0) {
            await connection.rollback();
            return errorResponse(res, 'Cart is empty', 400);
        }

        // Check stock availability
        for (const item of cartItems) {
            if (item.stock_quantity < item.quantity) {
                await connection.rollback();
                return errorResponse(res, `Insufficient stock for ${item.name}`, 400);
            }
        }

        // Calculate totals
        const totalAmount = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const shippingFee = totalAmount >= 500000 ? 0 : 30000; // Free shipping for orders >= 500k
        const finalAmount = totalAmount + shippingFee;

        // Create order
        const orderNumber = generateOrderNumber();
        const [orderResult] = await connection.execute(`
            INSERT INTO orders (
                user_id, order_number, total_amount, shipping_fee, final_amount,
                payment_method, shipping_name, shipping_phone, shipping_address, notes
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [userId, orderNumber, totalAmount, shippingFee, finalAmount, payment_method,
            shipping_name, shipping_phone, shipping_address, notes || null]);

        const orderId = orderResult.insertId;

        // Create order items and update stock
        for (const item of cartItems) {
            await connection.execute(`
                INSERT INTO order_items (order_id, product_id, quantity, price, total)
                VALUES (?, ?, ?, ?, ?)
            `, [orderId, item.product_id, item.quantity, item.price, item.price * item.quantity]);

            // Update product stock
            await connection.execute(
                'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
                [item.quantity, item.product_id]
            );
        }

        // Clear cart
        await connection.execute('DELETE FROM cart WHERE user_id = ?', [userId]);

        await connection.commit();

        // Get created order
        const [orders] = await pool.execute(`
            SELECT * FROM orders WHERE id = ?
        `, [orderId]);

        successResponse(res, orders[0], 'Order created successfully', 201);

    } catch (error) {
        await connection.rollback();
        console.error('Create order error:', error);
        errorResponse(res, 'Failed to create order', 500);
    } finally {
        connection.release();
    }
});

// Get user's orders
router.get('/', authenticateToken, async (req, res) => {
    try {
        const [orders] = await pool.execute(`
            SELECT o.*, COUNT(oi.id) as item_count
            FROM orders o
            LEFT JOIN order_items oi ON o.id = oi.order_id
            WHERE o.user_id = ?
            GROUP BY o.id
            ORDER BY o.created_at DESC
        `, [req.user.id]);

        successResponse(res, orders, 'Orders retrieved successfully');
    } catch (error) {
        console.error('Get orders error:', error);
        errorResponse(res, 'Failed to get orders', 500);
    }
});

// Get order details
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const orderId = req.params.id;
        const userId = req.user.id;

        // Get order
        const [orders] = await pool.execute(
            'SELECT * FROM orders WHERE id = ? AND user_id = ?',
            [orderId, userId]
        );

        if (orders.length === 0) {
            return errorResponse(res, 'Order not found', 404);
        }

        // Get order items
        const [orderItems] = await pool.execute(`
            SELECT oi.*, p.name, p.image
            FROM order_items oi
            JOIN products p ON oi.product_id = p.id
            WHERE oi.order_id = ?
        `, [orderId]);

        const order = orders[0];
        order.items = orderItems;

        successResponse(res, order, 'Order retrieved successfully');
    } catch (error) {
        console.error('Get order error:', error);
        errorResponse(res, 'Failed to get order', 500);
    }
});

module.exports = router;