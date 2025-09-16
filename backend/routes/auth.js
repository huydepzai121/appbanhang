const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const {
    hashPassword,
    comparePassword,
    generateToken,
    isValidEmail,
    successResponse,
    errorResponse,
    sanitizeUser
} = require('../utils/helpers');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Register
router.post('/register', [
    body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('phone').optional().isMobilePhone('vi-VN').withMessage('Please provide a valid Vietnamese phone number')
], async (req, res) => {
    try {
        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { name, email, password, phone, address } = req.body;

        // Check if user already exists
        const [existingUsers] = await pool.execute(
            'SELECT id FROM users WHERE email = ?',
            [email]
        );

        if (existingUsers.length > 0) {
            return errorResponse(res, 'Email already registered', 409);
        }

        // Hash password
        const hashedPassword = await hashPassword(password);

        // Insert new user
        const [result] = await pool.execute(
            'INSERT INTO users (name, email, password, phone, address, role) VALUES (?, ?, ?, ?, ?, ?)',
            [name, email, hashedPassword, phone || null, address || null, 'customer']
        );

        // Get created user
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, created_at FROM users WHERE id = ?',
            [result.insertId]
        );

        const user = users[0];
        const token = generateToken(user.id);

        successResponse(res, {
            user: sanitizeUser(user),
            token
        }, 'User registered successfully', 201);

    } catch (error) {
        console.error('Register error:', error);
        errorResponse(res, 'Registration failed', 500);
    }
});

// Login
router.post('/login', [
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
    try {
        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { email, password } = req.body;

        // Find user by email
        const [users] = await pool.execute(
            'SELECT * FROM users WHERE email = ?',
            [email]
        );

        if (users.length === 0) {
            return errorResponse(res, 'Invalid email or password', 401);
        }

        const user = users[0];

        // Check password
        const isPasswordValid = await comparePassword(password, user.password);
        if (!isPasswordValid) {
            return errorResponse(res, 'Invalid email or password', 401);
        }

        // Generate token
        const token = generateToken(user.id);

        successResponse(res, {
            user: sanitizeUser(user),
            token
        }, 'Login successful');

    } catch (error) {
        console.error('Login error:', error);
        errorResponse(res, 'Login failed', 500);
    }
});

// Get current user profile
router.get('/profile', authenticateToken, async (req, res) => {
    try {
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, avatar, created_at FROM users WHERE id = ?',
            [req.user.id]
        );

        if (users.length === 0) {
            return errorResponse(res, 'User not found', 404);
        }

        successResponse(res, sanitizeUser(users[0]), 'Profile retrieved successfully');

    } catch (error) {
        console.error('Get profile error:', error);
        errorResponse(res, 'Failed to get profile', 500);
    }
});

// Update profile
router.put('/profile', authenticateToken, [
    body('name').optional().trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
    body('phone').optional().isMobilePhone('vi-VN').withMessage('Please provide a valid Vietnamese phone number')
], async (req, res) => {
    try {
        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { name, phone, address } = req.body;
        const userId = req.user.id;

        // Update user profile
        await pool.execute(
            'UPDATE users SET name = COALESCE(?, name), phone = COALESCE(?, phone), address = COALESCE(?, address), updated_at = CURRENT_TIMESTAMP WHERE id = ?',
            [name || null, phone || null, address || null, userId]
        );

        // Get updated user
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, avatar, created_at, updated_at FROM users WHERE id = ?',
            [userId]
        );

        successResponse(res, sanitizeUser(users[0]), 'Profile updated successfully');

    } catch (error) {
        console.error('Update profile error:', error);
        errorResponse(res, 'Failed to update profile', 500);
    }
});

// Change password
router.put('/change-password', authenticateToken, [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword').isLength({ min: 6 }).withMessage('New password must be at least 6 characters')
], async (req, res) => {
    try {
        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const { currentPassword, newPassword } = req.body;
        const userId = req.user.id;

        // Get current user with password
        const [users] = await pool.execute(
            'SELECT password FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return errorResponse(res, 'User not found', 404);
        }

        // Verify current password
        const isCurrentPasswordValid = await comparePassword(currentPassword, users[0].password);
        if (!isCurrentPasswordValid) {
            return errorResponse(res, 'Current password is incorrect', 400);
        }

        // Hash new password
        const hashedNewPassword = await hashPassword(newPassword);

        // Update password
        await pool.execute(
            'UPDATE users SET password = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
            [hashedNewPassword, userId]
        );

        successResponse(res, null, 'Password changed successfully');

    } catch (error) {
        console.error('Change password error:', error);
        errorResponse(res, 'Failed to change password', 500);
    }
});

// Verify token (for frontend to check if token is still valid)
router.get('/verify', authenticateToken, (req, res) => {
    successResponse(res, { user: req.user }, 'Token is valid');
});

module.exports = router;