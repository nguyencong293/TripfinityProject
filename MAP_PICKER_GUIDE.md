# MapPicker Component - Hướng dẫn triển khai đầy đủ

## Tổng quan
Component MapPicker cho phép supplier chọn địa chỉ trên Google Maps và lưu tọa độ (latitude/longitude) vào database. Hệ thống đã được đồng bộ hoàn chỉnh giữa Frontend, Backend và Database.

## ✅ Các thay đổi đã thực hiện

### 1. Database Schema
**File**: `database/init.sql`
- Thêm cột `latitude DECIMAL(10,8)` vào bảng `hotels`
- Thêm cột `longitude DECIMAL(11,8)` vào bảng `hotels`
- Thêm index `idx_hotels_location` cho tối ưu truy vấn

**Migration File**: `database/migrations/add_latitude_longitude_to_hotels.sql`
- Script migration để cập nhật database hiện có
- Chạy script này nếu database đã tồn tại

### 2. Backend Changes

#### a) Entity (`backend/src/main/java/.../model/Hotel.java`)
```java
@Column(name = "latitude", precision = 10, scale = 8)
private BigDecimal latitude;

@Column(name = "longitude", precision = 11, scale = 8)
private BigDecimal longitude;
```

#### b) DTO (`backend/src/main/java/.../dto/HotelDTO.java`)
```java
@DecimalMin(value = "-90.0", message = "latitude phải >= -90.0")
@DecimalMax(value = "90.0", message = "latitude phải <= 90.0")
private BigDecimal latitude;

@DecimalMin(value = "-180.0", message = "longitude phải >= -180.0")
@DecimalMax(value = "180.0", message = "longitude phải <= 180.0")
private BigDecimal longitude;
```

#### c) Service (`backend/src/main/java/.../service/HotelService.java`)
- **convertToDTO**: Thêm mapping `latitude` và `longitude`
- **createHotel**: Thêm set `latitude` và `longitude` khi tạo mới
- **updateHotel**: Thêm update `latitude` và `longitude` khi cập nhật

### 3. Frontend Changes

#### a) MapPicker Component (`supplier/src/components/common/MapPicker.tsx`)
- Tích hợp Google Maps với `@react-google-maps/api`
- Tìm kiếm địa chỉ bằng Google Places Autocomplete
- Click trên map để chọn vị trí
- Reverse geocoding để lấy địa chỉ từ tọa độ
- Interface:
```typescript
interface LocationData {
  address: string;
  latitude: number;
  longitude: number;
}
```

#### b) Types (`supplier/src/types/index.ts`)
```typescript
export interface HotelDTO {
  address?: string;
  latitude?: number;  // NEW
  longitude?: number; // NEW
}
```

#### c) Hooks (`supplier/src/hooks/useHotels.ts`)
```typescript
interface HotelFormData {
  address: string;
  latitude?: number | null;  // NEW
  longitude?: number | null; // NEW
}
```

#### d) HotelCreatePage (`supplier/src/pages/Service/Hotel/HotelCreatePage.tsx`)
- Thay thế input Location và Address bằng MapPicker
- Tự động cập nhật `address`, `latitude`, `longitude`, và `location`

#### e) Environment Config
**Files**: `.env` và `.env.example`
```env
VITE_GOOGLE_MAPS_API_KEY=AIzaSyBEHT1sEuXBrx5zV5KG2nUOAXV1EtqbLB0
```

## 📋 Hướng dẫn triển khai

### Bước 1: Cập nhật Database
Nếu database đã tồn tại, chạy migration:
```bash
mysql -u root -p tripfinity < database/migrations/add_latitude_longitude_to_hotels.sql
```

Nếu tạo mới database:
```bash
mysql -u root -p < database/init.sql
```

### Bước 2: Restart Backend
```bash
cd backend
./mvnw spring-boot:run
```

### Bước 3: Restart Frontend
```bash
cd supplier
npm run dev
```

## 🎯 Cách sử dụng

### Cho Supplier (Tạo/Sửa Hotel)
1. Mở form tạo/sửa hotel
2. Ở phần "Vị trí & Địa chỉ":
   - **Option 1**: Nhập địa chỉ vào ô search và chọn từ gợi ý
   - **Option 2**: Click trực tiếp vào bản đồ
3. Địa chỉ và tọa độ sẽ tự động được lưu khi submit

### Dữ liệu được gửi lên Backend
```json
{
  "address": "123 Nguyễn Huệ, Quận 1, Thành phố Hồ Chí Minh",
  "latitude": 10.7751,
  "longitude": 106.7005,
  "location": "Quận 1, Thành phố Hồ Chí Minh"
}
```

## 🗺️ Hiển thị địa chỉ trên Map

### Option 1: Static Map (Không cần JavaScript)
```typescript
const staticMapUrl = `https://maps.googleapis.com/maps/api/staticmap?center=${hotel.latitude},${hotel.longitude}&zoom=15&size=600x300&markers=color:red%7C${hotel.latitude},${hotel.longitude}&key=${API_KEY}`;

<img src={staticMapUrl} alt="Hotel location" />
```

### Option 2: Interactive Map (Google Maps Embed)
```typescript
<iframe
  src={`https://www.google.com/maps/embed/v1/place?key=${API_KEY}&q=${hotel.latitude},${hotel.longitude}`}
  width="100%"
  height="450"
  style={{ border: 0 }}
  allowFullScreen
  loading="lazy"
/>
```

### Option 3: Link đến Google Maps
```typescript
const mapLink = `https://www.google.com/maps?q=${hotel.latitude},${hotel.longitude}`;

<a href={mapLink} target="_blank" rel="noopener noreferrer">
  Xem trên Google Maps
</a>
```

### Option 4: Component React (Tái sử dụng MapPicker)
```typescript
<MapPicker
  onLocationSelect={() => {}} // readonly mode
  initialLocation={{
    address: hotel.address,
    latitude: hotel.latitude,
    longitude: hotel.longitude,
  }}
/>
```

## 🔍 Query theo vị trí (Backend)

### Tìm hotels trong bán kính
```java
// Haversine formula
@Query("SELECT h FROM Hotel h WHERE " +
       "(6371 * acos(cos(radians(:lat)) * cos(radians(h.latitude)) * " +
       "cos(radians(h.longitude) - radians(:lng)) + " +
       "sin(radians(:lat)) * sin(radians(h.latitude)))) < :radius")
List<Hotel> findHotelsWithinRadius(
    @Param("lat") BigDecimal lat, 
    @Param("lng") BigDecimal lng, 
    @Param("radius") double radius // km
);
```

## 🛠️ Troubleshooting

### Lỗi: "This API key is not authorized"
- Kiểm tra API key trong `.env`
- Đảm bảo API key đã enable:
  - Maps JavaScript API
  - Places API
  - Geocoding API

### Map không hiển thị
- Kiểm tra console browser có lỗi
- Verify API key có hợp lệ
- Kiểm tra quota limit của API key

### Database error khi save
- Đảm bảo đã chạy migration script
- Verify cột `latitude` và `longitude` đã tồn tại:
```sql
DESCRIBE hotels;
```

### Backend không nhận latitude/longitude
- Kiểm tra HotelDTO có field
- Verify HotelService có map field trong createHotel/updateHotel
- Check log backend xem có error

## 📊 Data Types

| Layer      | Type                    | Range                      |
|------------|-------------------------|----------------------------|
| Database   | DECIMAL(10,8)          | -90.00000000 to 90.00000000 (lat) |
| Database   | DECIMAL(11,8)          | -180.00000000 to 180.00000000 (lng) |
| Backend    | BigDecimal             | Java BigDecimal            |
| Frontend   | number                 | JavaScript number          |

## 🔐 Security Notes

- API key hiện tại: `AIzaSyBEHT1sEuXBrx5zV5KG2nUOAXV1EtqbLB0`
- ⚠️ **Production**: Tạo API key mới với restrictions:
  - HTTP referrer restriction
  - API restrictions (chỉ enable cần thiết)
  - Quota limits

## 🚀 Tính năng mở rộng

1. **Autocomplete địa chỉ Việt Nam**: Filter results chỉ VN
2. **Distance calculator**: Tính khoảng cách giữa 2 hotels
3. **Map view cho danh sách**: Hiển thị nhiều hotels cùng lúc
4. **Nearby attractions**: Hiển thị địa điểm gần hotel
5. **Directions**: Chỉ đường từ vị trí hiện tại

## 📝 Testing Checklist

- [ ] Tạo hotel mới với địa chỉ từ map
- [ ] Update địa chỉ hotel đã có
- [ ] Verify data trong database
- [ ] Hiển thị map ở trang detail hotel
- [ ] Test trên mobile device
- [ ] Test với địa chỉ khác nhau (Hà Nội, Đà Nẵng, HCM)
- [ ] Test search autocomplete
- [ ] Test click trực tiếp trên map

## 🔗 Resources

- [Google Maps JavaScript API](https://developers.google.com/maps/documentation/javascript)
- [Google Places API](https://developers.google.com/maps/documentation/places/web-service)
- [React Google Maps API](https://react-google-maps-api-docs.netlify.app/)
- [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)
