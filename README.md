# TRIPFINITY - Ứng Dụng Du Lịch Thông Minh

## MỤC LỤC
- [PHẦN 1: DANH SÁCH CÁC TRANG GIAO DIỆN](#phần-1-danh-sách-các-trang-giao-diện)
  - [A. Flutter Mobile App](#a-flutter-mobile-app)
  - [B. Supplier Web (React)](#b-supplier-web-react)
- [PHẦN 2: CHI TIẾT CHỨC NĂNG](#phần-2-chi-tiết-chức-năng)
- [PHẦN 3: CẤU TRÚC BẢNG CƠ SỞ DỮ LIỆU](#phần-3-cấu-trúc-bảng-cơ-sở-dữ-liệu)

---

# PHẦN 1: DANH SÁCH CÁC TRANG GIAO DIỆN

## A. Flutter Mobile App

### 1. Xác thực & Giới thiệu
| Trang | Chức năng |
|-------|-----------|
| `onboarding_screen` | Giới thiệu ứng dụng cho người dùng mới |
| `login_screen` | Đăng nhập tài khoản |
| `register_screen` | Đăng ký tài khoản mới |
| `forget_account_screen` | Khôi phục mật khẩu |

### 2. Trang chính & Tổng quan
| Trang | Chức năng |
|-------|-----------|
| `home_screen` | Trang chủ hiển thị các dịch vụ nổi bật, gợi ý AI |
| `dashboard_user_screen` | Tổng quan thông tin người dùng |
| `profile_view_user_screen` | Xem và chỉnh sửa thông tin cá nhân |
| `option_setting_screen` | Cài đặt ứng dụng |
| `terms_policie_screen` | Điều khoản và chính sách |
| `contact_user_screen` | Liên hệ hỗ trợ |

### 3. Tìm kiếm
| Trang | Chức năng |
|-------|-----------|
| `general_search_screen` | Tìm kiếm tổng hợp tất cả dịch vụ |
| `search_overview_screen` | Xem kết quả tìm kiếm tổng quan |
| `search_map_screen` | Tìm kiếm trên bản đồ |
| `nearby_search_screen` | Tìm kiếm dịch vụ gần vị trí hiện tại |
| `search_history_screen` | Lịch sử tìm kiếm |

### 4. Tour
| Trang | Chức năng |
|-------|-----------|
| `tour_service_overview_search_screen` | Tìm kiếm và danh sách tour |
| `tour_service_detail_overview_screen` | Chi tiết tour |
| `tour_booking_checkout_screen` | Đặt tour và thanh toán |
| `tour_reviews_list_screen` | Danh sách đánh giá tour |
| `detail_tour_review_user_screen` | Chi tiết đánh giá tour của người dùng |

### 5. Khách sạn (Hotel)
| Trang | Chức năng |
|-------|-----------|
| `hotel_overview_search_screen` | Tìm kiếm và danh sách khách sạn |
| `hotel_detail_overview_screen` | Chi tiết khách sạn |
| `hotel_booking_checkout_screen` | Đặt phòng và thanh toán |
| `hotel_reviews_list_screen` | Danh sách đánh giá khách sạn |
| `detail_hotel_review_user_screen` | Chi tiết đánh giá khách sạn của người dùng |

### 6. Điểm tham quan (Attraction)
| Trang | Chức năng |
|-------|-----------|
| `attractions_overview_search_screen` | Tìm kiếm và danh sách điểm tham quan |
| `attractions_overview_detail_screen` | Chi tiết điểm tham quan |
| `attraction_booking_checkout_screen` | Đặt vé và thanh toán |
| `attraction_reviews_list_screen` | Danh sách đánh giá điểm tham quan |
| `detail_attraction_review_user_screen` | Chi tiết đánh giá điểm tham quan của người dùng |

### 7. Nhà hàng (Restaurant)
| Trang | Chức năng |
|-------|-----------|
| `restaurant_overview_search_screen` | Tìm kiếm và danh sách nhà hàng |
| `restaurant_overview_detail_screen` | Chi tiết nhà hàng |
| `restaurant_booking_checkout_screen` | Đặt bàn và thanh toán |
| `restaurant_reviews_list_screen` | Danh sách đánh giá nhà hàng |
| `detail_restaurant_review_user_screen` | Chi tiết đánh giá nhà hàng của người dùng |

### 8. Quản lý đặt chỗ
| Trang | Chức năng |
|-------|-----------|
| `pending_bookings_screen` | Danh sách đặt chỗ đang chờ xử lý |
| `confirmed_bookings_screen` | Danh sách đặt chỗ đã xác nhận |
| `payment_webview_screen` | Webview thanh toán ZaloPay |

### 9. Chuyến đi (Trip)
| Trang | Chức năng |
|-------|-----------|
| `trip_user_screen` | Danh sách chuyến đi của người dùng |
| `detail_trip_user_screen` | Chi tiết chuyến đi |
| `introduction_trip_screen` | Giới thiệu tính năng chuyến đi |
| `detail_trip_review_user_screen` | Đánh giá chuyến đi |

### 10. Blog
| Trang | Chức năng |
|-------|-----------|
| `blogs_screen` | Danh sách bài viết blog |
| `blog_detail_screen` | Chi tiết bài viết |
| `post_user_screen` | Bài viết của người dùng |
| `post_detail_screen` | Chi tiết bài đăng |

### 11. Chat & Hỗ trợ
| Trang | Chức năng |
|-------|-----------|
| `chat_help_bot_screen` | Chat với AI Bot hỗ trợ |
| `chat_with_provider_screen` | Chat với nhà cung cấp dịch vụ |
| `select_provider_chat_screen` | Chọn nhà cung cấp để chat |

### 12. Thông báo & Điểm thưởng
| Trang | Chức năng |
|-------|-----------|
| `notification_screen` | Danh sách thông báo |
| `badges_and_points_user_screen` | Huy hiệu và điểm thưởng |

---

## B. Supplier Web (React)

### 1. Xác thực
| Trang | Chức năng |
|-------|-----------|
| `SupplierLoginPage` | Đăng nhập nhà cung cấp |
| `SupplierRegisterPage` | Đăng ký tài khoản nhà cung cấp |
| `SupplierForgetAccountPage` | Khôi phục mật khẩu |
| `ProviderInfoPage` | Cập nhật thông tin nhà cung cấp |

### 2. Trang chính
| Trang | Chức năng |
|-------|-----------|
| `SupplierHomePage` | Dashboard tổng quan nhà cung cấp |
| `ProfileProviderPage` | Thông tin hồ sơ nhà cung cấp |
| `NotificationListPage` | Danh sách thông báo |
| `ListingsPage` | Quản lý tất cả dịch vụ |

### 3. Quản lý Tour
| Trang | Chức năng |
|-------|-----------|
| `DashboardTourPage` | Dashboard thống kê tour |
| `TourListPage` | Danh sách tour |
| `TourCreatePage` | Tạo tour mới |
| `TourEditPage` | Chỉnh sửa tour |
| `TourViewPage` | Xem chi tiết tour |
| `ListTourBookingPage` | Danh sách đặt tour |
| `TourBookingViewPage` | Chi tiết đơn đặt tour |
| `AllReviewsPage` | Tất cả đánh giá tour |
| `RecentReviewsPage` | Đánh giá tour gần đây |
| `ReviewDetailPage` | Chi tiết đánh giá tour |

### 4. Quản lý Khách sạn
| Trang | Chức năng |
|-------|-----------|
| `DashboardHotelPage` | Dashboard thống kê khách sạn |
| `ListHotelPage` | Danh sách khách sạn |
| `HotelCreatePage` | Tạo khách sạn mới |
| `HotelEditPage` | Chỉnh sửa khách sạn |
| `HotelViewPage` | Xem chi tiết khách sạn |
| `ListBookingPage` | Danh sách đặt phòng |
| `HotelBookingViewPage` | Chi tiết đơn đặt phòng |
| `AllReviewsPage` | Tất cả đánh giá khách sạn |
| `RecentReviewsPage` | Đánh giá khách sạn gần đây |
| `ReviewDetailPage` | Chi tiết đánh giá khách sạn |

### 5. Quản lý Điểm tham quan
| Trang | Chức năng |
|-------|-----------|
| `DashboardAttractionPage` | Dashboard thống kê điểm tham quan |
| `ListAttractionPage` | Danh sách điểm tham quan |
| `AttractionCreatePage` | Tạo điểm tham quan mới |
| `AttractionEditPage` | Chỉnh sửa điểm tham quan |
| `AttractionViewPage` | Xem chi tiết điểm tham quan |
| `ListAttractionBookingPage` | Danh sách đặt vé |
| `AttractionBookingViewPage` | Chi tiết đơn đặt vé |
| `AllReviewsPage` | Tất cả đánh giá điểm tham quan |
| `RecentReviewsPage` | Đánh giá điểm tham quan gần đây |
| `ReviewDetailPage` | Chi tiết đánh giá điểm tham quan |

### 6. Quản lý Nhà hàng
| Trang | Chức năng |
|-------|-----------|
| `DashboardRestaurantPage` | Dashboard thống kê nhà hàng |
| `ListRestaurantPage` | Danh sách nhà hàng |
| `RestaurantCreatePage` | Tạo nhà hàng mới |
| `RestaurantEditPage` | Chỉnh sửa nhà hàng |
| `RestaurantViewPage` | Xem chi tiết nhà hàng |
| `ListRestaurantBookingPage` | Danh sách đặt bàn |
| `RestaurantBookingViewPage` | Chi tiết đơn đặt bàn |
| `AllReviewsPage` | Tất cả đánh giá nhà hàng |
| `RecentReviewsPage` | Đánh giá nhà hàng gần đây |
| `ReviewDetailPage` | Chi tiết đánh giá nhà hàng |

### 7. Blog
| Trang | Chức năng |
|-------|-----------|
| `BlogsPage` | Danh sách bài viết blog |
| `CreateBlogPage` | Tạo bài viết mới |
| `EditBlogPage` | Chỉnh sửa bài viết |

### 8. Tin nhắn
| Trang | Chức năng |
|-------|-----------|
| `MessagesPage` | Quản lý tin nhắn với khách hàng |

---

# PHẦN 2: CHI TIẾT CHỨC NĂNG

## 1. Xác thực & Quản lý tài khoản

### 1.1 Đăng ký người dùng
- **Mô tả**: Cho phép người dùng tạo tài khoản mới với email, mật khẩu và thông tin cá nhân. Hỗ trợ đăng ký qua Google OAuth.
- **Bảng CSDL liên quan**: `users`

### 1.2 Đăng nhập
- **Mô tả**: Xác thực người dùng bằng email/mật khẩu hoặc Google OAuth. Hệ thống sử dụng JWT token để quản lý phiên đăng nhập.
- **Bảng CSDL liên quan**: `users`

### 1.3 Đăng ký nhà cung cấp (Provider)
- **Mô tả**: Cho phép nhà cung cấp dịch vụ đăng ký tài khoản để quản lý dịch vụ du lịch của họ.
- **Bảng CSDL liên quan**: `providers`

### 1.4 Khôi phục mật khẩu
- **Mô tả**: Gửi email chứa liên kết đặt lại mật khẩu khi người dùng quên mật khẩu.
- **Bảng CSDL liên quan**: `users`, `providers`

### 1.5 Quản lý hồ sơ người dùng
- **Mô tả**: Cho phép người dùng xem và cập nhật thông tin cá nhân như tên, avatar, số điện thoại.
- **Bảng CSDL liên quan**: `users`

---

## 2. Quản lý Tour

### 2.1 Xem danh sách Tour
- **Mô tả**: Hiển thị danh sách các tour du lịch với bộ lọc theo khu vực, giá, độ khó, loại tour. Hỗ trợ tìm kiếm và phân trang.
- **Bảng CSDL liên quan**: `tours`, `areas`

### 2.2 Xem chi tiết Tour
- **Mô tả**: Hiển thị thông tin chi tiết tour bao gồm: mô tả, lịch trình, giá, hình ảnh, địa điểm trên bản đồ, đánh giá.
- **Bảng CSDL liên quan**: `tours`, `tour_reviews`, `tour_review_aspects`, `areas`

### 2.3 Đặt Tour
- **Mô tả**: Cho phép người dùng đặt tour với số lượng người, ngày khởi hành. Tính toán tổng chi phí và tạo đơn đặt hàng.
- **Bảng CSDL liên quan**: `tour_bookings`, `tour_payments`, `tours`

### 2.4 Thanh toán Tour
- **Mô tả**: Xử lý thanh toán đơn đặt tour qua các phương thức: ZaloPay, thanh toán tại quầy. Cập nhật trạng thái đơn hàng sau khi thanh toán thành công.
- **Bảng CSDL liên quan**: `tour_payments`, `tour_bookings`

### 2.5 Đánh giá Tour
- **Mô tả**: Cho phép người dùng đánh giá tour sau khi hoàn thành với điểm số theo các tiêu chí: hướng dẫn viên, giá trị, an toàn, thú vị, lịch trình. Hỗ trợ đính kèm hình ảnh.
- **Bảng CSDL liên quan**: `tour_reviews`, `tour_review_aspects`

### 2.6 Quản lý Tour (Provider)
- **Mô tả**: Nhà cung cấp có thể tạo, chỉnh sửa, xóa, ẩn/hiện tour. Quản lý danh sách đặt tour và xác nhận đơn hàng.
- **Bảng CSDL liên quan**: `tours`, `tour_bookings`, `providers`

---

## 3. Quản lý Khách sạn (Hotel)

### 3.1 Xem danh sách Khách sạn
- **Mô tả**: Hiển thị danh sách khách sạn với bộ lọc theo khu vực, giá, số sao, loại hình lưu trú, tiện nghi.
- **Bảng CSDL liên quan**: `hotels`, `areas`

### 3.2 Xem chi tiết Khách sạn
- **Mô tả**: Hiển thị thông tin chi tiết khách sạn: mô tả, tiện nghi, phòng, giá, vị trí trên bản đồ, chính sách, đánh giá.
- **Bảng CSDL liên quan**: `hotels`, `hotel_reviews`, `hotel_review_aspects`, `areas`

### 3.3 Đặt phòng Khách sạn
- **Mô tả**: Cho phép người dùng đặt phòng với ngày check-in/check-out, số phòng, số giường. Tính toán tổng chi phí theo số đêm.
- **Bảng CSDL liên quan**: `hotel_bookings`, `hotel_payments`, `hotels`

### 3.4 Thanh toán Khách sạn
- **Mô tả**: Xử lý thanh toán đặt phòng qua ZaloPay hoặc thanh toán tại quầy. Cập nhật trạng thái booking.
- **Bảng CSDL liên quan**: `hotel_payments`, `hotel_bookings`

### 3.5 Đánh giá Khách sạn
- **Mô tả**: Cho phép đánh giá khách sạn với các tiêu chí: sạch sẽ, dịch vụ, giá trị, vị trí, tiện nghi. Hỗ trợ đính kèm hình ảnh.
- **Bảng CSDL liên quan**: `hotel_reviews`, `hotel_review_aspects`

### 3.6 Quản lý Khách sạn (Provider)
- **Mô tả**: Nhà cung cấp quản lý khách sạn: tạo/sửa/xóa khách sạn, quản lý phòng, xác nhận đặt phòng.
- **Bảng CSDL liên quan**: `hotels`, `hotel_bookings`, `providers`

---

## 4. Quản lý Điểm tham quan (Attraction)

### 4.1 Xem danh sách Điểm tham quan
- **Mô tả**: Hiển thị danh sách điểm tham quan với bộ lọc theo khu vực, loại hình (văn hóa, giải trí, lịch sử, tự nhiên...), giá.
- **Bảng CSDL liên quan**: `attractions`, `areas`

### 4.2 Xem chi tiết Điểm tham quan
- **Mô tả**: Hiển thị thông tin chi tiết: mô tả, giờ mở cửa, giá vé, vị trí, phù hợp cho đối tượng nào, đánh giá.
- **Bảng CSDL liên quan**: `attractions`, `attraction_reviews`, `attraction_review_aspects`, `areas`

### 4.3 Đặt vé Điểm tham quan
- **Mô tả**: Cho phép đặt vé tham quan với số lượng người, ngày tham quan.
- **Bảng CSDL liên quan**: `attraction_bookings`, `attraction_payments`, `attractions`

### 4.4 Thanh toán Điểm tham quan
- **Mô tả**: Xử lý thanh toán vé tham quan qua ZaloPay hoặc thanh toán tại quầy.
- **Bảng CSDL liên quan**: `attraction_payments`, `attraction_bookings`

### 4.5 Đánh giá Điểm tham quan
- **Mô tả**: Cho phép đánh giá với các tiêu chí: vị trí, giá trị, trải nghiệm, dịch vụ. Hỗ trợ đính kèm hình ảnh.
- **Bảng CSDL liên quan**: `attraction_reviews`, `attraction_review_aspects`

### 4.6 Quản lý Điểm tham quan (Provider)
- **Mô tả**: Nhà cung cấp quản lý điểm tham quan: tạo/sửa/xóa, quản lý đặt vé, xác nhận đơn.
- **Bảng CSDL liên quan**: `attractions`, `attraction_bookings`, `providers`

---

## 5. Quản lý Nhà hàng (Restaurant)

### 5.1 Xem danh sách Nhà hàng
- **Mô tả**: Hiển thị danh sách nhà hàng với bộ lọc theo khu vực, loại ẩm thực, chế độ ăn kiêng, mức giá.
- **Bảng CSDL liên quan**: `restaurants`, `areas`

### 5.2 Xem chi tiết Nhà hàng
- **Mô tả**: Hiển thị thông tin chi tiết: menu, giờ mở cửa, loại ẩm thực, chế độ ăn hỗ trợ, vị trí, đánh giá.
- **Bảng CSDL liên quan**: `restaurants`, `restaurant_reviews`, `restaurant_review_aspects`, `areas`

### 5.3 Đặt bàn Nhà hàng
- **Mô tả**: Cho phép đặt bàn với ngày, giờ, số người.
- **Bảng CSDL liên quan**: `restaurant_bookings`, `restaurant_payments`, `restaurants`

### 5.4 Thanh toán Nhà hàng
- **Mô tả**: Xử lý thanh toán đặt bàn qua ZaloPay hoặc thanh toán tại quầy.
- **Bảng CSDL liên quan**: `restaurant_payments`, `restaurant_bookings`

### 5.5 Đánh giá Nhà hàng
- **Mô tả**: Cho phép đánh giá với các tiêu chí: đồ ăn, dịch vụ, không gian, giá trị. Hỗ trợ đính kèm hình ảnh.
- **Bảng CSDL liên quan**: `restaurant_reviews`, `restaurant_review_aspects`

### 5.6 Quản lý Nhà hàng (Provider)
- **Mô tả**: Nhà cung cấp quản lý nhà hàng: tạo/sửa/xóa, quản lý đặt bàn, xác nhận đơn.
- **Bảng CSDL liên quan**: `restaurants`, `restaurant_bookings`, `providers`

---

## 6. Tìm kiếm

### 6.1 Tìm kiếm tổng hợp
- **Mô tả**: Tìm kiếm tất cả loại dịch vụ (tour, khách sạn, điểm tham quan, nhà hàng) theo từ khóa và bộ lọc.
- **Bảng CSDL liên quan**: `tours`, `hotels`, `attractions`, `restaurants`, `areas`

### 6.2 Tìm kiếm trên bản đồ
- **Mô tả**: Hiển thị các dịch vụ trên bản đồ Google Maps, cho phép lọc theo loại và khu vực.
- **Bảng CSDL liên quan**: `tours`, `hotels`, `attractions`, `restaurants`

### 6.3 Tìm kiếm gần vị trí
- **Mô tả**: Tìm các dịch vụ gần vị trí hiện tại của người dùng dựa trên tọa độ GPS.
- **Bảng CSDL liên quan**: `tours`, `hotels`, `attractions`, `restaurants`

### 6.4 Lịch sử tìm kiếm
- **Mô tả**: Lưu và hiển thị lịch sử tìm kiếm của người dùng để dễ dàng tìm kiếm lại.
- **Bảng CSDL liên quan**: `search_history`

---

## 7. Quản lý chuyến đi (Trip)

### 7.1 Tạo chuyến đi
- **Mô tả**: Cho phép người dùng tạo kế hoạch chuyến đi với tên, ngày bắt đầu/kết thúc, ảnh bìa.
- **Bảng CSDL liên quan**: `trips`

### 7.2 Quản lý lịch trình
- **Mô tả**: Thêm các dịch vụ (tour, khách sạn, điểm tham quan, nhà hàng) vào lịch trình theo từng ngày. Sắp xếp thứ tự các hoạt động.
- **Bảng CSDL liên quan**: `trips`, `trip_itineraries`, `trip_itinerary_items`

### 7.3 Xem danh sách chuyến đi
- **Mô tả**: Hiển thị danh sách các chuyến đi của người dùng theo trạng thái: đang diễn ra, đã hoàn thành, đã hủy.
- **Bảng CSDL liên quan**: `trips`

### 7.4 Tải xuống lịch trình
- **Mô tả**: Xuất lịch trình chuyến đi ra file để lưu trữ hoặc chia sẻ.
- **Bảng CSDL liên quan**: `trips`, `trip_itineraries`, `itineraries_downloads`

---

## 8. Yêu thích (Favorites)

### 8.1 Thêm vào yêu thích
- **Mô tả**: Cho phép người dùng đánh dấu yêu thích các dịch vụ (tour, khách sạn, điểm tham quan, nhà hàng) để xem lại sau.
- **Bảng CSDL liên quan**: `user_favorites`

### 8.2 Xem danh sách yêu thích
- **Mô tả**: Hiển thị danh sách các dịch vụ đã yêu thích, phân loại theo loại dịch vụ.
- **Bảng CSDL liên quan**: `user_favorites`, `tours`, `hotels`, `attractions`, `restaurants`

---

## 9. Đánh giá & Phản hồi

### 9.1 Like đánh giá
- **Mô tả**: Cho phép người dùng like các đánh giá hữu ích.
- **Bảng CSDL liên quan**: `review_likes`

### 9.2 Trả lời đánh giá
- **Mô tả**: Cho phép nhà cung cấp trả lời đánh giá của khách hàng.
- **Bảng CSDL liên quan**: `review_replies`

### 9.3 Báo cáo đánh giá
- **Mô tả**: Cho phép người dùng báo cáo đánh giá vi phạm.
- **Bảng CSDL liên quan**: `review_reports`

---

## 10. Blog

### 10.1 Xem danh sách bài viết
- **Mô tả**: Hiển thị danh sách bài viết blog về du lịch từ nhà cung cấp.
- **Bảng CSDL liên quan**: `blogs`

### 10.2 Xem chi tiết bài viết
- **Mô tả**: Hiển thị nội dung chi tiết bài viết blog.
- **Bảng CSDL liên quan**: `blogs`

### 10.3 Quản lý Blog (Provider)
- **Mô tả**: Nhà cung cấp có thể tạo, chỉnh sửa, xóa bài viết blog.
- **Bảng CSDL liên quan**: `blogs`, `providers`

---

## 11. Chat & Tin nhắn

### 11.1 Chat với AI Bot
- **Mô tả**: Chat với AI chatbot để được hỗ trợ lập kế hoạch du lịch, gợi ý địa điểm, trả lời câu hỏi về dịch vụ.
- **Bảng CSDL liên quan**: Không (xử lý qua AI model riêng)

### 11.2 Chat với nhà cung cấp
- **Mô tả**: Cho phép người dùng chat trực tiếp với nhà cung cấp dịch vụ để hỏi thông tin, hỗ trợ đặt chỗ.
- **Bảng CSDL liên quan**: `conversations`, `conversation_messages`

---

## 12. Thông báo

### 12.1 Thông báo đẩy (Push Notification)
- **Mô tả**: Gửi thông báo đẩy đến thiết bị người dùng về trạng thái đặt chỗ, khuyến mãi, cập nhật từ nhà cung cấp.
- **Bảng CSDL liên quan**: `notifications`

### 12.2 Xem danh sách thông báo
- **Mô tả**: Hiển thị danh sách thông báo trong ứng dụng, đánh dấu đã đọc.
- **Bảng CSDL liên quan**: `notifications`

---

## 13. Điểm thưởng & Huy hiệu

### 13.1 Tích điểm
- **Mô tả**: Người dùng được tích điểm khi đặt dịch vụ, viết đánh giá, hoàn thành chuyến đi.
- **Bảng CSDL liên quan**: `points`

### 13.2 Huy hiệu thành tích
- **Mô tả**: Mở khóa huy hiệu khi đạt các mốc thành tích như số lần đặt, số đánh giá, số chuyến đi.
- **Bảng CSDL liên quan**: `badges`, `user_badges`

---

## 14. Gợi ý AI (Recommendation)

### 14.1 Gợi ý dịch vụ cá nhân hóa
- **Mô tả**: Sử dụng mô hình AI Two-Tower để gợi ý các dịch vụ phù hợp với sở thích và hành vi của người dùng.
- **Bảng CSDL liên quan**: `ai_item_tower`, `user_item_interactions`

### 14.2 Theo dõi hành vi người dùng
- **Mô tả**: Ghi nhận các hành vi của người dùng (xem, click, yêu thích, đặt) để cải thiện gợi ý.
- **Bảng CSDL liên quan**: `user_item_interactions`

---

## 15. Thanh toán

### 15.1 Thanh toán ZaloPay
- **Mô tả**: Tích hợp cổng thanh toán ZaloPay cho tất cả loại dịch vụ. Xử lý callback xác nhận thanh toán.
- **Bảng CSDL liên quan**: `tour_payments`, `hotel_payments`, `attraction_payments`, `restaurant_payments`

### 15.2 Thanh toán tại quầy
- **Mô tả**: Cho phép đặt trước và thanh toán trực tiếp tại nhà cung cấp.
- **Bảng CSDL liên quan**: `tour_payments`, `hotel_payments`, `attraction_payments`, `restaurant_payments`

---

## 16. Quản lý khu vực

### 16.1 Xem danh sách khu vực
- **Mô tả**: Hiển thị các khu vực/tỉnh thành phố có dịch vụ du lịch.
- **Bảng CSDL liên quan**: `areas`

---

# PHẦN 3: CẤU TRÚC BẢNG CƠ SỞ DỮ LIỆU

| STT | Tên bảng | Mô tả |
|-----|----------|-------|
| 1 | `users` | Thông tin người dùng (khách hàng) |
| 2 | `providers` | Thông tin nhà cung cấp dịch vụ |
| 3 | `areas` | Danh sách khu vực/tỉnh thành |
| 4 | `tours` | Thông tin tour du lịch |
| 5 | `tour_bookings` | Đơn đặt tour |
| 6 | `tour_payments` | Thanh toán tour |
| 7 | `tour_reviews` | Đánh giá tour |
| 8 | `tour_review_aspects` | Chi tiết điểm đánh giá tour |
| 9 | `hotels` | Thông tin khách sạn |
| 10 | `hotel_bookings` | Đơn đặt phòng khách sạn |
| 11 | `hotel_payments` | Thanh toán khách sạn |
| 12 | `hotel_reviews` | Đánh giá khách sạn |
| 13 | `hotel_review_aspects` | Chi tiết điểm đánh giá khách sạn |
| 14 | `attractions` | Thông tin điểm tham quan |
| 15 | `attraction_bookings` | Đơn đặt vé tham quan |
| 16 | `attraction_payments` | Thanh toán điểm tham quan |
| 17 | `attraction_reviews` | Đánh giá điểm tham quan |
| 18 | `attraction_review_aspects` | Chi tiết điểm đánh giá điểm tham quan |
| 19 | `restaurants` | Thông tin nhà hàng |
| 20 | `restaurant_bookings` | Đơn đặt bàn nhà hàng |
| 21 | `restaurant_payments` | Thanh toán nhà hàng |
| 22 | `restaurant_reviews` | Đánh giá nhà hàng |
| 23 | `restaurant_review_aspects` | Chi tiết điểm đánh giá nhà hàng |
| 24 | `trips` | Chuyến đi của người dùng |
| 25 | `trip_itineraries` | Lịch trình theo ngày của chuyến đi |
| 26 | `trip_itinerary_items` | Các hoạt động trong lịch trình |
| 27 | `itineraries_downloads` | Lịch sử tải xuống lịch trình |
| 28 | `user_favorites` | Danh sách yêu thích của người dùng |
| 29 | `blogs` | Bài viết blog |
| 30 | `conversations` | Cuộc hội thoại chat |
| 31 | `conversation_messages` | Tin nhắn trong cuộc hội thoại |
| 32 | `notifications` | Thông báo |
| 33 | `points` | Điểm thưởng người dùng |
| 34 | `badges` | Danh sách huy hiệu |
| 35 | `user_badges` | Huy hiệu đã mở khóa của người dùng |
| 36 | `search_history` | Lịch sử tìm kiếm |
| 37 | `review_likes` | Lượt like đánh giá |
| 38 | `review_replies` | Phản hồi đánh giá |
| 39 | `review_reports` | Báo cáo đánh giá vi phạm |
| 40 | `provider_reviews` | Đánh giá nhà cung cấp |
| 41 | `ai_item_tower` | Dữ liệu AI - Features dịch vụ cho hệ thống gợi ý |
| 42 | `user_item_interactions` | Dữ liệu AI - Hành vi tương tác của người dùng |

---

## CÔNG NGHỆ SỬ DỤNG

### Mobile App (Flutter)
- Flutter SDK
- GetX (State Management)
- Firebase (Auth, Messaging, Analytics)
- Google Maps Flutter
- ZaloPay SDK
- Cloudinary (Image Upload)

### Supplier Web (React)
- React + TypeScript
- Vite
- TailwindCSS
- Axios
- React Router

### Backend (Spring Boot)
- Java Spring Boot
- Spring Security + JWT
- Spring Data JPA
- MySQL Database
- Cloudinary Integration
- ZaloPay Integration
- Firebase Cloud Messaging

### AI/ML
- Python
- TensorFlow/Keras
- Two-Tower Recommendation Model
- Chatbot AI

---

*Cập nhật lần cuối: 23/12/2025*
