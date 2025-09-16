const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken, requireAdmin, optionalAuth } = require('../middleware/auth');
const { upload, handleUploadError } = require('../middleware/upload');
const {
    successResponse,
    errorResponse,
    getPagination,
    getPagingData
} = require('../utils/helpers');

const router = express.Router();

// Get all products with filters and pagination
router.get('/', [
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
    query('category').optional().isInt({ min: 1 }).withMessage('Category must be a valid ID'),
    query('brand').optional().isString().withMessage('Brand must be a string'),
    query('minPrice').optional().isFloat({ min: 0 }).withMessage('Min price must be a positive number'),
    query('maxPrice').optional().isFloat({ min: 0 }).withMessage('Max price must be a positive number'),
    query('search').optional().isString().withMessage('Search must be a string'),
    query('sortBy').optional().isIn(['price', 'name', 'created_at']).withMessage('Invalid sort field'),
    query('sortOrder').optional().isIn(['ASC', 'DESC']).withMessage('Sort order must be ASC or DESC')
], optionalAuth, async (req, res) => {
    try {
        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const {
            page = 1,
            limit = 10,
            category,
            brand,
            minPrice,
            maxPrice,
            search,
            sortBy = 'created_at',
            sortOrder = 'DESC',
            featured
        } = req.query;

        const { limit: queryLimit, offset } = getPagination(page, limit);

        // Build WHERE clause
        let whereConditions = ['p.is_active = 1'];
        let queryParams = [];

        if (category) {
            whereConditions.push('p.category_id = ?');
            queryParams.push(category);
        }

        if (brand) {
            whereConditions.push('p.brand = ?');
            queryParams.push(brand);
        }

        if (minPrice) {
            whereConditions.push('p.price >= ?');
            queryParams.push(minPrice);
        }

        if (maxPrice) {
            whereConditions.push('p.price <= ?');
            queryParams.push(maxPrice);
        }

        if (search) {
            whereConditions.push('(p.name LIKE ? OR p.description LIKE ? OR p.brand LIKE ?)');
            const searchTerm = `%${search}%`;
            queryParams.push(searchTerm, searchTerm, searchTerm);
        }

        if (featured === 'true') {
            whereConditions.push('p.is_featured = 1');
        }

        const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

        // Count total products
        const countQuery = `
            SELECT COUNT(*) as total
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            ${whereClause}
        `;

        const [countResult] = await pool.execute(countQuery, queryParams);
        const totalItems = countResult[0].total;

        // Get products with pagination
        const productsQuery = `
            SELECT
                p.id, p.name, p.description, p.price, p.original_price,
                p.brand, p.model, p.color, p.storage, p.ram, p.screen_size,
                p.battery, p.camera, p.os, p.image, p.images,
                p.stock_quantity, p.is_featured, p.created_at,
                c.name as category_name,
                COALESCE(AVG(r.rating), 0) as average_rating,
                COUNT(r.id) as review_count
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN reviews r ON p.id = r.product_id
            ${whereClause}
            GROUP BY p.id
            ORDER BY p.${sortBy} ${sortOrder}
            LIMIT ? OFFSET ?
        `;

        const [products] = await pool.execute(productsQuery, [...queryParams, queryLimit, offset]);

        // Parse images JSON for each product
        const formattedProducts = products.map(product => ({
            ...product,
            images: product.images ? JSON.parse(product.images) : [],
            average_rating: parseFloat(product.average_rating).toFixed(1),
            review_count: parseInt(product.review_count)
        }));

        const paginationData = getPagingData(
            { count: totalItems, rows: formattedProducts },
            page,
            queryLimit
        );

        successResponse(res, paginationData, 'Products retrieved successfully');

    } catch (error) {
        console.error('Get products error:', error);
        errorResponse(res, 'Failed to get products', 500);
    }
});

// Get single product by ID
router.get('/:id', optionalAuth, async (req, res) => {
    try {
        const productId = req.params.id;

        const [products] = await pool.execute(`
            SELECT
                p.*,
                c.name as category_name,
                COALESCE(AVG(r.rating), 0) as average_rating,
                COUNT(r.id) as review_count
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN reviews r ON p.id = r.product_id
            WHERE p.id = ? AND p.is_active = 1
            GROUP BY p.id
        `, [productId]);

        if (products.length === 0) {
            return errorResponse(res, 'Product not found', 404);
        }

        const product = products[0];

        // Parse images JSON
        product.images = product.images ? JSON.parse(product.images) : [];
        product.average_rating = parseFloat(product.average_rating).toFixed(1);
        product.review_count = parseInt(product.review_count);

        // Get recent reviews
        const [reviews] = await pool.execute(`
            SELECT
                r.id, r.rating, r.comment, r.images, r.created_at,
                u.name as user_name, u.avatar as user_avatar
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE r.product_id = ?
            ORDER BY r.created_at DESC
            LIMIT 5
        `, [productId]);

        // Parse review images
        const formattedReviews = reviews.map(review => ({
            ...review,
            images: review.images ? JSON.parse(review.images) : []
        }));

        product.recent_reviews = formattedReviews;

        successResponse(res, product, 'Product retrieved successfully');

    } catch (error) {
        console.error('Get product error:', error);
        errorResponse(res, 'Failed to get product', 500);
    }
});

// Create new product (Admin only)
router.post('/', authenticateToken, requireAdmin, upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'images', maxCount: 10 }
]), handleUploadError, [
    body('name').trim().isLength({ min: 2 }).withMessage('Product name must be at least 2 characters'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('category_id').isInt({ min: 1 }).withMessage('Category ID is required'),
    body('stock_quantity').isInt({ min: 0 }).withMessage('Stock quantity must be a non-negative integer')
], async (req, res) => {
    try {
        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        const {
            name, description, price, original_price, brand, model, color,
            storage, ram, screen_size, battery, camera, os, category_id,
            stock_quantity, is_featured = false
        } = req.body;

        // Handle uploaded files
        let mainImage = null;
        let additionalImages = [];

        if (req.files) {
            if (req.files.image && req.files.image[0]) {
                mainImage = `/uploads/products/${req.files.image[0].filename}`;
            }

            if (req.files.images) {
                additionalImages = req.files.images.map(file => `/uploads/products/${file.filename}`);
            }
        }

        // Insert product
        const [result] = await pool.execute(`
            INSERT INTO products (
                name, description, price, original_price, brand, model, color,
                storage, ram, screen_size, battery, camera, os, image, images,
                category_id, stock_quantity, is_featured
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
            name, description, price, original_price || null, brand || null,
            model || null, color || null, storage || null, ram || null,
            screen_size || null, battery || null, camera || null, os || null,
            mainImage, JSON.stringify(additionalImages), category_id,
            stock_quantity, is_featured
        ]);

        // Get created product
        const [products] = await pool.execute(`
            SELECT p.*, c.name as category_name
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            WHERE p.id = ?
        `, [result.insertId]);

        const product = products[0];
        product.images = JSON.parse(product.images || '[]');

        successResponse(res, product, 'Product created successfully', 201);

    } catch (error) {
        console.error('Create product error:', error);
        errorResponse(res, 'Failed to create product', 500);
    }
});

// Update product (Admin only)
router.put('/:id', authenticateToken, requireAdmin, upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'images', maxCount: 10 }
]), handleUploadError, [
    body('name').trim().isLength({ min: 2 }).withMessage('Product name must be at least 2 characters'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('category_id').isInt({ min: 1 }).withMessage('Category ID is required'),
    body('stock_quantity').isInt({ min: 0 }).withMessage('Stock quantity must be a non-negative integer')
], async (req, res) => {
    try {
        const productId = parseInt(req.params.id);

        // Check validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return errorResponse(res, 'Validation failed', 400, errors.array());
        }

        // Check if product exists
        const [existingProducts] = await pool.execute(
            'SELECT id FROM products WHERE id = ?',
            [productId]
        );

        if (existingProducts.length === 0) {
            return errorResponse(res, 'Product not found', 404);
        }

        const {
            name, description, price, original_price, brand, model, color,
            storage, ram, screen_size, battery, camera, os, category_id,
            stock_quantity, is_featured = false
        } = req.body;

        // Handle uploaded files
        let mainImage = null;
        let additionalImages = [];

        if (req.files) {
            if (req.files.image && req.files.image[0]) {
                mainImage = `/uploads/products/${req.files.image[0].filename}`;
            }

            if (req.files.images) {
                additionalImages = req.files.images.map(file => `/uploads/products/${file.filename}`);
            }
        }

        // Build update query dynamically
        let updateFields = [];
        let updateValues = [];

        updateFields.push('name = ?', 'description = ?', 'price = ?', 'original_price = ?');
        updateValues.push(name, description, price, original_price || null);

        updateFields.push('brand = ?', 'model = ?', 'color = ?', 'storage = ?');
        updateValues.push(brand || null, model || null, color || null, storage || null);

        updateFields.push('ram = ?', 'screen_size = ?', 'battery = ?', 'camera = ?', 'os = ?');
        updateValues.push(ram || null, screen_size || null, battery || null, camera || null, os || null);

        updateFields.push('category_id = ?', 'stock_quantity = ?', 'is_featured = ?');
        updateValues.push(category_id, stock_quantity, is_featured);

        if (mainImage) {
            updateFields.push('image = ?');
            updateValues.push(mainImage);
        }

        if (additionalImages.length > 0) {
            updateFields.push('images = ?');
            updateValues.push(JSON.stringify(additionalImages));
        }

        updateFields.push('updated_at = CURRENT_TIMESTAMP');
        updateValues.push(productId);

        // Update product
        await pool.execute(`
            UPDATE products SET ${updateFields.join(', ')} WHERE id = ?
        `, updateValues);

        // Get updated product
        const [products] = await pool.execute(`
            SELECT p.*, c.name as category_name
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            WHERE p.id = ?
        `, [productId]);

        const product = products[0];
        product.images = JSON.parse(product.images || '[]');

        successResponse(res, product, 'Product updated successfully');

    } catch (error) {
        console.error('Update product error:', error);
        errorResponse(res, 'Failed to update product', 500);
    }
});

// Delete product (Admin only)
router.delete('/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const productId = parseInt(req.params.id);

        // Check if product exists
        const [existingProducts] = await pool.execute(
            'SELECT id, name FROM products WHERE id = ?',
            [productId]
        );

        if (existingProducts.length === 0) {
            return errorResponse(res, 'Product not found', 404);
        }

        // Check if product is in any orders (optional - you might want to prevent deletion)
        const [orderItems] = await pool.execute(
            'SELECT COUNT(*) as count FROM order_items WHERE product_id = ?',
            [productId]
        );

        if (orderItems[0].count > 0) {
            // Instead of deleting, mark as inactive
            await pool.execute(
                'UPDATE products SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                [productId]
            );

            successResponse(res, null, 'Product marked as inactive (has order history)');
        } else {
            // Safe to delete
            await pool.execute('DELETE FROM products WHERE id = ?', [productId]);
            successResponse(res, null, 'Product deleted successfully');
        }

    } catch (error) {
        console.error('Delete product error:', error);
        errorResponse(res, 'Failed to delete product', 500);
    }
});

module.exports = router;