# Dynamic Rating Calculation Implementation

## Tổng quan
Thay vì lưu trữ `rating_average` trong database, giờ rating được tính động từ bảng reviews của từng dịch vụ. Nếu dịch vụ chưa có review nào, trả về `null` để frontend có thể ẩn phần hiển thị rating.

## Review Models
Mỗi review có trường `rating` (Integer 1-5) và `reviewStatus` (approved/rejected):
- **TourReview**: Rating cho tours
- **RestaurantReview**: Rating cho restaurants  
- **HotelReview**: Rating cho hotels
- **AttractionReview**: Chưa có (chuẩn bị cho tương lai)

## Thay đổi Backend

### 1. Review Repositories
Thêm method `calculateAverageRating` vào:
- `TourReviewRepository.java`
- `RestaurantReviewRepository.java`
- `HotelReviewRepository.java`

```java
@Query("SELECT AVG(r.rating) FROM [ReviewType] r WHERE r.[service].[serviceId] = :id AND r.reviewStatus = 'approved'")
Double calculateAverageRating(@Param("id") Integer id);
```

**Lưu ý**: 
- Chỉ tính reviews có status = 'approved'
- Trả về `Double` (null nếu chưa có review)

### 2. DTOs
Thêm field `ratingAverage` vào:
- `TourDTO.java`
- `RestaurantDTO.java`
- `HotelDTO.java`
- `AttractionDTO.java`

```java
// Calculated field - null nếu chưa có review
private Double ratingAverage;
```

### 3. Service Layer

#### TourService.java
```java
private TourDTO toDTO(Tour t) {
    // Calculate rating average from reviews (null if no reviews)
    Double ratingAverage = tourReviewRepository.calculateAverageRating(t.getTourId());
    
    return TourDTO.builder()
        // ... other fields ...
        .ratingAverage(ratingAverage)
        .build();
}
```

#### RestaurantService.java
```java
private RestaurantDTO toDTO(Restaurant r) {
    Double ratingAverage = restaurantReviewRepository.calculateAverageRating(r.getRestaurantId());
    
    return RestaurantDTO.builder()
        // ... other fields ...
        .ratingAverage(ratingAverage)
        .build();
}
```

#### HotelService.java
```java
private HotelDTO convertToDTO(Hotel hotel) {
    Double ratingAverage = hotelReviewRepository.calculateAverageRating(hotel.getHotelId());
    
    return HotelDTO.builder()
        // ... other fields ...
        .ratingAverage(ratingAverage)
        .build();
}
```

#### AttractionService.java
```java
private AttractionDTO toDTO(Attraction a) {
    return AttractionDTO.builder()
        // ... other fields ...
        .ratingAverage(null) // Chưa có review system
        .build();
}
```

### 4. SearchService.java
Inject các ReviewRepository và cập nhật các toDTO methods:

```java
private final HotelReviewRepository hotelReviewRepository;
private final RestaurantReviewRepository restaurantReviewRepository;
private final TourReviewRepository tourReviewRepository;

private HotelDTO toHotelDTO(Hotel h) {
    Double ratingAverage = hotelReviewRepository.calculateAverageRating(h.getHotelId());
    return HotelDTO.builder()
        // ... fields ...
        .ratingAverage(ratingAverage)
        .build();
}

// Tương tự cho toRestaurantDTO và toTourDTO
```

## Frontend Behavior

### Khi ratingAverage = null
Frontend nên ẩn hoàn toàn phần hiển thị rating:

```dart
// Flutter example
if (service.ratingAverage != null) {
  Text('Rating: ${service.ratingAverage}');
  // Show star icons
} else {
  // Don't show rating section at all
}
```

```typescript
// React/TypeScript example
{service.ratingAverage && (
  <div className="rating">
    <span>Rating: {service.ratingAverage.toFixed(1)}</span>
    {/* Star icons */}
  </div>
)}
```

### Khi ratingAverage có giá trị
Hiển thị rating với format phù hợp (VD: 4.5 sao)

## Database Migration

Sau khi code hoạt động ổn định, chạy migration để xóa cột `rating_average`:

```sql
-- File: database/migrations/remove_unused_fields.sql

ALTER TABLE tours DROP COLUMN rating_average;
ALTER TABLE restaurants DROP COLUMN rating_average;
ALTER TABLE attractions DROP COLUMN rating_average;
ALTER TABLE hotels DROP COLUMN rating_average;
```

## Performance Considerations

### Ưu điểm
- ✅ Luôn hiển thị rating chính xác, realtime
- ✅ Không cần cập nhật rating khi có review mới
- ✅ Không có data inconsistency

### Nhược điểm & Giải pháp
- ⚠️ Query AVG mỗi lần lấy service → Cân nhắc caching nếu cần
- ⚠️ N+1 query khi list nhiều services → Có thể optimize bằng batch query hoặc JOIN

### Optimization Ideas (Optional)
1. **Redis Cache**: Cache rating trong 5-10 phút
2. **Batch Query**: Fetch ratings cho nhiều services cùng lúc
3. **JOIN Query**: Tính AVG ngay trong repository query chính

## Testing Checklist
- [ ] GET single service (tour/hotel/restaurant/attraction) - rating hiển thị đúng
- [ ] GET list services - rating hiển thị đúng cho tất cả
- [ ] Service chưa có review - ratingAverage = null
- [ ] Service có reviews nhưng tất cả rejected - ratingAverage = null
- [ ] Service có reviews approved - ratingAverage = AVG(ratings)
- [ ] Search API - rating hiển thị đúng
- [ ] Frontend ẩn rating khi null
- [ ] Frontend hiển thị rating khi có giá trị

## Files Changed

### Repositories
- `TourReviewRepository.java` - Added calculateAverageRating
- `RestaurantReviewRepository.java` - Added calculateAverageRating
- `HotelReviewRepository.java` - Added calculateAverageRating

### DTOs
- `TourDTO.java` - Added ratingAverage field
- `RestaurantDTO.java` - Added ratingAverage field
- `HotelDTO.java` - Added ratingAverage field
- `AttractionDTO.java` - Added ratingAverage field

### Services
- `TourService.java` - Calculate rating in toDTO
- `RestaurantService.java` - Calculate rating in toDTO
- `HotelService.java` - Calculate rating in convertToDTO
- `AttractionService.java` - Set ratingAverage to null
- `SearchService.java` - Inject repositories, calculate in all toDTO methods

## Next Steps
1. Test các API endpoints để verify rating calculation
2. Kiểm tra frontend có xử lý null đúng không
3. Monitor performance khi list nhiều services
4. Cân nhắc caching nếu cần thiết
5. Chạy database migration khi mọi thứ stable

## Notes
- Reviews với status = 'rejected' **KHÔNG** được tính vào rating
- Chỉ reviews với status = 'approved' được tính
- AVG query tự động skip null values
- AttractionReview chưa có → Attraction.ratingAverage luôn null
