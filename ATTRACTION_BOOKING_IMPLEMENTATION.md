# ATTRACTION BOOKING & PAYMENT SYSTEM - IMPLEMENTATION SUMMARY

## 📋 Overview
Hệ thống booking và thanh toán cho attraction (điểm tham quan) đã được hoàn thiện, bao gồm backend (Java Spring Boot) và frontend (Flutter), tích hợp ZaloPay payment và notification system.

---

## ✅ COMPLETED COMPONENTS

### 1. DATABASE SCHEMA
**File:** Manual SQL Update Required
```sql
ALTER TABLE attraction_bookings 
ADD COLUMN provider_confirmed INT NOT NULL DEFAULT 0,
ADD COLUMN provider_confirmed_at DATETIME DEFAULT NULL;
```
- `provider_confirmed`: 0=pending, 1=confirmed, 2=cancelled
- `provider_confirmed_at`: Timestamp when provider confirms/cancels

---

### 2. BACKEND - MODEL LAYER

#### AttractionBooking.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/model/AttractionBooking.java`

**Features:**
- JPA Entity with all required fields
- BookingStatus enum: pending, confirmed, cancelled, completed, refunded
- Provider confirmation fields: provider_confirmed, provider_confirmed_at
- Relationships: User, Attraction, Provider
- Automatic timestamp handling (bookingDate, lastModified)

**Key Fields:**
```java
@Column(name = "provider_confirmed", nullable = false)
private Integer providerConfirmed = 0; // 0=pending, 1=confirmed, 2=cancelled

@Column(name = "provider_confirmed_at")
private LocalDateTime providerConfirmedAt;
```

#### AttractionPayment.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/model/AttractionPayment.java`

**Features:**
- PaymentMethod enum: counter, zalopay, vnpay, momo, visa, mastercard, paypal, other
- PaymentStatus enum: pending, success, failed, refunded
- Unique transaction_id constraint
- Relationships: AttractionBooking, User

---

### 3. BACKEND - DTO LAYER

#### AttractionBookingDTO.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/dto/AttractionBookingDTO.java`

**Features:**
- Complete data transfer object with all booking fields
- Jackson annotations for JSON serialization with snake_case
- Lombok Builder pattern
- Includes provider confirmation fields

#### AttractionPaymentDTO.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/dto/AttractionPaymentDTO.java`

**Features:**
- Payment DTO with status tracking
- JSON property aliases for API compatibility

---

### 4. BACKEND - REPOSITORY LAYER

#### AttractionBookingRepository.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/repository/AttractionBookingRepository.java`

**Custom Queries:**
- `findByUser_UserId()` - Get user's bookings
- `findByAttraction_AttractionId()` - Get bookings for attraction
- `findByProvider_ProviderId()` - Get provider's bookings
- `findByUserAndStatus()` - Filter by user and status
- `findByAttractionAndStatus()` - Filter by attraction and status
- `findByProviderAndStatus()` - Filter by provider and status
- `countByAttractionAndStartDateAndBookingStatus()` - Count confirmed bookings for capacity check
- `findByProviderIdAndSeenByProvider()` - Get unseen bookings for provider notifications

#### AttractionPaymentRepository.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/repository/AttractionPaymentRepository.java`

**Custom Queries:**
- `findByBooking_BookingId()` - Get payments for booking
- `findByUser_UserId()` - Get user's payment history
- `findByTransactionId()` - Find payment by transaction ID

---

### 5. BACKEND - SERVICE LAYER

#### AttractionBookingService.java (~700 lines)
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/service/AttractionBookingService.java`

**Core Methods:**
1. **createBooking()** - Create new booking with validation
   - Checks maxParticipants capacity
   - Auto-creates payment record
   - Sends notifications to user and supplier
   - Sends email confirmations

2. **validateAvailability()** - Check if attraction has capacity
   - Counts existing confirmed bookings on startDate
   - Compares against maxParticipants limit

3. **confirmBooking()** - Provider confirms booking
   - Updates provider_confirmed to 1
   - Sets provider_confirmed_at timestamp
   - Sends confirmation email and notification to user

4. **cancelBooking()** - Provider cancels booking
   - Updates provider_confirmed to 2
   - Sends cancellation email and notification to user

5. **createPaymentRecord()** - Auto-generate payment record
   - Creates payment entity linked to booking
   - Sets payment method and initial status

6. **getBookingsByUser()** - User's booking history
7. **getBookingsByProvider()** - Provider's booking list
8. **getUnseenBookingsByProvider()** - New bookings notification count
9. **markBookingsAsSeenByProvider()** - Mark bookings as seen

**Validation Logic:**
```java
// Check capacity before booking
long confirmedBookingsCount = attractionBookingRepository
    .countByAttractionAndStartDateAndBookingStatus(
        attractionId, startDate, BookingStatus.confirmed
    );

if (confirmedBookingsCount >= attraction.getMaxParticipants()) {
    throw new IllegalStateException("Attraction is fully booked for this date");
}
```

**Notification Flow:**
- User creates booking → Email + In-app notification to user + supplier
- Provider confirms → Email + In-app notification to user
- Provider cancels → Email + In-app notification to user

#### AttractionPaymentService.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/service/AttractionPaymentService.java`

**Core Methods:**
1. **createPayment()** - Create payment record
2. **updatePaymentStatus()** - Update payment status
3. **getPaymentsByUser()** - User's payment history
4. **getPaymentByTransactionId()** - Find payment by transaction ID

---

### 6. BACKEND - CONTROLLER LAYER

#### AttractionBookingController.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/controller/AttractionBookingController.java`
**Base URL:** `/api/attraction-bookings`

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create new booking |
| GET | `/` | Get all bookings (admin) |
| GET | `/{id}` | Get booking by ID |
| PUT | `/{id}` | Update booking |
| DELETE | `/{id}` | Delete booking |
| GET | `/user/{userId}` | Get user's bookings |
| GET | `/attraction/{attractionId}` | Get bookings for attraction |
| GET | `/provider/{providerId}` | Get provider's bookings |
| GET | `/provider/{providerId}/unseen` | Get unseen bookings count |
| PUT | `/seen` | Mark bookings as seen |
| PUT | `/{id}/confirm` | Provider confirms booking |
| PUT | `/{id}/cancel` | Provider cancels booking |
| PUT | `/fix-provider-ids` | Maintenance endpoint |

#### AttractionPaymentController.java
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/controller/AttractionPaymentController.java`
**Base URL:** `/api/attraction-payments`

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create payment |
| GET | `/` | Get all payments (admin) |
| GET | `/{id}` | Get payment by ID |
| PUT | `/{id}` | Update payment |
| DELETE | `/{id}` | Delete payment |
| GET | `/booking/{bookingId}` | Get payments for booking |
| GET | `/user/{userId}` | Get user's payments |
| GET | `/transaction/{transactionId}` | Get payment by transaction |

#### TestController.java (Updated)
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/controller/TestController.java`
**Base URL:** `/api/test`

**Updated Endpoint:**
- `POST /create-booking-from-pending?appTransId=xxx`
  - **Auto-detects booking type** from PendingPaymentDto
  - Supports hotel, restaurant, tour, **and now attraction**
  - Creates booking after ZaloPay payment success
  - Removes pending payment record

---

### 7. NOTIFICATION & EMAIL INTEGRATION

#### NotificationService.java (Extended)
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/service/NotificationService.java`

**New Methods for Attractions:**
1. `notifyUserAttractionBookingCreated()` - User receives booking confirmation
2. `notifySupplierNewAttractionBooking()` - Supplier receives new booking alert
3. `notifyUserAttractionBookingConfirmed()` - User receives provider confirmation
4. `notifyUserAttractionBookingCancelled()` - User receives cancellation notice

#### EmailService.java (Extended)
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/service/EmailService.java`

**New Methods with HTML Templates:**
1. `sendAttractionBookingConfirmationEmail()` - User booking confirmation
   - Includes booking details, attraction name, date, price
   - Payment method and status
   - HTML formatted with professional styling

2. `sendSupplierNewAttractionBookingEmail()` - Supplier new booking notification
   - Customer details (name, email, phone)
   - Booking details with date and participants
   - Call-to-action to confirm booking

3. `sendAttractionBookingApprovedEmail()` - User receives approval
   - Confirmed booking details
   - Attraction information
   - Visit instructions

4. `sendAttractionBookingCancelledEmail()` - User receives cancellation
   - Cancellation notice
   - Refund information (if applicable)
   - Alternative suggestions

**Email Template Features:**
- Professional HTML design
- Responsive layout
- Brand colors and styling
- Clear call-to-action buttons
- All text in Vietnamese

---

### 8. ZALOPAY INTEGRATION (EXTENDED)

#### PendingPaymentDto.java (Updated)
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/dto/PendingPaymentDto.java`

**New Field Added:**
```java
private Integer attractionId; // For attraction bookings
```

Now supports: hotelId, restaurantId, tourId, **attractionId**

#### ZaloPayController.java (Extended)
**Location:** `backend/src/main/java/com/vn/tripfinity/backend/controller/ZaloPayController.java`

**🔒 CRITICAL: Core ZaloPay functions UNCHANGED (as required)**

**New Endpoint Added:**
```java
@PostMapping("/create-attraction-order")
public Map<String, String> createAttractionOrder(
    @RequestParam Integer attractionId,
    @RequestParam String startDate,
    @RequestParam Integer numAdults,
    @RequestParam BigDecimal amount,
    @RequestParam(required = false) String providerNotes
)
```

**Flow:**
1. Receives attraction booking details
2. Creates PendingPaymentDto with attractionId
3. Stores in PendingPaymentService with apptransid as key
4. Calls existing `zaloPayService.createOrder()` (UNCHANGED)
5. Returns order_url and apptransid to Flutter

**Integration Pattern:**
```
Flutter → POST /zalopay/create-attraction-order
       ← {order_url, apptransid}
       → Opens WebView with order_url
       → User completes payment
       → POST /test/create-booking-from-pending?appTransId=xxx
       ← {success: true, bookingId: xxx}
```

---

### 9. FLUTTER - API SERVICE LAYER

#### attraction_booking_api_service.dart
**Location:** `app/lib/services/attraction_booking_api_service.dart`

**Features:**
- Complete CRUD operations for attraction bookings
- Dio HTTP client with auth token interceptor
- JSON serialization with snake_case conversion

**Methods:**
1. `createBooking()` - Create new booking
   ```dart
   Future<Map<String, dynamic>> createBooking({
     required int userId,
     required int attractionId,
     required String startDate,
     required int numAdults,
     required double totalPrice,
     String? providerNotes,
     required String paymentMethod,
   })
   ```

2. `getBookingsByUser(int userId)` - User's booking history
3. `getBookingById(int bookingId)` - Get booking details
4. `updateBooking()` - Update booking
5. `deleteBooking()` - Cancel booking

**Auth Integration:**
- Reads JWT token from SharedPreferences
- Adds Authorization header to all requests
- Handles 401 Unauthorized errors

#### zalopay_api_service.dart (Extended)
**Location:** `app/lib/services/zalopay_api_service.dart`

**New Method Added:**
```dart
Future<Map<String, String>> createAttractionOrder({
  required int attractionId,
  required String startDate,
  required int numAdults,
  required double totalPrice,
  String? providerNotes,
}) async {
  // Calls /zalopay/create-attraction-order
  // Returns {order_url, apptransid}
}
```

**🔒 Existing methods UNCHANGED (hotel, restaurant, tour)**

---

### 10. FLUTTER - UI LAYER

#### attraction_booking_checkout_screen.dart (~800 lines)
**Location:** `app/lib/views/screens/attraction_booking_checkout_screen.dart`

**Features:**

1. **Dual Payment Method Support**
   - Counter Payment (Pay Later)
   - ZaloPay (Online Payment)

2. **User Information Section**
   - Pre-filled from AuthController
   - Editable fields: name, email, phone
   - Auto-save to user profile if changed
   - Validation for all required fields

3. **Booking Details Display**
   - Attraction name and image
   - Selected date
   - Number of adults
   - Total price with currency

4. **Counter Payment Flow**
   ```dart
   1. User fills information
   2. Clicks "Xác nhận đặt chỗ"
   3. Direct API call to create booking
   4. Navigate to success screen
   ```

5. **ZaloPay Payment Flow**
   ```dart
   1. User fills information
   2. Clicks "Thanh toán ZaloPay"
   3. Create ZaloPay order → get order_url
   4. Open PaymentWebViewScreen with order_url
   5. User completes payment in WebView
   6. WebView detects success callback
   7. Call /test/create-booking-from-pending
   8. Navigate to success screen
   ```

6. **UI Components**
   - Professional gradient design
   - Payment method selection cards
   - Form validation with error messages
   - Loading indicators
   - Responsive layout
   - Vietnamese language support

7. **Error Handling**
   - Network errors
   - Validation errors
   - Payment failures
   - User-friendly error messages with Fluttertoast

**Key Code Segments:**

```dart
// Counter payment - immediate booking
if (_selectedPaymentMethod == 'counter') {
  final response = await _bookingService.createBooking(
    userId: currentUser!.userId!,
    attractionId: widget.attraction['attraction_id'],
    startDate: widget.startDate,
    numAdults: widget.numAdults,
    totalPrice: widget.totalPrice,
    providerNotes: _notesController.text.trim(),
    paymentMethod: 'counter',
  );
  // Navigate to success
}

// ZaloPay payment - pending booking
else if (_selectedPaymentMethod == 'zalopay') {
  final orderResponse = await _zaloPayService.createAttractionOrder(
    attractionId: widget.attraction['attraction_id'],
    startDate: widget.startDate,
    numAdults: widget.numAdults,
    totalPrice: widget.totalPrice,
    providerNotes: _notesController.text.trim(),
  );
  
  // Open WebView
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentWebViewScreen(
        url: orderResponse['order_url']!,
        appTransId: orderResponse['apptransid']!,
        bookingType: 'attraction',
      ),
    ),
  );
}
```

**Design Pattern:**
- Matches hotel booking UI (as required)
- Uses attraction-specific data structure
- Maintains consistent UX across all booking types

---

## 🔧 CONFIGURATION REQUIREMENTS

### Backend Configuration
1. **Database Migration:**
   ```sql
   -- Run this SQL on your database
   ALTER TABLE attraction_bookings 
   ADD COLUMN provider_confirmed INT NOT NULL DEFAULT 0,
   ADD COLUMN provider_confirmed_at DATETIME DEFAULT NULL;
   ```

2. **Email Service:**
   - SMTP configuration in `application.properties`
   - Async email sending enabled with @EnableAsync

3. **FCM Configuration:**
   - Firebase Cloud Messaging for push notifications
   - `firebase_options.dart` configured in Flutter app

### Flutter Configuration
1. **Dependencies:**
   - dio (HTTP client)
   - provider (State management)
   - shared_preferences (Token storage)
   - fluttertoast (User notifications)
   - webview_flutter (ZaloPay payment)

2. **API Base URL:**
   - Update in API service files to match your backend URL

---

## 📊 DATA FLOW DIAGRAMS

### Counter Payment Flow
```
User → AttractionBookingCheckoutScreen
     → Fill user info + booking details
     → Select "Counter Payment"
     → Click "Xác nhận đặt chỗ"
     → AttractionBookingApiService.createBooking()
     → Backend: AttractionBookingController.createBooking()
     → AttractionBookingService.createBooking()
       → Validate availability (check capacity)
       → Create AttractionBooking entity
       → Create AttractionPayment entity (status: pending)
       → Send notification to user
       → Send notification to supplier
       → Send email to user
       → Send email to supplier
       → Send FCM push notification
     → Return booking ID to Flutter
     → Navigate to success screen
```

### ZaloPay Payment Flow
```
User → AttractionBookingCheckoutScreen
     → Fill user info + booking details
     → Select "ZaloPay"
     → Click "Thanh toán ZaloPay"
     → ZaloPayApiService.createAttractionOrder()
     → Backend: ZaloPayController.createAttractionOrder()
       → Create PendingPaymentDto (with attractionId)
       → Store in PendingPaymentService
       → Call ZaloPayService.createOrder() [UNCHANGED]
       → Return order_url + apptransid
     → Open PaymentWebViewScreen(order_url)
     → User completes payment in WebView
     → ZaloPay redirects to callback URL
     → WebView detects success in URL
     → Flutter calls /test/create-booking-from-pending
     → Backend: TestController.createBookingFromPending()
       → Get PendingPaymentDto by apptransid
       → Detect booking type (attractionId present)
       → Create AttractionBookingDTO
       → Call AttractionBookingService.createBooking()
       → Same flow as counter payment (notifications, emails, etc.)
       → Remove pending payment
       → Return booking ID
     → Navigate to success screen
```

### Provider Confirmation Flow
```
Provider → Supplier Dashboard (Web/App)
         → View new booking
         → Click "Confirm" or "Cancel"
         → Backend: AttractionBookingController.confirmBooking()
         → AttractionBookingService.confirmBooking()
           → Update provider_confirmed = 1 (or 2 for cancel)
           → Set provider_confirmed_at = now
           → Send notification to user
           → Send email to user
           → Send FCM push notification
         → Return success response
         → Update supplier UI
```

---

## 🧪 TESTING CHECKLIST

### Backend Testing
- [ ] Test createBooking with valid data
- [ ] Test capacity validation (maxParticipants limit)
- [ ] Test counter payment booking creation
- [ ] Test ZaloPay order creation
- [ ] Test test endpoint with valid appTransId
- [ ] Test provider confirmation
- [ ] Test provider cancellation
- [ ] Verify email sending (check spam folder)
- [ ] Verify in-app notifications
- [ ] Verify FCM push notifications
- [ ] Test all repository queries
- [ ] Test error handling (invalid IDs, missing data)

### Flutter Testing
- [ ] Test counter payment booking
- [ ] Test ZaloPay payment flow
- [ ] Test user info auto-fill
- [ ] Test user info update
- [ ] Test form validation
- [ ] Test error messages
- [ ] Test WebView payment completion
- [ ] Test navigation flows
- [ ] Test loading indicators
- [ ] Test UI responsiveness

### Integration Testing
- [ ] End-to-end counter payment
- [ ] End-to-end ZaloPay payment
- [ ] Provider sees new booking notification
- [ ] User receives confirmation email
- [ ] Supplier receives new booking email
- [ ] Provider confirmation updates user
- [ ] FCM notifications delivered to both platforms

---

## 🐛 KNOWN ISSUES & FIXES

### ✅ Fixed Issues
1. **Unused import in AttractionBookingRepository** - Fixed ✅
2. **Unused variable in TestController** - Fixed ✅
3. **TestController missing attraction support** - Fixed ✅

### ⚠️ Pending Supplier UI
**Status:** Not yet implemented
**Required:** Supplier dashboard to view and confirm attraction bookings
**Similar to:** Tour booking management (ListTourBookingPage.tsx)
**Location:** `frontend/src/` or `supplier/src/`

**Required Features:**
- List all attraction bookings for supplier
- Filter by status (pending/confirmed/cancelled)
- View booking details
- Confirm booking action
- Cancel booking action
- Real-time notification badge for unseen bookings

---

## 📝 NOTES FOR DEVELOPERS

### Important Constraints
1. **🔒 DO NOT MODIFY CORE ZALOPAY FUNCTIONS**
   - `ZaloPayService.createOrder()` must remain unchanged
   - Only extend ZaloPayController with new endpoints
   - Use same PendingPaymentService pattern

2. **Consistent Naming Pattern**
   - Follow hotel/restaurant/tour naming conventions
   - Use "attraction" prefix for all attraction-related classes
   - Maintain snake_case for JSON API fields

3. **Provider Confirmation Logic**
   - provider_confirmed: 0=pending, 1=confirmed, 2=cancelled
   - Only update via confirmBooking() or cancelBooking() methods
   - Always send notification and email on status change

4. **Capacity Validation**
   - Always check maxParticipants before booking
   - Count only CONFIRMED bookings on same date
   - Throw IllegalStateException if fully booked

5. **Payment Flow**
   - Counter payment: Create booking immediately
   - ZaloPay: Create pending payment → pay → create booking
   - Test endpoint bridges payment success to booking creation

### Code Quality
- ✅ No compile errors
- ✅ No warnings (all unused imports removed)
- ✅ Proper exception handling
- ✅ Consistent code style
- ✅ Comprehensive documentation

---

## 🚀 DEPLOYMENT CHECKLIST

### Backend Deployment
- [ ] Run database migration (ALTER TABLE)
- [ ] Update application.properties (SMTP, FCM)
- [ ] Build with Maven: `mvn clean package`
- [ ] Deploy JAR to server
- [ ] Verify all endpoints with Postman
- [ ] Check logs for errors

### Flutter Deployment
- [ ] Update API base URL for production
- [ ] Test on physical devices (Android + iOS)
- [ ] Verify ZaloPay integration (sandbox → production)
- [ ] Test push notifications
- [ ] Build release APK/IPA
- [ ] Submit to Play Store / App Store

### Post-Deployment
- [ ] Monitor error logs
- [ ] Check email delivery rates
- [ ] Verify payment success rates
- [ ] Gather user feedback
- [ ] Monitor server performance

---

## 📞 SUPPORT & MAINTENANCE

### Common Issues
1. **Email not received:**
   - Check SMTP configuration
   - Check spam folder
   - Verify email service logs

2. **ZaloPay payment fails:**
   - Check ZaloPay credentials
   - Verify callback URL configuration
   - Check network connectivity

3. **Notification not delivered:**
   - Verify FCM token registration
   - Check Firebase console logs
   - Ensure app has notification permissions

### Monitoring
- Backend logs: Check for exceptions in AttractionBookingService
- Database: Monitor attraction_bookings and attraction_payments tables
- Firebase: Check FCM delivery reports
- Email: Monitor SMTP server logs

---

## 📚 RELATED DOCUMENTATION
- [Hotel Booking Implementation](IMPLEMENTATION_SUMMARY.md)
- [FCM Implementation Guide](FCM_IMPLEMENTATION_GUIDE.md)
- [ZaloPay Integration](backend/src/main/java/com/vn/tripfinity/backend/service/ZaloPayService.java)
- [Notification System](NOTIFICATION_SYSTEM.md)

---

## ✅ IMPLEMENTATION STATUS

**Backend:** ✅ Complete (100%)
- Models: ✅
- DTOs: ✅
- Repositories: ✅
- Services: ✅
- Controllers: ✅
- Notifications: ✅
- Emails: ✅
- ZaloPay Integration: ✅
- Test Endpoint: ✅

**Flutter:** ✅ Complete (100%)
- API Services: ✅
- ZaloPay Integration: ✅
- Checkout UI: ✅
- Payment Flow: ✅

**Pending:** ⏳
- Supplier UI for attraction bookings
- Production testing with real data
- Performance optimization

---

**Last Updated:** 2025-06-XX
**Version:** 1.0.0
**Status:** Ready for Testing ✅
