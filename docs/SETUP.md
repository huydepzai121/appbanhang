# 🚀 Hướng dẫn cài đặt App Bán Điện Thoại

## 📋 Yêu cầu hệ thống

### Backend
- Node.js >= 16.0.0
- MySQL >= 8.0
- npm hoặc yarn

### Mobile App
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio hoặc VS Code
- Android SDK (cho Android)
- Xcode (cho iOS - chỉ trên macOS)

## 🗄️ Cài đặt Database

### 1. Tạo database MySQL
```bash
mysql -u root -p
```

### 2. Chạy script setup
```bash
cd database
mysql -u root -p < setup.sql
```

Hoặc chạy từng file:
```bash
mysql -u root -p < schema.sql
mysql -u root -p < sample_data.sql
```

### 3. Kiểm tra database
```sql
USE phone_store;
SHOW TABLES;
SELECT COUNT(*) FROM products;
```

## 🖥️ Cài đặt Backend API

### 1. Di chuyển vào thư mục backend
```bash
cd backend
```

### 2. Cài đặt dependencies
```bash
npm install
```

### 3. Cấu hình môi trường
Sửa file `.env` với thông tin database của bạn:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=phone_store
```

### 4. Chạy server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: http://localhost:3000

### 5. Test API
```bash
curl http://localhost:3000/api/health
```

## 📱 Cài đặt Mobile App

### 1. Kiểm tra Flutter
```bash
flutter doctor
```

### 2. Di chuyển vào thư mục mobile app
```bash
cd mobile_app
```

### 3. Cài đặt dependencies
```bash
flutter pub get
```

### 4. Cấu hình API endpoint
Sửa file `lib/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

**Lưu ý:** Thay `YOUR_IP` bằng IP thực của máy chạy backend (không dùng localhost khi test trên thiết bị thật).

### 5. Chạy app
```bash
# Chạy trên emulator/simulator
flutter run

# Chạy trên thiết bị cụ thể
flutter run -d device_id
```

## 🔐 Tài khoản mặc định

### Admin
- **Email:** admin@phonestore.com
- **Password:** password

### Customer
- **Email:** nguyenvana@gmail.com
- **Password:** password

## 🧪 Test hệ thống

### 1. Test Backend API
```bash
cd backend
npm test  # (nếu có test cases)
```

### 2. Test Mobile App
```bash
cd mobile_app
flutter test
```

### 3. Test tích hợp
1. Khởi động backend server
2. Chạy mobile app
3. Đăng nhập với tài khoản admin hoặc customer
4. Test các chức năng cơ bản:
   - Xem danh sách sản phẩm
   - Thêm vào giỏ hàng
   - Đặt hàng
   - Xem lịch sử đơn hàng

## 🐛 Troubleshooting

### Backend không khởi động được
- Kiểm tra MySQL đã chạy chưa
- Kiểm tra thông tin database trong `.env`
- Kiểm tra port 3000 có bị chiếm không

### Mobile app không kết nối được API
- Kiểm tra IP address trong `api_constants.dart`
- Kiểm tra firewall/antivirus
- Thử ping từ thiết bị đến máy chạy backend

### Database lỗi
- Kiểm tra quyền user MySQL
- Kiểm tra charset database (nên dùng utf8mb4)
- Xem log MySQL để debug

## 📚 Tài liệu API
Xem file `API_DOCUMENTATION.md` để biết chi tiết về các API endpoints.

## 🔄 Cập nhật
Để cập nhật hệ thống:
1. Pull code mới
2. Chạy `npm install` trong backend
3. Chạy `flutter pub get` trong mobile_app
4. Restart các services