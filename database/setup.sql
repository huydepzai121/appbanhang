-- Complete setup script for Phone Store Database
-- Run this script to set up the entire database with sample data

-- Source the schema
SOURCE schema.sql;

-- Source the sample data
SOURCE sample_data.sql;

-- Verify setup
SELECT 'Database setup completed successfully!' as message;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_categories FROM categories;
SELECT COUNT(*) as total_products FROM products;

-- Show admin credentials
SELECT 'Admin login credentials:' as info;
SELECT 'Email: admin@phonestore.com' as email;
SELECT 'Password: password' as password;