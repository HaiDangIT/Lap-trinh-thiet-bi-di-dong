# 🚀 API ENDPOINTS FOR FRONTEND

**Base URL:** `http://localhost:3000`  
**API Base:** `http://localhost:3000/api`

---

## 📋 TABLE OF CONTENTS

1. [Authentication & Authorization](#authentication--authorization)
2. [Users API](#users-api)
3. [Two-Factor Authentication API](#two-factor-authentication-api)
4. [Calendars API](#calendars-api)
5. [Events API](#events-api)
6. [Smart Assistant API](#smart-assistant-api)
7. [Health Check](#health-check)
8. [Error Responses](#error-responses)

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### Current Authentication Method (Mock)

**Header Required:**

```
Authorization: Bearer <userId>
```

**Example:**

```javascript
fetch("http://localhost:3000/api/users/me", {
  headers: {
    Authorization: "Bearer 550e8400-e29b-41d4-a716-446655440000",
    "Content-Type": "application/json",
  },
});
```

**Note:** Replace `<userId>` with actual user ID from login response.

---

## 👤 USERS API

### 1. Register User

```http
POST /api/users/register
```

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "John Doe",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

**Response (201):**

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "fullName": "John Doe",
      "timezone": "Asia/Ho_Chi_Minh",
      "createdAt": "2026-01-03T10:00:00.000Z"
    }
  }
}
```

**JavaScript Example:**

```javascript
const registerUser = async (userData) => {
  const response = await fetch("http://localhost:3000/api/users/register", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(userData),
  });
  return await response.json();
};
```

---

### 2. Login User

```http
POST /api/users/login
```

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200) - Without 2FA:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "fullName": "John Doe"
    },
    "requires2FA": false
  }
}
```

**Response (200) - With 2FA Enabled:**

```json
{
  "success": true,
  "message": "2FA verification required",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com"
    },
    "requires2FA": true
  }
}
```

**JavaScript Example:**

```javascript
const loginUser = async (email, password) => {
  const response = await fetch("http://localhost:3000/api/users/login", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email, password }),
  });
  const data = await response.json();

  if (data.data.requires2FA) {
    // Redirect to 2FA verification page
    return { requires2FA: true, userId: data.data.user.id };
  }

  // Save user ID for Authorization header
  localStorage.setItem("userId", data.data.user.id);
  return data;
};
```

---

### 3. Verify 2FA Login

```http
POST /api/users/verify-2fa
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "token": "123456"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "2FA verification successful"
}
```

---

### 4. Get Current User Profile

```http
GET /api/users/me
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "fullName": "John Doe",
    "timezone": "Asia/Ho_Chi_Minh",
    "createdAt": "2026-01-03T10:00:00.000Z"
  }
}
```

---

### 5. Get All Users (Admin/Manager only)

```http
GET /api/users
```

**Headers:**

```
Authorization: Bearer <adminUserId>
```

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

**Response (200):**

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "email": "user@example.com",
        "fullName": "John Doe",
        "createdAt": "2026-01-03T10:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25
    }
  }
}
```

---

### 6. Search Users

```http
GET /api/users/search
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Query Parameters:**

- `q`: Search query (email or full name)

**Response (200):**

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "email": "john@example.com",
        "fullName": "John Doe"
      }
    ]
  }
}
```

**JavaScript Example:**

```javascript
const searchUsers = async (query) => {
  const response = await fetch(
    `http://localhost:3000/api/users/search?q=${encodeURIComponent(query)}`,
    {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("userId")}`,
      },
    }
  );
  return await response.json();
};
```

---

### 7. Get User Statistics

```http
GET /api/users/:id/stats
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "totalCalendars": 5,
    "totalEvents": 42,
    "upcomingEvents": 12
  }
}
```

---

### 8. Get User by ID

```http
GET /api/users/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "John Doe",
    "timezone": "Asia/Ho_Chi_Minh"
  }
}
```

---

### 9. Update User

```http
PUT /api/users/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "fullName": "John Smith",
  "timezone": "America/New_York"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "John Smith",
    "timezone": "America/New_York"
  }
}
```

---

### 10. Change Password

```http
POST /api/users/change-password
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "currentPassword": "oldpassword123",
  "newPassword": "newpassword456"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

### 11. Delete User

```http
DELETE /api/users/:id
```

**Headers:**

```
Authorization: Bearer <adminUserId>
```

**Response (200):**

```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

---

### 12. Bulk Delete Users (Admin only)

```http
POST /api/users/bulk-delete
```

**Headers:**

```
Authorization: Bearer <adminUserId>
```

**Request Body:**

```json
{
  "userIds": ["uuid-1", "uuid-2", "uuid-3"]
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Deleted 3 users successfully"
}
```

---

## 🔐 TWO-FACTOR AUTHENTICATION API

### 1. Setup 2FA

```http
POST /api/2fa/setup
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "message": "2FA setup initiated",
  "data": {
    "qrCodeUrl": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
    "secret": "JBSWY3DPEHPK3PXP",
    "backupCodes": [
      "12345678",
      "23456789",
      "34567890",
      "45678901",
      "56789012",
      "67890123",
      "78901234",
      "89012345",
      "90123456",
      "01234567"
    ]
  }
}
```

**JavaScript Example:**

```javascript
const setup2FA = async () => {
  const response = await fetch("http://localhost:3000/api/2fa/setup", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${localStorage.getItem("userId")}`,
      "Content-Type": "application/json",
    },
  });
  const data = await response.json();

  // Display QR code
  document.getElementById("qr-code").src = data.data.qrCodeUrl;

  // Display backup codes
  console.log("Backup codes:", data.data.backupCodes);

  return data;
};
```

---

### 2. Enable 2FA

```http
POST /api/2fa/enable
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "token": "123456"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "2FA enabled successfully"
}
```

---

### 3. Disable 2FA

```http
POST /api/2fa/disable
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "token": "123456"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "2FA disabled successfully"
}
```

---

### 4. Verify 2FA Token

```http
POST /api/2fa/verify
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "token": "123456"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Token verified successfully",
  "data": {
    "valid": true
  }
}
```

---

### 5. Check 2FA Status

```http
GET /api/2fa/status
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "isEnabled": true,
    "hasBackupCodes": true
  }
}
```

---

### 6. Regenerate Backup Codes

```http
POST /api/2fa/regenerate-backup-codes
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "token": "123456"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Backup codes regenerated successfully",
  "data": {
    "backupCodes": [
      "12345678",
      "23456789",
      "34567890",
      "45678901",
      "56789012",
      "67890123",
      "78901234",
      "89012345",
      "90123456",
      "01234567"
    ]
  }
}
```

---

## 📅 CALENDARS API

### 1. Create Calendar

```http
POST /api/calendars
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "name": "Work Calendar",
  "colorCode": "#F4511E",
  "isPrimary": false
}
```

**Response (201):**

```json
{
  "success": true,
  "message": "Calendar created successfully",
  "data": {
    "id": "uuid",
    "name": "Work Calendar",
    "colorCode": "#F4511E",
    "isPrimary": false,
    "userId": "uuid"
  }
}
```

---

### 2. Get All Calendars

```http
GET /api/calendars
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Work Calendar",
      "colorCode": "#F4511E",
      "isPrimary": false
    },
    {
      "id": "uuid",
      "name": "Personal Calendar",
      "colorCode": "#039BE5",
      "isPrimary": true
    }
  ]
}
```

**JavaScript Example:**

```javascript
const getCalendars = async () => {
  const response = await fetch("http://localhost:3000/api/calendars", {
    headers: {
      Authorization: `Bearer ${localStorage.getItem("userId")}`,
    },
  });
  return await response.json();
};
```

---

### 3. Get Calendar by ID

```http
GET /api/calendars/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Work Calendar",
    "colorCode": "#F4511E",
    "isPrimary": false,
    "userId": "uuid"
  }
}
```

---

### 4. Update Calendar

```http
PUT /api/calendars/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "name": "Updated Work Calendar",
  "colorCode": "#E67C73"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Calendar updated successfully",
  "data": {
    "id": "uuid",
    "name": "Updated Work Calendar",
    "colorCode": "#E67C73"
  }
}
```

---

### 5. Delete Calendar

```http
DELETE /api/calendars/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "message": "Calendar deleted successfully"
}
```

---

## 📌 EVENTS API

### 1. Create Event

```http
POST /api/events
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body (Simple Event):**

```json
{
  "calendarId": "uuid",
  "title": "Team Meeting",
  "description": "Weekly team sync",
  "location": "Conference Room A",
  "startTime": "2026-01-10T10:00:00Z",
  "endTime": "2026-01-10T11:00:00Z",
  "isAllDay": false,
  "isRecurring": false
}
```

**Request Body (Recurring Event):**

```json
{
  "calendarId": "uuid",
  "title": "Daily Standup",
  "startTime": "2026-01-10T09:00:00Z",
  "endTime": "2026-01-10T09:30:00Z",
  "isRecurring": true,
  "recurrenceRule": {
    "frequency": "DAILY",
    "interval": 1,
    "until": "2026-12-31T23:59:59Z"
  },
  "reminders": [
    {
      "minutesBefore": 15,
      "method": "email"
    }
  ]
}
```

**Response (201):**

```json
{
  "success": true,
  "message": "Event created successfully",
  "data": {
    "id": "uuid",
    "title": "Team Meeting",
    "startTime": "2026-01-10T10:00:00Z",
    "endTime": "2026-01-10T11:00:00Z"
  }
}
```

---

### 2. Get Events in Date Range

```http
GET /api/events/range?startTime=2026-01-01T00:00:00Z&endTime=2026-01-31T23:59:59Z
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Query Parameters:**

- `startTime` (required): ISO 8601 date-time
- `endTime` (required): ISO 8601 date-time
- `calendarId` (optional): Filter by calendar

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Team Meeting",
      "description": "Weekly team sync",
      "startTime": "2026-01-10T10:00:00Z",
      "endTime": "2026-01-10T11:00:00Z",
      "isAllDay": false,
      "isRecurring": false,
      "calendar": {
        "id": "uuid",
        "name": "Work Calendar",
        "colorCode": "#F4511E"
      }
    }
  ]
}
```

**JavaScript Example:**

```javascript
const getEventsInRange = async (startDate, endDate, calendarId = null) => {
  let url = `http://localhost:3000/api/events/range?startTime=${startDate}&endTime=${endDate}`;
  if (calendarId) {
    url += `&calendarId=${calendarId}`;
  }

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${localStorage.getItem("userId")}`,
    },
  });
  return await response.json();
};

// Usage
const events = await getEventsInRange(
  "2026-01-01T00:00:00Z",
  "2026-01-31T23:59:59Z"
);
```

---

### 3. Get Event by ID

```http
GET /api/events/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Team Meeting",
    "description": "Weekly team sync",
    "location": "Conference Room A",
    "startTime": "2026-01-10T10:00:00Z",
    "endTime": "2026-01-10T11:00:00Z",
    "isAllDay": false,
    "isRecurring": false,
    "calendar": {
      "id": "uuid",
      "name": "Work Calendar"
    },
    "attendees": [
      {
        "email": "john@example.com",
        "status": "accepted"
      }
    ],
    "reminders": [
      {
        "minutesBefore": 15,
        "method": "email"
      }
    ]
  }
}
```

---

### 4. Update Event

```http
PUT /api/events/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "title": "Updated Team Meeting",
  "startTime": "2026-01-10T14:00:00Z",
  "endTime": "2026-01-10T15:00:00Z"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Event updated successfully",
  "data": {
    "id": "uuid",
    "title": "Updated Team Meeting",
    "startTime": "2026-01-10T14:00:00Z"
  }
}
```

---

### 5. Delete Event

```http
DELETE /api/events/:id
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Response (200):**

```json
{
  "success": true,
  "message": "Event deleted successfully"
}
```

---

### 6. Get Upcoming Events

```http
GET /api/events/upcoming?limit=10
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Query Parameters:**

- `limit` (optional): Number of events (default: 10)

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Team Meeting",
      "startTime": "2026-01-10T10:00:00Z",
      "calendar": {
        "name": "Work Calendar",
        "colorCode": "#F4511E"
      }
    }
  ]
}
```

---

## 🤖 SMART ASSISTANT API

### 1. Analyze Event

```http
POST /api/smart/analyze-event
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "title": "Flight to Hanoi",
  "description": "Business trip",
  "startTime": "2026-01-15T06:00:00Z",
  "endTime": "2026-01-15T08:00:00Z"
}
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "category": {
      "name": "Travel",
      "icon": "✈️",
      "color": "#0F9D58",
      "confidence": 0.95
    },
    "suggestions": {
      "reminders": [
        {
          "minutesBefore": 120,
          "reason": "Travel events need early reminder"
        }
      ],
      "warnings": ["Early morning event (6:00 AM)"],
      "tips": ["Consider traffic and check-in time"]
    },
    "estimatedDuration": 120
  }
}
```

**JavaScript Example:**

```javascript
const analyzeEvent = async (eventData) => {
  const response = await fetch(
    "http://localhost:3000/api/smart/analyze-event",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${localStorage.getItem("userId")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(eventData),
    }
  );
  return await response.json();
};
```

---

### 2. Check Conflicts

```http
POST /api/smart/check-conflicts
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "calendarId": "uuid",
  "startTime": "2026-01-10T10:00:00Z",
  "endTime": "2026-01-10T11:00:00Z",
  "excludeEventId": "uuid"
}
```

**Response (200) - No Conflicts:**

```json
{
  "success": true,
  "data": {
    "hasConflict": false,
    "conflictingEvents": []
  }
}
```

**Response (200) - With Conflicts:**

```json
{
  "success": true,
  "data": {
    "hasConflict": true,
    "conflictingEvents": [
      {
        "id": "uuid",
        "title": "Team Meeting",
        "startTime": "2026-01-10T10:30:00Z",
        "endTime": "2026-01-10T11:30:00Z"
      }
    ]
  }
}
```

---

### 3. Find Free Time Slots

```http
POST /api/smart/find-free-slots
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "calendarId": "uuid",
  "date": "2026-01-10",
  "duration": 60,
  "workingHoursStart": 9,
  "workingHoursEnd": 18
}
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "freeSlots": [
      {
        "start": "2026-01-10T09:00:00Z",
        "end": "2026-01-10T10:00:00Z",
        "duration": 60
      },
      {
        "start": "2026-01-10T14:00:00Z",
        "end": "2026-01-10T16:00:00Z",
        "duration": 120
      }
    ]
  }
}
```

**JavaScript Example:**

```javascript
const findFreeSlots = async (calendarId, date, duration = 60) => {
  const response = await fetch(
    "http://localhost:3000/api/smart/find-free-slots",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${localStorage.getItem("userId")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        calendarId,
        date,
        duration,
        workingHoursStart: 9,
        workingHoursEnd: 18,
      }),
    }
  );
  return await response.json();
};
```

---

### 4. Suggest Best Time

```http
POST /api/smart/suggest-time
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "calendarId": "uuid",
  "preferredDate": "2026-01-10",
  "duration": 60,
  "preferences": {
    "preferMorning": true,
    "avoidLunchTime": true,
    "preferredStartHour": 10
  }
}
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "suggestedSlot": {
      "start": "2026-01-10T10:00:00Z",
      "end": "2026-01-10T11:00:00Z"
    },
    "reason": "Matches morning preference and no conflicts",
    "alternativeSlots": [
      {
        "start": "2026-01-10T14:00:00Z",
        "end": "2026-01-10T15:00:00Z"
      }
    ]
  }
}
```

---

### 5. Get User Statistics & Insights

```http
GET /api/smart/user-stats?startDate=2026-01-01&endDate=2026-01-31
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Query Parameters:**

- `startDate` (optional): Start date (YYYY-MM-DD)
- `endDate` (optional): End date (YYYY-MM-DD)

**Response (200):**

```json
{
  "success": true,
  "data": {
    "totalEvents": 45,
    "totalHours": 67.5,
    "categoryBreakdown": {
      "Meeting": 20,
      "Work": 15,
      "Health": 5,
      "Other": 5
    },
    "busiestDay": "2026-01-15",
    "averageEventDuration": 90,
    "insights": [
      "44% of your events are Meeting-related.",
      "Your average event is 90 minutes.",
      "Your busiest day is 2026-01-15 with 8 events."
    ]
  }
}
```

**JavaScript Example:**

```javascript
const getUserStats = async (startDate, endDate) => {
  const response = await fetch(
    `http://localhost:3000/api/smart/user-stats?startDate=${startDate}&endDate=${endDate}`,
    {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("userId")}`,
      },
    }
  );
  return await response.json();
};
```

---

### 6. Auto-Categorize Events

```http
POST /api/smart/auto-categorize
```

**Headers:**

```
Authorization: Bearer <userId>
```

**Request Body:**

```json
{
  "calendarId": "uuid",
  "startDate": "2026-01-01",
  "endDate": "2026-01-31"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Successfully categorized 25 events",
  "data": {
    "totalProcessed": 25,
    "categories": {
      "Meeting": 10,
      "Work": 8,
      "Travel": 3,
      "Health": 2,
      "Other": 2
    }
  }
}
```

---

## 🏥 HEALTH CHECK

### Health Check

```http
GET /api/health
```

**No authentication required**

**Response (200):**

```json
{
  "status": "ok",
  "timestamp": "2026-01-03T10:00:00.000Z",
  "uptime": 3600.5,
  "environment": "development"
}
```

**JavaScript Example:**

```javascript
const checkHealth = async () => {
  const response = await fetch("http://localhost:3000/api/health");
  return await response.json();
};
```

---

## ❌ ERROR RESPONSES

### Standard Error Format

All errors follow this format:

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "statusCode": 400
  }
}
```

### Common Error Codes

| Code | Description  | Example                             |
| ---- | ------------ | ----------------------------------- |
| 400  | Bad Request  | Invalid input data                  |
| 401  | Unauthorized | Invalid credentials or missing auth |
| 403  | Forbidden    | Insufficient permissions            |
| 404  | Not Found    | Resource doesn't exist              |
| 409  | Conflict     | Email already exists                |
| 500  | Server Error | Internal server error               |

### Error Examples

**400 - Validation Error:**

```json
{
  "success": false,
  "error": {
    "message": "Email is required",
    "statusCode": 400,
    "details": {
      "field": "email",
      "value": ""
    }
  }
}
```

**401 - Unauthorized:**

```json
{
  "success": false,
  "error": {
    "message": "Invalid credentials",
    "statusCode": 401
  }
}
```

**403 - Forbidden:**

```json
{
  "success": false,
  "error": {
    "message": "Insufficient permissions",
    "statusCode": 403
  }
}
```

**404 - Not Found:**

```json
{
  "success": false,
  "error": {
    "message": "User not found",
    "statusCode": 404
  }
}
```

---

## 💡 JAVASCRIPT UTILITY CLASS

```javascript
class CalendarAPI {
  constructor(baseURL = "http://localhost:3000/api") {
    this.baseURL = baseURL;
  }

  // Get auth header
  getHeaders(includeAuth = true) {
    const headers = {
      "Content-Type": "application/json",
    };

    if (includeAuth) {
      const userId = localStorage.getItem("userId");
      if (userId) {
        headers["Authorization"] = `Bearer ${userId}`;
      }
    }

    return headers;
  }

  // Generic request method
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      ...options,
      headers: this.getHeaders(options.auth !== false),
    };

    try {
      const response = await fetch(url, config);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error?.message || "Request failed");
      }

      return data;
    } catch (error) {
      console.error("API Error:", error);
      throw error;
    }
  }

  // User methods
  async register(userData) {
    return this.request("/users/register", {
      method: "POST",
      body: JSON.stringify(userData),
      auth: false,
    });
  }

  async login(email, password) {
    return this.request("/users/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
      auth: false,
    });
  }

  async getProfile() {
    return this.request("/users/me");
  }

  // Calendar methods
  async getCalendars() {
    return this.request("/calendars");
  }

  async createCalendar(calendarData) {
    return this.request("/calendars", {
      method: "POST",
      body: JSON.stringify(calendarData),
    });
  }

  // Event methods
  async getEventsInRange(startTime, endTime, calendarId = null) {
    let url = `/events/range?startTime=${startTime}&endTime=${endTime}`;
    if (calendarId) url += `&calendarId=${calendarId}`;
    return this.request(url);
  }

  async createEvent(eventData) {
    return this.request("/events", {
      method: "POST",
      body: JSON.stringify(eventData),
    });
  }

  // Smart Assistant methods
  async analyzeEvent(eventData) {
    return this.request("/smart/analyze-event", {
      method: "POST",
      body: JSON.stringify(eventData),
    });
  }

  async findFreeSlots(calendarId, date, duration) {
    return this.request("/smart/find-free-slots", {
      method: "POST",
      body: JSON.stringify({ calendarId, date, duration }),
    });
  }

  async getUserStats(startDate, endDate) {
    return this.request(
      `/smart/user-stats?startDate=${startDate}&endDate=${endDate}`
    );
  }
}

// Usage
const api = new CalendarAPI();

// Login
const loginData = await api.login("user@example.com", "password123");
localStorage.setItem("userId", loginData.data.user.id);

// Get calendars
const calendars = await api.getCalendars();

// Create event
const event = await api.createEvent({
  calendarId: "uuid",
  title: "Meeting",
  startTime: "2026-01-10T10:00:00Z",
  endTime: "2026-01-10T11:00:00Z",
});
```

---

## 🎯 QUICK TESTING WITH FETCH

```javascript
// 1. Register
fetch("http://localhost:3000/api/users/register", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: "test@example.com",
    password: "password123",
    fullName: "Test User",
  }),
})
  .then((r) => r.json())
  .then(console.log);

// 2. Login
fetch("http://localhost:3000/api/users/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: "test@example.com",
    password: "password123",
  }),
})
  .then((r) => r.json())
  .then((data) => {
    console.log(data);
    localStorage.setItem("userId", data.data.user.id);
  });

// 3. Get Profile
fetch("http://localhost:3000/api/users/me", {
  headers: {
    Authorization: `Bearer ${localStorage.getItem("userId")}`,
  },
})
  .then((r) => r.json())
  .then(console.log);

// 4. Create Calendar
fetch("http://localhost:3000/api/calendars", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${localStorage.getItem("userId")}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    name: "Work Calendar",
    colorCode: "#F4511E",
  }),
})
  .then((r) => r.json())
  .then(console.log);
```

---

## 📚 SWAGGER UI

**Interactive API Documentation:**

```
http://localhost:3000/api-docs
```

Try all endpoints directly in browser with Swagger UI!

---

**🎉 Happy Coding! 🎉**

_Last Updated: January 3, 2026_
