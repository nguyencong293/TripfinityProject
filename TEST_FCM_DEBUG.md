# 🐛 Debug FCM Không Nhận Thông Báo

## ✅ Đã fix: Thêm permissions vào AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
```

---

## 🔍 Các bước debug chi tiết

### 1️⃣ Kiểm tra Flutter App có get được FCM token không?

**Chạy app và xem log:**
```bash
cd app
flutter run
```

**Tìm log này:**
```
✅ User granted notification permission
📱 FCM Token: [TOKEN DÀI NGOẰNG]
✅ FCM token updated successfully
```

**Nếu thấy `❌ User declined notification permission`:**
- Vào Settings → Apps → TripFinity → Permissions
- Bật "Notifications" permission

---

### 2️⃣ Kiểm tra FCM token có được lưu vào database không?

**Kết nối MySQL:**
```bash
mysql -u root -p tripfinity
```

**Kiểm tra token:**
```sql
-- Xem tất cả user có FCM token
SELECT user_id, full_name, email, 
       LEFT(fcm_token, 50) as fcm_token_preview 
FROM users 
WHERE fcm_token IS NOT NULL;

-- Kiểm tra supplier cụ thể (thay USER_ID)
SELECT user_id, full_name, fcm_token 
FROM users 
WHERE user_id = 2;
```

**Nếu fcm_token = NULL:**
- App chưa gửi token lên backend
- Kiểm tra log Flutter: `✅ FCM token updated successfully`
- Kiểm tra backend log: `PUT /api/fcm/token`

---

### 3️⃣ Test gửi thông báo thủ công (không qua booking)

**Tạo file test:**
`backend/src/test/java/com/vn/tripfinity/backend/FCMManualTest.java`

```java
package com.vn.tripfinity.backend;

import com.vn.tripfinity.backend.service.FCMService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashMap;
import java.util.Map;

@SpringBootTest
public class FCMManualTest {

    @Autowired
    private FCMService fcmService;

    @Test
    public void testSendNotification() {
        // THAY ĐỔI TOKEN NÀY BẰNG TOKEN THẬT TỪ DATABASE
        String fcmToken = "YOUR_FCM_TOKEN_HERE";
        
        Map<String, String> data = new HashMap<>();
        data.put("type", "test");
        data.put("message", "Test FCM từ backend");

        fcmService.sendNotificationToDevice(
            fcmToken,
            "🔔 Test Notification",
            "Đây là thông báo test từ backend",
            data
        );

        System.out.println("✅ Đã gửi test notification!");
    }
}
```

**Chạy test:**
```bash
cd backend
mvn test -Dtest=FCMManualTest
```

---

### 4️⃣ Kiểm tra backend có gửi FCM không khi booking mới?

**Tạo booking mới và xem backend log:**
```bash
cd backend
mvn spring-boot:run
```

**Tìm log này sau khi đặt phòng:**
```
📱 FCM notification sent to supplier
✅ Message sent successfully. Message ID: projects/tripfinity-466014/messages/0:1234567890
```

**Nếu KHÔNG thấy log:**
- Backend không gọi FCMService
- Kiểm tra HotelBookingService.java line ~248

**Nếu thấy ERROR:**
```
❌ Error sending FCM notification: ...
```
- Copy full error message để debug
- Có thể là:
  - Service account JSON sai
  - FCM token không hợp lệ
  - Network issue

---

### 5️⃣ Kiểm tra Firebase Console

**Truy cập:**
https://console.firebase.google.com/project/tripfinity-466014/notification

**Cloud Messaging → Usage:**
- Xem số lượng messages sent
- Xem delivery rate
- Nếu 0 messages → Backend chưa gửi

---

### 6️⃣ Debug từng trạng thái app

#### **Foreground (App đang mở):**
```dart
// Trong fcm_service.dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  debugPrint('🔔 FOREGROUND MESSAGE:');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  // Phải tự hiển thị dialog/snackbar
});
```

#### **Background (App minimize):**
- Android tự động hiển thị notification tray
- Click vào → mở app
- Log: `FirebaseMessaging.onMessageOpenedApp`

#### **Terminated (App đóng hoàn toàn):**
- Android tự động hiển thị notification
- Click vào → mở app
- Log: `getInitialMessage()`

---

### 7️⃣ Test bằng Firebase Console trực tiếp

**Gửi test notification không qua backend:**

1. Vào: https://console.firebase.google.com/project/tripfinity-466014/notification/compose
2. Click "Send test message"
3. Nhập FCM token từ database
4. Gửi

**Nếu nhận được → Backend có vấn đề**
**Nếu KHÔNG nhận → Flutter app có vấn đề**

---

### 8️⃣ Checklist đầy đủ

- [ ] AndroidManifest.xml có POST_NOTIFICATIONS permission
- [ ] Flutter app request permission thành công
- [ ] FCM token được lưu vào database (users.fcm_token)
- [ ] Backend có file firebase-service-account.json
- [ ] Backend log hiển thị "FCM notification sent"
- [ ] Firebase Console hiển thị messages sent > 0
- [ ] User là SUPPLIER (chỉ supplier nhận notification khi có booking)

---

## 🎯 Test Case Cụ Thể

### Scenario: Đặt phòng mới

1. **User A (Customer)** login → đặt phòng
2. **User B (Supplier)** sẽ nhận 3 loại thông báo:
   - ✉️ Email (sendSupplierNewBookingEmail)
   - 🔔 In-app notification (notifySupplierNewBooking)
   - 📱 **FCM Push Notification** ← ĐÂY LÀ ĐIỀU CẦN TEST

**Kiểm tra:**
```sql
-- User B phải là supplier của hotel
SELECT h.hotel_id, h.title, u.user_id, u.full_name, u.fcm_token
FROM hotels h
JOIN hotel_providers hp ON h.hotel_id = hp.hotel_id
JOIN users u ON hp.user_id = u.user_id
WHERE h.hotel_id = [HOTEL_ID_VỪA_ĐẶT];
```

---

## 🚨 Lỗi thường gặp

### ❌ "User declined notification permission"
**Fix:** Xin lại permission trong Settings

### ❌ "FCM token is null"
**Fix:** 
- Chạy lại `flutter clean && flutter run`
- Xóa app và cài lại

### ❌ "Invalid registration token"
**Fix:**
- FCM token cũ/expired
- User logout nhưng token chưa xóa
- Clear token: `UPDATE users SET fcm_token = NULL WHERE user_id = X;`

### ❌ "Service account credentials error"
**Fix:**
- Kiểm tra `firebase-service-account.json` đúng format
- Re-download từ Firebase Console

### ❌ Camera errors (emulator)
**Ignore:** Không ảnh hưởng FCM, chỉ là emulator không có camera

---

## 📞 Quick Debug Commands

```bash
# 1. Xem Flutter logs real-time
flutter logs

# 2. Filter chỉ FCM logs
flutter logs | grep -E "FCM|firebase|notification"

# 3. Xem backend logs
cd backend
mvn spring-boot:run | grep -E "FCM|notification"

# 4. Check database
mysql -u root -p -e "SELECT user_id, LEFT(fcm_token,30) FROM tripfinity.users WHERE fcm_token IS NOT NULL;"
```

---

**✅ Sau khi fix permissions, rebuild app:**
```bash
cd app
flutter clean
flutter pub get
flutter run
```
