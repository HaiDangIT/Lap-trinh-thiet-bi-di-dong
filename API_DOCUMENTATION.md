# 📅 Calendar Management API

Hệ thống quản lý lịch, thời gian và nhắc nhở tương tự Google Calendar được xây dựng với Node.js, TypeScript, Express và Prisma.

## 🏗️ Kiến trúc Dự án

```
src/
├── config/              # Cấu hình (database, environment)
│   ├── database.config.ts
│   └── env.config.ts
├── controllers/         # API Controllers và Routes
│   ├── user.controller.ts
│   ├── calendar.controller.ts
│   ├── event.controller.ts
│   ├── user.routes.ts
│   ├── calendar.routes.ts
│   ├── event.routes.ts
│   └── index.ts
├── services/           # Business Logic Layer
│   ├── user.service.ts
│   ├── calendar.service.ts
│   └── event.service.ts
├── repositories/       # Data Access Layer
│   ├── user.repository.ts
│   ├── calendar.repository.ts
│   ├── event.repository.ts
│   ├── attendee.repository.ts
│   ├── reminder.repository.ts
│   ├── recurrence-rule.repository.ts
│   └── event-exception.repository.ts
├── midlewares/         # Express Middlewares
│   ├── auth.middleware.ts
│   ├── error.middleware.ts
│   └── common.middleware.ts
├── validator/          # Request Validation
│   ├── user.validator.ts
│   ├── calendar.validator.ts
│   └── event.validator.ts
├── utils/              # Utility Functions
│   ├── errors.ts
│   ├── response.util.ts
│   ├── timezone.util.ts
│   ├── rrule.util.ts
│   ├── date.util.ts
│   └── crypto.util.ts
├── scripts/            # Database Scripts
│   └── seed.ts
├── app.ts              # Express App Configuration
└── server.ts           # Server Entry Point
```

## 🚀 Tính năng

### ✅ Đã Hoàn thành (MVP)

1. **Quản lý User**

   - Đăng ký, đăng nhập
   - Quản lý profile và timezone

2. **Quản lý Calendar**

   - Tạo nhiều bộ lịch với màu sắc riêng
   - Set primary calendar
   - CRUD calendars

3. **Quản lý Events**

   - CRUD events đơn lẻ
   - Events lặp lại (recurring) theo chuẩn RRULE
   - All-day events
   - Tìm kiếm events
   - Lấy events theo khoảng thời gian

4. **Recurring Events (Sự kiện lặp lại)**

   - Hỗ trợ DAILY, WEEKLY, MONTHLY, YEARLY
   - Custom interval
   - By day (MO, TU, WE...)
   - Until date hoặc count
   - Event exceptions (sửa/xóa 1 occurrence)

5. **Attendees (Người tham gia)**

   - Mời người tham gia
   - RSVP status (PENDING, ACCEPTED, DECLINED)

6. **Reminders (Nhắc nhở)**

   - Multiple reminders per event
   - Push và Email notifications

7. **Timezone Support**
   - Lưu trữ UTC trong database
   - Chuyển đổi múi giờ

## 📦 Cài đặt

### Yêu cầu

- Node.js >= 18.x
- PostgreSQL >= 14.x
- npm hoặc yarn

### Bước 1: Clone và cài đặt dependencies

```bash
# Cài đặt packages
npm install
```

### Bước 2: Cấu hình Database

1. Tạo database PostgreSQL:

```sql
CREATE DATABASE calendar_app;
```

2. Copy file `.env.example` thành `.env`:

```bash
cp .env.example .env
```

3. Cập nhật `DATABASE_URL` trong `.env`:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/calendar_app?schema=public"
```

### Bước 3: Chạy migrations

```bash
# Generate Prisma Client
npm run generate

# Chạy migrations
npm run migrate

# Hoặc push schema trực tiếp (dev only)
npm run db:push
```

### Bước 4: Seed dữ liệu mẫu

```bash
npm run db:seed
```

### Bước 5: Chạy server

```bash
# Development mode (với hot reload)
npm run dev

# Production mode
npm run build
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

## 📚 API Documentation

### Base URL

```
http://localhost:3000/api
```

### Authentication

API sử dụng header `X-User-Id` để xác thực (mock authentication cho dev).

```bash
X-User-Id: <user-id>
```

### Endpoints

#### **Users**

```http
POST   /api/users/register          # Đăng ký user mới
POST   /api/users/login             # Đăng nhập
GET    /api/users/me                # Lấy thông tin user hiện tại
GET    /api/users/:id               # Lấy user theo ID
PUT    /api/users/:id               # Cập nhật user
DELETE /api/users/:id               # Xóa user
GET    /api/users                   # Lấy danh sách users (phân trang)
```

#### **Calendars**

```http
POST   /api/calendars               # Tạo calendar mới
GET    /api/calendars               # Lấy tất cả calendars của user
GET    /api/calendars/:id           # Lấy calendar theo ID
PUT    /api/calendars/:id           # Cập nhật calendar
DELETE /api/calendars/:id           # Xóa calendar
POST   /api/calendars/:id/primary   # Set calendar làm primary
```

#### **Events**

```http
POST   /api/events                  # Tạo event mới
GET    /api/events/:id              # Lấy event theo ID
PUT    /api/events/:id              # Cập nhật event
DELETE /api/events/:id              # Xóa event
GET    /api/events/range            # Lấy events trong khoảng thời gian
GET    /api/events/search           # Tìm kiếm events
GET    /api/events/upcoming         # Lấy upcoming events
PUT    /api/events/:id/occurrence   # Cập nhật 1 occurrence của recurring event
```

### Ví dụ Requests

#### 1. Đăng ký User

```bash
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "fullName": "John Doe",
    "timezone": "Asia/Ho_Chi_Minh"
  }'
```

#### 2. Tạo Calendar

```bash
curl -X POST http://localhost:3000/api/calendars \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <user-id>" \
  -d '{
    "name": "Work Calendar",
    "colorCode": "#039BE5"
  }'
```

#### 3. Tạo Event Đơn

```bash
curl -X POST http://localhost:3000/api/events \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <user-id>" \
  -d '{
    "calendarId": "<calendar-id>",
    "title": "Team Meeting",
    "description": "Weekly sync",
    "startTime": "2026-01-10T09:00:00Z",
    "endTime": "2026-01-10T10:00:00Z",
    "attendees": [
      {
        "email": "colleague@example.com",
        "displayName": "Colleague"
      }
    ],
    "reminders": [
      {
        "minutesBefore": 15,
        "method": "PUSH"
      }
    ]
  }'
```

#### 4. Tạo Recurring Event

```bash
curl -X POST http://localhost:3000/api/events \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <user-id>" \
  -d '{
    "calendarId": "<calendar-id>",
    "title": "Daily Standup",
    "startTime": "2026-01-06T02:00:00Z",
    "endTime": "2026-01-06T02:15:00Z",
    "isRecurring": true,
    "recurrenceRule": {
      "frequency": "WEEKLY",
      "interval": 1,
      "byDay": ["MO", "TU", "WE", "TH", "FR"]
    },
    "reminders": [
      {
        "minutesBefore": 5,
        "method": "PUSH"
      }
    ]
  }'
```

#### 5. Lấy Events theo Range

```bash
curl -X GET "http://localhost:3000/api/events/range?startTime=2026-01-01T00:00:00Z&endTime=2026-01-31T23:59:59Z" \
  -H "X-User-Id: <user-id>"
```

## 🗄️ Database Schema

### Models

- **User**: Tài khoản người dùng
- **Calendar**: Bộ lịch (Work, Personal, Family...)
- **Event**: Sự kiện
- **RecurrenceRule**: Quy tắc lặp lại (RRULE)
- **EventException**: Ngoại lệ cho recurring events
- **Attendee**: Người tham gia sự kiện
- **Reminder**: Nhắc nhở

Xem chi tiết schema tại: [prisma/schema.prisma](prisma/schema.prisma)

## 🧪 Testing

Sau khi seed data, bạn có thể test với credentials:

```
Email: john@example.com
Password: password123
User ID: (sẽ được in ra sau khi seed)
```

## 🛠️ Scripts

```bash
npm run dev              # Chạy development server với hot reload
npm run build            # Build production
npm start                # Chạy production server
npm run migrate          # Chạy database migrations
npm run migrate:reset    # Reset database và re-run migrations
npm run db:push          # Push schema changes (dev only)
npm run db:seed          # Seed dữ liệu mẫu
npm run db:studio        # Mở Prisma Studio (GUI)
npm run generate         # Generate Prisma Client
```

## 📖 Business Logic

### 1. Timezone Logic

- Tất cả thời gian được lưu ở UTC trong database
- Chuyển đổi sang timezone của user khi hiển thị
- Utils: `src/utils/timezone.util.ts`

### 2. Recurrence Logic (RRULE)

- Implement theo chuẩn iCalendar RFC 5545
- Tính toán occurrences động khi query
- Support DAILY, WEEKLY, MONTHLY, YEARLY
- Utils: `src/utils/rrule.util.ts`

### 3. Exception Logic

- Cho phép sửa/xóa 1 occurrence của recurring event
- Không ảnh hưởng đến các occurrences khác
- Repository: `event-exception.repository.ts`

### 4. Conflict Detection

- Kiểm tra trùng lịch khi tạo event
- Option `checkConflicts` trong create event
- Service: `event.service.ts`

## 🔐 Security Notes

**⚠️ Quan trọng**: Đây là implementation cơ bản cho học tập.

Trong production cần:

- Implement JWT authentication thay vì mock header
- Sử dụng bcrypt/argon2 thay vì SHA-256 cho password hashing
- Add rate limiting và input sanitization
- Setup HTTPS
- Add request validation middleware
- Implement proper error handling
- Add logging và monitoring

## 📝 TODO - Tính năng nâng cao

- [ ] JWT Authentication
- [ ] Email notifications
- [ ] Push notifications
- [ ] File attachments
- [ ] Google Maps integration
- [ ] AI suggestions
- [ ] Time analytics
- [ ] Offline support
- [ ] WebSocket for real-time updates
- [ ] Export to iCal format

## 🤝 Contributing

Dự án này được tạo cho mục đích học tập và kiểm tra.

## 📄 License

ISC

---

**Developed with ❤️ using Node.js + TypeScript + Prisma**
