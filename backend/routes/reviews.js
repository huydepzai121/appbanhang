const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

const router = express.Router();

// Get reviews for a product
router.get('/product/:productId', async (req, res) => {
    try {
        const [reviews] = await pool.execute(`
            SELECT
                r.id, r.rating, r.comment, r.images, r.created_at,
                u.name as user_name, u.avatar as user_avatar
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE r.product_id = ?
            ORDER BY r.created_at DESC
        `, [req.params.productId]);

        const formattedReviews = reviews.map(review => ({
            ...review,
            images: review.images ? JSON.parse(review.images) : []
        }));

        successResponse(res, formattedReviews, 'Reviews retrieved successfully');
    } catch (error) {
        console.error('Get reviews error:', error);
        errorResponse(res, 'Failed to get reviews', 500);
    }
});

// Create review
router.post('/', authenticateToken, [
    body('product_id').isInt({ min: 1 }).withMessage('Product ID is required'),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
    body('comment').optional().trim().isLength({ max: 1000 }).withMessage('Comment too long')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { product_id, rating, comment } = req.body;
        const userId = req.user.id;

        // Check if user has purchased this product
        const [purchases] = await pool.execute(`
            SELECT 1 FROM orders o
            JOIN order_items oi ON o.id = oi.order_id
            WHERE o.user_id = ? AND oi.product_id = ? AND o.status = 'delivered'
            LIMIT 1
        `, [userId, product_id]);

        if (purchases.length === 0) {
            return errorResponse(res, 'You can only review products you have purchased', 403);
        }

        // Check if user already reviewed this product
        const [existingReviews] = await pool.execute(
            'SELECT id FROM reviews WHERE user_id = ? AND product_id = ?',
            [userId, product_id]
        );

        if (existingReviews.length > 0) {
            return errorResponse(res, 'You have already reviewed this product', 409);
        }

        // Create review
        const [result] = await pool.execute(
            'INSERT INTO reviews (user_id, product_id, rating, comment) VALUES (?, ?, ?, ?)',
            [userId, product_id, rating, comment || null]
        );

        const [reviews] = await pool.execute(`
            SELECT
                r.*, u.name as user_name, u.avatar as user_avatar
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE r.id = ?
        `, [result.insertId]);

        successResponse(res, reviews[0], 'Review created successfully', 201);
    } catch (error) {
        console.error('Create review error:', error);
        errorResponse(res, 'Failed to create review', 500);
    }
});

module.exports = router;