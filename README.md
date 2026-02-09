# 🌟 TRIPFINITY - Ứng dụng Du lịch Thông minh với AI

> **Đồ án tốt nghiệp:** XÂY DỰNG ỨNG DỤNG DU LỊCH TRIPFINITY TÍCH HỢP AI VÀ HỆ THỐNG GỢI Ý THÔNG MINH  
> **Sinh viên thực hiện:** Nguyễn Thành Công

---

## 📋 MỤC LỤC

1. [Giới thiệu dự án](#-giới-thiệu-dự-án)
2. [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
3. [Yêu cầu phiên bản](#-yêu-cầu-phiên-bản)
4. [Cấu hình dự án](#-cấu-hình-dự-án)
5. [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
6. [Chức năng hệ thống](#-chức-năng-hệ-thống)
7. [Build & Deploy](#-build--deploy)
8. [API Endpoints](#-api-endpoints)
9. [Troubleshooting](#-troubleshooting)

---

## 🎯 GIỚI THIỆU DỰ ÁN

**Tripfinity** là ứng dụng du lịch thông minh bao gồm:
- **Mobile App (Flutter)**: Ứng dụng cho khách du lịch
- **Supplier Portal (React)**: Website quản lý cho nhà cung cấp dịch vụ
- **Backend (Spring Boot)**: API Server xử lý nghiệp vụ
- **AI Chatbot (Python/LangChain)**: Chatbot hỗ trợ du lịch thông minh
- **AI Recommendation (Python)**: Hệ thống gợi ý Two-Tower Model

### Tính năng nổi bật:
- 🤖 AI Chatbot hỗ trợ tư vấn du lịch (LangChain + Groq)
- 🎯 Hệ thống gợi ý thông minh (Two-Tower Neural Network)
- 🏨 Đặt phòng khách sạn, nhà hàng, tour, điểm tham quan
- 💳 Thanh toán ZaloPay tích hợp
- 🔔 Push Notification (Firebase)
- 🗺️ Tích hợp Google Maps
- 📱 Đa ngôn ngữ (Tiếng Việt, Tiếng Anh, Tiếng Hàn)

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          TRIPFINITY ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────────────┐    │
│  │ Flutter App  │     │   Supplier   │     │      Backend         │    │
│  │  (Mobile)    │────▶│   (React)    │────▶│   (Spring Boot)      │    │
│  │  Port: N/A   │     │  Port: 5173  │     │    Port: 8080        │    │
│  └──────────────┘     └──────────────┘     └──────────┬───────────┘    │
│         │                    │                        │                │
│         │                    │                        ▼                │
│         │                    │              ┌──────────────────┐       │
│         │                    │              │     MySQL 8.0    │       │
│         │                    │              │    Port: 3306    │       │
│         │                    │              └──────────────────┘       │
│         │                    │                        │                │
│         ▼                    │                        ▼                │
│  ┌──────────────┐           │              ┌──────────────────┐       │
│  │   Chatbot    │───────────┴─────────────▶│   Model AI       │       │
│  │  (FastAPI)   │                          │   (Flask)        │       │
│  │  Port: 8000  │                          │  Port: 5000      │       │
│  └──────────────┘                          └──────────────────┘       │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    EXTERNAL SERVICES                             │   │
│  │  • Firebase (Auth, FCM, Cloud Messaging)                         │   │
│  │  • Cloudinary (Image Storage)                                    │   │
│  │  • Google OAuth2, Google Maps API                                │   │
│  │  • Groq AI (LLM for Chatbot)                                     │   │
│  │  • ZaloPay (Payment Gateway)                                     │   │
│  │  • Ngrok (Tunneling for iOS)                                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 YÊU CẦU PHIÊN BẢN

### Backend (Spring Boot)
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **Java JDK** | `17` | LTS, bắt buộc |
| **Spring Boot** | `3.5.3` | Latest stable |
| **MySQL** | `8.0.33+` | MySQL Connector 8.0.33 |
| **Maven** | `3.8+` | Build tool |
| **Lombok** | `Latest` | Annotation processor |

### Supplier Portal (React + Vite)
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **Node.js** | `18.x` hoặc `20.x` | LTS recommended |
| **npm** | `9.x+` | Đi kèm Node.js |
| **React** | `19.1.0` | Latest |
| **Vite** | `7.0.3` | Build tool |
| **TypeScript** | `5.8.3` | Type checking |
| **TailwindCSS** | `3.3.0` | Styling |

### Flutter App (Mobile)
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **Flutter SDK** | `3.22.1+` | Stable channel |
| **Dart SDK** | `^3.8.1` | Đi kèm Flutter |
| **Android SDK** | `35` | API Level 35 |
| **Kotlin** | `2.1.0` | Android build |
| **Gradle** | `8.9.1` | Android plugin |
| **Java (Android)** | `11` | Compile options |

### AI Services (Python)
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **Python** | `3.10+` | Recommended 3.11 |
| **FastAPI** | `0.118.0` | Chatbot server |
| **Flask** | `3.0.0+` | AI Model server |
| **TensorFlow** | `2.16.1+` | ML framework |
| **PyTorch** | `2.9.0` | Deep learning |
| **LangChain** | `0.1.20` | Chatbot framework |
| **FAISS** | `Latest` | Vector search |

### Database & Services
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **MySQL Server** | `8.0.34` | Docker image |
| **Ngrok** | `Latest` | Tunneling service |

---

## ⚙️ CẤU HÌNH DỰ ÁN

### 📁 1. Backend Configuration

#### File: `backend/src/main/resources/application.yml`

```yaml
# === DATABASE ===
spring:
  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:tripfinity}
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:sqlpass}  # ⚠️ Thay đổi password
```

**Cách lấy cấu hình:**

| Cấu hình | Mô tả | Cách lấy |
|----------|-------|----------|
| `DB_HOST` | MySQL host | Mặc định `localhost` hoặc Docker container name |
| `DB_PORT` | MySQL port | Mặc định `3306` |
| `DB_NAME` | Tên database | Tạo database mới hoặc dùng `tripfinity` |
| `DB_USERNAME` | MySQL username | Mặc định `root` |
| `DB_PASSWORD` | MySQL password | Password bạn đặt khi cài MySQL |

---

#### File: `backend/src/main/java/com/vn/tripfinity/backend/config/CloudinaryConfig.java`

```java
config.put("cloud_name", "tripfinity-img");       // ⚠️ Thay cloud name
config.put("api_key", "411282154756183");         // ⚠️ Thay API key
config.put("api_secret", "vpBe5pBrhJoTYc7VxAXQxHiopQo"); // ⚠️ Thay API secret
```

**Cách lấy Cloudinary credentials:**
1. Đăng ký tài khoản tại: https://cloudinary.com/users/register_free
2. Vào Dashboard: https://console.cloudinary.com/console
3. Copy `Cloud Name`, `API Key`, `API Secret` từ dashboard

---

#### File: `backend/src/main/resources/firebase-service-account.json`

**Cách lấy Firebase Service Account:**
1. Truy cập: https://console.firebase.google.com/
2. Chọn project hoặc tạo mới
3. Vào **Project Settings** → **Service Accounts**
4. Click **Generate new private key**
5. Download file JSON và rename thành `firebase-service-account.json`
6. Copy vào `backend/src/main/resources/`

---

#### File: `backend/src/main/resources/application.yml` - Google OAuth2

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: YOUR_GOOGLE_CLIENT_ID        # ⚠️ Thay client ID
            client-secret: YOUR_GOOGLE_CLIENT_SECRET # ⚠️ Thay client secret
```

**Cách lấy Google OAuth2 credentials:**
1. Truy cập: https://console.cloud.google.com/apis/credentials
2. Tạo project mới hoặc chọn project có sẵn
3. Click **Create Credentials** → **OAuth 2.0 Client IDs**
4. Chọn Application type: **Web application**
5. Thêm Authorized redirect URIs:
   - `http://localhost:8080/login/oauth2/code/google`
6. Copy `Client ID` và `Client Secret`

---

#### File: `backend/src/main/resources/application.yml` - ZaloPay

```yaml
app:
  zalopay:
    appid: 553                            # ⚠️ ZaloPay App ID
    key1: 9phuAOYhan4urywHTh0ndEXiV3pKHr5Q # ⚠️ ZaloPay Key1
    key2: Iyz2habzyr7AG8SgvoBCbKwKi3UzlLi3 # ⚠️ ZaloPay Key2
    endpoint: https://sandbox.zalopay.com.vn/v001/tpe/createorder
    callbackUrl: https://your-ngrok-url.ngrok-free.app/api/zalopay/callback
```

**Cách lấy ZaloPay credentials (Sandbox):**
1. Đăng ký tài khoản merchant: https://docs.zalopay.vn/
2. Truy cập ZaloPay Merchant Portal
3. Lấy `App ID`, `Key1`, `Key2` từ Sandbox environment
4. Đọc tài liệu API: https://docs.zalopay.vn/v2/

---

#### File: `backend/src/main/resources/application.yml` - Email

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com     # ⚠️ Email gửi OTP
    password: your-app-password        # ⚠️ App Password (không phải mật khẩu Gmail)
```

**Cách tạo Gmail App Password:**
1. Bật 2-Factor Authentication cho Gmail
2. Truy cập: https://myaccount.google.com/apppasswords
3. Tạo App Password mới cho "Mail"
4. Copy 16-ký tự password (không có khoảng trắng)

---

### 📁 2. Supplier Portal Configuration

#### File: `supplier/.env`

```env
VITE_GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
VITE_GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

**Cách lấy Google Maps API Key:**
1. Truy cập: https://console.cloud.google.com/apis/library
2. Enable các APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API
3. Vào **Credentials** → **Create Credentials** → **API Key**
4. Restrict API key theo domain (recommended)

---

#### File: `supplier/src/services/api.ts`

```typescript
const API_BASE_URL = "http://localhost:8080/api";  // Backend URL
```

> **Lưu ý:** Supplier chạy trên browser cùng máy với Backend, dùng localhost trực tiếp.

---

### 📁 3. Flutter App Configuration

#### File: `app/lib/config/app_config.dart`

```dart
// === NGROK URL (CHỈ DÀNH CHO iOS) ===
static const String ngrokBackendUrl =
    'https://your-ngrok-url.ngrok-free.dev';  // ⚠️ Cập nhật khi chạy ngrok

// URLs tự động theo platform:
// - Android Emulator: http://10.0.2.2:8080
// - Web: http://localhost:8080
// - iOS: ngrok URL (vì iOS simulator/device không access localhost)
```

---

#### File: `app/lib/firebase_options.dart`

File này được tạo tự động bởi FlutterFire CLI. **Cách tạo:**

```bash
# 1. Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Đăng nhập Firebase
firebase login

# 3. Configure FlutterFire (chạy trong thư mục app/)
cd app
flutterfire configure --project=your-firebase-project-id
```

**Link tài liệu:** https://firebase.flutter.dev/docs/cli/

---

#### File: `app/android/app/google-services.json`

**Cách lấy:**
1. Truy cập Firebase Console: https://console.firebase.google.com/
2. Chọn project → **Project Settings**
3. Trong **Your apps** → click icon Android
4. Download `google-services.json`
5. Copy vào `app/android/app/`

---

#### File: `app/ios/Runner/GoogleService-Info.plist`

**Cách lấy:**
1. Truy cập Firebase Console
2. Trong **Your apps** → click icon iOS
3. Download `GoogleService-Info.plist`
4. Copy vào `app/ios/Runner/`

---

### 📁 4. AI Chatbot Configuration

#### File: `chatbot_tripfinity.py`

```python
# Groq API Key (LLM Provider)
os.environ["GROQ_API_KEY"] = "gsk_YOUR_GROQ_API_KEY"  # ⚠️ Thay API key

# Ngrok Auth Token (nếu dùng internal ngrok)
ngrok.set_auth_token("YOUR_NGROK_AUTH_TOKEN")  # ⚠️ Thay token
```

**Cách lấy Groq API Key:**
1. Đăng ký tại: https://console.groq.com/
2. Vào **API Keys** → **Create API Key**
3. Copy API key (bắt đầu bằng `gsk_`)

**Cách lấy Ngrok Auth Token:**
1. Đăng ký tại: https://ngrok.com/
2. Vào Dashboard: https://dashboard.ngrok.com/get-started/your-authtoken
3. Copy authtoken

---

### 📁 5. AI Model Server Configuration

#### File: `server_model_ai.py`

```python
# Database Configuration
DB_CONFIG = {
    'user': 'root',
    'password': 'sqlpass',      # ⚠️ Thay password MySQL
    'host': 'localhost',
    'database': 'tripfinity',
    'port': 3306
}
```

---

### 📁 6. Ngrok Configuration

#### File: `ngrok_backend.yml`

```yaml
version: "2"
authtoken: YOUR_NGROK_AUTHTOKEN  # ⚠️ Thay authtoken

tunnels:
  backend:
    addr: 8080
    proto: http
```

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT

### Bước 1: Clone Repository

```bash
git clone https://github.com/your-repo/TripfinityProject.git
cd TripfinityProject
```

### Bước 2: Cài đặt Database

**Option A: Dùng Docker (Khuyến nghị)**
```bash
docker-compose up -d db
```

**Option B: Cài MySQL thủ công**
1. Cài MySQL 8.0: https://dev.mysql.com/downloads/mysql/
2. Tạo database:
```sql
CREATE DATABASE tripfinity CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```
3. Import data mẫu:
```bash
mysql -u root -p tripfinity < database/tripfinity_database_2025.sql
```

### Bước 3: Cấu hình Backend

1. Copy và chỉnh sửa file cấu hình:
```bash
cd backend/src/main/resources
# Chỉnh sửa application.yml với database credentials
# Thêm firebase-service-account.json
```

2. Chỉnh sửa CloudinaryConfig.java với credentials của bạn

### Bước 4: Cài đặt Supplier Portal

```bash
cd supplier
npm install
cp .env.example .env
# Chỉnh sửa .env với Google API keys
```

### Bước 5: Cài đặt Flutter App

```bash
cd app
flutter pub get
# Cấu hình Firebase theo hướng dẫn ở trên
```

### Bước 6: Cài đặt Python AI Services

```bash
# Tạo virtual environment (khuyến nghị)
python -m venv venv
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# Cài đặt dependencies
pip install -r requirements.txt
```

### Bước 7: Khởi động tất cả services

**Cách nhanh (Windows):**
```bash
# Chạy tất cả services cùng lúc
start_all.bat
```

**Cách thủ công:**

```bash
# Terminal 1: Backend (Port 8080)
cd backend
mvn spring-boot:run

# Terminal 2: Model AI (Port 5000)
python server_model_ai.py

# Terminal 3: Chatbot (Port 8000)
python chatbot_tripfinity.py

# Terminal 4: Supplier Portal (Port 5173)
cd supplier
npm run dev

# Terminal 5: Flutter App
cd app
flutter run -d android  # hoặc -d chrome cho web
```

---

## 💡 CHỨC NĂNG HỆ THỐNG

### 📱 FLUTTER APP (Người dùng cuối)

#### 🔐 Xác thực & Tài khoản
| Chức năng | Mô tả | File/Screen |
|-----------|-------|-------------|
| Đăng nhập | Email/Password hoặc Google OAuth2 | `login_screen.dart` |
| Đăng ký | Tạo tài khoản mới | `register_screen.dart` |
| Quên mật khẩu | Gửi OTP qua email | `forget_account_screen.dart` |
| Hồ sơ cá nhân | Xem/sửa thông tin cá nhân | `profile_view_user_screen.dart` |
| Điểm thưởng & Huy hiệu | Gamification system | `badges_and_points_user_screen.dart` |

#### 🏨 Dịch vụ Khách sạn
| Chức năng | Mô tả |
|-----------|-------|
| Tìm kiếm khách sạn | Theo địa điểm, giá, tiện nghi, đánh giá |
| Xem chi tiết | Thông tin, hình ảnh, tiện nghi, vị trí trên bản đồ |
| Đặt phòng | Chọn ngày, số lượng phòng, thanh toán |
| Đánh giá | Viết review, đánh giá sao, upload hình ảnh |

#### 🍽️ Dịch vụ Nhà hàng
| Chức năng | Mô tả |
|-----------|-------|
| Tìm kiếm nhà hàng | Theo ẩm thực, giá, khoảng cách |
| Xem menu | Danh sách món ăn, giá |
| Đặt bàn | Chọn thời gian, số người |
| Đánh giá | Review chất lượng đồ ăn, phục vụ |

#### 🎫 Dịch vụ Tour
| Chức năng | Mô tả |
|-----------|-------|
| Tìm kiếm tour | Theo loại tour, địa điểm, thời gian |
| Xem lịch trình | Chi tiết các điểm đến, hoạt động |
| Đặt tour | Chọn ngày khởi hành, số người |
| Đánh giá | Review trải nghiệm tour |

#### 🏛️ Điểm tham quan
| Chức năng | Mô tả |
|-----------|-------|
| Tìm kiếm điểm tham quan | Theo loại, khu vực, giá vé |
| Thông tin chi tiết | Giờ mở cửa, giá vé, hình ảnh |
| Đặt vé | Mua vé trực tuyến |
| Đánh giá | Review điểm tham quan |

#### 🗺️ Chuyến đi & Lịch trình
| Chức năng | Mô tả |
|-----------|-------|
| Tạo chuyến đi | Lên kế hoạch du lịch |
| Quản lý lịch trình | Thêm/sửa/xóa các điểm đến |
| Xem tổng quan | Bản đồ tổng hợp các điểm |

#### 🤖 AI Features
| Chức năng | Mô tả |
|-----------|-------|
| Chatbot hỗ trợ | Tư vấn du lịch bằng AI (LangChain + Groq) |
| Gợi ý thông minh | Two-Tower Recommendation System |
| Tìm kiếm thông minh | Tìm kiếm theo ngữ cảnh |

#### 📝 Blog & Cộng đồng
| Chức năng | Mô tả |
|-----------|-------|
| Đọc blog | Các bài viết về du lịch |
| Viết bài | Chia sẻ trải nghiệm du lịch |

#### 🔔 Thông báo
| Chức năng | Mô tả |
|-----------|-------|
| Push Notification | Thông báo đặt chỗ, khuyến mãi |
| Lịch sử thông báo | Xem các thông báo đã nhận |

#### 💬 Nhắn tin
| Chức năng | Mô tả |
|-----------|-------|
| Chat với nhà cung cấp | Hỏi đáp trực tiếp |
| Lịch sử chat | Xem các cuộc trò chuyện |

#### 💳 Thanh toán
| Chức năng | Mô tả |
|-----------|-------|
| ZaloPay | Thanh toán qua ví ZaloPay |
| Thanh toán tại quầy | Đặt chỗ, thanh toán sau |

---

### 🏪 SUPPLIER PORTAL (Nhà cung cấp)

#### 🔐 Xác thực
| Chức năng | Mô tả | File |
|-----------|-------|------|
| Đăng nhập | Email/Password hoặc Google | `SupplierLoginPage.tsx` |
| Đăng ký | Đăng ký làm nhà cung cấp | `SupplierRegisterPage.tsx` |
| Quên mật khẩu | Reset password | `SupplierForgetAccountPage.tsx` |
| Thông tin cá nhân | Cập nhật profile | `ProviderInfoPage.tsx` |

#### 📊 Dashboard
| Chức năng | Mô tả |
|-----------|-------|
| Thống kê doanh thu | Biểu đồ, báo cáo |
| Lượt đặt chỗ | Số booking theo thời gian |
| Đánh giá | Điểm đánh giá trung bình |

#### 🏨 Quản lý Khách sạn
| Chức năng | File |
|-----------|------|
| Danh sách khách sạn | `ListHotelPage.tsx` |
| Thêm khách sạn | `HotelCreatePage.tsx` |
| Sửa khách sạn | `HotelEditPage.tsx` |
| Xem chi tiết | `HotelViewPage.tsx` |
| Dashboard | `DashboardHotelPage.tsx` |
| Quản lý booking | `ListBookingPage.tsx` |
| Xem chi tiết booking | `HotelBookingViewPage.tsx` |
| Quản lý đánh giá | `AllReviewsPage.tsx`, `RecentReviewsPage.tsx` |

#### 🍽️ Quản lý Nhà hàng
| Chức năng | File |
|-----------|------|
| Danh sách nhà hàng | `ListRestaurantPage.tsx` |
| Thêm nhà hàng | `RestaurantCreatePage.tsx` |
| Sửa nhà hàng | `RestaurantEditPage.tsx` |
| Xem chi tiết | `RestaurantViewPage.tsx` |
| Dashboard | `DashboardRestaurantPage.tsx` |
| Quản lý booking | `ListRestaurantBookingPage.tsx` |
| Xem chi tiết booking | `RestaurantBookingViewPage.tsx` |

#### 🎫 Quản lý Tour
| Chức năng | File |
|-----------|------|
| Danh sách tour | `TourListPage.tsx` |
| Thêm tour | `TourCreatePage.tsx` |
| Sửa tour | `TourEditPage.tsx` |
| Xem chi tiết | `TourViewPage.tsx` |
| Dashboard | `DashboardTourPage.tsx` |
| Quản lý booking | `ListTourBookingPage.tsx` |
| Xem chi tiết booking | `TourBookingViewPage.tsx` |

#### 🏛️ Quản lý Điểm tham quan
| Chức năng | File |
|-----------|------|
| Danh sách | `ListAttractionPage.tsx` |
| Thêm mới | `AttractionCreatePage.tsx` |
| Sửa | `AttractionEditPage.tsx` |
| Xem chi tiết | `AttractionViewPage.tsx` |
| Dashboard | `DashboardAttractionPage.tsx` |
| Quản lý booking | `ListAttractionBookingPage.tsx` |

#### 📝 Quản lý Blog
| Chức năng | File |
|-----------|------|
| Danh sách blog | `BlogsPage.tsx` |
| Viết blog | `CreateBlogPage.tsx` |
| Sửa blog | `EditBlogPage.tsx` |

#### 💬 Nhắn tin
| Chức năng | File |
|-----------|------|
| Chat với khách hàng | `MessagesPage.tsx` |

---

### ⚙️ BACKEND API (Spring Boot)

#### Controllers (API Endpoints)
| Controller | Chức năng |
|------------|-----------|
| `AuthController` | Đăng nhập, đăng ký, OAuth2 |
| `UserController` | Quản lý người dùng |
| `HotelController` | CRUD khách sạn |
| `HotelBookingController` | Đặt phòng khách sạn |
| `HotelReviewController` | Đánh giá khách sạn |
| `RestaurantController` | CRUD nhà hàng |
| `RestaurantBookingController` | Đặt bàn |
| `TourController` | CRUD tour |
| `TourBookingController` | Đặt tour |
| `AttractionController` | CRUD điểm tham quan |
| `AttractionBookingController` | Đặt vé |
| `BlogController` | CRUD blog |
| `ChatController` | Nhắn tin |
| `NotificationController` | Thông báo |
| `FCMController` | Firebase Cloud Messaging |
| `ZaloPayController` | Thanh toán ZaloPay |
| `RecommendationController` | Gợi ý AI |
| `SearchServiceController` | Tìm kiếm |
| `UploadController` | Upload hình ảnh |
| `TripController` | Quản lý chuyến đi |
| `PointsController` | Điểm thưởng |
| `AreaController` | Khu vực/Tỉnh thành |

#### Services (Business Logic)
| Service | Chức năng |
|---------|-----------|
| `CloudinaryService` | Upload/Delete hình ảnh |
| `EmailService` | Gửi email, OTP |
| `FCMService` | Push notification |
| `ZaloPayService` | Tích hợp thanh toán |
| `RecommendationService` | Gọi AI Model |
| `SearchService` | Tìm kiếm đa dịch vụ |

---

### 🤖 AI CHATBOT (Python/FastAPI)

| Chức năng | Mô tả |
|-----------|-------|
| Tư vấn du lịch | Trả lời câu hỏi về địa điểm, khách sạn, tour |
| Tìm kiếm thông minh | Hiểu ngữ cảnh, tìm dịch vụ phù hợp |
| Gợi ý theo tiện nghi | Tìm khách sạn có hồ bơi, spa, v.v. |
| Hỗ trợ đa ngôn ngữ | Tiếng Việt, Tiếng Anh |

**Technologies:**
- LangChain: Framework chatbot
- Groq: LLM Provider (nhanh, miễn phí)
- FAISS: Vector search
- FastAPI: Web server

---

### 🧠 AI RECOMMENDATION (Python/Flask)

| Chức năng | Mô tả |
|-----------|-------|
| Two-Tower Model | User Tower + Item Tower |
| Geo-Location Matching | Gợi ý theo vị trí địa lý |
| Price Similarity | Gợi ý theo mức giá tương tự |
| Feature Matching | Khớp tiện nghi, danh mục |
| User Behavior Learning | Học từ lịch sử tương tác |

**Weights Configuration:**
- Geo Proximity: 40%
- Price Similarity: 25%
- Feature Matching: 35%

---

## 🔨 BUILD & DEPLOY

### Build Backend (JAR)

```bash
cd backend
mvn clean package -DskipTests

# Output: target/backend-0.0.1-SNAPSHOT.jar

# Chạy JAR
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

### Build Supplier Portal (Production)

```bash
cd supplier
npm run build

# Output: dist/ folder
# Deploy lên Nginx, Vercel, Netlify, v.v.
```

### Build Flutter App

```bash
cd app

# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (cho Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS (cần macOS)
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app

# Web
flutter build web --release
# Output: build/web/
```

### Docker Build

```bash
# Build tất cả services
docker-compose build

# Chạy với Docker
docker-compose up -d
```

---

## 📡 API ENDPOINTS

### Base URL
- **Local:** `http://localhost:8080/api`
- **Ngrok (iOS):** `https://your-url.ngrok-free.dev/api`

### Authentication
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/auth/login` | Đăng nhập |
| POST | `/auth/register` | Đăng ký |
| POST | `/auth/google` | Google OAuth2 |
| POST | `/auth/forgot-password` | Quên mật khẩu |
| POST | `/auth/verify-otp` | Xác thực OTP |

### Hotels
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/hotels` | Danh sách khách sạn |
| GET | `/hotels/{id}` | Chi tiết khách sạn |
| POST | `/hotels` | Tạo khách sạn (Provider) |
| PUT | `/hotels/{id}` | Cập nhật khách sạn |
| DELETE | `/hotels/{id}` | Xóa khách sạn |

### Bookings
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/hotel-bookings` | Đặt phòng khách sạn |
| GET | `/hotel-bookings/user` | Lịch sử đặt phòng |
| PUT | `/hotel-bookings/{id}/status` | Cập nhật trạng thái |

### (Tương tự cho Restaurants, Tours, Attractions)

### AI Services
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/recommendations/{userId}` | Gợi ý cho user |
| POST | `/chat` | Chat với AI |

### Payments
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/zalopay/create-order` | Tạo đơn thanh toán |
| POST | `/zalopay/callback` | ZaloPay callback |

---

## 🔧 TROUBLESHOOTING

### Lỗi kết nối Database

```
Cannot connect to MySQL server
```

**Giải pháp:**
1. Kiểm tra MySQL đang chạy: `mysql -u root -p`
2. Kiểm tra port 3306 không bị chiếm
3. Kiểm tra credentials trong `application.yml`

### Lỗi Firebase

```
Firebase Admin SDK initialization error
```

**Giải pháp:**
1. Kiểm tra file `firebase-service-account.json` tồn tại
2. Kiểm tra file JSON hợp lệ
3. Kiểm tra quyền đọc file

### Lỗi Android Build

```
SDK location not found
```

**Giải pháp:**
1. Tạo file `app/android/local.properties`:
```properties
sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\flutter
```

### Lỗi Flutter pub get

```
Version solving failed
```

**Giải pháp:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Lỗi CORS

```
Access-Control-Allow-Origin
```

**Giải pháp:**
Backend đã cấu hình CORS. Kiểm tra:
1. Backend đang chạy
2. URL đúng (localhost vs 10.0.2.2)

### Lỗi Ngrok

```
Invalid tunnel configuration
```

**Giải pháp:**
1. Kiểm tra authtoken trong `ngrok_backend.yml`
2. Đăng nhập lại: `ngrok config add-authtoken YOUR_TOKEN`

---

## 📞 HỖ TRỢ

- **Email:** tripfinity2025@gmail.com
- **Documentation:** Xem file `bao_cao_do_an.docx` trong project

---

## 📄 LICENSE

Copyright © 2025 Nguyễn Thành Công - Tripfinity Project

---

> **Lưu ý:** Đây là project đồ án tốt nghiệp. Các API keys và credentials trong code là demo, vui lòng thay thế bằng credentials của bạn khi sử dụng.
