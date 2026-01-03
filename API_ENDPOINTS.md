# 📅 Calendar Management API - Complete Documentation

## 🚀 Tổng quan

API quản lý lịch và sự kiện với hệ thống phân quyền RBAC (Role-Based Access Control). Hỗ trợ:

- ✅ Recurring events (RRULE)
- ✅ Multiple calendars
- ✅ Attendees & Reminders
- ✅ Timezone support
- ✅ RBAC với 3 roles: ADMIN, MANAGER, USER
- ✅ Swagger documentation
- ✅ Rate limiting & security

---

## 🔧 Setup & Installation

### 1. Cài đặt dependencies

```bash
npm install
```

### 2. Cấu hình môi trường (.env)

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/Calendar?schema=public"
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key-here
```

### 3. Setup database

```bash
# Generate Prisma Client
npm run generate

# Run migrations
npm run migrate

# Seed sample data
npm run seed
```

### 4. Start server

```bash
# Development
npm run dev

# Production
npm run build
npm start
```

---

## 📚 Swagger Documentation

**Truy cập Swagger UI tại:**

```
http://localhost:3000/api-docs
```

**Swagger JSON:**

```
http://localhost:3000/api-docs.json
```

---

## 🔐 Hệ thống phân quyền RBAC

### Roles

| Role        | Description                 | Permissions                      |
| ----------- | --------------------------- | -------------------------------- |
| **ADMIN**   | Full system access          | All permissions (16 permissions) |
| **MANAGER** | Calendar & event management | 9 permissions                    |
| **USER**    | Basic user                  | 5 permissions                    |

### Permissions

**User Permissions:**

- `user:read` - Đọc thông tin user
- `user:write` - Tạo/sửa user
- `user:delete` - Xóa user
- `user:manage-roles` - Quản lý roles của user

**Calendar Permissions:**

- `calendar:read` - Xem calendars
- `calendar:write` - Tạo/sửa calendars
- `calendar:delete` - Xóa calendars
- `calendar:share` - Chia sẻ calendars

**Event Permissions:**

- `event:read` - Xem events
- `event:write` - Tạo/sửa events
- `event:delete` - Xóa events
- `event:manage-attendees` - Quản lý người tham dự

**Admin Permissions:**

- `admin:manage-users` - Quản lý users
- `admin:manage-roles` - Quản lý roles
- `admin:view-logs` - Xem logs
- `admin:system-config` - Cấu hình hệ thống

---

## 🔑 Authentication

Tất cả endpoints (trừ register/login) yêu cầu header:

```
Authorization: Bearer <user_id>
```

---

## 📋 DANH SÁCH TẤT CẢ ENDPOINTS

### Base URL

```
http://localhost:3000/api
```

---

## 🏥 Health & Info

### 1. Root endpoint

```
GET /
```

Response:

```json
{
  "success": true,
  "message": "Calendar API Server",
  "version": "1.0.0",
  "documentation": "/api-docs",
  "endpoints": {
    "health": "/api/health",
    "users": "/api/users",
    "calendars": "/api/calendars",
    "events": "/api/events"
  }
}
```

### 2. Health check

```
GET /api/health
```

**Security:** Public (no auth required)

Response:

```json
{
  "status": "ok",
  "timestamp": "2026-01-03T07:00:00.000Z",
  "uptime": 123.456,
  "environment": "development"
}
```

### 3. API information

```
GET /api
```

**Security:** Public

Response:

```json
{
  "name": "Calendar Management API",
  "version": "1.0.0",
  "description": "API for managing calendars, events, and schedules with RBAC",
  "endpoints": {
    "health": "/api/health",
    "docs": "/api-docs",
    "users": "/api/users",
    "calendars": "/api/calendars",
    "events": "/api/events"
  }
}
```

---

## 👤 USER ENDPOINTS

### 4. Register user

```
POST /api/users/register
```

**Security:** Public

Request body:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "John Doe",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

Response (201):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "John Doe",
    "timezone": "Asia/Ho_Chi_Minh",
    "createdAt": "2026-01-03T00:00:00.000Z",
    "updatedAt": "2026-01-03T00:00:00.000Z"
  }
}
```

**Validation:**

- email: required, valid email format
- password: required, min 6 characters
- fullName: optional
- timezone: optional, default "UTC"

### 5. Login

```
POST /api/users/login
```

**Security:** Public

Request body:

```json
{
  "email": "admin@example.com",
  "password": "admin123"
}
```

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "57ed1c95-7c01-4918-8b3e-f6327dfc841a",
    "email": "admin@example.com",
    "fullName": "Admin User",
    "timezone": "Asia/Ho_Chi_Minh"
  }
}
```

### 6. Get current user profile

```
GET /api/users/me
```

**Security:** Authenticated
**Permission:** `user:read`

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "admin@example.com",
    "fullName": "Admin User",
    "timezone": "Asia/Ho_Chi_Minh",
    "createdAt": "2026-01-03T00:00:00.000Z",
    "updatedAt": "2026-01-03T00:00:00.000Z"
  }
}
```

### 7. Get all users

```
GET /api/users
```

**Security:** Authenticated
**Role:** ADMIN or MANAGER only

Response (200):

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "admin@example.com",
      "fullName": "Admin User",
      "timezone": "Asia/Ho_Chi_Minh"
    }
  ]
}
```

### 8. Get user by ID

```
GET /api/users/:id
```

**Security:** Authenticated
**Permission:** `user:read`

Response (200): Same as "Get current user profile"

### 9. Update user

```
PUT /api/users/:id
```

**Security:** Authenticated
**Permission:** `user:write`

Request body:

```json
{
  "fullName": "Updated Name",
  "timezone": "America/New_York"
}
```

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "Updated Name",
    "timezone": "America/New_York"
  }
}
```

### 10. Delete user

```
DELETE /api/users/:id
```

**Security:** Authenticated
**Role:** ADMIN only

Response (200):

```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

---

## 📅 CALENDAR ENDPOINTS

### 11. Create calendar

```
POST /api/calendars
```

**Security:** Authenticated
**Permission:** `calendar:write`

Request body:

```json
{
  "name": "Work Calendar",
  "colorCode": "#039BE5",
  "isPrimary": false
}
```

Response (201):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Work Calendar",
    "colorCode": "#039BE5",
    "isPrimary": false,
    "userId": "uuid",
    "createdAt": "2026-01-03T00:00:00.000Z",
    "updatedAt": "2026-01-03T00:00:00.000Z"
  }
}
```

**Validation:**

- name: required, string
- colorCode: optional, default "#039BE5"
- isPrimary: optional, boolean, default false

### 12. Get all calendars of current user

```
GET /api/calendars
```

**Security:** Authenticated
**Permission:** `calendar:read`

Response (200):

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Work",
      "colorCode": "#039BE5",
      "isPrimary": true,
      "userId": "uuid",
      "createdAt": "2026-01-03T00:00:00.000Z",
      "updatedAt": "2026-01-03T00:00:00.000Z"
    }
  ]
}
```

### 13. Get calendar by ID

```
GET /api/calendars/:id
```

**Security:** Authenticated
**Permission:** `calendar:read`

Response (200): Same format as item in "Get all calendars"

### 14. Update calendar

```
PUT /api/calendars/:id
```

**Security:** Authenticated
**Permission:** `calendar:write`

Request body:

```json
{
  "name": "Updated Calendar Name",
  "colorCode": "#33B679"
}
```

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Updated Calendar Name",
    "colorCode": "#33B679",
    "isPrimary": false,
    "userId": "uuid"
  }
}
```

### 15. Delete calendar

```
DELETE /api/calendars/:id
```

**Security:** Authenticated
**Permission:** `calendar:delete`

Response (200):

```json
{
  "success": true,
  "message": "Calendar deleted successfully"
}
```

### 16. Set calendar as primary

```
POST /api/calendars/:id/primary
```

**Security:** Authenticated
**Permission:** `calendar:write`

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Work",
    "isPrimary": true
  }
}
```

---

## 📆 EVENT ENDPOINTS

### 17. Create event

```
POST /api/events
```

**Security:** Authenticated
**Permission:** `event:write`

**Simple Event:**

```json
{
  "title": "Team Meeting",
  "description": "Discuss project progress",
  "location": "Conference Room A",
  "startTime": "2026-01-15T10:00:00Z",
  "endTime": "2026-01-15T11:00:00Z",
  "isAllDay": false,
  "calendarId": "uuid",
  "attendees": [
    {
      "email": "colleague@example.com",
      "name": "Jane Smith"
    }
  ],
  "reminders": [
    {
      "minutesBefore": 30,
      "method": "email"
    }
  ]
}
```

**Recurring Event:**

```json
{
  "title": "Daily Standup",
  "startTime": "2026-01-15T09:00:00Z",
  "endTime": "2026-01-15T09:30:00Z",
  "calendarId": "uuid",
  "isRecurring": true,
  "recurrence": {
    "frequency": "WEEKLY",
    "interval": 1,
    "byDay": "MO,TU,WE,TH,FR",
    "count": 50
  }
}
```

Response (201):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Team Meeting",
    "description": "Discuss project progress",
    "location": "Conference Room A",
    "startTime": "2026-01-15T10:00:00.000Z",
    "endTime": "2026-01-15T11:00:00.000Z",
    "isAllDay": false,
    "isRecurring": false,
    "calendarId": "uuid",
    "creatorId": "uuid",
    "createdAt": "2026-01-03T00:00:00.000Z"
  }
}
```

**Validation:**

- title: required, string
- startTime: required, ISO date
- endTime: required, ISO date, must be after startTime
- calendarId: required, UUID
- frequency: DAILY, WEEKLY, MONTHLY, YEARLY
- byDay: MO,TU,WE,TH,FR,SA,SU

### 18. Get events in date range

```
GET /api/events/range?startTime=2026-01-01T00:00:00Z&endTime=2026-01-31T23:59:59Z&calendarId=uuid
```

**Security:** Authenticated
**Permission:** `event:read`

**Query Parameters:**

- `startTime` (required): ISO date string
- `endTime` (required): ISO date string
- `calendarId` (optional): UUID - filter by calendar

Response (200):

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Team Standup",
      "description": "Weekly sync",
      "location": "Conference Room A",
      "startTime": "2026-01-15T10:00:00.000Z",
      "endTime": "2026-01-15T11:00:00.000Z",
      "isAllDay": false,
      "isRecurring": true,
      "calendarId": "uuid",
      "creatorId": "uuid",
      "recurrenceRule": {
        "id": "uuid",
        "frequency": "WEEKLY",
        "interval": 1,
        "byDay": "MO,WE,FR"
      },
      "attendees": [
        {
          "id": "uuid",
          "email": "user@example.com",
          "name": "John Doe",
          "responseStatus": "accepted"
        }
      ],
      "reminders": [
        {
          "id": "uuid",
          "minutesBefore": 15,
          "method": "email"
        }
      ]
    }
  ]
}
```

### 19. Search events

```
GET /api/events/search?q=meeting
```

**Security:** Authenticated
**Permission:** `event:read`

**Query Parameters:**

- `q` (optional): Search query

Response (200): Same format as "Get events in range"

### 20. Get upcoming events

```
GET /api/events/upcoming
```

**Security:** Authenticated
**Permission:** `event:read`

Returns events starting from now for next 30 days.

Response (200): Same format as "Get events in range"

### 21. Get event by ID

```
GET /api/events/:id
```

**Security:** Authenticated
**Permission:** `event:read`

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Team Meeting",
    "description": "Discuss project",
    "location": "Room A",
    "startTime": "2026-01-15T10:00:00.000Z",
    "endTime": "2026-01-15T11:00:00.000Z",
    "isAllDay": false,
    "isRecurring": false,
    "calendar": {
      "id": "uuid",
      "name": "Work",
      "userId": "uuid"
    },
    "creator": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe"
    },
    "attendees": [],
    "reminders": []
  }
}
```

### 22. Update event

```
PUT /api/events/:id
```

**Security:** Authenticated
**Permission:** `event:write`

Request body:

```json
{
  "title": "Updated Meeting Title",
  "description": "Updated description",
  "startTime": "2026-01-15T14:00:00Z",
  "endTime": "2026-01-15T15:00:00Z"
}
```

Response (200):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Updated Meeting Title",
    "startTime": "2026-01-15T14:00:00.000Z",
    "endTime": "2026-01-15T15:00:00.000Z"
  }
}
```

### 23. Update recurring event occurrence

```
PUT /api/events/:id/occurrence
```

**Security:** Authenticated
**Permission:** `event:write`

Modify or cancel a single occurrence of a recurring event.

Request body:

```json
{
  "originalStartTime": "2026-01-22T09:00:00Z",
  "newStartTime": "2026-01-22T10:00:00Z",
  "newEndTime": "2026-01-22T10:30:00Z",
  "updatedTitle": "Rescheduled Meeting",
  "updatedLocation": "New Room",
  "isCancelled": false
}
```

**Cancel occurrence:**

```json
{
  "originalStartTime": "2026-01-22T09:00:00Z",
  "isCancelled": true
}
```

Response (200):

```json
{
  "success": true,
  "message": "Occurrence updated successfully"
}
```

### 24. Delete event

```
DELETE /api/events/:id
```

**Security:** Authenticated
**Permission:** `event:delete`

Response (200):

```json
{
  "success": true,
  "message": "Event deleted successfully"
}
```

---

## 🔁 Recurring Events (RRULE)

### Frequency Types

- `DAILY` - Every day
- `WEEKLY` - Every week
- `MONTHLY` - Every month
- `YEARLY` - Every year

### Day Values (for WEEKLY)

- `MO` - Monday
- `TU` - Tuesday
- `WE` - Wednesday
- `TH` - Thursday
- `FR` - Friday
- `SA` - Saturday
- `SU` - Sunday

### Example Patterns

**Every weekday (Mon-Fri):**

```json
{
  "frequency": "WEEKLY",
  "interval": 1,
  "byDay": "MO,TU,WE,TH,FR"
}
```

**Every other Monday:**

```json
{
  "frequency": "WEEKLY",
  "interval": 2,
  "byDay": "MO"
}
```

**Monthly on 15th:**

```json
{
  "frequency": "MONTHLY",
  "interval": 1,
  "byMonthDay": "15"
}
```

**10 occurrences only:**

```json
{
  "frequency": "WEEKLY",
  "interval": 1,
  "byDay": "MO",
  "count": 10
}
```

**Until specific date:**

```json
{
  "frequency": "DAILY",
  "interval": 1,
  "untilDate": "2026-12-31T23:59:59Z"
}
```

---

## 📊 Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    /* response data */
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "details": {}
  }
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (missing/invalid auth)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (e.g., duplicate email)
- `429` - Too Many Requests (rate limit)
- `500` - Internal Server Error

---

## 🧪 Test Accounts

Sau khi chạy `npm run seed`:

### Admin Account

```
Email: admin@example.com
Password: admin123
Role: ADMIN
Permissions: All 16 permissions
```

### Manager Account

```
Email: manager@example.com
Password: manager123
Role: MANAGER
Permissions: 9 permissions
```

### Regular User Account

```
Email: user@example.com
Password: user123
Role: USER
Permissions: 5 basic permissions
```

---

## 🔒 Security Features

- ✅ Password hashing (bcrypt)
- ✅ Role-Based Access Control (RBAC)
- ✅ Permission-based authorization
- ✅ Input validation (Zod schemas)
- ✅ SQL injection protection (Prisma ORM)
- ✅ CORS enabled
- ✅ Rate limiting (100 req/min)
- ✅ Request body size limit
- ✅ Error sanitization

---

## ⚡ Performance

- Database indexes on frequently queried fields
- Prisma query optimization
- Efficient recurring event expansion
- Connection pooling
- Response caching headers

---

## 🏗️ Architecture

```
src/
├── config/              # Configuration files
│   ├── database.config.ts
│   ├── env.config.ts
│   ├── swagger.config.ts
│   └── permissions.config.ts
├── controllers/         # Request handlers
│   ├── user.controller.ts
│   ├── calendar.controller.ts
│   └── event.controller.ts
├── services/            # Business logic
│   ├── user.service.ts
│   ├── calendar.service.ts
│   └── event.service.ts
├── repositories/        # Data access layer (Prisma)
│   ├── user.repository.ts
│   ├── calendar.repository.ts
│   ├── event.repository.ts
│   ├── attendee.repository.ts
│   ├── reminder.repository.ts
│   ├── recurrence-rule.repository.ts
│   └── event-exception.repository.ts
├── routes/              # API routes with Swagger docs
│   ├── index.ts
│   ├── user.routes.ts
│   ├── calendar.routes.ts
│   └── event.routes.ts
├── midlewares/          # Middleware functions
│   ├── auth.middleware.ts
│   ├── authorization.middleware.ts
│   ├── error.middleware.ts
│   └── common.middleware.ts
├── validator/           # Request validation (Zod)
│   ├── user.validator.ts
│   ├── calendar.validator.ts
│   └── event.validator.ts
├── utils/               # Helper functions
│   ├── errors.ts
│   ├── timezone.util.ts
│   ├── rrule.util.ts
│   ├── response.util.ts
│   ├── crypto.util.ts
│   └── date.util.ts
└── scripts/
    └── seed.ts          # Database seeding
```

### Flow:

```
Request → Middleware (auth, RBAC) → Routes → Controller → Service → Repository → Database
                                                  ↓
                                            Validation
```

---

## 📝 Example Usage

### 1. Register & Login

```bash
# Register
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","fullName":"Test User"}'

# Login (returns user ID)
curl -X POST http://localhost:3000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

### 2. Create Calendar

```bash
curl -X POST http://localhost:3000/api/calendars \
  -H "Authorization: Bearer YOUR_USER_ID" \
  -H "Content-Type: application/json" \
  -d '{"name":"My Calendar","colorCode":"#039BE5"}'
```

### 3. Create Event

```bash
curl -X POST http://localhost:3000/api/events \
  -H "Authorization: Bearer YOUR_USER_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Team Meeting",
    "startTime":"2026-01-15T10:00:00Z",
    "endTime":"2026-01-15T11:00:00Z",
    "calendarId":"YOUR_CALENDAR_ID"
  }'
```

### 4. Get Events

```bash
curl -X GET "http://localhost:3000/api/events/range?startTime=2026-01-01T00:00:00Z&endTime=2026-01-31T23:59:59Z" \
  -H "Authorization: Bearer YOUR_USER_ID"
```

---

## 🐛 Debugging

Enable query logging in `.env`:

```env
NODE_ENV=development
```

Server logs:

- All Prisma queries
- HTTP requests with timing
- Error stack traces

---

## 📧 Support

Server running at:

- **Base URL:** http://localhost:3000
- **API:** http://localhost:3000/api
- **Swagger:** http://localhost:3000/api-docs
- **Health:** http://localhost:3000/api/health

---

## 🎯 Summary

**Total Endpoints: 24**

- Public: 4 (health, info, register, login)
- User: 6 endpoints
- Calendar: 6 endpoints
- Event: 8 endpoints

**Security:**

- 3 Roles (ADMIN, MANAGER, USER)
- 16 Permissions
- RBAC on all protected endpoints

**Features:**

- ✅ Complete CRUD operations
- ✅ Recurring events with RRULE
- ✅ Permission-based access control
- ✅ Swagger documentation
- ✅ Input validation
- ✅ Error handling
- ✅ Rate limiting
