# Notification System Implementation Summary

## Overview
Comprehensive notification system for supplier dashboard that automatically creates notifications when hotels are created or updated.

## Database Schema (Already in database/init.sql)
```sql
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,    -- 'in_app', 'email', etc
    category VARCHAR(100) NOT NULL,             -- 'service_hotel_new', 'service_hotel_update', etc
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at DATETIME DEFAULT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id)
)
```

### Category Naming Convention
- **Service Notifications**: `service_hotel_new`, `service_hotel_update`, `service_hotel_booking`
- **Tour**: `service_tour_new`, `service_tour_update`, `service_tour_booking`
- **Payment**: `payment_success`, `payment_failed`, `payment_refund`
- **System**: `system_alert`, `system_maintenance`, `promotion`

## Backend Implementation

### Files Created
1. **backend/src/main/java/com/vn/tripfinity/backend/model/Notification.java**
   - JPA entity with VARCHAR types for flexibility
   - Constants for common notification types and categories
   - Auto-defaults: `isRead=false`, `sentAt=CURRENT_TIMESTAMP`

2. **backend/src/main/java/com/vn/tripfinity/backend/repository/NotificationRepository.java**
   - `findByUserIdOrderByCreatedAtDesc()` - Get all notifications sorted
   - `findUnreadByUserId()` - Get unread notifications
   - `countUnreadByUserId()` - Count for badge
   - `markAsRead()` - Update single notification
   - `markAllAsReadByUserId()` - Bulk update
   - `findTopNByUserId(Pageable)` - Dashboard widget (limit 4)
   - `deleteByNotificationId()` - Delete notification

3. **backend/src/main/java/com/vn/tripfinity/backend/dto/NotificationDTO.java**
   - Transfer object with `fromEntity()` converter
   - All fields use String for type/category

4. **backend/src/main/java/com/vn/tripfinity/backend/service/NotificationService.java**
   - `createNotification()` - Create notification
   - `getAllNotifications()` - Get all for user
   - `getRecentNotifications()` - Get N most recent
   - `getUnreadNotifications()` - Get unread only
   - `countUnread()` - Count unread
   - `markAsRead()` - Mark single as read
   - `markAllAsRead()` - Mark all as read
   - `deleteNotification()` - Delete notification
   - **Helper methods**:
     - `notifyHotelCreated(userId, hotelTitle)` - Auto-create notification
     - `notifyHotelUpdated(userId, hotelTitle)` - Auto-update notification

5. **backend/src/main/java/com/vn/tripfinity/backend/controller/NotificationController.java**
   - `GET /api/notifications/user/{userId}` - All notifications
   - `GET /api/notifications/user/{userId}/recent?limit=4` - Dashboard widget
   - `GET /api/notifications/user/{userId}/unread` - Unread notifications
   - `GET /api/notifications/user/{userId}/unread/count` - Badge count
   - `PATCH /api/notifications/{id}/read` - Mark single as read
   - `PATCH /api/notifications/user/{userId}/read-all` - Mark all as read
   - `POST /api/notifications` - Create notification (manual)
   - `DELETE /api/notifications/{id}` - Delete notification

### HotelService Integration
Updated `backend/src/main/java/com/vn/tripfinity/backend/service/HotelService.java`:

```java
// Added dependency
private final NotificationService notificationService;

// In createHotel():
Hotel savedHotel = hotelRepository.save(hotel);
try {
    Integer userId = provider.getUser().getUserId();
    notificationService.notifyHotelCreated(userId, savedHotel.getTitle());
} catch (Exception e) {
    log.error("⚠️ Không thể tạo thông báo", e);
}

// In updateHotel():
Hotel updatedHotel = hotelRepository.save(hotel);
try {
    Integer userId = updatedHotel.getProvider().getUser().getUserId();
    notificationService.notifyHotelUpdated(userId, updatedHotel.getTitle());
} catch (Exception e) {
    log.error("⚠️ Không thể tạo thông báo", e);
}
```

## Frontend Implementation

### Files Created/Updated

1. **supplier/src/pages/Service/Hotel/NotificationListPage.tsx** (NEW)
   - Full notification list page with filtering
   - Features:
     - Filter: All / Unread
     - Category badges (top-left corner)
     - Red dot indicator for unread
     - Mark as read / Mark all as read
     - Delete notification
     - Time formatting (e.g., "5 phút trước", "2 giờ trước")
   - Route: `/supplier/service/hotel/notifications`

2. **supplier/src/routes/AppRoutes.tsx** (UPDATED)
   - Added route: `<Route path="service/hotel/notifications" element={<NotificationListPage />} />`

3. **supplier/src/pages/Service/Hotel/DashboardHotelPage.tsx** (UPDATED)
   - Replaced hardcoded notifications with API call
   - Fetches max 4 recent notifications
   - Maps backend data to frontend format
   - "Xem tất cả" button navigates to `/supplier/service/hotel/notifications`
   - Shows unread count badge

4. **supplier/src/layouts/MainLayout.tsx** (UPDATED)
   - Added notification bell icon in header
   - Fetches unread count from API
   - Shows badge with unread count (e.g., "3", "99+")
   - Refreshes count every 30 seconds
   - Click navigates to notification list page

## Data Flow

### Create Hotel Flow
```
Supplier creates hotel
    ↓
HotelService.createHotel()
    ↓
Save hotel to database
    ↓
Get provider's user_id
    ↓
NotificationService.notifyHotelCreated()
    ↓
Create notification:
  - type: 'in_app'
  - category: 'service_hotel_new'
  - title: 'Khách sạn mới đã được tạo'
  - content: 'Khách sạn [title] đã được tạo thành công.'
    ↓
Save to notifications table
```

### Update Hotel Flow
Same as above, but:
- category: `service_hotel_update`
- title: "Khách sạn đã được cập nhật"

### Frontend Display Flow
```
Dashboard loads
    ↓
Fetch recent notifications (limit=4)
    ↓
Map backend format to frontend format
    ↓
Display in SECTION 2: Thông báo
    ↓
Show unread count badge
    ↓
User clicks notification → (future: navigate to detail)
User clicks "Xem tất cả" → Navigate to NotificationListPage
```

### MainLayout Bell Icon Flow
```
MainLayout loads
    ↓
Fetch unread count
    ↓
Display badge if count > 0
    ↓
Refresh every 30 seconds
    ↓
User clicks bell → Navigate to NotificationListPage
```

## Key Features

### Backend
✅ VARCHAR-based categories (flexible, not ENUM)
✅ Auto-creation on hotel create/update
✅ Filtering (all, unread, recent N)
✅ Mark as read (single or bulk)
✅ Delete notifications
✅ Pagination support via Pageable
✅ Transaction safety with @Transactional

### Frontend
✅ Dashboard widget (max 4 notifications)
✅ Full list page with filtering
✅ Category badges with color coding
✅ Red dot indicator for unread
✅ Time formatting (relative time)
✅ Mark as read functionality
✅ Delete functionality
✅ MainLayout bell icon with unread count
✅ Auto-refresh every 30 seconds

## Visual Design

### Category Badge Colors
- `service_hotel_new`: Green (`bg-green-500`)
- `service_hotel_update`: Blue (`bg-blue-500`)
- `service_hotel_booking`: Purple (`bg-purple-500`)
- `payment_success`: Emerald (`bg-emerald-500`)
- `payment_failed`: Red (`bg-red-500`)
- `system_alert`: Orange (`bg-orange-500`)
- `promotion`: Pink (`bg-pink-500`)

### Notification Card
- **Unread**: Blue border (`border-blue-300`), light blue background
- **Read**: Gray border (`border-gray-200`), white background
- **Red Dot**: Animated pulse effect for unread
- **Badge**: Top-left corner with category name

## Testing Checklist

### Backend
- [ ] Create hotel → notification created with correct category
- [ ] Update hotel → notification created with correct category
- [ ] GET /api/notifications/user/{userId} → returns all notifications
- [ ] GET /api/notifications/user/{userId}/recent?limit=4 → returns max 4
- [ ] GET /api/notifications/user/{userId}/unread/count → returns correct count
- [ ] PATCH /api/notifications/{id}/read → marks as read, sets readAt timestamp
- [ ] DELETE /api/notifications/{id} → deletes notification

### Frontend
- [ ] Dashboard shows max 4 recent notifications
- [ ] Dashboard shows correct unread count badge
- [ ] "Xem tất cả" navigates to notification list page
- [ ] Notification list page shows all notifications
- [ ] Filter "Chỉ chưa đọc" works correctly
- [ ] Mark as read button updates UI immediately
- [ ] Mark all as read button updates UI immediately
- [ ] Delete button removes notification from list
- [ ] Category badges display correct colors
- [ ] Red dot shows only for unread notifications
- [ ] MainLayout bell icon shows correct unread count
- [ ] Bell icon refreshes every 30 seconds
- [ ] Clicking bell navigates to notification list

## Future Enhancements

1. **Click-through Actions**
   - Navigate to hotel detail when clicking hotel notification
   - Navigate to booking detail for booking notifications

2. **Real-time Updates**
   - WebSocket connection for instant notifications
   - Push notifications in browser

3. **Email Notifications**
   - Send email for important events (configurable)
   - Email digest (daily/weekly summary)

4. **Advanced Filtering**
   - Filter by category
   - Filter by date range
   - Search by keyword

5. **Notification Preferences**
   - User settings to enable/disable notification types
   - Frequency preferences (instant, digest)

6. **Extend to Other Services**
   - Tour notifications
   - Restaurant notifications
   - Booking notifications from customers
   - Review notifications

## Notes

- **VARCHAR vs ENUM**: Used VARCHAR for `notification_type` and `category` to allow future expansion without schema migration
- **Transaction Safety**: All write operations use `@Transactional` to ensure data consistency
- **Error Handling**: Notification failures are logged but don't block main operations (hotel create/update)
- **Performance**: Uses pagination for large notification lists
- **Multi-tab Sync**: MainLayout uses storage events to sync auth state across tabs
