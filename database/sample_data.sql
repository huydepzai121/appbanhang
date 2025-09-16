-- =============================================
-- Sample Data for Phone Store App
-- =============================================

USE phone_store;

-- =============================================
-- Insert Admin User
-- =============================================
INSERT INTO users (name, email, password, phone, address, role) VALUES
('Admin', 'admin@phonestore.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456789', 'Hà Nội', 'admin');

-- =============================================
-- Insert Sample Users
-- =============================================
INSERT INTO users (name, email, password, phone, address, role) VALUES
('Nguyễn Văn A', 'nguyenvana@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0987654321', '123 Đường ABC, Quận 1, TP.HCM', 'customer'),
('Trần Thị B', 'tranthib@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0912345678', '456 Đường XYZ, Quận 2, TP.HCM', 'customer'),
('Lê Văn C', 'levanc@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0934567890', '789 Đường DEF, Quận 3, TP.HCM', 'customer');

-- =============================================
-- Insert Categories
-- =============================================
INSERT INTO categories (name, description, image) VALUES
('iPhone', 'Điện thoại iPhone của Apple', 'https://example.com/images/iphone-category.jpg'),
('Samsung', 'Điện thoại Samsung Galaxy', 'https://example.com/images/samsung-category.jpg'),
('Xiaomi', 'Điện thoại Xiaomi', 'https://example.com/images/xiaomi-category.jpg'),
('Oppo', 'Điện thoại Oppo', 'https://example.com/images/oppo-category.jpg'),
('Vivo', 'Điện thoại Vivo', 'https://example.com/images/vivo-category.jpg'),
('Huawei', 'Điện thoại Huawei', 'https://example.com/images/huawei-category.jpg');

-- =============================================
-- Insert Sample Products - iPhone
-- =============================================
INSERT INTO products (name, description, price, original_price, brand, model, color, storage, ram, screen_size, battery, camera, os, image, images, category_id, stock_quantity, is_featured) VALUES
('iPhone 15 Pro Max', 'iPhone 15 Pro Max với chip A17 Pro mạnh mẽ', 29990000, 32990000, 'Apple', 'iPhone 15 Pro Max', 'Titan Tự Nhiên', '256GB', '8GB', '6.7 inch', '4441mAh', 'Camera chính 48MP, Ultra Wide 12MP, Telephoto 12MP', 'iOS 17', 'https://example.com/images/iphone-15-pro-max.jpg', '["https://example.com/images/iphone-15-pro-max-1.jpg", "https://example.com/images/iphone-15-pro-max-2.jpg"]', 1, 50, TRUE),
('iPhone 15', 'iPhone 15 với Dynamic Island và camera 48MP', 22990000, 24990000, 'Apple', 'iPhone 15', 'Hồng', '128GB', '6GB', '6.1 inch', '3349mAh', 'Camera chính 48MP, Ultra Wide 12MP', 'iOS 17', 'https://example.com/images/iphone-15.jpg', '["https://example.com/images/iphone-15-1.jpg", "https://example.com/images/iphone-15-2.jpg"]', 1, 30, TRUE),
('iPhone 14', 'iPhone 14 với chip A15 Bionic', 19990000, 21990000, 'Apple', 'iPhone 14', 'Xanh', '128GB', '6GB', '6.1 inch', '3279mAh', 'Camera chính 12MP, Ultra Wide 12MP', 'iOS 16', 'https://example.com/images/iphone-14.jpg', '["https://example.com/images/iphone-14-1.jpg", "https://example.com/images/iphone-14-2.jpg"]', 1, 25, FALSE);

-- =============================================
-- Insert Sample Products - Samsung
-- =============================================
INSERT INTO products (name, description, price, original_price, brand, model, color, storage, ram, screen_size, battery, camera, os, image, images, category_id, stock_quantity, is_featured) VALUES
('Samsung Galaxy S24 Ultra', 'Galaxy S24 Ultra với S Pen tích hợp', 26990000, 29990000, 'Samsung', 'Galaxy S24 Ultra', 'Titan Xám', '256GB', '12GB', '6.8 inch', '5000mAh', 'Camera chính 200MP, Ultra Wide 12MP, Telephoto 50MP, Telephoto 10MP', 'Android 14', 'https://example.com/images/galaxy-s24-ultra.jpg', '["https://example.com/images/galaxy-s24-ultra-1.jpg", "https://example.com/images/galaxy-s24-ultra-2.jpg"]', 2, 40, TRUE),
('Samsung Galaxy S24', 'Galaxy S24 với hiệu năng mạnh mẽ', 18990000, 20990000, 'Samsung', 'Galaxy S24', 'Tím', '128GB', '8GB', '6.2 inch', '4000mAh', 'Camera chính 50MP, Ultra Wide 12MP, Telephoto 10MP', 'Android 14', 'https://example.com/images/galaxy-s24.jpg', '["https://example.com/images/galaxy-s24-1.jpg", "https://example.com/images/galaxy-s24-2.jpg"]', 2, 35, TRUE),
('Samsung Galaxy A55', 'Galaxy A55 với camera chất lượng cao', 8990000, 9990000, 'Samsung', 'Galaxy A55', 'Xanh Navy', '128GB', '8GB', '6.6 inch', '5000mAh', 'Camera chính 50MP, Ultra Wide 12MP, Macro 5MP', 'Android 14', 'https://example.com/images/galaxy-a55.jpg', '["https://example.com/images/galaxy-a55-1.jpg", "https://example.com/images/galaxy-a55-2.jpg"]', 2, 60, FALSE);

-- =============================================
-- Insert Sample Products - Xiaomi
-- =============================================
INSERT INTO products (name, description, price, original_price, brand, model, color, storage, ram, screen_size, battery, camera, os, image, images, category_id, stock_quantity, is_featured) VALUES
('Xiaomi 14 Ultra', 'Xiaomi 14 Ultra với camera Leica', 24990000, 26990000, 'Xiaomi', '14 Ultra', 'Đen', '512GB', '16GB', '6.73 inch', '5300mAh', 'Camera chính 50MP Leica, Ultra Wide 50MP, Telephoto 50MP, Telephoto 50MP', 'Android 14', 'https://example.com/images/xiaomi-14-ultra.jpg', '["https://example.com/images/xiaomi-14-ultra-1.jpg", "https://example.com/images/xiaomi-14-ultra-2.jpg"]', 3, 20, TRUE),
('Xiaomi 14', 'Xiaomi 14 với chip Snapdragon 8 Gen 3', 16990000, 18990000, 'Xiaomi', '14', 'Trắng', '256GB', '12GB', '6.36 inch', '4610mAh', 'Camera chính 50MP Leica, Ultra Wide 50MP, Telephoto 50MP', 'Android 14', 'https://example.com/images/xiaomi-14.jpg', '["https://example.com/images/xiaomi-14-1.jpg", "https://example.com/images/xiaomi-14-2.jpg"]', 3, 30, TRUE),
('Redmi Note 13 Pro', 'Redmi Note 13 Pro với camera 200MP', 6990000, 7990000, 'Xiaomi', 'Redmi Note 13 Pro', 'Xanh', '128GB', '8GB', '6.67 inch', '5100mAh', 'Camera chính 200MP, Ultra Wide 8MP, Macro 2MP', 'Android 13', 'https://example.com/images/redmi-note-13-pro.jpg', '["https://example.com/images/redmi-note-13-pro-1.jpg", "https://example.com/images/redmi-note-13-pro-2.jpg"]', 3, 80, FALSE);

-- =============================================
-- Insert Sample Products - Oppo
-- =============================================
INSERT INTO products (name, description, price, original_price, brand, model, color, storage, ram, screen_size, battery, camera, os, image, images, category_id, stock_quantity, is_featured) VALUES
('Oppo Find X7 Ultra', 'Oppo Find X7 Ultra với camera Hasselblad', 22990000, 24990000, 'Oppo', 'Find X7 Ultra', 'Nâu', '256GB', '16GB', '6.82 inch', '5400mAh', 'Camera chính 50MP Hasselblad, Ultra Wide 50MP, Telephoto 50MP, Telephoto 50MP', 'Android 14', 'https://example.com/images/oppo-find-x7-ultra.jpg', '["https://example.com/images/oppo-find-x7-ultra-1.jpg", "https://example.com/images/oppo-find-x7-ultra-2.jpg"]', 4, 15, TRUE),
('Oppo Reno11', 'Oppo Reno11 với thiết kế thời trang', 8990000, 9990000, 'Oppo', 'Reno11', 'Xanh Lá', '128GB', '8GB', '6.7 inch', '5000mAh', 'Camera chính 50MP, Ultra Wide 8MP, Macro 2MP', 'Android 14', 'https://example.com/images/oppo-reno11.jpg', '["https://example.com/images/oppo-reno11-1.jpg", "https://example.com/images/oppo-reno11-2.jpg"]', 4, 45, FALSE),
('Oppo A79', 'Oppo A79 giá rẻ, pin khủng', 4990000, 5490000, 'Oppo', 'A79', 'Tím', '128GB', '8GB', '6.72 inch', '5000mAh', 'Camera chính 50MP, Depth 2MP', 'Android 13', 'https://example.com/images/oppo-a79.jpg', '["https://example.com/images/oppo-a79-1.jpg", "https://example.com/images/oppo-a79-2.jpg"]', 4, 70, FALSE);

-- =============================================
-- Insert Sample Reviews
-- =============================================
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
(2, 1, 5, 'iPhone 15 Pro Max rất tuyệt vời! Camera chụp ảnh cực đẹp và hiệu năng mượt mà.'),
(3, 1, 4, 'Sản phẩm tốt nhưng giá hơi cao. Tổng thể vẫn hài lòng.'),
(4, 2, 5, 'iPhone 15 màu hồng rất đẹp, phù hợp với phái nữ.'),
(2, 4, 4, 'Galaxy S24 Ultra với S Pen rất tiện lợi cho công việc.'),
(3, 7, 5, 'Xiaomi 14 Ultra camera Leica chụp ảnh đẹp không thua kém iPhone.'),
(4, 5, 3, 'Galaxy S24 tốt nhưng pin hơi yếu so với mong đợi.');