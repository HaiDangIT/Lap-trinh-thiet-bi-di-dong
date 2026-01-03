# 🧪 HƯỚNG DẪN TEST API

## 📋 **MỤC LỤC**

- [1. Setup](#1-setup)
- [2. Authentication](#2-authentication)
- [3. User APIs](#3-user-apis)
- [4. 2FA APIs](#4-2fa-apis)
- [5. Testing với Postman](#5-testing-với-postman)

---

## **1. SETUP**

### Start Server

```bash
npm run dev
```

Server sẽ chạy tại: `http://localhost:3000`

### API Documentation

Swagger UI: `http://localhost:3000/api-docs`

---

## **2. AUTHENTICATION**

API này sử dụng mock authentication với header `Authorization: Bearer <userId>` hoặc `x-user-id: <userId>`

### Lấy userId từ database:

```bash
# Kết nối PostgreSQL và chạy query
SELECT id, email FROM users;
```

Hoặc xem trong file seed để biết userId mặc định.

---

## **3. USER APIs**

### 3.1. Đăng ký User Mới

```http
POST /api/users/register
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "password123",
  "fullName": "New User",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

**Response 201:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "newuser@example.com",
    "fullName": "New User",
    "timezone": "Asia/Ho_Chi_Minh"
  },
  "message": "User registered successfully"
}
```

---

### 3.2. Đăng nhập

```http
POST /api/users/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "admin123"
}
```

**Response 200 (Không có 2FA):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "admin@example.com",
    "fullName": "Admin User",
    "timezone": "UTC"
  },
  "message": "Login successful"
}
```

**Response 200 (Có 2FA):**

```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "email": "admin@example.com",
    "requires2FA": true,
    "message": "Please provide 2FA token to complete login"
  },
  "message": "2FA required"
}
```

---

### 3.3. Verify 2FA Sau Khi Login

```http
POST /api/users/verify-2fa
Content-Type: application/json

{
  "userId": "user-uuid",
  "token": "123456"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "admin@example.com",
    "fullName": "Admin User",
    "timezone": "UTC",
    "token": "uuid"
  },
  "message": "Login successful"
}
```

---

### 3.4. Lấy Thông Tin User Hiện Tại

```http
GET /api/users/me
Authorization: Bearer <userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "admin@example.com",
    "fullName": "Admin User",
    "timezone": "UTC",
    "createdAt": "2026-01-03T00:00:00.000Z"
  }
}
```

---

### 3.5. Lấy Danh Sách Users (Admin/Manager)

```http
GET /api/users?page=1&pageSize=20&search=admin
Authorization: Bearer <admin-userId>
```

**Query Parameters:**

- `page`: Trang hiện tại (default: 1)
- `pageSize`: Số items trên mỗi trang (default: 20)
- `search`: Tìm kiếm theo email hoặc tên (optional)

**Response 200:**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "admin@example.com",
      "fullName": "Admin User",
      "timezone": "UTC",
      "createdAt": "2026-01-03T00:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

---

### 3.6. Search Users

```http
GET /api/users/search?q=admin&limit=10
Authorization: Bearer <userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "admin@example.com",
      "fullName": "Admin User",
      "timezone": "UTC"
    }
  ]
}
```

---

### 3.7. Lấy User Theo ID

```http
GET /api/users/:id
Authorization: Bearer <userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "User Name",
    "timezone": "UTC",
    "createdAt": "2026-01-03T00:00:00.000Z"
  }
}
```

---

### 3.8. Lấy User Statistics

```http
GET /api/users/:id/stats
Authorization: Bearer <userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "calendarsCount": 5,
    "eventsCreated": 23,
    "eventsAttending": 12
  },
  "message": "User statistics retrieved"
}
```

---

### 3.9. Cập Nhật User

```http
PUT /api/users/:id
Authorization: Bearer <userId>
Content-Type: application/json

{
  "fullName": "Updated Name",
  "timezone": "Asia/Tokyo"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "Updated Name",
    "timezone": "Asia/Tokyo"
  },
  "message": "User updated successfully"
}
```

---

### 3.10. Đổi Mật Khẩu

```http
POST /api/users/change-password
Authorization: Bearer <userId>
Content-Type: application/json

{
  "currentPassword": "oldpass123",
  "newPassword": "newpass456"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": null,
  "message": "Password changed successfully"
}
```

---

### 3.11. Xóa User (Admin Only)

```http
DELETE /api/users/:id
Authorization: Bearer <admin-userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": null,
  "message": "User deleted successfully"
}
```

---

### 3.12. Bulk Delete Users (Admin Only)

```http
POST /api/users/bulk-delete
Authorization: Bearer <admin-userId>
Content-Type: application/json

{
  "userIds": ["uuid1", "uuid2", "uuid3"]
}
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "deletedCount": 3
  },
  "message": "Successfully deleted 3 user(s)"
}
```

---

## **4. 2FA APIs**

### 4.1. Setup 2FA - Tạo QR Code

```http
POST /api/2fa/setup
Authorization: Bearer <userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "secret": "BASE32ENCODEDSECRET",
    "qrCodeUrl": "data:image/png;base64,iVBORw0KG...",
    "backupCodes": [
      "12345678",
      "87654321",
      "ABCD1234",
      ...
    ]
  },
  "message": "2FA setup initiated. Please scan the QR code and verify with a token to enable."
}
```

> **LƯU Ý:** Lưu `backupCodes` ở nơi an toàn! Chỉ hiển thị 1 lần duy nhất.

---

### 4.2. Enable 2FA

```http
POST /api/2fa/enable
Authorization: Bearer <userId>
Content-Type: application/json

{
  "token": "123456"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": null,
  "message": "2FA enabled successfully"
}
```

---

### 4.3. Kiểm Tra Trạng Thái 2FA

```http
GET /api/2fa/status
Authorization: Bearer <userId>
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "isEnabled": true,
    "hasBackupCodes": true,
    "backupCodesCount": 10
  },
  "message": "2FA status retrieved"
}
```

---

### 4.4. Regenerate Backup Codes

```http
POST /api/2fa/regenerate-backup-codes
Authorization: Bearer <userId>
Content-Type: application/json

{
  "token": "123456"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "backupCodes": [
      "NEW12345",
      "NEW67890",
      ...
    ]
  },
  "message": "Backup codes regenerated successfully. Save these codes in a safe place!"
}
```

---

### 4.5. Disable 2FA

```http
POST /api/2fa/disable
Authorization: Bearer <userId>
Content-Type: application/json

{
  "token": "123456"
}
```

> Token có thể là TOTP code hoặc backup code

**Response 200:**

```json
{
  "success": true,
  "data": null,
  "message": "2FA disabled successfully"
}
```

---

### 4.6. Verify 2FA (Internal - Được gọi từ login)

```http
POST /api/2fa/verify
Content-Type: application/json

{
  "userId": "user-uuid",
  "token": "123456"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "verified": true,
    "usedBackupCode": false
  },
  "message": "2FA verified successfully"
}
```

---

## **5. TESTING VỚI POSTMAN**

### 5.1. Import Collection

1. Mở Postman
2. Click **Import**
3. Dán URL: `http://localhost:3000/api-docs.json`
4. Click **Import**

### 5.2. Setup Environment

Tạo Environment trong Postman với các biến:

```
baseUrl = http://localhost:3000
userId = <your-user-id-from-database>
adminId = <admin-user-id-from-database>
```

### 5.3. Test Flow 2FA

**Bước 1: Đăng ký user mới**

```http
POST {{baseUrl}}/api/users/register
```

**Bước 2: Setup 2FA**

```http
POST {{baseUrl}}/api/2fa/setup
Authorization: Bearer {{userId}}
```

**Bước 3: Scan QR code bằng Google Authenticator**

**Bước 4: Enable 2FA với token từ app**

```http
POST {{baseUrl}}/api/2fa/enable
Authorization: Bearer {{userId}}
{
  "token": "123456"
}
```

**Bước 5: Test login với 2FA**

```http
POST {{baseUrl}}/api/users/login
{
  "email": "your@email.com",
  "password": "yourpassword"
}
```

**Bước 6: Verify 2FA**

```http
POST {{baseUrl}}/api/users/verify-2fa
{
  "userId": "uuid-from-step-5",
  "token": "123456"
}
```

---

## **6. ERROR RESPONSES**

### 400 Bad Request

```json
{
  "success": false,
  "message": "Invalid request data"
}
```

### 401 Unauthorized

```json
{
  "success": false,
  "message": "Authentication required"
}
```

### 403 Forbidden

```json
{
  "success": false,
  "message": "You don't have permission to access this resource"
}
```

### 404 Not Found

```json
{
  "success": false,
  "message": "Resource not found"
}
```

### 500 Internal Server Error

```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## **7. TIPS & BEST PRACTICES**

### 7.1. Lưu Backup Codes An Toàn

- Backup codes chỉ hiển thị 1 lần duy nhất khi setup hoặc regenerate
- Lưu vào password manager hoặc in ra giấy
- Mỗi backup code chỉ dùng được 1 lần

### 7.2. Mock Authentication

API hiện tại dùng mock authentication với userId trong header:

```http
Authorization: Bearer <userId>
# hoặc
x-user-id: <userId>
```

Trong production, thay thế bằng JWT tokens.

### 7.3. Testing 2FA

- Dùng Google Authenticator, Authy, hoặc 1Password
- TOTP codes có hiệu lực 30 giây
- Window = 2 cho phép codes trước/sau 1 phút vẫn valid

### 7.4. RBAC Testing

Để test RBAC, cần:

1. Tạo roles trong database
2. Assign roles cho users
3. Test với different user roles

---

## **8. COMMON ISSUES & SOLUTIONS**

### QR Code không hiển thị?

**Giải pháp:**

1. Kiểm tra packages đã cài: `speakeasy`, `qrcode`
2. Restart server sau khi cài packages
3. Check logs trong terminal

### 2FA Token không hợp lệ?

**Nguyên nhân:**

- Clock không đồng bộ
- Đã dùng token cũ
- Token hết hạn (30s)

**Giải pháp:**

- Đồng bộ thời gian máy tính
- Dùng token mới từ authenticator app
- Dùng backup code nếu cần

### Search không trả về kết quả?

**Kiểm tra:**

- Query string có ít nhất 2 ký tự
- Database có data
- Case-insensitive search đang hoạt động

---

**Happy Testing! 🎉**
