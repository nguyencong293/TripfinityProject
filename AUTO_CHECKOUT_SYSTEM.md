# Hệ thống Tự động Trả Phòng (Auto Check-Out)

## 📋 Tổng quan

Hệ thống tự động chuyển trạng thái booking từ `completed` → `checked_out` khi đã quá ngày checkout, giúp tính toán chính xác số phòng còn trống.

## 🎯 Mục đích

### Trước khi có tính năng này:
- ❌ Booking `completed` vẫn được tính vào số phòng đã book
- ❌ Khách đã trả phòng nhưng phòng vẫn bị "khóa" 
- ❌ Supplier phải thủ công cập nhật status

### Sau khi có tính năng này:
- ✅ Tự động check-out booking đã hết hạn
- ✅ Phòng được giải phóng ngay khi quá checkout date
- ✅ Tính toán `availableRooms` chính xác

## 📊 Booking Status Flow

```
┌─────────┐      ┌───────────┐      ┌───────────┐      ┌─────────────┐
│ pending │ ───> │ confirmed │ ───> │ completed │ ───> │ checked_out │
└─────────┘      └───────────┘      └───────────┘      └─────────────┘
     │                  │                                       ↑
     │                  │                                       │
     ↓                  ↓                                       │
┌───────────┐      ┌──────────┐                      Auto (Daily 12:00)
│ cancelled │      │ refunded │                      When endDate < TODAY
└───────────┘      └──────────┘
```

## 🔧 Các thành phần đã thay đổi

### 1. **Backend Model** - `HotelBooking.java`
```java
public enum BookingStatus {
    pending, confirmed, cancelled, completed, refunded, checked_out  // ✅ Thêm checked_out
}
```

### 2. **Database Migration** - `add_checked_out_status.sql`
```sql
ALTER TABLE hotel_bookings 
MODIFY COLUMN booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'refunded', 'checked_out');
```

### 3. **Repository Queries** - `HotelBookingRepository.java`
```java
// Query tính số phòng đã book - LOẠI TRỪ checked_out
@Query("... WHERE bookingStatus NOT IN ('cancelled', 'refunded', 'checked_out')")
Integer sumRoomsByHotelActive(@Param("hotelId") Integer hotelId);

// Query tìm booking cần check-out
@Query("SELECT b FROM HotelBooking b WHERE b.bookingStatus = 'completed' AND b.endDate < :cutoffDate")
List<HotelBooking> findBookingsToCheckOut(@Param("cutoffDate") LocalDate cutoffDate);
```

### 4. **Scheduled Task** - `BookingScheduler.java`
```java
@Scheduled(cron = "0 0 12 * * ?") // Chạy lúc 12:00 trưa mỗi ngày
public void autoCheckOutExpiredBookings() {
    LocalDate today = LocalDate.now();
    List<HotelBooking> expiredBookings = bookingRepository.findBookingsToCheckOut(today);
    
    for (HotelBooking booking : expiredBookings) {
        booking.setBookingStatus(BookingStatus.checked_out);
        bookingRepository.save(booking);
    }
}
```

### 5. **Service Logic** - `HotelService.java` & `HotelBookingService.java`
```java
// Tính availableRooms - Không tính cancelled, refunded, checked_out
Integer bookedRooms = bookingRepository.sumRoomsByHotelActive(hotelId);
Integer availableRooms = totalRooms - bookedRooms;
```

### 6. **Frontend Translation**
- ✅ Tiếng Việt: "Đã trả phòng"
- ✅ English: "Checked Out"
- ✅ 한국어: "체크아웃됨"

## ⏰ Cron Schedule

```
┌───────────── giây (0-59)
│ ┌─────────── phút (0-59)  
│ │ ┌───────── giờ (0-23)
│ │ │ ┌─────── ngày trong tháng (1-31)
│ │ │ │ ┌───── tháng (1-12)
│ │ │ │ │ ┌─── ngày trong tuần (0-7) (0 hoặc 7 = Chủ Nhật)
│ │ │ │ │ │
0 0 12 * * ?  → Chạy lúc 12:00 trưa mỗi ngày
```

### Các cron schedule khác bạn có thể dùng:
- `0 0 0 * * ?` - Chạy lúc 00:00 nửa đêm mỗi ngày
- `0 0 */6 * * ?` - Chạy mỗi 6 giờ
- `0 */30 * * * ?` - Chạy mỗi 30 phút

## 📝 Công thức tính Available Rooms

```
availableRooms = totalRooms - SUM(rooms)
```

**Trong đó:**
- `totalRooms` = Tổng số phòng của khách sạn (trong bảng `hotels`)
- `SUM(rooms)` = Tổng số phòng của **TẤT CẢ** booking active

**Booking active bao gồm:**
- ✅ `pending` - Đang chờ xác nhận
- ✅ `confirmed` - Đã xác nhận
- ✅ `completed` - Đã hoàn thành (nhưng chưa trả phòng)

**Booking KHÔNG tính:**
- ❌ `cancelled` - Đã hủy
- ❌ `refunded` - Đã hoàn tiền
- ❌ `checked_out` - Đã trả phòng ← **MỚI**

## 🧪 Testing

### Test thủ công:

1. **Tạo booking test:**
```sql
INSERT INTO hotel_bookings (user_id, hotel_id, start_date, end_date, booking_status, ...)
VALUES (1, 1, '2025-11-20', '2025-11-22', 'completed', ...);
```

2. **Chạy scheduler thủ công:**
- Uncomment dòng `@Scheduled(fixedDelay = ...)` trong `BookingScheduler.java`
- Restart backend
- Xem log để kiểm tra

3. **Kiểm tra kết quả:**
```sql
SELECT booking_id, hotel_id, end_date, booking_status 
FROM hotel_bookings 
WHERE booking_status = 'checked_out';
```

### Test automation:
```bash
# Kiểm tra booking đã quá hạn
curl http://localhost:8080/api/hotel-bookings?status=completed

# Sau khi chạy scheduler, check lại
curl http://localhost:8080/api/hotel-bookings?status=checked_out
```

## 📊 Ví dụ thực tế

### Scenario:
- **Hotel A** có `totalRooms = 10`
- **22/11/2025:**
  - User 1 book 3 phòng (22-24/11) → status: `confirmed`
  - User 2 book 5 phòng (22-25/11) → status: `confirmed`
  - `availableRooms = 10 - 8 = 2` ✅

- **24/11/2025:**
  - User 1 check-out → status tự động: `completed`
  - `availableRooms = 10 - 8 = 2` (vẫn còn ở, chưa trả phòng)

- **25/11/2025 12:00:**
  - **Scheduler chạy:**
    - User 1 booking: `endDate = 24/11 < 25/11` → chuyển `checked_out` ✅
  - `availableRooms = 10 - 5 = 5` (User 1 đã trả, chỉ còn User 2)

- **26/11/2025 12:00:**
  - **Scheduler chạy:**
    - User 2 booking: `endDate = 25/11 < 26/11` → chuyển `checked_out` ✅
  - `availableRooms = 10 - 0 = 10` (tất cả đã trả phòng)

## 🚀 Deployment Checklist

- [x] Database migration: Chạy `add_checked_out_status.sql`
- [x] Backend code: Deploy với `BookingScheduler.java`
- [x] Enable scheduling: `@EnableScheduling` trong `BackendApplication`
- [x] Supplier frontend: Update translation files
- [x] Test scheduler: Kiểm tra log sau 12:00 trưa
- [ ] Monitor: Theo dõi số lượng auto check-out hàng ngày

## 📞 Support

Nếu có vấn đề:
1. Kiểm tra log: `grep "Auto Check-Out" logs/backend.log`
2. Kiểm tra database: `SELECT * FROM hotel_bookings WHERE booking_status = 'checked_out'`
3. Verify scheduler đang chạy: Log sẽ hiển thị "🏨 [Auto Check-Out] Starting..."

## 🎉 Kết luận

Hệ thống tự động trả phòng giúp:
- ✅ Giảm công việc thủ công cho supplier
- ✅ Tính toán phòng trống chính xác
- ✅ Cải thiện trải nghiệm đặt phòng
- ✅ Tự động hóa quy trình quản lý
