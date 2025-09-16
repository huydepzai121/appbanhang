const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const { successResponse, errorResponse, sanitizeUser } = require('../utils/helpers');

const router = express.Router();

// Get all users (Admin only)
router.get('/', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [users] = await pool.execute(`
            SELECT id, name, email, phone, address, role, avatar, created_at, updated_at
            FROM users
            ORDER BY created_at DESC
        `);

        successResponse(res, users, 'Users retrieved successfully');
    } catch (error) {
        console.error('Get users error:', error);
        errorResponse(res, 'Failed to get users', 500);
    }
});

// Get user by ID (Admin only)
router.get('/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, avatar, created_at, updated_at FROM users WHERE id = ?',
            [req.params.id]
        );

        if (users.length === 0) {
            return errorResponse(res, 'User not found', 404);
        }

        successResponse(res, users[0], 'User retrieved successfully');
    } catch (error) {
        console.error('Get user error:', error);
        errorResponse(res, 'Failed to get user', 500);
    }
});

module.exports = router;