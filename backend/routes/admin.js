const express = require('express');
const bcrypt = require('bcryptjs');
const { pool } = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

const router = express.Router();

// Get dashboard statistics (Admin only)
router.get('/dashboard', authenticateToken, requireAdmin, async (req, res) => {
    try {
        // Get total products
        const [productStats] = await pool.execute(`
            SELECT 
                COUNT(*) as total_products,
                COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_products,
                COUNT(CASE WHEN is_featured = 1 THEN 1 END) as featured_products,
                COUNT(CASE WHEN stock_quantity = 0 THEN 1 END) as out_of_stock
            FROM products
        `);

        // Get total users
        const [userStats] = await pool.execute(`
            SELECT 
                COUNT(*) as total_users,
                COUNT(CASE WHEN role = 'customer' THEN 1 END) as customers,
                COUNT(CASE WHEN role = 'admin' THEN 1 END) as admins
            FROM users
        `);

        // Get order statistics
        const [orderStats] = await pool.execute(`
            SELECT 
                COUNT(*) as total_orders,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_orders,
                COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed_orders,
                COUNT(CASE WHEN status = 'shipping' THEN 1 END) as shipping_orders,
                COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered_orders,
                COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_orders,
                SUM(total_amount) as total_revenue
            FROM orders
        `);

        // Get today's orders
        const [todayOrders] = await pool.execute(`
            SELECT COUNT(*) as today_orders
            FROM orders 
            WHERE DATE(created_at) = CURDATE()
        `);

        // Get recent orders
        const [recentOrders] = await pool.execute(`
            SELECT 
                o.id,
                o.order_number,
                o.total_amount,
                o.status,
                o.created_at,
                u.name as customer_name
            FROM orders o
            LEFT JOIN users u ON o.user_id = u.id
            ORDER BY o.created_at DESC
            LIMIT 10
        `);

        // Get top selling products
        const [topProducts] = await pool.execute(`
            SELECT 
                p.id,
                p.name,
                p.price,
                p.image,
                SUM(oi.quantity) as total_sold
            FROM products p
            LEFT JOIN order_items oi ON p.id = oi.product_id
            LEFT JOIN orders o ON oi.order_id = o.id
            WHERE o.status IN ('delivered', 'confirmed', 'shipping')
            GROUP BY p.id
            ORDER BY total_sold DESC
            LIMIT 5
        `);

        const dashboardData = {
            products: productStats[0],
            users: userStats[0],
            orders: {
                ...orderStats[0],
                today_orders: todayOrders[0].today_orders
            },
            recent_orders: recentOrders,
            top_products: topProducts
        };

        successResponse(res, dashboardData, 'Dashboard data retrieved successfully');

    } catch (error) {
        console.error('Dashboard error:', error);
        errorResponse(res, 'Failed to get dashboard data', 500);
    }
});

// Get all orders for admin (Admin only)
router.get('/orders', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { status, page = 1, limit = 20 } = req.query;
        const offset = (page - 1) * limit;

        let whereClause = '';
        let queryParams = [];

        if (status && status !== 'all') {
            whereClause = 'WHERE o.status = ?';
            queryParams.push(status);
        }

        const [orders] = await pool.execute(`
            SELECT
                o.*,
                o.shipping_name as customer_name,
                u.email as customer_email,
                o.shipping_phone as customer_phone,
                COUNT(oi.id) as item_count
            FROM orders o
            LEFT JOIN users u ON o.user_id = u.id
            LEFT JOIN order_items oi ON o.id = oi.order_id
            ${whereClause}
            GROUP BY o.id
            ORDER BY o.created_at DESC
            LIMIT ? OFFSET ?
        `, [...queryParams, parseInt(limit), parseInt(offset)]);

        // Get total count
        const [totalCount] = await pool.execute(`
            SELECT COUNT(*) as total
            FROM orders o
            ${whereClause}
        `, queryParams);

        const result = {
            orders,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total: totalCount[0].total,
                pages: Math.ceil(totalCount[0].total / limit)
            }
        };

        successResponse(res, result, 'Orders retrieved successfully');

    } catch (error) {
        console.error('Get orders error:', error);
        errorResponse(res, 'Failed to get orders', 500);
    }
});

// Update order status (Admin only)
router.put('/orders/:id/status', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const orderId = parseInt(req.params.id);
        const { status } = req.body;

        const validStatuses = ['pending', 'confirmed', 'shipping', 'delivered', 'cancelled'];
        if (!validStatuses.includes(status)) {
            return errorResponse(res, 'Invalid status', 400);
        }

        // Check if order exists
        const [existingOrders] = await pool.execute(
            'SELECT id FROM orders WHERE id = ?',
            [orderId]
        );

        if (existingOrders.length === 0) {
            return errorResponse(res, 'Order not found', 404);
        }

        // Update order status
        await pool.execute(
            'UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
            [status, orderId]
        );

        // Get updated order
        const [orders] = await pool.execute(`
            SELECT 
                o.*,
                u.name as customer_name,
                u.email as customer_email
            FROM orders o
            LEFT JOIN users u ON o.user_id = u.id
            WHERE o.id = ?
        `, [orderId]);

        successResponse(res, orders[0], 'Order status updated successfully');

    } catch (error) {
        console.error('Update order status error:', error);
        errorResponse(res, 'Failed to update order status', 500);
    }
});

// Get order details (Admin only)
router.get('/orders/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const orderId = parseInt(req.params.id);

        // Get order with customer info
        const [orders] = await pool.execute(`
            SELECT 
                o.*,
                u.name as customer_name,
                u.email as customer_email,
                u.phone as customer_phone,
                u.address as customer_address
            FROM orders o
            LEFT JOIN users u ON o.user_id = u.id
            WHERE o.id = ?
        `, [orderId]);

        if (orders.length === 0) {
            return errorResponse(res, 'Order not found', 404);
        }

        // Get order items
        const [orderItems] = await pool.execute(`
            SELECT 
                oi.*,
                p.name as product_name,
                p.image as product_image,
                p.brand as product_brand
            FROM order_items oi
            LEFT JOIN products p ON oi.product_id = p.id
            WHERE oi.order_id = ?
        `, [orderId]);

        const orderDetails = {
            ...orders[0],
            items: orderItems
        };

        successResponse(res, orderDetails, 'Order details retrieved successfully');

    } catch (error) {
        console.error('Get order details error:', error);
        errorResponse(res, 'Failed to get order details', 500);
    }
});

// Create order for admin (Admin only)
router.post('/orders', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const {
            customer_name,
            customer_phone,
            customer_address,
            notes,
            items,
            total_amount,
            status = 'confirmed'
        } = req.body;

        // Validate required fields
        if (!customer_name || !customer_phone || !customer_address || !items || items.length === 0) {
            return errorResponse(res, 'Missing required fields', 400);
        }

        // Start transaction
        const connection = await pool.getConnection();
        await connection.beginTransaction();

        try {
            // Generate order number
            const orderNumber = `ORD${Date.now()}`;

            // Use admin user as the order creator (since user_id is required)
            const adminUserId = req.user.id; // Get admin user ID from token

            // Create order with admin user_id but customer shipping info
            const [orderResult] = await connection.execute(`
                INSERT INTO orders (
                    order_number, user_id, shipping_name, shipping_phone,
                    shipping_address, notes, total_amount, final_amount, status
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            `, [
                orderNumber, adminUserId, customer_name, customer_phone,
                customer_address, notes || null, total_amount, total_amount, status
            ]);

            const orderId = orderResult.insertId;

            // Add order items
            for (const item of items) {
                const itemTotal = item.price * item.quantity;
                await connection.execute(`
                    INSERT INTO order_items (order_id, product_id, quantity, price, total)
                    VALUES (?, ?, ?, ?, ?)
                `, [orderId, item.product_id, item.quantity, item.price, itemTotal]);

                // Update product stock
                await connection.execute(`
                    UPDATE products
                    SET stock_quantity = stock_quantity - ?
                    WHERE id = ? AND stock_quantity >= ?
                `, [item.quantity, item.product_id, item.quantity]);
            }

            await connection.commit();

            // Get created order with items
            const [orders] = await pool.execute(`
                SELECT
                    o.*,
                    COUNT(oi.id) as item_count
                FROM orders o
                LEFT JOIN order_items oi ON o.id = oi.order_id
                WHERE o.id = ?
                GROUP BY o.id
            `, [orderId]);

            successResponse(res, orders[0], 'Order created successfully', 201);

        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }

    } catch (error) {
        console.error('Create order error:', error);
        errorResponse(res, 'Failed to create order', 500);
    }
});

// Update user (Admin only)
router.put('/users/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const userId = parseInt(req.params.id);
        const { name, email, phone, address, role } = req.body;

        // Check if user exists
        const [existingUsers] = await pool.execute(
            'SELECT id FROM users WHERE id = ?',
            [userId]
        );

        if (existingUsers.length === 0) {
            return errorResponse(res, 'User not found', 404);
        }

        // Update user (without is_active since column doesn't exist)
        await pool.execute(`
            UPDATE users
            SET name = ?, email = ?, phone = ?, address = ?, role = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        `, [name, email, phone || null, address || null, role, userId]);

        // Get updated user
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, created_at, updated_at FROM users WHERE id = ?',
            [userId]
        );

        successResponse(res, users[0], 'User updated successfully');

    } catch (error) {
        console.error('Update user error:', error);
        errorResponse(res, 'Failed to update user', 500);
    }
});

// Delete user (Admin only)
router.delete('/users/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const userId = parseInt(req.params.id);

        // Check if user exists
        const [existingUsers] = await pool.execute(
            'SELECT id, role FROM users WHERE id = ?',
            [userId]
        );

        if (existingUsers.length === 0) {
            return errorResponse(res, 'User not found', 404);
        }

        // Don't allow deleting admin users
        if (existingUsers[0].role === 'admin') {
            return errorResponse(res, 'Cannot delete admin user', 403);
        }

        // Check if user has orders
        const [orders] = await pool.execute(
            'SELECT COUNT(*) as count FROM orders WHERE user_id = ?',
            [userId]
        );

        if (orders[0].count > 0) {
            // Mark as inactive instead of deleting
            await pool.execute(
                'UPDATE users SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                [userId]
            );
            successResponse(res, null, 'User marked as inactive (has order history)');
        } else {
            // Safe to delete
            await pool.execute('DELETE FROM users WHERE id = ?', [userId]);
            successResponse(res, null, 'User deleted successfully');
        }

    } catch (error) {
        console.error('Delete user error:', error);
        errorResponse(res, 'Failed to delete user', 500);
    }
});

module.exports = router;
