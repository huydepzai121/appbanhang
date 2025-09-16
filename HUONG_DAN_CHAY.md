# 🚀 HƯỚNG DẪN CHẠY DỰ ÁN APP BÁN ĐIỆN THOẠI

## 📋 Yêu cầu hệ thống

- **Node.js** >= 16.0.0
- **MySQL** >= 8.0
- **Flutter SDK** >= 3.0.0
- **Chrome Browser** (để chạy app)

## ⚡ CÁCH CHẠY NHANH (3 BƯỚC)

### 🗄️ Bước 1: Setup Database (chỉ làm 1 lần)

```bash
# Mở MySQL Command Line hoặc phpMyAdmin
mysql -u root -p

# Chạy script tạo database
mysql -u root -p < database/setup.sql
```

**Kết quả:** Database `phone_store` được tạo với dữ liệu mẫu

### 🖥️ Bước 2: Chạy Backend API

**Mở Terminal 1:**
```bash
cd backend
npm install          # chỉ lần đầu tiên
npm run dev
```

**Kết quả mong đợi:**
```
🚀 Server is running on port 3000
📱 Phone Store API: http://localhost:3000/api
✅ Database connected successfully
```

**Test API:** Mở browser → http://localhost:3000/api/health

### 📱 Bước 3: Chạy Mobile App

**Mở Terminal 2:**
```bash
cd mobile_app
flutter pub get      # chỉ lần đầu tiên
flutter run -d chrome
```

**Kết quả:** App mở trong Chrome browser

## 🎯 DEMO APP

### Đăng nhập với tài khoản có sẵn:

**Admin:**
- Email: `admin@phonestore.com`
- Password: `password`

**Customer:**
- Email: `nguyenvana@gmail.com`
- Password: `password`

### Tính năng có thể test:

- ✅ Đăng nhập/đăng xuất
- ✅ Xem danh sách sản phẩm
- ✅ Xem chi tiết sản phẩm
- ✅ Thêm vào giỏ hàng
- ✅ Quản lý profile
- ✅ Navigation giữa các tab

## 🔧 CHẠY TRÊN VS CODE

### 1. Cài đặt Extensions:
- **Flutter** (by Dart Code)
- **Dart** (by Dart Code)

### 2. Mở project:
```bash
cd mobile_app
code .
```

### 3. Chạy app:
- Nhấn `F5` (Debug mode)
- Hoặc `Ctrl + F5` (Run mode)
- Chọn device: Chrome

### 4. Hot Reload:
- Lưu file: `Ctrl + S` → App reload tự động
- Hot Restart: `Ctrl + Shift + F5`

## 🧪 TEST HỆ THỐNG

### Test Backend API:
```bash
cd backend
node test_api.js
```

### Test từng endpoint:
- Health: http://localhost:3000/api/health
- Products: http://localhost:3000/api/products
- Categories: http://localhost:3000/api/categories

## 🐛 XỬ LÝ LỖI THƯỜNG GẶP

### ❌ Backend không chạy được:

**Lỗi:** `ENOENT: no such file or directory, open 'package.json'`
```bash
# Đảm bảo đang ở thư mục backend
cd backend
npm install
```

**Lỗi:** `ER_ACCESS_DENIED_ERROR`
```bash
# Kiểm tra thông tin MySQL trong file .env
# Sửa DB_PASSWORD trong backend/.env
```

**Lỗi:** `EADDRINUSE: address already in use :::3000`
```bash
# Port 3000 đã được sử dụng
netstat -ano | findstr :3000
# Kill process hoặc đổi port trong .env
```

### ❌ Mobile app không chạy được:

**Lỗi:** `flutter: command not found`
```bash
# Cài đặt Flutter SDK và thêm vào PATH
flutter doctor
```

**Lỗi:** `No devices found`
```bash
# Chạy trên Chrome (dễ nhất)
flutter config --enable-web
flutter run -d chrome
```

**Lỗi:** `Failed to connect to API`
```bash
# Kiểm tra backend đã chạy chưa
# Kiểm tra URL trong lib/constants/api_constants.dart
```

### ❌ Database lỗi:

**Lỗi:** `Unknown database 'phone_store'`
```bash
# Chạy lại script setup
mysql -u root -p < database/setup.sql
```

## 📂 CẤU TRÚC DỰ ÁN

```
appbanhang/
├── backend/                 # Node.js API Server
│   ├── routes/             # API routes
│   ├── config/             # Database config
│   ├── .env               # Environment variables
│   └── server.js          # Main server file
├── mobile_app/            # Flutter Application
│   ├── lib/
│   │   ├── screens/       # UI screens
│   │   ├── models/        # Data models
│   │   └── main.dart      # App entry point
│   └── pubspec.yaml       # Flutter dependencies
├── database/              # MySQL Scripts
│   ├── schema.sql         # Database structure
│   ├── sample_data.sql    # Sample data
│   └── setup.sql          # Complete setup
└── README.md              # Documentation
```

## 🔄 WORKFLOW DEVELOPMENT

### Mỗi ngày làm việc:

1. **Khởi động MySQL server**
2. **Terminal 1:** `cd backend && npm run dev`
3. **Terminal 2:** `cd mobile_app && flutter run -d chrome`
4. **Coding:** Edit files → Save → Hot reload tự động

### Khi thêm tính năng mới:

1. **Backend:** Thêm API routes trong `backend/routes/`
2. **Mobile:** Thêm screens trong `mobile_app/lib/screens/`
3. **Test:** Restart cả backend và mobile app

## 📞 HỖ TRỢ

### Kiểm tra hệ thống:

```bash
# Kiểm tra Node.js
node --version

# Kiểm tra MySQL
mysql --version

# Kiểm tra Flutter
flutter doctor

# Kiểm tra ports
netstat -an | findstr :3000
```

### Logs quan trọng:

- **Backend logs:** Xem trong terminal chạy `npm run dev`
- **Mobile logs:** Xem trong terminal chạy `flutter run`
- **API logs:** Xem Network tab trong Chrome DevTools

## 🎉 HOÀN THÀNH!

Nếu làm đúng các bước trên, bạn sẽ có:
- ✅ Backend API chạy tại http://localhost:3000
- ✅ Mobile app chạy trong Chrome browser
- ✅ Có thể đăng nhập và sử dụng app
- ✅ Hot reload hoạt động khi edit code

**Chúc bạn code vui vẻ! 🚀**