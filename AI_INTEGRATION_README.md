# Hệ Thống Gợi Ý AI - Hướng Dẫn Triển Khai

## 📋 Tổng Quan

Hệ thống gợi ý AI được tích hợp vào TripFinity với 3 tầng:
1. **Python Flask API** - Chạy AI model (server_model_ai.py)
2. **Java Spring Boot Backend** - API trung gian
3. **Flutter App** - Gọi API khi user đăng nhập

## 🚀 Cách Chạy

### 1. Khởi động Python AI Server

```bash
# Cài đặt dependencies
pip install -r requirements.txt

# Chạy server (port 5000)
python server_model_ai.py
```

Server sẽ chạy tại: `http://localhost:5000`

### 2. Khởi động Backend Java

```bash
cd backend
./mvnw spring-boot:run
```

Backend sẽ chạy tại: `http://localhost:8080`

### 3. Chạy Flutter App

```bash
cd app
flutter run
```

## 🔄 Flow Hoạt Động

```
User Login (Flutter)
    ↓
AuthController.login()
    ↓
_fetchRecommendations(userId) [không chặn flow]
    ↓
Flutter RecommendationService
    ↓
Backend RecommendationController (Java)
    ↓
Backend RecommendationService (WebClient)
    ↓
Python Flask API
    ↓
AI Model (Keras)
    ↓
Trả về danh sách gợi ý
    ↓
Log ra console (Flutter & Backend & Python)
```

## 📝 Logic Gợi Ý

### Case 1: User đã được train trong model
- ✅ Sử dụng profile offline từ model
- 📊 Hiển thị 10-15 items được gợi ý

### Case 2: User mới nhưng có tương tác trong DB
- ⚡ Đọc real-time từ bảng `user_item_interactions`
- 📊 Tính toán profile và chạy model
- 📋 Hiển thị gợi ý dựa trên tương tác gần nhất

### Case 3: User hoàn toàn mới (chưa có tương tác)
- 🆕 Bỏ qua gợi ý (như YouTube)
- ℹ️ Trả về message "Người dùng mới"
- 🚫 Không hiển thị lỗi cho user

## 🔍 Kiểm Tra Log

### Python Console
```
📞 API Request - User ID: 123
✅ TRẠNG THÁI: USER CŨ (Offline Model)
📋 GỢI Ý CHO USER 123:
1. Công viên Lê Văn Tám
   Loại: attraction | Giá: 0 đ | Khoảng cách: 2.3km | Score: 0.8543
```

### Backend Console
```
📞 Backend API Request - Getting recommendations for User ID: 123
✅ Successfully fetched 15 recommendations for User 123
```

### Flutter Console
```
📞 Flutter API Request - Getting recommendations for User ID: 123
✅ Successfully fetched 15 recommendations
  - Công viên Lê Văn Tám (attraction) - 0 đ
  - Nhà hàng ABC (restaurant) - 150,000 đ
```

## 📂 Các File Mới

### Python
- `server_model_ai.py` - Flask API server (đã xóa UI, chỉ API)
- `requirements.txt` - Dependencies

### Backend Java
- `RecommendationController.java` - API endpoint
- `RecommendationService.java` - Service gọi Python API
- `RecommendationResponse.java` - DTO response
- `RecommendationItem.java` - DTO item
- `application.yml` - Thêm config `recommendation.api.url`
- `pom.xml` - Thêm spring-boot-starter-webflux

### Flutter
- `recommendation_service.dart` - Service gọi backend API
- `recommendation_response.dart` - DTO response
- `recommendation_item.dart` - DTO item
- `auth_controller.dart` - Thêm logic gọi API sau login
- `main.dart` - Khởi tạo RecommendationService

## ⚙️ Cấu Hình

### Python Server Port
Mặc định: `5000`
Sửa trong `server_model_ai.py`:
```python
app.run(host='0.0.0.0', port=5000, debug=True)
```

### Backend Connection URL
Mặc định: `http://localhost:5000`
Sửa trong `application.yml`:
```yaml
recommendation:
  api:
    url: http://localhost:5000
```

Hoặc set biến môi trường:
```bash
export RECOMMENDATION_API_URL=http://your-python-server:5000
```

## ✅ Kiểm Tra Lỗi

### Flutter
```bash
cd app
flutter analyze  # ✅ No issues found!
dart fix --apply  # ✅ Nothing to fix!
```

### Backend
- Đã thêm WebFlux dependency vào pom.xml
- Controller và Service đã sẵn sàng

### Python
- Đã xóa ipywidgets và UI
- Chỉ còn Flask API

## 🎯 Testing

### Test Python API trực tiếp
```bash
curl http://localhost:5000/health
curl http://localhost:5000/api/recommendations/123
```

### Test Backend API
```bash
curl http://localhost:8080/api/recommendations/123
```

### Test trong Flutter
Đăng nhập và kiểm tra console log

## 📊 Database

Bảng `user_item_interactions` cần có:
- `user_id`
- `item_id`
- `item_type`
- `action_weight`
- `interaction_timestamp`

## 🔥 Lưu Ý

1. **Không chặn flow đăng nhập** - API gợi ý chạy async, không làm chậm login
2. **Không hiển thị lỗi cho user** - Lỗi chỉ log ra console
3. **User mới được skip** - Không gợi ý nếu chưa có data
4. **Real-time fallback** - Nếu không có trong model, đọc từ DB

## 🐛 Troubleshooting

### Python server không chạy
- Kiểm tra port 5000 đã được sử dụng chưa
- Kiểm tra database connection (MySQL)
- Kiểm tra file model đã tồn tại: `data/tripfinity_recsys_model.keras`

### Backend không kết nối được Python
- Kiểm tra `recommendation.api.url` trong application.yml
- Kiểm tra Python server đang chạy
- Kiểm tra firewall/network

### Flutter không nhận được data
- Kiểm tra backend API endpoint
- Kiểm tra AppConfig.baseUrl trong Flutter
- Kiểm tra log console để debug

## 📞 Support

Nếu gặp vấn đề, kiểm tra log ở cả 3 tầng:
1. Python console (server_model_ai.py)
2. Backend console (Spring Boot)
3. Flutter console (debugPrint)

---
Tạo bởi: TripFinity Team
Ngày: 18/12/2025
