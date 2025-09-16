# 📚 API Documentation - Phone Store

Base URL: `http://localhost:3000/api`

## 🔐 Authentication

### POST /auth/login
Đăng nhập người dùng

**Request Body:**
```json
{
  "email": "admin@phonestore.com",
  "password": "password"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin",
      "email": "admin@phonestore.com",
      "role": "admin"
    },
    "token": "jwt_token_here"
  }
}
```

### POST /auth/register
Đăng ký người dùng mới

**Request Body:**
```json
{
  "name": "Nguyen Van A",
  "email": "user@example.com",
  "password": "password123",
  "phone": "0987654321",
  "address": "123 ABC Street"
}
```

### GET /auth/profile
Lấy thông tin profile (cần token)

**Headers:**
```
Authorization: Bearer <token>
```

## 📱 Products

### GET /products
Lấy danh sách sản phẩm

**Query Parameters:**
- `page` (int): Trang hiện tại (default: 1)
- `limit` (int): Số sản phẩm mỗi trang (default: 10)
- `search` (string): Tìm kiếm theo tên
- `category` (int): Lọc theo danh mục
- `brand` (string): Lọc theo hãng
- `minPrice` (float): Giá tối thiểu
- `maxPrice` (float): Giá tối đa
- `featured` (boolean): Sản phẩm nổi bật
- `sortBy` (string): Sắp xếp theo (price, name, created_at)
- `sortOrder` (string): ASC hoặc DESC

**Example:**
```
GET /products?page=1&limit=10&featured=true&sortBy=price&sortOrder=ASC
```

**Response:**
```json
{
  "success": true,
  "message": "Products retrieved successfully",
  "data": {
    "items": [
      {
        "id": 1,
        "name": "iPhone 15 Pro Max",
        "price": 29990000,
        "original_price": 32990000,
        "brand": "Apple",
        "image": "https://example.com/image.jpg",
        "average_rating": "4.5",
        "review_count": 10
      }
    ],
    "totalItems": 100,
    "totalPages": 10,
    "currentPage": 1,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

### GET /products/:id
Lấy chi tiết sản phẩm

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "iPhone 15 Pro Max",
    "description": "iPhone 15 Pro Max với chip A17 Pro",
    "price": 29990000,
    "brand": "Apple",
    "model": "iPhone 15 Pro Max",
    "storage": "256GB",
    "ram": "8GB",
    "images": ["image1.jpg", "image2.jpg"],
    "recent_reviews": [...]
  }
}
```

### POST /products (Admin only)
Tạo sản phẩm mới

**Headers:**
```
Authorization: Bearer <admin_token>
Content-Type: multipart/form-data
```

**Form Data:**
- `name` (string): Tên sản phẩm
- `price` (number): Giá
- `category_id` (int): ID danh mục
- `stock_quantity` (int): Số lượng tồn kho
- `image` (file): Ảnh chính
- `images` (files): Ảnh phụ

## 🛒 Cart

### GET /cart
Lấy giỏ hàng (cần token)

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "product_id": 1,
        "name": "iPhone 15 Pro Max",
        "price": 29990000,
        "quantity": 2,
        "image": "image.jpg"
      }
    ],
    "total": 59980000,
    "count": 1
  }
}
```

### POST /cart/add
Thêm sản phẩm vào giỏ hàng

**Request Body:**
```json
{
  "product_id": 1,
  "quantity": 2
}
```

### PUT /cart/:id
Cập nhật số lượng sản phẩm trong giỏ

**Request Body:**
```json
{
  "quantity": 3
}
```

### DELETE /cart/:id
Xóa sản phẩm khỏi giỏ hàng

## 📦 Orders

### POST /orders
Tạo đơn hàng mới

**Request Body:**
```json
{
  "shipping_name": "Nguyen Van A",
  "shipping_phone": "0987654321",
  "shipping_address": "123 ABC Street, District 1, HCMC",
  "payment_method": "cod",
  "notes": "Giao hàng giờ hành chính"
}
```

### GET /orders
Lấy danh sách đơn hàng của user

### GET /orders/:id
Lấy chi tiết đơn hàng

## 📝 Reviews

### GET /reviews/product/:productId
Lấy đánh giá của sản phẩm

### POST /reviews
Tạo đánh giá mới

**Request Body:**
```json
{
  "product_id": 1,
  "rating": 5,
  "comment": "Sản phẩm rất tốt!"
}
```

## 📊 Categories

### GET /categories
Lấy danh sách danh mục

### POST /categories (Admin only)
Tạo danh mục mới

## 👥 Users (Admin only)

### GET /users
Lấy danh sách người dùng

### GET /users/:id
Lấy thông tin người dùng

## 🔒 Error Responses

Tất cả API đều trả về format lỗi như sau:

```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

## 📋 Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error