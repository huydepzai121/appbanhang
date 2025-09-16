const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

const router = express.Router();

// Get user's cart
router.get('/', authenticateToken, async (req, res) => {
    try {
        const [cartItems] = await pool.execute(`
            SELECT
                c.id, c.quantity, c.created_at,
                p.id as product_id, p.name, p.price, p.image, p.stock_quantity
            FROM cart c
            JOIN products p ON c.product_id = p.id
            WHERE c.user_id = ? AND p.is_active = 1
            ORDER BY c.created_at DESC
        `, [req.user.id]);

        const total = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);

        successResponse(res, {
            items: cartItems,
            total: total,
            count: cartItems.length
        }, 'Cart retrieved successfully');
    } catch (error) {
        console.error('Get cart error:', error);
        errorResponse(res, 'Failed to get cart', 500);
    }
});

// Add item to cart
router.post('/add', authenticateToken, [
    body('product_id').isInt({ min: 1 }).withMessage('Product ID is required'),
    body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { product_id, quantity } = req.body;
        const user_id = req.user.id;

        // Check if product exists and is active
        const [products] = await pool.execute(
            'SELECT id, stock_quantity FROM products WHERE id = ? AND is_active = 1',
            [product_id]
        );

        if (products.length === 0) {
            return errorResponse(res, 'Product not found', 404);
        }

        if (products[0].stock_quantity < quantity) {
            return errorResponse(res, 'Insufficient stock', 400);
        }

        // Check if item already in cart
        const [existingItems] = await pool.execute(
            'SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ?',
            [user_id, product_id]
        );

        if (existingItems.length > 0) {
            // Update quantity
            const newQuantity = existingItems[0].quantity + quantity;
            if (products[0].stock_quantity < newQuantity) {
                return errorResponse(res, 'Insufficient stock', 400);
            }

            await pool.execute(
                'UPDATE cart SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                [newQuantity, existingItems[0].id]
            );
        } else {
            // Add new item
            await pool.execute(
                'INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)',
                [user_id, product_id, quantity]
            );
        }

        successResponse(res, null, 'Item added to cart successfully');
    } catch (error) {
        console.error('Add to cart error:', error);
        errorResponse(res, 'Failed to add item to cart', 500);
    }
});

// Update cart item quantity
router.put('/:id', authenticateToken, [
    body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { quantity } = req.body;
        const cartId = req.params.id;
        const userId = req.user.id;

        // Check if cart item belongs to user
        const [cartItems] = await pool.execute(
            'SELECT c.*, p.stock_quantity FROM cart c JOIN products p ON c.product_id = p.id WHERE c.id = ? AND c.user_id = ?',
            [cartId, userId]
        );

        if (cartItems.length === 0) {
            return errorResponse(res, 'Cart item not found', 404);
        }

        if (cartItems[0].stock_quantity < quantity) {
            return errorResponse(res, 'Insufficient stock', 400);
        }

        await pool.execute(
            'UPDATE cart SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
            [quantity, cartId]
        );

        successResponse(res, null, 'Cart updated successfully');
    } catch (error) {
        console.error('Update cart error:', error);
        errorResponse(res, 'Failed to update cart', 500);
    }
});

// Remove item from cart
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const cartId = req.params.id;
        const userId = req.user.id;

        const [result] = await pool.execute(
            'DELETE FROM cart WHERE id = ? AND user_id = ?',
            [cartId, userId]
        );

        if (result.affectedRows === 0) {
            return errorResponse(res, 'Cart item not found', 404);
        }

        successResponse(res, null, 'Item removed from cart successfully');
    } catch (error) {
        console.error('Remove from cart error:', error);
        errorResponse(res, 'Failed to remove item from cart', 500);
    }
});

// Clear cart
router.delete('/', authenticateToken, async (req, res) => {
    try {
        await pool.execute('DELETE FROM cart WHERE user_id = ?', [req.user.id]);
        successResponse(res, null, 'Cart cleared successfully');
    } catch (error) {
        console.error('Clear cart error:', error);
        errorResponse(res, 'Failed to clear cart', 500);
    }
});

module.exports = router;