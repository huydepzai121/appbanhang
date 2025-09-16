# 📱 App Bán Điện Thoại - Flutter + MySQL

## 🎯 Mô tả dự án
Ứng dụng bán điện thoại được phát triển bằng Flutter với backend API Node.js và cơ sở dữ liệu MySQL.

## 🏗️ Kiến trúc hệ thống
```
├── backend/          # Node.js API Server
├── mobile_app/       # Flutter Application
├── database/         # MySQL Scripts
└── docs/            # Documentation
```

## ✨ Tính năng chính

### 👤 Khách hàng
- [x] Đăng ký/Đăng nhập
- [x] Xem danh sách sản phẩm
- [x] Tìm kiếm và lọc sản phẩm
- [x] Xem chi tiết sản phẩm
- [x] Giỏ hàng
- [x] Đặt hàng
- [x] Lịch sử đơn hàng
- [x] Đánh giá sản phẩm
- [x] Quản lý profile

### 👨‍💼 Admin
- [x] Quản lý sản phẩm (CRUD)
- [x] Quản lý danh mục
- [x] Quản lý đơn hàng
- [x] Quản lý người dùng
- [x] Thống kê doanh thu

## 🛠️ Công nghệ sử dụng

### Backend
- Node.js + Express.js
- MySQL Database
- JWT Authentication
- Multer (Upload images)
- bcrypt (Password hashing)

### Mobile App
- Flutter (Dart)
- Provider (State Management)
- HTTP (API calls)
- SharedPreferences (Local storage)
- Image Picker
- Cached Network Image

## 📊 Database Schema

### Tables:
1. **users** - Thông tin người dùng
2. **categories** - Danh mục sản phẩm
3. **products** - Sản phẩm điện thoại
4. **cart** - Giỏ hàng
5. **orders** - Đơn hàng
6. **order_items** - Chi tiết đơn hàng
7. **reviews** - Đánh giá sản phẩm

## 🚀 Cài đặt và chạy

### Backend
```bash
cd backend
npm install
npm start
```

### Mobile App
```bash
cd mobile_app
flutter pub get
flutter run
```

### Database
```bash
mysql -u root -p < database/setup.sql
```

## 🎯 Tính năng đã hoàn thành

### ✅ Backend API (Node.js + Express)
- [x] Authentication (JWT)
- [x] User management
- [x] Product CRUD
- [x] Category management
- [x] Shopping cart
- [x] Order processing
- [x] Review system
- [x] File upload
- [x] Input validation
- [x] Error handling
- [x] Security middleware

### ✅ Database (MySQL)
- [x] Complete schema design
- [x] Sample data
- [x] Relationships & constraints
- [x] Indexes for performance

### ✅ Mobile App (Flutter)
- [x] Authentication screens
- [x] Product listing
- [x] Shopping cart
- [x] User profile
- [x] State management (Provider)
- [x] API integration
- [x] Responsive UI

## 🚀 Hướng dẫn chạy dự án

### ⚡ Quick Start (3 bước)

#### Bước 1: Setup Database (chỉ làm 1 lần)
```bash
# Tạo database và import dữ liệu mẫu
mysql -u root -p < database/setup.sql
```

#### Bước 2: Chạy Backend API (Terminal 1)
```bash
cd backend
npm install          # chỉ lần đầu
npm run dev          # server chạy tại http://localhost:3000
```

#### Bước 3: Chạy Mobile App (Terminal 2)
```bash
cd mobile_app
flutter pub get      # chỉ lần đầu
flutter run -d chrome # app mở trong Chrome browser
```

### 🎯 Kết quả mong đợi

**Backend Terminal:**
```
🚀 Server is running on port 3000
📱 Phone Store API: http://localhost:3000/api
✅ Database connected successfully
```

**Mobile App Terminal:**
```
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

**Browser:** App mở tại http://localhost:xxxxx

### 🔐 Tài khoản test
- **Admin:** admin@phonestore.com / password
- **Customer:** nguyenvana@gmail.com / password

### 🧪 Test API (Optional)
```bash
cd backend
node test_api.js
```

## 🔐 Default Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@phonestore.com | password |
| Customer | nguyenvana@gmail.com | password |

## 📁 Project Structure

```
appbanhang/
├── backend/                 # Node.js API Server
│   ├── config/             # Database config
│   ├── controllers/        # Route controllers
│   ├── middleware/         # Auth, upload, etc.
│   ├── models/            # Data models
│   ├── routes/            # API routes
│   ├── utils/             # Helper functions
│   ├── uploads/           # Uploaded files
│   └── server.js          # Main server file
├── mobile_app/            # Flutter Application
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   ├── widgets/       # Reusable widgets
│   │   └── main.dart      # App entry point
│   └── pubspec.yaml       # Flutter dependencies
├── database/              # MySQL Scripts
│   ├── schema.sql         # Database structure
│   ├── sample_data.sql    # Sample data
│   └── setup.sql          # Complete setup
└── docs/                  # Documentation
    ├── SETUP.md           # Setup guide
    └── API_DOCUMENTATION.md # API docs
```

## 🔧 Development Workflow

### Mỗi lần làm việc:

1. **Mở 2 terminals:**
   ```bash
   # Terminal 1: Backend
   cd backend
   npm run dev

   # Terminal 2: Mobile App
   cd mobile_app
   flutter run -d chrome
   ```

2. **Giữ cả 2 terminals chạy** trong suốt quá trình development

3. **Hot Reload:** Lưu file Flutter (`Ctrl + S`) để reload app ngay lập tức

### VS Code Setup:

1. **Cài extensions:**
   - Flutter
   - Dart

2. **Mở project:**
   ```bash
   cd mobile_app
   code .
   ```

3. **Chạy app:** Nhấn `F5` hoặc `Ctrl + F5`

## 🐛 Troubleshooting

### Backend không chạy được:
```bash
# Kiểm tra MySQL đã chạy chưa
mysql -u root -p

# Kiểm tra port 3000 có bị chiếm không
netstat -an | findstr :3000

# Reset dependencies
cd backend
rm -rf node_modules
npm install
```

### Mobile app không kết nối API:
```bash
# Kiểm tra Flutter
flutter doctor

# Reset Flutter cache
flutter clean
flutter pub get

# Chạy trên web browser (dễ nhất)
flutter run -d chrome
```

### Database lỗi:
```bash
# Xóa và tạo lại database
mysql -u root -p
DROP DATABASE IF EXISTS phone_store;
SOURCE database/setup.sql;
```

## 📞 Hỗ trợ

Nếu gặp lỗi, hãy kiểm tra:
1. ✅ MySQL server đang chạy
2. ✅ Backend server chạy thành công (port 3000)
3. ✅ Flutter doctor không có lỗi
4. ✅ Chrome browser có thể truy cập http://localhost:3000/api/health

**Thứ tự quan trọng:** Database → Backend → Mobile App