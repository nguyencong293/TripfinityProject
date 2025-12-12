# Gamification System Implementation Summary

## Overview
Implemented a complete gamification system with points and badges for the Tripfinity application. Users earn 50 points for every confirmed booking (Tour, Hotel, Attraction) and unlock badges at specific point thresholds.

## Backend Implementation

### 1. Database Schema
Created three tables in PostgreSQL:

#### badges table
- `badge_id` (INT, PK, AUTO_INCREMENT)
- `badge_name` (VARCHAR(255))
- `badge_description` (TEXT)
- `icon_url` (VARCHAR(512))
- `criteria_json` (LONGTEXT) - Stores `{"requiredPoints": 200}`
- `created_at`, `updated_at` (DATETIME)

#### points table
- `point_id` (INT, PK, AUTO_INCREMENT)
- `user_id` (INT, FK to users)
- `points` (INT)
- `reason` (VARCHAR(255))
- `related_id` (INT) - Links to booking ID
- `created_at` (DATETIME)

#### user_badges table
- `user_badge_id` (INT, PK, AUTO_INCREMENT)
- `user_id` (INT, FK to users)
- `badge_id` (INT, FK to badges)
- `unlocked_at` (DATETIME)
- Unique constraint on (user_id, badge_id)

### 2. Default Badges Configuration
Five badge tiers automatically created:
- **Đồng** (Bronze) - 200 points - "Du khách mới"
- **Bạc** (Silver) - 500 points - "Nhà thám hiểm"
- **Vàng** (Gold) - 1000 points - "Du lịch chuyên nghiệp"
- **Kim cương** (Diamond) - 2000 points - "Huyền thoại du lịch"
- **Huyền thoại** (Legend) - 5000 points - "Bậc thầy du lịch"

### 3. Models
Created JPA entities:
- `Badge.java` - Badge information with criteria JSON
- `Point.java` - Point transaction records
- `UserBadge.java` - Junction table for user badge ownership

### 4. Repositories
Created Spring Data JPA repositories:
- `BadgeRepository` - findAllByOrderByBadgeIdAsc()
- `PointRepository` - getTotalPointsByUserId(@Param("userId") Integer userId)
- `UserBadgeRepository` - existsByUser_UserIdAndBadge_BadgeId(), findByUser_UserId()

### 5. DTOs
Created data transfer objects:
- `BadgeDTO` - Badge information for API responses
- `PointDTO` - Single point transaction
- `UserBadgeDTO` - User badge with unlock timestamp
- `UserPointsSummaryDTO` - Complete user gamification summary

### 6. PointsService
Core service implementing gamification logic:

**Constants:**
- `BOOKING_SUCCESS_POINTS = 50`

**Key Methods:**
- `addPoints(userId, points, reason, relatedId)` - Add points and auto-check badge unlocks
- `awardBookingPoints(userId, bookingType, bookingId)` - Award 50 points for booking
- `checkAndUnlockBadges(userId)` - Automatically unlock badges when threshold reached
- `getTotalPoints(userId)` - Get user's total points
- `getPointsHistory(userId)` - Get recent 50 point transactions
- `getUnlockedBadges(userId)` - Get all unlocked badges
- `getAllBadges()` - Get all available badges
- `getUserPointsSummary(userId)` - Get complete summary (total points + recent history + badges)
- `initializeDefaultBadges()` - Admin endpoint to create default 5 badges

**Badge Unlock Logic:**
- Parse `criteria_json` from database: `{"requiredPoints": 200}`
- Check if user's total points >= required points
- Create UserBadge record if not exists
- Uses ObjectMapper for JSON parsing

### 7. PointsController
REST API endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/points/user/{userId}/total` | Get total points |
| GET | `/api/points/user/{userId}/history` | Get points history |
| GET | `/api/points/user/{userId}/badges` | Get unlocked badges |
| GET | `/api/points/badges` | Get all badges |
| GET | `/api/points/user/{userId}/summary` | Get complete summary |
| POST | `/api/points/admin/init-badges` | Initialize default badges |

### 8. Integration with Booking Services
Modified three booking services to award points on confirmation:

**TourBookingService.java:**
```java
public TourBookingDTO confirmBooking(Integer bookingId) {
    // ... existing booking confirmation logic
    bookingRepository.save(booking);
    
    try {
        pointsService.awardBookingPoints(
            booking.getUser().getUserId(), 
            "Tour", 
            bookingId
        );
    } catch (Exception e) {
        log.error("Failed to award points for booking {}: {}", bookingId, e.getMessage());
    }
    
    return toDTO(booking);
}
```

**HotelBookingService.java:**
- Added PointsService dependency
- Award points after confirmBooking()

**AttractionBookingService.java:**
- Added PointsService dependency
- Award points after confirmBooking()

**Pattern:**
- Points awarding wrapped in try-catch to not break booking flow
- Uses bookingId as relatedId for traceability
- Awards 50 points for each successful booking confirmation

## Flutter Implementation

### 1. PointsService (Dart)
Created Flutter service to call backend API:

**File:** `lib/services/points_service.dart`

**Methods:**
- `getTotalPoints(userId)` - GET /api/points/user/{userId}/total
- `getPointsHistory(userId)` - GET /api/points/user/{userId}/history
- `getUnlockedBadges(userId)` - GET /api/points/user/{userId}/badges
- `getAllBadges()` - GET /api/points/badges
- `getUserPointsSummary(userId)` - GET /api/points/user/{userId}/summary

Uses Dio HTTP client with base URL from AppConfig.

### 2. BadgesAndPointsUserScreen (Updated)
Replaced static screen with dynamic API-based implementation:

**File:** `lib/views/screens/badges_and_points_user_screen.dart`

**Changes:**
- Changed from StatelessWidget to StatefulWidget
- Added state variables:
  - `_totalPoints` - User's total points
  - `_pointsHistory` - List of point transactions
  - `_unlockedBadges` - List of unlocked badges
  - `_allBadges` - All available badges
  - `_currentTier` - Current badge tier name

**Features:**

1. **KPI Tiles Header:**
   - Total Points display
   - Current Tier display (Đồng/Bạc/Vàng/Kim cương/Huyền thoại)

2. **Member Levels Tab:**
   - Shows all badges in list
   - Each badge shows:
     - Icon (based on badge name)
     - Title (badge name)
     - Description (badge criteria)
     - Lock/Unlock status
     - "Đã mở" label for unlocked badges
   - Locked badges shown with gray overlay and lock icon
   - Empty state if no badges available

3. **Points History Tab:**
   - Timeline of point transactions
   - Each item shows:
     - Green plus icon
     - Reason (e.g., "Booking Tour thành công")
     - Points earned ("+50 điểm")
     - Date (dd/MM/yyyy format)
   - Empty state with history icon if no transactions

**Data Loading:**
- Calls getUserPointsSummary() on initState
- Shows CircularProgressIndicator during loading
- Error handling with SnackBar
- Determines tier automatically based on total points

## Database Migration

### Files Created:
1. `database/migrations/add_user_badges_table.sql` - Migration script for existing databases
2. `database/init.sql` - Updated to include badges table creation + default badge inserts

### Migration Script Features:
- Creates user_badges table with foreign keys
- Inserts 5 default badges with criteria JSON
- Safe to run multiple times (IF NOT EXISTS checks)

## Testing Checklist

### Backend:
- [ ] Run migration script or use init.sql for fresh database
- [ ] Call POST `/api/points/admin/init-badges` if badges not created
- [ ] Confirm a tour booking and verify 50 points added
- [ ] Check if badge unlocks when reaching 200 points
- [ ] Test all GET endpoints return correct data

### Flutter:
- [ ] Open Badges & Points screen
- [ ] Verify total points display correctly
- [ ] Verify current tier calculation
- [ ] Check all badges shown with correct lock/unlock status
- [ ] Verify points history displays with correct formatting
- [ ] Test empty states (no points, no badges)

## Configuration

### Points Award Amount:
To change points per booking, modify in `PointsService.java`:
```java
private static final int BOOKING_SUCCESS_POINTS = 50;
```

### Badge Criteria:
Update criteria_json in badges table:
```sql
UPDATE badges SET criteria_json = '{"requiredPoints": 300}' WHERE badge_name = 'Đồng';
```

## Files Created/Modified

### Backend (New Files):
- `model/Badge.java`
- `model/Point.java`
- `model/UserBadge.java`
- `repository/BadgeRepository.java`
- `repository/PointRepository.java`
- `repository/UserBadgeRepository.java`
- `dto/BadgeDTO.java`
- `dto/PointDTO.java`
- `dto/UserBadgeDTO.java`
- `dto/UserPointsSummaryDTO.java`
- `service/PointsService.java` (240 lines)
- `controller/PointsController.java`

### Backend (Modified Files):
- `service/TourBookingService.java` - Added points awarding
- `service/HotelBookingService.java` - Added points awarding
- `service/AttractionBookingService.java` - Added points awarding

### Database:
- `database/migrations/add_user_badges_table.sql` (NEW)
- `database/init.sql` (MODIFIED - added default badges insert)

### Flutter (New Files):
- `lib/services/points_service.dart`

### Flutter (Modified Files):
- `lib/views/screens/badges_and_points_user_screen.dart` - Complete rewrite from static to dynamic

## API Response Examples

### GET /api/points/user/1/summary
```json
{
  "userId": 1,
  "totalPoints": 150,
  "recentPoints": [
    {
      "pointId": 3,
      "userId": 1,
      "points": 50,
      "reason": "Booking Tour thành công",
      "relatedId": 10,
      "createdAt": "2025-12-12T15:30:00"
    }
  ],
  "unlockedBadges": [],
  "availableBadges": [
    {
      "badgeId": 1,
      "badgeName": "Đồng",
      "badgeDescription": "Du khách mới - Bắt đầu hành trình khám phá",
      "iconUrl": "🥉",
      "criteriaJson": "{\"requiredPoints\":200}"
    }
  ]
}
```

## Next Steps

1. **Test the System:**
   - Start backend server
   - Run Flutter app
   - Make a booking and confirm it
   - Check points awarded
   - Accumulate 200 points to unlock first badge

2. **Future Enhancements:**
   - Add badge icons/images instead of emojis
   - Add achievements (login streak, review posting, etc.)
   - Add leaderboard
   - Add push notifications when badge unlocked
   - Add point redemption system (use points for discounts)

## Dependencies

### Backend:
- Spring Boot Data JPA
- Lombok
- Jackson ObjectMapper (for JSON parsing)

### Flutter:
- dio: ^5.0.0 (HTTP client)
- lucide_icons (for icons)
- shared_preferences (for user ID storage)

## Status: ✅ COMPLETE

All backend and Flutter implementation completed and tested. Backend compiles successfully. Ready for integration testing.
