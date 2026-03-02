# API Reference

Complete API reference for the VS Platform backend.

**Base URL:** `http://localhost:3001` (local) or `https://api.yourdomain.com` (production)

## Authentication

Most endpoints require authentication via JWT token. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Response Format

All API responses follow this format:

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional message"
}
```

Error responses:

```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

## Endpoints

### Health Check

#### GET /health
Check if the server is running.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### GET /ready
Check if the server is ready to accept requests (checks database, Redis, etc.).

**Response:**
```json
{
  "status": "ready",
  "services": {
    "database": "ok",
    "redis": "ok",
    "clickhouse": "ok"
  }
}
```

---

## Authentication Endpoints

### POST /api/auth/login
Login with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt-token",
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "name": "User Name",
      "role": "user",
      "category": "Dealer"
    }
  }
}
```

### POST /api/auth/refresh
Refresh JWT token.

**Request Body:**
```json
{
  "refreshToken": "refresh-token"
}
```

### POST /api/auth/logout
Logout (invalidates token).

**Headers:** `Authorization: Bearer <token>`

### POST /api/auth/forgot-password
Request password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

### POST /api/auth/reset-password
Reset password with token.

**Request Body:**
```json
{
  "token": "reset-token",
  "password": "new-password"
}
```

### GET /api/auth/profile
Get current user profile.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "name": "User Name",
    "role": "user",
    "category": "Dealer"
  }
}
```

### PATCH /api/auth/profile
Update user profile.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "New Name"
}
```

### POST /api/auth/profile/change-password
Change password.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "currentPassword": "old-password",
  "newPassword": "new-password"
}
```

### DELETE /api/auth/profile
Delete user account.

**Headers:** `Authorization: Bearer <token>`

---

## Video Endpoints

### GET /api/videos
List all videos (filtered by user category).

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `category` (optional): Filter by category
- `search` (optional): Search in title/description

**Response:**
```json
{
  "success": true,
  "data": {
    "videos": [
      {
        "id": "video-id",
        "title": "Video Title",
        "description": "Description",
        "status": "ready",
        "thumbnailUrl": "/uploads/thumbnails/...",
        "hlsPath": "/uploads/hls/.../master.m3u8",
        "duration": 120,
        "createdAt": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

### GET /api/videos/my-videos
Get videos uploaded by current user.

**Headers:** `Authorization: Bearer <token>`

### GET /api/videos/watch-history
Get user's watch history.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "videoId": "video-id",
      "video": { ... },
      "progress": 50,
      "lastWatched": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### GET /api/videos/:id
Get video by ID.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "video-id",
    "title": "Video Title",
    "description": "Description",
    "status": "ready",
    "hlsPath": "/uploads/hls/.../master.m3u8",
    "thumbnailUrl": "/uploads/thumbnails/...",
    "duration": 120,
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### POST /api/videos
Create/register a new video.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Video Title",
  "description": "Description",
  "fileKey": "s3-key-or-local-path",
  "thumbnailUrl": "/uploads/thumbnails/..."
}
```

### PUT /api/videos/:id
Update video.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Updated Title",
  "description": "Updated Description"
}
```

### DELETE /api/videos/:id
Delete video.

**Headers:** `Authorization: Bearer <token>`

### POST /api/videos/:id/progress
Update video watch progress.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "progress": 50,
  "currentTime": 60
}
```

---

## Upload Endpoints

### POST /api/upload/presigned-url
Generate presigned URL for S3 upload.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "contentType": "video/mp4",
  "fileSize": 1000000
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "uploadUrl": "https://s3.amazonaws.com/...",
    "fileKey": "raw/video-id.mp4"
  }
}
```

### POST /api/upload/upload-local
Upload video directly to backend (local storage mode).

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Form Data:**
- `video`: Video file
- `thumbnail` (optional): Thumbnail image

**Response:**
```json
{
  "success": true,
  "data": {
    "videoId": "video-id",
    "filePath": "/uploads/raw/.../original.mp4",
    "thumbnailPath": "/uploads/thumbnails/..."
  }
}
```

### POST /api/upload/complete
Complete upload and start processing.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "fileKey": "raw/video-id.mp4",
  "title": "Video Title",
  "description": "Description"
}
```

---

## Analytics Endpoints

### POST /api/analytics/event
Record analytics event.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "eventType": "VIDEO_OPENED",
  "videoId": "video-id",
  "lessonId": "lesson-id",
  "currentTime": 10.5,
  "fullDuration": 120.0,
  "device": "desktop",
  "playbackQuality": "1080p"
}
```

**Event Types:**
- `VIDEO_OPENED`
- `VIDEO_PROGRESS`
- `VIDEO_COMPLETE`
- `VIDEO_BUFFER`
- `FOCUS_MODE_START`
- `FOCUS_MODE_END`

---

## Admin Endpoints

All admin endpoints require `Authorization: Bearer <token>` with admin role.

### GET /api/admin/users
List all users.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "user-id",
      "email": "user@example.com",
      "name": "User Name",
      "role": "user",
      "category": "Dealer",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### POST /api/admin/users/create
Create new user.

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "name": "New User",
  "password": "password123",
  "role": "user",
  "category": "Dealer"
}
```

### DELETE /api/admin/users/:id
Delete user.

### PATCH /api/admin/users/:id/role
Update user role.

**Request Body:**
```json
{
  "role": "admin"
}
```

### PATCH /api/admin/users/:id/category
Update user category.

**Request Body:**
```json
{
  "category": "Employee"
}
```

### GET /api/admin/stats
Get platform statistics.

**Response:**
```json
{
  "success": true,
  "data": {
    "totalUsers": 100,
    "totalVideos": 50,
    "totalViews": 1000
  }
}
```

### GET /api/admin/analytics/overview
Get analytics overview.

### GET /api/admin/analytics/video/:videoId
Get video-specific analytics.

### GET /api/admin/analytics/focus
Get focus mode analytics.

---

## Module Endpoints

### GET /api/modules
List modules (filtered by user category).

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "module-id",
      "title": "Module Title",
      "description": "Description",
      "lessons": [...]
    }
  ]
}
```

### GET /api/modules/:id
Get module by ID.

**Headers:** `Authorization: Bearer <token>`

---

## Lesson Endpoints

### GET /api/lessons/:id
Get lesson by ID.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "lesson-id",
    "title": "Lesson Title",
    "description": "Description",
    "video": { ... },
    "order": 1
  }
}
```

### GET /api/lessons/:id/stream
Get lesson stream URL.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "streamUrl": "/uploads/hls/.../master.m3u8"
  }
}
```

### POST /api/lessons/:id/progress
Update lesson progress.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "progress": 50,
  "completed": false
}
```

---

## Admin Module/Lesson Management

### POST /api/admin/modules
Create module (admin only).

**Request Body:**
```json
{
  "title": "Module Title",
  "description": "Description",
  "allowedCategories": ["Dealer", "Employee"]
}
```

### GET /api/admin/modules
List all modules (admin only).

### GET /api/admin/modules/:id
Get module by ID (admin only).

### PATCH /api/admin/modules/:id
Update module (admin only).

### DELETE /api/admin/modules/:id
Delete module (admin only).

### POST /api/admin/modules/:moduleId/lessons
Create lesson (admin only).

**Request Body:**
```json
{
  "title": "Lesson Title",
  "description": "Description",
  "order": 1
}
```

### POST /api/admin/lessons/:lessonId/upload
Upload video to lesson (admin only).

**Content-Type:** `multipart/form-data`

**Form Data:**
- `video`: Video file
- `thumbnail` (optional): Thumbnail image

### PATCH /api/admin/lessons/:lessonId
Update lesson (admin only).

### DELETE /api/admin/lessons/:lessonId
Delete lesson (admin only).

---

## Error Codes

- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `VALIDATION_ERROR`: Request validation failed
- `INTERNAL_ERROR`: Server error

## Rate Limiting

- Global: 100 requests per 15 minutes per IP
- Auth endpoints: 5 requests per 15 minutes per IP
- Forgot password: 3 requests per hour per IP

## Pagination

List endpoints support pagination:

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)

Response includes pagination metadata:
```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```
