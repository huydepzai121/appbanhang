const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/helpers');

const router = express.Router();

// Get all categories
router.get('/', async (req, res) => {
    try {
        const [categories] = await pool.execute(`
            SELECT c.*, COUNT(p.id) as product_count
            FROM categories c
            LEFT JOIN products p ON c.id = p.category_id AND p.is_active = 1
            GROUP BY c.id
            ORDER BY c.name
        `);

        successResponse(res, categories, 'Categories retrieved successfully');
    } catch (error) {
        console.error('Get categories error:', error);
        errorResponse(res, 'Failed to get categories', 500);
    }
});

// Get category by ID
router.get('/:id', async (req, res) => {
    try {
        const [categories] = await pool.execute(
            'SELECT * FROM categories WHERE id = ?',
            [req.params.id]
        );

        if (categories.length === 0) {
            return errorResponse(res, 'Category not found', 404);
        }

        successResponse(res, categories[0], 'Category retrieved successfully');
    } catch (error) {
        console.error('Get category error:', error);
        errorResponse(res, 'Failed to get category', 500);
    }
});

// Create category (Admin only)
router.post('/', authenticateToken, requireAdmin, [
    body('name').trim().isLength({ min: 2 }).withMessage('Category name must be at least 2 characters')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { name, description, image } = req.body;

        const [result] = await pool.execute(
            'INSERT INTO categories (name, description, image) VALUES (?, ?, ?)',
            [name, description || null, image || null]
        );

        const [categories] = await pool.execute(
            'SELECT * FROM categories WHERE id = ?',
            [result.insertId]
        );

        successResponse(res, categories[0], 'Category created successfully', 201);
    } catch (error) {
        console.error('Create category error:', error);
        errorResponse(res, 'Failed to create category', 500);
    }
});

module.exports = router;