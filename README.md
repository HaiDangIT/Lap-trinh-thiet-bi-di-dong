# 📅 Calendar Management API - v2.0.0

> **Hệ thống quản lý lịch, sự kiện với RBAC và 2FA**

## ✨ **TÍNH NĂNG MỚI (v2.0.0)**

### 🔐 Two-Factor Authentication (2FA)

- ✅ Setup 2FA với QR code generation
- ✅ TOTP authentication với Google Authenticator
- ✅ Backup codes (10 codes, SHA256 hashed)
- ✅ Regenerate backup codes
- ✅ Enable/Disable 2FA
- ✅ 2FA status checking

### 👥 User Management - Nâng Cao

- ✅ **Search users** - Tìm kiếm theo email/tên
- ✅ **User statistics** - Thống kê calendars, events
- ✅ **Change password** - Đổi mật khẩu an toàn
- ✅ **Bulk operations** - Xóa nhiều users cùng lúc
- ✅ **Pagination & Search** - Phân trang với tìm kiếm
- ✅ **Verify 2FA** - Xác thực 2FA khi login

---

## 📚 **DOCUMENTATION**

| Document                                                     | Description                     |
| ------------------------------------------------------------ | ------------------------------- |
| [API_TESTING_GUIDE.md](./API_TESTING_GUIDE.md)               | 🧪 Hướng dẫn test API chi tiết  |
| [CHANGELOG.md](./CHANGELOG.md)                               | 📝 Chi tiết các thay đổi v2.0.0 |
| [2FA_GUIDE.md](./2FA_GUIDE.md)                               | 🔐 Hướng dẫn tích hợp 2FA       |
| [API_ENDPOINTS.md](./API_ENDPOINTS.md)                       | 📋 Danh sách tất cả endpoints   |
| [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)               | 📖 API documentation đầy đủ     |
| [MOBILE_INTEGRATION_GUIDE.md](./MOBILE_INTEGRATION_GUIDE.md) | 📱 Tích hợp mobile app          |

---

## 🚀 **QUICK START**

### Prerequisites

- Node.js 18+
- PostgreSQL 14+
- npm hoặc yarn

### Installation

```bash
# Clone repository
git clone <repo-url>
cd lehaidang-kiemtra-t7

# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env với database credentials

# Run migrations
npm run migrate

# Seed database (optional)
npm run seed

# Start development server
npm run dev
```

Server sẽ chạy tại: **http://localhost:3000**

---

## 🎯 **API ENDPOINTS**

### 🔐 Authentication & Users (13 endpoints)

```
POST   /api/users/register           - Đăng ký user mới
POST   /api/users/login              - Đăng nhập
POST   /api/users/verify-2fa         - Verify 2FA khi login ✨
GET    /api/users/me                 - Lấy profile user hiện tại
GET    /api/users                    - Lấy danh sách users (Admin/Manager) ✨
GET    /api/users/search             - Tìm kiếm users ✨
GET    /api/users/:id                - Lấy user theo ID
GET    /api/users/:id/stats          - Lấy statistics của user ✨
PUT    /api/users/:id                - Cập nhật user
POST   /api/users/change-password    - Đổi mật khẩu ✨
DELETE /api/users/:id                - Xóa user (Admin)
POST   /api/users/bulk-delete        - Xóa nhiều users (Admin) ✨
```

### 🔐 Two-Factor Authentication (6 endpoints) ✨

```
POST   /api/2fa/setup                      - Setup 2FA & tạo QR code
POST   /api/2fa/enable                     - Enable 2FA
POST   /api/2fa/disable                    - Disable 2FA
POST   /api/2fa/verify                     - Verify 2FA token
GET    /api/2fa/status                     - Kiểm tra status 2FA
POST   /api/2fa/regenerate-backup-codes    - Tạo lại backup codes
```

### 📅 Calendars

```
POST   /api/calendars                - Tạo calendar mới
GET    /api/calendars                - Lấy tất cả calendars
GET    /api/calendars/:id            - Lấy calendar theo ID
PUT    /api/calendars/:id            - Cập nhật calendar
DELETE /api/calendars/:id            - Xóa calendar
```

### 📌 Events

```
POST   /api/events                   - Tạo event mới
GET    /api/events                   - Lấy danh sách events
GET    /api/events/:id               - Lấy event theo ID
PUT    /api/events/:id               - Cập nhật event
DELETE /api/events/:id               - Xóa event
```

### 🏥 Health

```
GET    /api/health                   - Health check
GET    /api                          - API information
```

**✨ = Tính năng mới trong v2.0.0**

---

## 🧪 **TESTING**

### Swagger UI

Truy cập: **http://localhost:3000/api-docs**

### Quick Test Script

```bash
# Run automated tests
node test-api.js
```

### Manual Testing

Xem chi tiết trong [API_TESTING_GUIDE.md](./API_TESTING_GUIDE.md)

**Example - Setup 2FA:**

```bash
# 1. Setup 2FA
curl -X POST http://localhost:3000/api/2fa/setup \
  -H "Authorization: Bearer <userId>"

# 2. Scan QR code với Google Authenticator

# 3. Enable 2FA
curl -X POST http://localhost:3000/api/2fa/enable \
  -H "Authorization: Bearer <userId>" \
  -H "Content-Type: application/json" \
  -d '{"token": "123456"}'
```

---

## 📖 **TECH STACK**

- **Runtime:** Node.js 18+
- **Framework:** Express.js 5
- **Language:** TypeScript 5
- **Database:** PostgreSQL 14+
- **ORM:** Prisma 6
- **Authentication:** TOTP (speakeasy)
- **QR Code:** qrcode package
- **Documentation:** Swagger UI

---

## 🏗️ **PROJECT STRUCTURE**

```
lehaidang-kiemtra-t7/
├── src/
│   ├── config/              # Configuration
│   │   ├── database.config.ts
│   │   ├── env.config.ts
│   │   ├── permissions.config.ts
│   │   └── swagger.config.ts
│   ├── controllers/         # Request handlers
│   │   ├── user.controller.ts
│   │   ├── twoFactor.controller.ts
│   │   ├── calendar.controller.ts
│   │   └── event.controller.ts
│   ├── services/            # Business logic
│   │   ├── user.service.ts
│   │   ├── twoFactor.service.ts
│   │   ├── calendar.service.ts
│   │   └── event.service.ts
│   ├── repositories/        # Data access
│   │   ├── user.repository.ts
│   │   ├── twoFactor.repository.ts
│   │   ├── calendar.repository.ts
│   │   └── event.repository.ts
│   ├── routes/              # API routes
│   │   ├── index.ts
│   │   ├── user.routes.ts
│   │   ├── twoFactor.routes.ts
│   │   ├── calendar.routes.ts
│   │   └── event.routes.ts
│   ├── midlewares/          # Express middlewares
│   │   ├── auth.middleware.ts
│   │   ├── authorization.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── common.middleware.ts
│   ├── utils/               # Utilities
│   │   ├── crypto.util.ts
│   │   ├── twoFactor.util.ts
│   │   ├── response.util.ts
│   │   └── errors.ts
│   ├── validator/           # Request validation
│   ├── app.ts              # Express app
│   └── server.ts           # Entry point
├── prisma/
│   ├── schema.prisma       # Database schema
│   └── migrations/         # DB migrations
├── test-api.js             # API test script ✨
├── API_TESTING_GUIDE.md    # Testing guide ✨
├── CHANGELOG.md            # Version changes ✨
└── README.md              # This file
```

---

## 🔒 **SECURITY FEATURES**

### Authentication

- Mock authentication với userId (Development)
- JWT tokens ready (Production)

### Authorization

- RBAC (Role-Based Access Control)
- Multiple roles: Admin, Manager, User
- Fine-grained permissions

### Two-Factor Authentication

- TOTP with 30-second window
- QR code generation
- Backup codes (SHA256 hashed)
- Time drift tolerance (window = 2)

---

## 💾 **DATABASE SCHEMA**

### Core Tables

- **users** - User accounts
- **two_factor** - 2FA settings ✨
- **roles** - User roles
- **user_roles** - User-Role mapping
- **role_claims** - Role permissions
- **calendars** - User calendars
- **events** - Calendar events
- **recurrence_rules** - Recurring events
- **event_exceptions** - Modified recurring events
- **attendees** - Event participants
- **reminders** - Event reminders

---

## 🐛 **BUG FIXES IN v2.0.0**

1. ✅ QR code generation fixed
2. ✅ Secret storage corrected
3. ✅ Routes duplication removed
4. ✅ Email in QR code now shows real user email
5. ✅ Search functionality working properly

---

## 📈 **WHAT'S NEXT**

### Planned Features

- [ ] JWT authentication
- [ ] Refresh tokens
- [ ] Email verification
- [ ] Email notifications for 2FA
- [ ] Audit logging
- [ ] Rate limiting per user
- [ ] Unit & Integration tests

### Frontend/Mobile

- [ ] Admin dashboard UI
- [ ] User management interface
- [ ] 2FA setup wizard
- [ ] Statistics dashboard

---

## 📞 **SUPPORT & TROUBLESHOOTING**

### Common Issues

**QR Code not showing?**

```bash
npm install speakeasy qrcode
npm run dev
```

**Database connection error?**

```bash
# Check .env file
DATABASE_URL="postgresql://user:pass@localhost:5432/dbname"
npm run migrate
```

**2FA token invalid?**

- Sync computer time
- Use fresh token from authenticator
- Try backup code

---

## 📄 **LICENSE**

ISC

---

## 👨‍💻 **AUTHOR**

Lê Hải Đăng

---

**Version:** 2.0.0  
**Last Updated:** 03/01/2026  
**Status:** ✅ Production Ready

---

Đề tài gốc: Tạo app quản lý lịch + thời gian + nhắc nhở tương tự app Google Calendar

1. Cấp độ Cơ bản (MVP - Minimum Viable Product)
   Tính năng
   Quản lý sự kiệnCRUD (Thêm, sửa, xóa, xem) các sự kiện đơn lẻ.
   Đa chế độ xemXem theo Ngày (Day), Tuần (Week), Tháng (Month) và Lịch trình (Agenda).
   Nhắc nhở (Push)Thông báo đẩy trên điện thoại/trình duyệt trước X phút.
   Quản lý LịchTạo nhiều bộ lịch (Công việc, Nhà, Học tập) với màu sắc khác nhau.

2. Cấp độ Chuyên nghiệp (Professional)
   Sự kiện lặp lại nâng cao: Lặp theo ngày tùy chỉnh (ví dụ: thứ 2 và thứ 6 hàng tuần).

Mời tham gia & RSVP: Gửi lời mời qua email, người nhận nhấn "Đồng ý" hoặc "Từ chối". Trạng thái sẽ cập nhật thời gian thực vào lịch của cả 2 người.

Tìm kiếm thông minh: Tìm kiếm sự kiện theo từ khóa, người tham gia hoặc địa điểm.

Đính kèm tệp: Đính kèm file từ Google Drive hoặc local vào sự kiện.

Vị trí & Bản đồ: Tích hợp Map để gợi ý địa điểm và tính toán thời gian di chuyển.

3. Cấp độ Thông minh (Smart Features - Xu hướng 2026)
   AI Suggestions: Tự động phân loại sự kiện (ví dụ: thấy chữ "Bay đi Hà Nội" thì tự gán icon máy bay và đổi màu).

Smart Reschedule: Khi có sự kiện trùng, AI gợi ý các khoảng thời gian trống khác mà mọi người đều rảnh.

Time Analytics: Báo cáo cuối tuần: "Bạn đã dành 60% thời gian cho họp hành, 40% cho làm việc tập trung".

Offline First: Cho phép thao tác mượt mà khi mất mạng và đồng bộ ngay khi có internet.

Luồng vận hành (Workflow) mẫu
Người dùng tạo sự kiện: "Họp Team" vào 10:00 sáng mai, lặp lại mỗi thứ Hai.

Hệ thống: Lưu vào DB 1 dòng sự kiện + 1 dòng quy tắc lặp.

Hiển thị: Khi người dùng mở lịch tháng sau, App quét quy tắc lặp -> Tính ra các ngày thứ Hai -> Vẽ lên giao diện.

Nhắc nhở: 15 phút trước giờ họp, Worker chạy ngầm quét DB -> Thấy sự kiện sắp diễn ra -> Gửi thông báo Push đến điện thoại.

Chỉnh sửa: Người dùng dời buổi họp của thứ Hai tuần tới sang thứ Ba -> Hệ thống tạo 1 bản ghi vào bảng Event_Exceptions để ghi chú sự thay đổi này.

// User: Quản lý tài khoản và thiết lập cá nhân
model User {
id String @id @default(uuid())
email String @unique
passwordHash String
fullName String?
timezone String @default("UTC")
calendars Calendar[]
eventsCreated Event[]
attendees Attendee[]
createdAt DateTime @default(now())
}

// Calendar: Nhóm các sự kiện (Ví dụ: Lịch Công Việc, Lịch Nhà)
model Calendar {
id String @id @default(uuid())
name String
colorCode String @default("#039BE5")
isPrimary Boolean @default(false)
userId String
user User @relation(fields: [userId], references: [id])
events Event[]
}

// Event: Thông tin cơ bản của một sự kiện
model Event {
id String @id @default(uuid())
calendarId String
calendar Calendar @relation(fields: [calendarId], references: [id])
creatorId String
creator User @relation(fields: [creatorId], references: [id])
title String
description String?
location String?
startTime DateTime
endTime DateTime
isAllDay Boolean @default(false)
isRecurring Boolean @default(false)

recurrenceRule RecurrenceRule?
exceptions EventException[]
attendees Attendee[]
reminders Reminder[]
}

// RecurrenceRule: Định nghĩa quy luật lặp lại (theo chuẩn iCalendar)
model RecurrenceRule {
id String @id @default(uuid())
eventId String @unique
event Event @relation(fields: [eventId], references: [id])
frequency String // DAILY, WEEKLY, MONTHLY, YEARLY
interval Int @default(1)
byDay String? // Ví dụ: "MO,WE,FR"
untilDate DateTime?
count Int?
rruleString String? // Chuỗi RRULE đầy đủ
}

// EventException: Xử lý khi sửa/xóa 1 ngày trong chuỗi lặp
model EventException {
id String @id @default(uuid())
eventId String
event Event @relation(fields: [eventId], references: [id])
originalStartTime DateTime // Mốc thời gian gốc bị ghi đè
isCancelled Boolean @default(false)
newStartTime DateTime?
newEndTime DateTime?
updatedTitle String?
}

// Attendee: Quản lý người tham gia và trạng thái mời
model Attendee {
id String @id @default(uuid())
eventId String
event Event @relation(fields: [eventId], references: [id])
userId String?
user User? @relation(fields: [userId], references: [id])
email String // Cho những người mời chưa có tài khoản
status String @default("PENDING") // ACCEPTED, DECLINED...
}

// Reminder: Cấu hình thông báo
model Reminder {
id String @id @default(uuid())
eventId String
event Event @relation(fields: [eventId], references: [id])
minutesBefore Int
method String @default("PUSH") // EMAIL, PUSH
}

-- Tìm nhanh các sự kiện trong khoảng thời gian (Dùng cho view Tháng/Tuần)
CREATE INDEX idx_events_start_time ON events(start_time);

-- Tìm nhanh các sự kiện thuộc về một lịch cụ thể
CREATE INDEX idx_events_calendar_id ON events(calendar_id);

-- Tìm nhanh các ngoại lệ của một sự kiện lặp
CREATE INDEX idx_exceptions_event_id ON event_exceptions(event_id);

-- Hỗ trợ quét nhắc nhở hàng phút (Cron job)
CREATE INDEX idx_reminders_event_id ON reminders(event_id);

I. Phân tích Nghiệp vụ (Business Logic) chuyên sâu
Nghiệp vụ của App Calendar xoay quanh 4 trụ cột logic chính:

1. Logic về Thời gian và Múi giờ (Timezone Logic)
   Đây là phần quan trọng nhất.

Lưu trữ: Mọi thời gian phải được lưu ở chuẩn UTC 0 trong Database.

Hiển thị: Chuyển đổi sang múi giờ địa phương dựa trên thiết bị của người dùng.

Sự kiện xuyên múi giờ: Nếu bạn bay từ Việt Nam sang Mỹ, app phải tự động điều chỉnh lịch hiển thị nhưng vẫn giữ nguyên mốc thời gian tuyệt đối.

2. Logic Lặp lại (Recurrence Logic - RRULE)
   Thay vì lưu hàng ngàn bản ghi cho một cuộc họp hàng tuần, bạn chỉ lưu 1 bản ghi gốc kèm một chuỗi quy tắc (ví dụ: FREQ=WEEKLY;BYDAY=MO).

Thuật toán tính toán: Backend hoặc Frontend phải có một bộ máy (engine) để "tính" xem trong tháng 10 này, sự kiện đó rơi vào những ngày nào để vẽ lên màn hình.

3. Logic Ngoại lệ (Exception Logic)
   Đây là phần khó nhất:

Người dùng có một chuỗi họp hàng ngày vào lúc 8h sáng.

Riêng thứ Tư tuần này, họ muốn đổi sang 9h hoặc xóa bỏ.

Nghiệp vụ: Hệ thống phải tạo ra một bản ghi "đè" (Override) lên ngày đó mà không làm ảnh hưởng đến quy luật của các ngày khác trong tương lai.

4. Logic Xung đột (Conflict Logic)
   Kiểm tra xem một người dùng hoặc một phòng họp có bị "book" trùng lịch vào cùng một thời điểm hay không (Double-booking prevention).
