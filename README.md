# TRIPFINITY - PRESENTATION SLIDES
## Đề tài: Xây dựng hệ thống du lịch thông minh đa nền tảng ứng dụng AI
## Topic: Building a Cross-Platform Intelligent Tourism System using AI

**Sinh viên:** Nguyễn Thành Công - Lớp 21KIT  
**GVHD:** ThS. Nguyễn Ngọc Huyền Trân & KS. Từ Tấn Hoàng Sơn  
**Trường:** Đại học Công nghệ Thông tin và Truyền thông Việt-Hàn

**Thời lượng:** 10 phút (thuyết trình + demo)

---

# 📋 CẤU TRÚC BÀI THUYẾT TRÌNH

| Phần | Nội dung | Số slides |
|------|----------|-----------|
| 1 | Bối cảnh & Đặt vấn đề | 3 slides |
| 2 | Công nghệ sử dụng | 1 slide |
| 3 | Kiến trúc hệ thống | 2 slides |
| 4 | Công nghệ AI ⭐ | 3 slides |
| 5 | Kết luận & Demo | 3 slides |

**Tổng: 12 slides + 2 slides (Bìa + Mục lục) = 14 slides**

---

# SLIDE 1: TRANG BÌA (30 giây)

### 🇻🇳 Nội dung slide:
```
XÂY DỰNG HỆ THỐNG DU LỊCH THÔNG MINH 
ĐA NỀN TẢNG ỨNG DỤNG AI

GVHD: ThS. Nguyễn Ngọc Huyền Trân
      KS. Từ Tấn Hoàng Sơn

SVTH: Nguyễn Thành Công
Lớp: 21KIT - Ngành: Kỹ thuật phần mềm

[Logo VKU]
```

### 🇬🇧 Slide Content:
```
BUILDING A CROSS-PLATFORM INTELLIGENT 
TOURISM SYSTEM USING AI

Supervisor: MSc. Nguyen Ngoc Huyen Tran
            Eng. Tu Tan Hoang Son

Student: Nguyen Thanh Cong
Class: 21KIT - Software Engineering

[VKU Logo]
```

### 💬 Phần nói:
"Kính chào quý Thầy Cô trong Hội đồng. Em là Nguyễn Thành Công, sinh viên lớp 21KIT ngành Kỹ thuật phần mềm. Hôm nay em xin trình bày đồ án tốt nghiệp với đề tài: Xây dựng hệ thống du lịch thông minh đa nền tảng ứng dụng AI - TRIPFINITY."

---

# SLIDE 2: NỘI DUNG TRÌNH BÀY (20 giây)

### 🇻🇳 Nội dung slide:
```
📋 NỘI DUNG TRÌNH BÀY

1. Bối cảnh & Đặt vấn đề
2. Công nghệ sử dụng
3. Kiến trúc hệ thống
4. Công nghệ AI ⭐
5. Kết luận & Demo
```

### 🇬🇧 Slide Content:
```
📋 PRESENTATION OUTLINE

1. Context & Problem Statement
2. Technologies Used
3. System Architecture
4. AI Technologies ⭐
5. Conclusion & Demo
```

### 💬 Phần nói:
"Bài thuyết trình gồm 5 phần. Phần 1 em trình bày bối cảnh ngành du lịch và bài toán cần giải quyết. Phần 2-3 là công nghệ và kiến trúc. Phần 4 - Công nghệ AI . Cuối cùng là kết luận và demo."

---

# ═══════════════════════════════════════════════════════════
# PHẦN 1: BỐI CẢNH & ĐẶT VẤN ĐỀ (3 SLIDES)
# ═══════════════════════════════════════════════════════════

---

# SLIDE 3: BỐI CẢNH - DU LỊCH VIỆT NAM

### 🇻🇳 Nội dung slide:
```
📊 BỐI CẢNH DU LỊCH VIỆT NAM

📈 TỔNG THU DU LỊCH QUA CÁC NĂM:
┌──────────────────────────────────────┐
│  Năm  │ Tổng thu (nghìn tỷ) │ Tăng % │
├───────┼─────────────────────┼────────┤
│ 2021  │      180.00         │ -42.3% │
│ 2022  │      495.00         │ +175%  │
│ 2023  │      678.30         │ +37%   │
│ 2024  │      840.00         │ +23.9% │
│ 2025  │    1,000.00         │ +19%   │
└──────────────────────────────────────┘

→ Ngành du lịch phục hồi mạnh sau COVID
→ Nhu cầu ứng dụng hỗ trợ du lịch tăng cao

Nguồn: Cục Du lịch Quốc gia Việt Nam
```

### 🇬🇧 Slide Content:
```
📊 VIETNAM TOURISM CONTEXT

📈 TOURISM REVENUE OVER THE YEARS:
┌──────────────────────────────────────┐
│ Year  │ Revenue (trillion VND)│ Growth│
├───────┼───────────────────────┼───────┤
│ 2021  │      180.00           │ -42.3%│
│ 2022  │      495.00           │ +175% │
│ 2023  │      678.30           │ +37%  │
│ 2024  │      840.00           │ +23.9%│
│ 2025  │    1,000.00           │ +19%  │
└──────────────────────────────────────┘

→ Tourism strongly recovered after COVID
→ Increasing demand for travel support apps

Source: Vietnam National Administration of Tourism
```

### 💬 Phần nói:
"Du lịch Việt Nam đang phục hồi mạnh sau COVID. Năm 2021 chỉ đạt 180 nghìn tỷ do đại dịch, nhưng đến năm 2025 đã đạt 1 triệu tỷ đồng.

Sự tăng trưởng này cho thấy nhu cầu du lịch ngày càng cao, đồng nghĩa với việc cần có các ứng dụng hỗ trợ du khách tốt hơn. Đây là bối cảnh để em thực hiện đồ án này."

---

# SLIDE 4: VẤN ĐỀ ĐẶT RA

### 🇻🇳 Nội dung slide:
```
🔴 MỘT SỐ BẤT TIỆN KHI LÊN KẾ HOẠCH DU LỊCH:

❌ PHÂN TÁN THÔNG TIN
   • Khách sạn: Booking.com, Agoda
   • Tour: Klook, GetYourGuide
   • Nhà hàng: Google Maps
   → Phải dùng nhiều app riêng lẻ

❌ GỢI Ý CHƯA PHÙ HỢP
   • Các app thường gợi ý giống nhau cho mọi người
   • Chưa dựa trên sở thích cá nhân

❌ TÌM KIẾM CHƯA THÔNG MINH
   • Phải filter thủ công nhiều tiêu chí
   • Chưa hỗ trợ tìm kiếm bằng ngôn ngữ tự nhiên
```

### 🇬🇧 Slide Content:
```
🔴 INCONVENIENCES WHEN PLANNING TRIPS:

❌ SCATTERED INFORMATION
   • Hotels: Booking.com, Agoda
   • Tours: Klook, GetYourGuide
   • Restaurants: Google Maps
   → Need to use multiple separate apps

❌ GENERIC RECOMMENDATIONS
   • Apps often suggest the same for everyone
   • Not based on personal preferences

❌ SEARCH NOT SMART ENOUGH
   • Manual filtering with many criteria
   • No natural language search support
```

### 💬 Phần nói:
"Qua tìm hiểu, em nhận thấy một số bất tiện khi lên kế hoạch du lịch:

Thứ nhất, thông tin bị phân tán - muốn đặt khách sạn dùng Booking, đặt tour dùng Klook, tìm nhà hàng lại dùng Google Maps.

Thứ hai, các gợi ý thường chung chung, giống nhau cho mọi người, chưa dựa vào sở thích cá nhân.

Thứ ba, tìm kiếm còn thủ công, chưa hỗ trợ tìm bằng ngôn ngữ tự nhiên như 'tìm khách sạn gần biển giá rẻ'."

---

# SLIDE 5: MỤC TIÊU ĐỒ ÁN

### 🇻🇳 Nội dung slide:
```
🎯 MỤC TIÊU ĐỒ ÁN - TRIPFINITY:

✅ XÂY DỰNG ỨNG DỤNG TÍCH HỢP
   Gộp 4 loại dịch vụ vào 1 app:
   🏨 Hotel | 🍜 Restaurant | 🏛️ Attraction | 🚌 Tour

✅ ÁP DỤNG AI GỢI Ý
   • Gợi ý dịch vụ dựa trên hành vi người dùng
   • Ưu tiên theo vị trí, giá cả, đặc trưng dịch vụ

✅ XÂY DỰNG CHATBOT HỖ TRỢ
   • Tìm kiếm dịch vụ bằng ngôn ngữ tự nhiên
   • Trả lời dựa trên dữ liệu trong hệ thống

📌 PHẠM VI: Đồ án tập trung vào việc nghiên cứu và
   áp dụng AI vào bài toán gợi ý du lịch
```

### 🇬🇧 Slide Content:
```
🎯 PROJECT OBJECTIVES - TRIPFINITY:

✅ BUILD AN INTEGRATED APPLICATION
   Combine 4 service types in 1 app:
   🏨 Hotel | 🍜 Restaurant | 🏛️ Attraction | 🚌 Tour

✅ APPLY AI RECOMMENDATION
   • Recommend services based on user behavior
   • Prioritize by location, price, service features

✅ BUILD SUPPORT CHATBOT
   • Search services using natural language
   • Respond based on system data

📌 SCOPE: The project focuses on researching and
   applying AI to tourism recommendation problem
```

### 💬 Phần nói:
"Với những vấn đề trên, em đặt ra mục tiêu cho đồ án:

Một là, xây dựng ứng dụng tích hợp 4 loại dịch vụ: Hotel, Restaurant, Attraction và Tour trong 1 app.

Hai là, áp dụng AI để gợi ý dịch vụ dựa trên hành vi người dùng - ưu tiên theo vị trí gần, giá phù hợp, và đặc trưng dịch vụ.

Ba là, xây dựng chatbot hỗ trợ tìm kiếm bằng ngôn ngữ tự nhiên.

Cần lưu ý đây là đồ án tốt nghiệp, em tập trung vào việc nghiên cứu và áp dụng AI vào bài toán gợi ý - chưa phải sản phẩm thương mại hoàn chỉnh."

---

# ═══════════════════════════════════════════════════════════
# PHẦN 2: CÔNG NGHỆ SỬ DỤNG (1 SLIDE)
# ═══════════════════════════════════════════════════════════

---

# SLIDE 6: CÔNG NGHỆ SỬ DỤNG

### 🇻🇳 Nội dung slide:
```
🛠️ CÔNG NGHỆ XÂY DỰNG HỆ THỐNG:

┌─────────────────────────────────────────────────────┐
│ 📱 FRONTEND                                         │
│    • Flutter 3.x - Mobile App (Tourist)             │
│    • React + TypeScript - Web Portal (Supplier)     │
├─────────────────────────────────────────────────────┤
│ 🖥️ BACKEND                                          │
│    • Spring Boot 3.5 + Java 17 - RESTful API        │
│    • Python + Flask - AI Server                     │
├─────────────────────────────────────────────────────┤
│ 🗄️ DATABASE                                         │
│    • MySQL 8.0 - 39 tables, chuẩn 3NF               │
├─────────────────────────────────────────────────────┤
│ 🤖 AI/ML                                            │
│    • Two-Tower Model (Recommendation) - TỰ XÂY DỰNG │
│    • LangChain + Llama 3 70B via Groq (Chatbot RAG) │
├─────────────────────────────────────────────────────┤
│ ☁️ THIRD-PARTY INTEGRATIONS                         │
│    Firebase | ZaloPay | Google Maps | Cloudinary    │
└─────────────────────────────────────────────────────┘
```

### 🇬🇧 Slide Content:
```
🛠️ TECHNOLOGIES USED:

┌─────────────────────────────────────────────────────┐
│ 📱 FRONTEND                                         │
│    • Flutter 3.x - Mobile App (Tourist)             │
│    • React + TypeScript - Web Portal (Supplier)     │
├─────────────────────────────────────────────────────┤
│ 🖥️ BACKEND                                          │
│    • Spring Boot 3.5 + Java 17 - RESTful API        │
│    • Python + Flask - AI Server                     │
├─────────────────────────────────────────────────────┤
│ 🗄️ DATABASE                                         │
│    • MySQL 8.0 - 39 tables, 3NF normalized          │
├─────────────────────────────────────────────────────┤
│ 🤖 AI/ML                                            │
│    • Two-Tower Model (Recommendation) - SELF-BUILT  │
│    • LangChain + Llama 3 70B via Groq (Chatbot RAG) │
├─────────────────────────────────────────────────────┤
│ ☁️ THIRD-PARTY INTEGRATIONS                         │
│    Firebase | ZaloPay | Google Maps | Cloudinary    │
└─────────────────────────────────────────────────────┘
```

### 💬 Phần nói:
"Về công nghệ, Frontend em dùng Flutter cho mobile app vì khả năng cross-platform - 1 codebase chạy Android, iOS, Web. React với TypeScript cho web nhà cung cấp.

Backend là Spring Boot xử lý nghiệp vụ, Python Flask chạy AI Server riêng. Database MySQL với 39 bảng chuẩn 3NF.

Đặc biệt về AI, em TỰ XÂY DỰNG Two-Tower Model cho recommendation - không dùng thư viện có sẵn. Chatbot dùng Llama 3 với 70 tỷ parameters qua Groq API.

Tích hợp Firebase cho Auth và Push Notification, ZaloPay cho thanh toán, Google Maps cho bản đồ, Cloudinary cho media."

---

# ═══════════════════════════════════════════════════════════
# PHẦN 3: KIẾN TRÚC HỆ THỐNG (2 SLIDES)
# ═══════════════════════════════════════════════════════════

---

# SLIDE 7: KIẾN TRÚC TỔNG QUAN

### 🇻🇳 Nội dung slide:
```
🏗️ KIẾN TRÚC 3 TẦNG (THREE-TIER ARCHITECTURE):

┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│   ┌─────────────────┐       ┌─────────────────────┐     │
│   │   Flutter App   │       │    React Web        │     │
│   │   (Tourist)     │       │    (Supplier)       │     │
│   │   51 screens    │       │    25+ components   │     │
│   └────────┬────────┘       └──────────┬──────────┘     │
└────────────┼───────────────────────────┼────────────────┘
             │          REST API          │
             ▼                            ▼
┌─────────────────────────────────────────────────────────┐
│                   BACKEND LAYER                          │
│   ┌─────────────────────────────────────────────────┐   │
│   │           Spring Boot API Gateway               │   │
│   │   • JWT Authentication + Spring Security        │   │
│   │   • 36+ REST API Endpoints                      │   │
│   │   • Business Logic & Validation                 │   │
│   └──────────────────────┬──────────────────────────┘   │
└──────────────────────────┼──────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────┐
│                    DATA LAYER                            │
│   ┌──────────┐   ┌───────┴───────┐   ┌──────────────┐   │
│   │  MySQL   │   │  AI Server    │   │ Third-party  │   │
│   │39 tables │   │  (Python)     │   │  Services    │   │
│   └──────────┘   └───────────────┘   └──────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 🇬🇧 Slide Content:
```
🏗️ THREE-TIER ARCHITECTURE:

┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│   ┌─────────────────┐       ┌─────────────────────┐     │
│   │   Flutter App   │       │    React Web        │     │
│   │   (Tourist)     │       │    (Supplier)       │     │
│   │   51 screens    │       │    25+ components   │     │
│   └────────┬────────┘       └──────────┬──────────┘     │
└────────────┼───────────────────────────┼────────────────┘
             │          REST API          │
             ▼                            ▼
┌─────────────────────────────────────────────────────────┐
│                   BACKEND LAYER                          │
│   ┌─────────────────────────────────────────────────┐   │
│   │           Spring Boot API Gateway               │   │
│   │   • JWT Authentication + Spring Security        │   │
│   │   • 36+ REST API Endpoints                      │   │
│   │   • Business Logic & Validation                 │   │
│   └──────────────────────┬──────────────────────────┘   │
└──────────────────────────┼──────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────┐
│                    DATA LAYER                            │
│   ┌──────────┐   ┌───────┴───────┐   ┌──────────────┐   │
│   │  MySQL   │   │  AI Server    │   │ Third-party  │   │
│   │39 tables │   │  (Python)     │   │  Services    │   │
│   └──────────┘   └───────────────┘   └──────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 💬 Phần nói:
"Hệ thống theo kiến trúc 3 tầng:

Tầng Client gồm Flutter App với 51 screens cho du khách, và React Web với 25+ components cho nhà cung cấp. Cả hai giao tiếp với backend qua REST API.

Tầng Backend là Spring Boot đóng vai trò API Gateway - xử lý authentication với JWT, có 36+ endpoints, và business logic.

Tầng Data gồm MySQL 39 bảng, AI Server Python chạy độc lập để xử lý recommendation và chatbot, cùng các third-party services."

---

# SLIDE 8: DATABASE SCHEMA

### 🇻🇳 Nội dung slide:
```
🗄️ CƠ SỞ DỮ LIỆU: 39 BẢNG - 13 NHÓM THỰC THỂ

┌────────────────────────────────────────────────────────┐
│ 👤 USER (4 bảng)                                       │
│    users, user_badges, user_favorites, user_points    │
├────────────────────────────────────────────────────────┤
│ 🏨 SERVICES (8 bảng)                                   │
│    hotels, tours, restaurants, attractions            │
│    + rooms, tour_schedules, opening_hours...          │
├────────────────────────────────────────────────────────┤
│ 📅 BOOKINGS (8 bảng)                                   │
│    hotel_bookings, tour_bookings, restaurant_bookings │
│    attraction_bookings + *_payments                   │
├────────────────────────────────────────────────────────┤
│ ⭐ REVIEWS (8 bảng)                                    │
│    *_reviews + *_review_aspects (đánh giá đa khía cạnh)│
├────────────────────────────────────────────────────────┤
│ 🤖 AI DATA (2 bảng) ← QUAN TRỌNG                       │
│    • ai_item_tower: Features chuẩn hóa cho AI         │
│    • user_item_interactions: Tracking hành vi user    │
│      (view, click, favorite, book)                    │
└────────────────────────────────────────────────────────┘

✅ Chuẩn hóa 3NF | Denormalized có chủ đích cho AI
```

### 🇬🇧 Slide Content:
```
🗄️ DATABASE: 39 TABLES - 13 ENTITY GROUPS

┌────────────────────────────────────────────────────────┐
│ 👤 USER (4 tables)                                     │
│    users, user_badges, user_favorites, user_points    │
├────────────────────────────────────────────────────────┤
│ 🏨 SERVICES (8 tables)                                 │
│    hotels, tours, restaurants, attractions            │
│    + rooms, tour_schedules, opening_hours...          │
├────────────────────────────────────────────────────────┤
│ 📅 BOOKINGS (8 tables)                                 │
│    hotel_bookings, tour_bookings, restaurant_bookings │
│    attraction_bookings + *_payments                   │
├────────────────────────────────────────────────────────┤
│ ⭐ REVIEWS (8 tables)                                  │
│    *_reviews + *_review_aspects (multi-aspect ratings)│
├────────────────────────────────────────────────────────┤
│ 🤖 AI DATA (2 tables) ← IMPORTANT                      │
│    • ai_item_tower: Normalized features for AI        │
│    • user_item_interactions: User behavior tracking   │
│      (view, click, favorite, book)                    │
└────────────────────────────────────────────────────────┘

✅ 3NF Normalized | Intentional denormalization for AI
```

### 💬 Phần nói:
"Database có 39 bảng, tổ chức thành 13 nhóm thực thể, chuẩn hóa 3NF.

Điểm đặc biệt là em thiết kế riêng 2 bảng cho AI:

Bảng ai_item_tower lưu features đã chuẩn hóa của tất cả dịch vụ - gộp thông tin từ nhiều bảng vào 1 chỗ để AI query nhanh. Đây là denormalized có chủ đích.

Bảng user_item_interactions tracking 4 loại hành vi: view, click, favorite, book - làm dữ liệu đầu vào real-time cho recommendation system."

---

# ═══════════════════════════════════════════════════════════
# PHẦN 4: CÔNG NGHỆ AI (3 SLIDES) ⭐
# ═══════════════════════════════════════════════════════════

---

# SLIDE 9: AI - TWO-TOWER RECOMMENDATION MODEL ⭐

### 🇻🇳 Nội dung slide:
```
🏗️ TWO-TOWER MODEL (Real-time Inference - Tự xây dựng)

┌─────────────────────┐       ┌─────────────────────┐
│     USER TOWER      │       │     ITEM TOWER      │
│  (Query từ DB)      │       │  (Query từ DB)      │
│                     │       │                     │
│ Input:              │       │ Input:              │
│ • User ID           │       │ • 4 loại dịch vụ    │
│ • 10 interactions   │       │ • Lat/Long, Price   │
│   gần nhất (LIFO)   │       │ • Service-specific  │
│                     │       │   features          │
│ Xử lý:              │       │                     │
│ • Time-decay weight │       │ Output:             │
│ • Extract prefs     │       │ Item Candidates     │
│                     │       │ Matrix              │
│ Output:             │       │                     │
│ User Profile        │       │                     │
└──────────┬──────────┘       └──────────┬──────────┘
           │                             │
           └─────────────┬───────────────┘
                         ▼
             ┌───────────────────────┐
             │  MULTI-FACTOR SCORING │
             │  • Geo: 40%           │
             │  • Price: 25%         │
             │  • Features: 35%      │
             └───────────┬───────────┘
                         ▼
                  TOP 10 GỢI Ý
              (5 Latest + 5 History)
```

### 🇬🇧 Slide Content:
```
🏗️ TWO-TOWER MODEL (Real-time Inference - Self-built)

┌─────────────────────┐       ┌─────────────────────┐
│     USER TOWER      │       │     ITEM TOWER      │
│  (Query from DB)    │       │  (Query from DB)    │
│                     │       │                     │
│ Input:              │       │ Input:              │
│ • User ID           │       │ • 4 service types   │
│ • 10 recent         │       │ • Lat/Long, Price   │
│   interactions      │       │ • Service-specific  │
│                     │       │   features          │
│ Process:            │       │                     │
│ • Time-decay weight │       │ Output:             │
│ • Extract prefs     │       │ Item Candidates     │
│                     │       │ Matrix              │
│ Output:             │       │                     │
│ User Profile        │       │                     │
└──────────┬──────────┘       └──────────┬──────────┘
           │                             │
           └─────────────┬───────────────┘
                         ▼
             ┌───────────────────────┐
             │  MULTI-FACTOR SCORING │
             │  • Geo: 40%           │
             │  • Price: 25%         │
             │  • Features: 35%      │
             └───────────┬───────────┘
                         ▼
               TOP 10 RECOMMENDATIONS
              (5 Latest + 5 History)
```

### 💬 Phần nói:
"Đây là phần AI quan trọng nhất. Em tự xây dựng Two-Tower Model từ đầu bằng Python, hoạt động với dữ liệu ĐỘNG real-time - không cần training offline.

USER TOWER query database lấy 10 tương tác gần nhất của user, apply time-decay weight - interaction mới quan trọng hơn, phân tích ra preference về giá, loại dịch vụ yêu thích.

ITEM TOWER load toàn bộ 4 loại dịch vụ từ bảng ai_item_tower.

Hai tower gặp nhau ở Multi-Factor Scoring với 3 tiêu chí: Geo 40% ưu tiên gần nhất, Price 25% khớp ngân sách, Features 35% khớp đặc trưng dịch vụ.

Logic 5+5: 5 items gần vị trí Latest, 5 items gần vị trí trung bình History. Ưu điểm lớn là giải quyết Cold Start - user mới chỉ cần 1 interaction là có gợi ý ngay."

---

# SLIDE 10: AI - SERVICE-SPECIFIC FEATURES ⭐

### 🇻🇳 Nội dung slide:
```
🎯 ĐẶC TRƯNG RIÊNG 4 LOẠI DỊCH VỤ (Content-Based Filtering):

┌─────────────────────────────────────────────────────────┐
│ 🏨 HOTEL                                                │
│    • amenities_json: WiFi, Pool, Spa, Gym, Parking...  │
│    • property_type: Hotel, Resort, Villa, Homestay     │
│    • star_rating: 1-5 sao (cấp sao khách sạn)          │
├─────────────────────────────────────────────────────────┤
│ 🍜 RESTAURANT                                           │
│    • cuisines_json: Vietnamese, Japanese, Italian...   │
│    • diets_json: Vegetarian, Vegan, Halal, Gluten-free │
│    • categories_json: Fine Dining, Street Food, Cafe   │
├─────────────────────────────────────────────────────────┤
│ 🏛️ ATTRACTION                                          │
│    • attraction_type: Museum, Temple, Park, Beach...   │
│    • suitable_for_json: Family, Couples, Solo, Kids    │
│    • categories_json: Cultural, Nature, Entertainment  │
├─────────────────────────────────────────────────────────┤
│ 🚌 TOUR                                                 │
│    • tour_type: Group, Private, Custom                 │
│    • difficulty_level: Easy, Moderate, Hard            │
│    • categories_json: Adventure, Cultural, Nature      │
└─────────────────────────────────────────────────────────┘

→ Jaccard Similarity để match features giữa user prefs & items
```

### 🇬🇧 Slide Content:
```
🎯 SERVICE-SPECIFIC FEATURES (Content-Based Filtering):

┌─────────────────────────────────────────────────────────┐
│ 🏨 HOTEL                                                │
│    • amenities_json: WiFi, Pool, Spa, Gym, Parking...  │
│    • property_type: Hotel, Resort, Villa, Homestay     │
│    • star_rating: 1-5 stars (hotel class)              │
├─────────────────────────────────────────────────────────┤
│ 🍜 RESTAURANT                                           │
│    • cuisines_json: Vietnamese, Japanese, Italian...   │
│    • diets_json: Vegetarian, Vegan, Halal, Gluten-free │
│    • categories_json: Fine Dining, Street Food, Cafe   │
├─────────────────────────────────────────────────────────┤
│ 🏛️ ATTRACTION                                          │
│    • attraction_type: Museum, Temple, Park, Beach...   │
│    • suitable_for_json: Family, Couples, Solo, Kids    │
│    • categories_json: Cultural, Nature, Entertainment  │
├─────────────────────────────────────────────────────────┤
│ 🚌 TOUR                                                 │
│    • tour_type: Group, Private, Custom                 │
│    • difficulty_level: Easy, Moderate, Hard            │
│    • categories_json: Adventure, Cultural, Nature      │
└─────────────────────────────────────────────────────────┘

→ Jaccard Similarity to match features between user prefs & items
```

### 💬 Phần nói:
"Điểm độc đáo của model là xử lý đặc trưng riêng cho từng loại dịch vụ - không phải one-size-fits-all.

Hotel match theo amenities như WiFi, hồ bơi, spa; property type và số sao.

Restaurant match theo cuisine - ẩm thực Việt, Nhật, Ý; và diet - chay, vegan, halal.

Attraction match theo loại điểm đến và phù hợp với đối tượng nào - gia đình, cặp đôi, solo.

Tour match theo loại tour và độ khó.

Em dùng Jaccard Similarity để so sánh độ khớp giữa preference của user và features của item. Nếu user hay xem khách sạn 5 sao có hồ bơi và spa, model sẽ gợi ý các khách sạn tương tự."

---

# SLIDE 11: AI - RAG CHATBOT (TripBOT) ⭐

### 🇻🇳 Nội dung slide:
```
🤖 TRIPBOT - RAG + LLAMA 3 (70B Parameters)

User: "Tìm khách sạn 5 sao ở Đà Nẵng có hồ bơi"
                    │
                    ▼
┌───────────────────────────────────────────────────┐
│ 1. QUERY CLASSIFICATION (Phân loại câu hỏi)       │
│    → greeting | service | general_travel | off_topic│
└────────────────────────┬──────────────────────────┘
                         ▼
┌───────────────────────────────────────────────────┐
│ 2. RETRIEVAL (Tìm kiếm trong DB Tripfinity)       │
│    → Parse: location="Đà Nẵng", star=5, pool=true │
│    → SQL Query → Return top relevant items        │
└────────────────────────┬──────────────────────────┘
                         ▼
┌───────────────────────────────────────────────────┐
│ 3. AUGMENTED GENERATION (Sinh câu trả lời)        │
│    → Context: Retrieved items + Conversation history│
│    → Llama 3 via Groq API → Natural response      │
└────────────────────────┬──────────────────────────┘
                         ▼
"Tôi tìm thấy 5 khách sạn 5 sao có hồ bơi tại Đà Nẵng:
 1. InterContinental... 2. Furama Resort..."
 + [Clickable Service Cards in App]

🌐 8 ngôn ngữ | 🇻🇳 Hiểu tiếng Việt không dấu | 🧠 Context Memory
```

### 🇬🇧 Slide Content:
```
🤖 TRIPBOT - RAG + LLAMA 3 (70B Parameters)

User: "Find 5-star hotel in Da Nang with pool"
                    │
                    ▼
┌───────────────────────────────────────────────────┐
│ 1. QUERY CLASSIFICATION                           │
│    → greeting | service | general_travel | off_topic│
└────────────────────────┬──────────────────────────┘
                         ▼
┌───────────────────────────────────────────────────┐
│ 2. RETRIEVAL (Search Tripfinity Database)         │
│    → Parse: location="Da Nang", star=5, pool=true │
│    → SQL Query → Return top relevant items        │
└────────────────────────┬──────────────────────────┘
                         ▼
┌───────────────────────────────────────────────────┐
│ 3. AUGMENTED GENERATION                           │
│    → Context: Retrieved items + Conversation history│
│    → Llama 3 via Groq API → Natural response      │
└────────────────────────┬──────────────────────────┘
                         ▼
"I found 5 five-star hotels with pool in Da Nang:
 1. InterContinental... 2. Furama Resort..."
 + [Clickable Service Cards in App]

🌐 8 languages | 🇻🇳 Understands Vietnamese without diacritics | 🧠 Context Memory
```

### 💬 Phần nói:
"Module AI thứ hai là TripBOT sử dụng RAG - Retrieval-Augmented Generation - với Llama 3 model 70 tỷ parameters qua Groq API.

Flow: User hỏi 'Tìm khách sạn 5 sao ở Đà Nẵng có hồ bơi'.

Bước 1: Phân loại câu hỏi - đây là service query cần tìm dịch vụ.

Bước 2: Retrieval - parse ra location Đà Nẵng, star 5, amenity pool - rồi query database Tripfinity.

Bước 3: Generation - đưa kết quả tìm được vào context cùng với lịch sử hội thoại cho Llama 3 sinh câu trả lời tự nhiên.

Điểm mạnh là chatbot không bịa đặt - đưa ra dịch vụ thực trong database, user click xem và đặt luôn. Hỗ trợ 8 ngôn ngữ và hiểu cả tiếng Việt không dấu như 'khach san da nang'."

---

# ═══════════════════════════════════════════════════════════
# PHẦN 5: KẾT LUẬN & DEMO (3 SLIDES)
# ═══════════════════════════════════════════════════════════

---

# SLIDE 12: DEMO ỨNG DỤNG

### 🇻🇳 Nội dung slide:
```
🎬 KỊCH BẢN DEMO (3 phút):

1️⃣ HOME SCREEN - AI Recommendations (45s)
   • Xem widget "Gợi ý cho bạn"
   • Có reason giải thích: "Gần bạn 2km", "Tiện ích phù hợp"

2️⃣ TÌM KIẾM + XEM CHI TIẾT (45s)
   • Search Hotel với filter
   • Map view, Reviews, Amenities

3️⃣ CHAT VỚI TRIPBOT (1 phút) ⭐
   • "Tìm tour Đà Nẵng cho gia đình"
   • "Khách sạn 5 sao có hồ bơi"
   • Click vào kết quả → xem chi tiết

4️⃣ BOOKING + PAYMENT (30s)
   • Chọn phòng, ngày
   • Thanh toán ZaloPay

📹 ĐÃ CÓ VIDEO BACKUP NẾU DEMO LỖI
```

### 🇬🇧 Slide Content:
```
🎬 DEMO SCENARIO (3 minutes):

1️⃣ HOME SCREEN - AI Recommendations (45s)
   • View "Recommended for you" widget
   • Reason explanation: "Near you 2km", "Matching amenities"

2️⃣ SEARCH + VIEW DETAILS (45s)
   • Search Hotel with filters
   • Map view, Reviews, Amenities

3️⃣ CHAT WITH TRIPBOT (1 min) ⭐
   • "Find tour in Da Nang for family"
   • "5-star hotel with pool"
   • Click result → view details

4️⃣ BOOKING + PAYMENT (30s)
   • Select room, dates
   • Pay with ZaloPay

📹 VIDEO BACKUP AVAILABLE IF DEMO FAILS
```

### 💬 Phần nói:
*(Demo thực tế, nói ngắn gọn theo từng bước)*

**Khi demo lỗi:** "Do kết nối mạng, em xin phép chiếu video backup đã chuẩn bị."

---

# SLIDE 13: KẾT QUẢ ĐẠT ĐƯỢC

### 🇻🇳 Nội dung slide:
```
✅ KẾT QUẢ ĐẠT ĐƯỢC:

📱 MOBILE APP (Flutter):
   • 51 screens hoàn chỉnh
   • Cross-platform: Android, iOS, Web

🖥️ WEB SUPPLIER (React + TypeScript):
   • Full CRUD cho 4 loại dịch vụ
   • Dashboard thống kê

🤖 AI MODULES:
   • Two-Tower: Real-time inference < 500ms
   • Chatbot: 8 ngôn ngữ, hiểu tiếng Việt không dấu
   • Giải quyết Cold Start Problem

🖥️ BACKEND:
   • 36+ REST API endpoints
   • 39 tables database (3NF)

💳 TÍCH HỢP:
   • ZaloPay Payment ✓
   • Firebase Auth + FCM ✓
   • Google Maps ✓
   • Cloudinary ✓
```

### 🇬🇧 Slide Content:
```
✅ ACHIEVEMENTS:

📱 MOBILE APP (Flutter):
   • 51 complete screens
   • Cross-platform: Android, iOS, Web

🖥️ WEB SUPPLIER (React + TypeScript):
   • Full CRUD for 4 service types
   • Statistics dashboard

🤖 AI MODULES:
   • Two-Tower: Real-time inference < 500ms
   • Chatbot: 8 languages, understands Vietnamese without diacritics
   • Cold Start Problem solved

🖥️ BACKEND:
   • 36+ REST API endpoints
   • 39 database tables (3NF)

💳 INTEGRATIONS:
   • ZaloPay Payment ✓
   • Firebase Auth + FCM ✓
   • Google Maps ✓
   • Cloudinary ✓
```

### 💬 Phần nói:
"Tổng kết kết quả: 

Mobile app 51 screens chạy đa nền tảng. Web supplier với full CRUD cho 4 loại dịch vụ.

AI Recommendation real-time với response dưới 500ms, giải quyết Cold Start Problem. Chatbot hỗ trợ 8 ngôn ngữ.

Backend 36+ APIs với 39 bảng chuẩn 3NF.

Tích hợp thành công ZaloPay, Firebase, Google Maps, Cloudinary."

---

# SLIDE 14: HẠN CHẾ & CẢM ƠN

### 🇻🇳 Nội dung slide:
```
⚠️ HẠN CHẾ:
• Chưa deploy production (đang chạy localhost + ngrok)
• Chưa có benchmark AI chính thức
• Chưa tích hợp nguồn dữ liệu booking thực

🚀 HƯỚNG PHÁT TRIỂN:
• Deploy cloud (AWS/GCP) với CI/CD
• A/B Testing để optimize trọng số AI
• Tích hợp thêm VNPay, Momo
• Multi-modal search (voice, image)

═══════════════════════════════════════════════════

🙏 XIN CHÂN THÀNH CẢM ƠN

GVHD: ThS. Nguyễn Ngọc Huyền Trân
      KS. Từ Tấn Hoàng Sơn

Hội đồng chấm thi | Gia đình và bạn bè

💬 KÍNH MỜI HỘI ĐỒNG ĐẶT CÂU HỎI
```

### 🇬🇧 Slide Content:
```
⚠️ LIMITATIONS:
• Not yet deployed to production (localhost + ngrok)
• No formal AI benchmark
• Not integrated with real booking data sources

🚀 FUTURE DEVELOPMENT:
• Deploy to cloud (AWS/GCP) with CI/CD
• A/B Testing to optimize AI weights
• Integrate VNPay, Momo payment
• Multi-modal search (voice, image)

═══════════════════════════════════════════════════

🙏 THANK YOU

Supervisors: MSc. Nguyen Ngoc Huyen Tran
             Eng. Tu Tan Hoang Son

Examination Committee | Family and Friends

💬 Q&A SESSION
```

### 💬 Phần nói:
"Em xin thẳng thắn nêu hạn chế: Hệ thống chưa deploy production, đang chạy localhost với ngrok. Chưa có benchmark AI chính thức vì model là real-time inference.

Hướng phát triển: Deploy lên cloud, A/B Testing để optimize trọng số, tích hợp thêm cổng thanh toán.

Em xin chân thành cảm ơn Thầy Cô hướng dẫn và Hội đồng. Kính mời Hội đồng đặt câu hỏi."

---

# 📝 CÂU HỎI HỘI ĐỒNG CÓ THỂ HỎI

## Q1: "Tại sao chọn Two-Tower mà không dùng Collaborative Filtering?"

**Trả lời:**
"Dạ Collaborative Filtering truyền thống gặp Cold Start Problem - user mới không có lịch sử thì không thể gợi ý. Two-Tower của em kết hợp Content-Based với Location-Based, chỉ cần user xem 1 dịch vụ là gợi ý được ngay. Model hoạt động với dữ liệu động real-time từ database, không cần training offline."

## Q2: "RAG khác gì chatbot thông thường?"

**Trả lời:**
"Dạ chatbot thường chỉ dựa vào knowledge của LLM đã train sẵn - có thể trả lời sai hoặc bịa đặt. RAG trước tiên tìm thông tin từ database Tripfinity, sau đó đưa vào context cho LLM sinh câu trả lời. Nhờ vậy chatbot đưa ra dịch vụ thực với giá cả, địa chỉ chính xác - user click và đặt luôn được."

## Q3: "Model AI đánh giá performance bằng gì?"

**Trả lời:**
"Dạ model Two-Tower là real-time inference, hoạt động với dữ liệu động nên không có metrics offline như Accuracy, Precision. Em đánh giá theo: Response time dưới 500ms, Relevance thực tế qua test manual, Cold Start handling với user mới. Hướng phát triển sẽ setup A/B Testing để đo Click-Through Rate."

## Q4: "Database có chuẩn hóa không?"

**Trả lời:**
"Dạ database chuẩn 3NF. Ví dụ tách review_aspects riêng để đánh giá từng khía cạnh, tách payments khỏi bookings. Đặc biệt bảng ai_item_tower là denormalized có chủ đích - aggregate features để AI query nhanh hơn."

## Q5: "Bảo mật hệ thống như thế nào?"

**Trả lời:**
"Dạ em dùng JWT token với expiration, Spring Security role-based access control, BCrypt hash password, Firebase Auth hỗ trợ Google OAuth, ZaloPay có HMAC signature verify mỗi transaction."

## Q6: "Groq API là gì? Tại sao không tự host Llama?"

**Trả lời:**
"Dạ Groq là inference platform tối ưu cho LLM với latency cực thấp nhờ custom LPU hardware. Llama 70B cần GPU VRAM 140GB+, chi phí cao. Groq có free tier đủ cho prototype và latency nhanh đạt real-time chat. Production có thể chuyển sang self-host hoặc provider khác."

## Q7: "User interaction tracking hoạt động như thế nào?"

**Trả lời:**
"Dạ em tracking 4 loại: VIEW (xem detail), CLICK (từ recommendation), FAVORITE (save wishlist), BOOK (đặt dịch vụ) - với weight khác nhau. Mỗi interaction ghi vào database với timestamp, AI model lấy 10 interactions gần nhất với time-decay weight để build user preference."

---

# ⏱️ PHÂN BỔ THỜI GIAN (10 phút)

| Phần | Slides | Nội dung | Thời gian |
|------|--------|----------|-----------|
| - | 1-2 | Mở đầu + Mục lục | 45s |
| 1 | 3-5 | Bối cảnh & Đặt vấn đề | 2.5 phút |
| 2 | 6 | Công nghệ sử dụng | 45s |
| 3 | 7-8 | Kiến trúc hệ thống | 1.5 phút |
| 4 | 9-11 | **Công nghệ AI** ⭐ | **2.5 phút** |
| 5 | 12-14 | **Kết luận & Demo** | **3 phút** |

**Tổng: ~10-11 phút**

---

# 💡 MẸO THUYẾT TRÌNH

1. **Nhìn vào mắt giám khảo** khi nói, KHÔNG đọc slide
2. **Slide AI (9-11) là điểm nhấn** - nói chậm, rõ ràng
3. **Khi demo lỗi** → Bình tĩnh chuyển video backup
4. **Thừa nhận hạn chế** = Điểm cộng
5. **Gặp câu hỏi không biết** → "Em chưa nghiên cứu sâu phần này, xin phép tìm hiểu thêm"

---

# 📊 THỐNG KÊ DỰ ÁN

```
FLUTTER MOBILE APP: 51 screens, ~100+ Dart files
REACT WEB SUPPLIER: 25+ components, ~80+ TS files
SPRING BOOT BACKEND: 36 controllers, 38 entities, ~150+ Java files
PYTHON AI SERVER: ~2,500+ lines (Two-Tower + Chatbot)
DATABASE: 39 tables, 13 entity groups, 3NF

4 LOẠI DỊCH VỤ:
🏨 Hotel    🍜 Restaurant    🏛️ Attraction    🚌 Tour

THIRD-PARTY:
Firebase | Google Maps | ZaloPay | Cloudinary | Groq API
```

---

*File được tạo cho mục đích thuyết trình đồ án tốt nghiệp*
*Sinh viên: Nguyễn Thành Công - 21KIT - VKU*
*Tháng 1/2026*
