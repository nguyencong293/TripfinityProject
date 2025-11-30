# 📱 Hướng dẫn triển khai Firebase Cloud Messaging (FCM)

## 📋 Tổng quan

Hệ thống FCM đã được tích hợp đầy đủ để gửi push notification đến thiết bị của người dùng khi:
- ✅ Có đơn đặt phòng mới (supplier nhận thông báo)
- ✅ App ở trạng thái: Foreground, Background, hoặc Terminated
- ✅ Tự động đồng bộ FCM token khi login/logout
- ✅ Hỗ trợ navigation khi click vào notification

---

## 🔧 Các bước triển khai

### 1️⃣ Chạy Database Migration

Thêm cột `fcm_token` vào bảng `users`:

```bash
cd database/migrations
# Chạy file SQL này trên MySQL database
mysql -u root -p tripfinity < add_fcm_token_to_users.sql
```

**Hoặc chạy trực tiếp SQL:**
```sql
ALTER TABLE users
ADD COLUMN fcm_token VARCHAR(255) NULL
COMMENT 'Firebase Cloud Messaging token for push notifications';

CREATE INDEX idx_fcm_token ON users(fcm_token);
```

### 2️⃣ Deploy Backend (Spring Boot)

**Kiểm tra file cần thiết:**
```
backend/src/main/resources/firebase-service-account.json
```

**Build và chạy backend:**
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

**Hoặc build Docker:**
```bash
docker build -t tripfinity-backend .
docker run -p 8080:8080 tripfinity-backend
```

### 3️⃣ Chạy Flutter App

```bash
cd app
flutter pub get
flutter run
```

**Hoặc build APK (Android):**
```bash
flutter build apk --release
```

---

## 🔄 Luồng hoạt động

### 📲 Khi User Login
1. Flutter app request quyền notification
2. Firebase Messaging cấp FCM token cho thiết bị
3. App gửi token lên backend qua API: `PUT /api/fcm/token`
4. Backend lưu token vào `users.fcm_token`

### 🛎️ Khi Booking mới được tạo
1. `HotelBookingService.createBooking()` được gọi
2. Backend lấy `supplier.user.fcmToken` từ database
3. `FCMService.sendNotificationToDevice()` gửi push notification qua Firebase
4. Firebase Cloud Messaging gửi đến thiết bị supplier
5. App hiển thị notification (foreground/background/terminated)

### 🚪 Khi User Logout
1. App gọi `AuthController.logout()`
2. FCM token được xóa khỏi backend: `DELETE /api/fcm/token/{userId}`
3. User không còn nhận notification nữa

---

## 🧪 Test End-to-End

### Test trên Android:

1. **Login vào app** → Kiểm tra log:
   ```
   ✅ FCM token updated successfully
   ```

2. **Đặt phòng mới** → Supplier nhận notification:
   - **Foreground**: Alert dialog hiện ngay lập tức
   - **Background**: Notification tray hiện thông báo
   - **Terminated**: App closed hoàn toàn vẫn nhận được

3. **Click vào notification** → Navigate đến booking detail

4. **Logout** → Kiểm tra log:
   ```
   ✅ FCM token deleted successfully
   ```

### Test Backend Logs:

```bash
# Xem log khi booking được tạo
📱 FCM notification sent to supplier
✅ Message sent successfully. Message ID: 0:1234567890...
```

---

## 📁 Các file quan trọng

### Backend (Spring Boot)
- `config/FirebaseConfig.java` - Khởi tạo Firebase Admin SDK
- `service/FCMService.java` - Gửi push notification
- `controller/FCMController.java` - API endpoints quản lý token
- `model/User.java` - Thêm field `fcmToken`
- `service/HotelBookingService.java` - Tích hợp FCM vào booking flow

### Flutter App
- `lib/services/fcm_service.dart` - Quản lý FCM token & message handling
- `lib/services/fcm_api_service.dart` - API calls đến backend
- `lib/controllers/auth_controller.dart` - Tích hợp FCM vào login/logout
- `lib/main.dart` - Initialize Firebase & FCM

### Database
- `database/migrations/add_fcm_token_to_users.sql` - Migration script

---

## 🔐 Bảo mật

- ✅ Service account JSON chỉ ở backend (không expose ra client)
- ✅ FCM token được bảo vệ bởi JWT authentication
- ✅ Chỉ user đã login mới update/delete token được
- ✅ Backend validate `userId` khớp với JWT claim

---

## 🐛 Troubleshooting

### ❌ Không nhận được notification?

1. **Kiểm tra quyền notification:**
   ```dart
   NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
   print(settings.authorizationStatus); // AuthorizationStatus.authorized?
   ```

2. **Kiểm tra FCM token có được lưu?**
   ```sql
   SELECT user_id, fcm_token FROM users WHERE fcm_token IS NOT NULL;
   ```

3. **Kiểm tra backend log:**
   ```bash
   # Phải thấy log này khi booking được tạo
   📱 FCM notification sent to supplier
   ```

4. **Kiểm tra Firebase Console:**
   - Truy cập: https://console.firebase.google.com/project/tripfinity-466014
   - Cloud Messaging → Check usage metrics

### ❌ Backend lỗi "firebase-service-account.json not found"?

```bash
# Đảm bảo file ở đúng vị trí
ls backend/src/main/resources/firebase-service-account.json

# Nếu chưa có, download từ Firebase Console:
# Project Settings → Service Accounts → Generate new private key
```

### ❌ Flutter build lỗi "firebase_options.dart not found"?

```bash
# Chạy lại FlutterFire CLI
flutterfire configure --project=tripfinity-466014
```

---

## 📊 Monitoring

### Backend Logs
```java
log.info("📱 FCM notification sent to supplier");
log.info("✅ Message sent successfully. Message ID: {}", response);
log.error("❌ Error sending FCM notification: {}", e.getMessage());
```

### Flutter Logs
```dart
debugPrint('📱 FCM Token: $token');
debugPrint('✅ FCM token updated successfully');
debugPrint('🔔 Notification received: ${message.notification?.title}');
debugPrint('Navigate to booking: $bookingId');
```

---

## 🚀 Tối ưu hóa

### Gửi notification cho nhiều thiết bị:
```java
fcmService.sendNotificationToMultipleDevices(
    List.of(token1, token2, token3),
    "Tiêu đề",
    "Nội dung"
);
```

### Subscribe vào topic (broadcast):
```dart
// Flutter
await fcmService.subscribeToTopic('all-suppliers');

// Backend gửi đến topic
fcmService.sendNotificationToTopic('all-suppliers', title, body);
```

### Tùy chỉnh notification icon/sound:
```java
// FCMService.java - thêm vào Notification.builder()
.setImage("https://example.com/image.png")
.setAndroidConfig(AndroidConfig.builder()
    .setNotification(AndroidNotification.builder()
        .setSound("notification_sound")
        .setColor("#FF0000")
        .build())
    .build())
```

---

## 📞 Support

- Firebase Documentation: https://firebase.google.com/docs/cloud-messaging
- Flutter Firebase Messaging: https://pub.dev/packages/firebase_messaging
- Firebase Console: https://console.firebase.google.com/project/tripfinity-466014

---

**✅ Hệ thống đã sẵn sàng sử dụng!**
