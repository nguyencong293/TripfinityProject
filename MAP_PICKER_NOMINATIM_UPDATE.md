# Map Picker với Nominatim - Cập nhật hoàn chỉnh

## Tóm tắt thay đổi

### 1. MapPicker Component
**File:** `supplier/src/components/common/MapPicker.tsx`

#### Tính năng mới:
- ✅ **Export LocationData interface** với 4 trường:
  - `address`: Địa chỉ đầy đủ (VD: "Trần Đại Nghĩa, Phường Ngũ Hành Sơn, Thành phố Đà Nẵng, Việt Nam")
  - `location`: Tỉnh/Thành phố (VD: "Đà Nẵng", "TP. Hồ Chí Minh")
  - `latitude`: Kinh độ (dạng số)
  - `longitude`: Vĩ độ (dạng số)

- ✅ **Tách location tự động** từ Nominatim API:
  ```typescript
  const extractLocation = (nominatimAddress?: NominatimResult['address']): string => {
    // Priority: city > state > province
    return nominatimAddress.city || nominatimAddress.state || nominatimAddress.province || '';
  };
  ```

- ✅ **Fix dropdown background** - không còn chữ chồng chữ:
  ```tsx
  className="bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
  style={{ backgroundColor: 'var(--color-surface, #ffffff)' }}
  ```

- ✅ **Hiển thị thông tin đầy đủ** khi chọn vị trí:
  - Khu vực: Đà Nẵng
  - Địa chỉ: Trần Đại Nghĩa, Phường Ngũ Hành Sơn...
  - Tọa độ: Latitude, Longitude

#### Forward Geocoding (Tìm kiếm):
- Gõ địa chỉ → Nominatim API → 5 kết quả gợi ý
- Click kết quả → tự động điền address, location, lat, lng

#### Reverse Geocoding (Click map):
- Click bản đồ → lấy tọa độ → Nominatim API → địa chỉ tiếng Việt
- Tự động trích xuất tỉnh/thành phố

### 2. HotelCreatePage
**File:** `supplier/src/pages/Service/Hotel/HotelCreatePage.tsx`

#### Cập nhật:
```tsx
<MapPicker
  onLocationSelect={(data: LocationData) => {
    updateField("address", data.address);      // Địa chỉ đầy đủ
    updateField("location", data.location);    // Tỉnh/thành phố
    updateField("latitude", data.latitude);    // Kinh độ (số)
    updateField("longitude", data.longitude);  // Vĩ độ (số)
  }}
  initialLocation={
    formData.latitude && formData.longitude
      ? {
          address: formData.address || "",
          location: formData.location || "",
          latitude: formData.latitude,
          longitude: formData.longitude,
        }
      : undefined  // Fix lỗi null type
  }
/>
```

#### Hiển thị:
```tsx
{formData.location && (
  <div className="text-caption-mobile theme-text-secondary">
    <strong>Khu vực:</strong> {formData.location}
  </div>
)}
{formData.address && (
  <div className="text-caption-mobile theme-text-secondary mt-1">
    <strong>Địa chỉ:</strong> {formData.address}
  </div>
)}
```

### 3. HotelEditPage
**File:** `supplier/src/pages/Service/Hotel/HotelEditPage.tsx`

#### Cập nhật tương tự HotelCreatePage:
- Import LocationData type đúng cách
- Thêm `location` field vào callback
- Fix `initialLocation` type từ `null` → `undefined`
- Hiển thị cả khu vực và địa chỉ

### 4. Database & Backend
**Không cần thay đổi** - đã có sẵn:
- ✅ `location VARCHAR(255)` trong `hotels` table
- ✅ `address VARCHAR(255)` trong `hotels` table
- ✅ `latitude DECIMAL(10,8)` và `longitude DECIMAL(11,8)`
- ✅ Backend `HotelDTO` có đầy đủ 4 trường

### 5. Flutter App
**Không cần thay đổi** - đã tương thích:
- ✅ Sử dụng `hotel['location']` và `hotel['address']` từ API
- ✅ Map với `latitude`/`longitude` đã hoạt động
- ✅ Nominatim reverse geocoding đã implement

## Cách sử dụng

### Kịch bản 1: Tìm kiếm địa điểm
1. Gõ "Trần Đại Nghĩa, Đà Nẵng" vào ô search
2. Chờ 500ms → hiển thị dropdown 5 kết quả
3. Click kết quả → map zoom đến vị trí
4. Tự động điền:
   - **Khu vực**: Đà Nẵng
   - **Địa chỉ**: Trần Đại Nghĩa, Phường Ngũ Hành Sơn, Thành phố Đà Nẵng, Việt Nam
   - **Tọa độ**: 16.054290, 108.202311

### Kịch bản 2: Click trên map
1. Click bất kỳ vị trí trên map
2. Marker hiển thị tại vị trí click
3. Nominatim API lấy địa chỉ tiếng Việt
4. Tự động điền tương tự kịch bản 1

### Kịch bản 3: Edit hotel
1. Mở trang edit → MapPicker load với vị trí cũ
2. Marker hiển thị đúng vị trí
3. Hiển thị khu vực + địa chỉ đã lưu
4. Người dùng có thể search hoặc click để thay đổi

## Lợi ích

### 1. UX tốt hơn
- ✅ Dropdown có background rõ ràng, không chồng chữ
- ✅ Hiển thị khu vực riêng biệt, dễ nhìn
- ✅ Địa chỉ đầy đủ bằng tiếng Việt

### 2. Data structure chuẩn
- ✅ `location`: Tỉnh/thành phố → dùng cho filter, search
- ✅ `address`: Địa chỉ đầy đủ → hiển thị chi tiết
- ✅ `latitude`/`longitude`: Số → Google Maps chính xác

### 3. Free & Reliable
- ✅ Nominatim OpenStreetMap - không cần API key
- ✅ Hỗ trợ tiếng Việt tốt
- ✅ Rate limit 1 req/s - đủ với debounce 500ms

### 4. Tương thích ngược
- ✅ Database schema không đổi
- ✅ Backend API không đổi
- ✅ Flutter app không cần update

## Testing Checklist

- [ ] Tìm kiếm "Hà Nội" → thấy 5 kết quả → click → location="Hà Nội"
- [ ] Tìm kiếm "Đà Nẵng" → click → location="Đà Nẵng"
- [ ] Click map ở Sài Gòn → location="TP. Hồ Chí Minh"
- [ ] Tạo hotel mới → lưu → kiểm tra database có đầy đủ location, address, lat, lng
- [ ] Edit hotel → thấy marker đúng vị trí → thay đổi → save → reload → vẫn đúng
- [ ] Dropdown không bị chồng chữ với text phía sau
- [ ] Theme sáng/tối đều có background rõ ràng

## Files đã sửa

1. `supplier/src/components/common/MapPicker.tsx` - 303 lines
2. `supplier/src/pages/Service/Hotel/HotelCreatePage.tsx` - Updated MapPicker usage
3. `supplier/src/pages/Service/Hotel/HotelEditPage.tsx` - Updated MapPicker usage

## Errors đã fix

- ✅ `LocationData` not exported → Added export interface
- ✅ `initialLocation` type null vs undefined → Changed to undefined
- ✅ Dropdown text overlap → Added solid background
- ✅ Location extraction missing → Added extractLocation() function
- ✅ TypeScript Libraries type error → import type { Libraries }

Hoàn tất! 🎉
