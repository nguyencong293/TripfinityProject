/**
 * Tour Constants - Categories, Services, Languages, Difficulty Levels
 * Standardized options for tour creation and management
 */

// ==================== TOUR CATEGORIES ====================
export const TOUR_CATEGORIES = [
  { value: "culture", label: "Văn hóa", icon: "🏛️" },
  { value: "nature", label: "Thiên nhiên", icon: "🌿" },
  { value: "adventure", label: "Phiêu lưu", icon: "⛰️" },
  { value: "food", label: "Ẩm thực", icon: "🍜" },
  { value: "beach", label: "Biển", icon: "🏖️" },
  { value: "mountain", label: "Núi", icon: "🗻" },
  { value: "city", label: "Thành phố", icon: "🏙️" },
  { value: "historical", label: "Lịch sử", icon: "🏰" },
  { value: "religious", label: "Tâm linh", icon: "🛕" },
  { value: "wildlife", label: "Động vật hoang dã", icon: "🦁" },
  { value: "photography", label: "Nhiếp ảnh", icon: "📷" },
  { value: "shopping", label: "Mua sắm", icon: "🛍️" },
  { value: "nightlife", label: "Giải trí về đêm", icon: "🎉" },
  { value: "eco-tourism", label: "Du lịch sinh thái", icon: "♻️" },
  { value: "wellness", label: "Chăm sóc sức khỏe", icon: "🧘" },
];

// ==================== TOUR SERVICES ====================
export const TOUR_SERVICES = [
  { value: "pickup", label: "Đón tận nơi" },
  { value: "airport_transfer", label: "Đưa đón sân bay" },
  { value: "professional_guide", label: "Hướng dẫn viên chuyên nghiệp" },
  { value: "tour_leader", label: "Trưởng đoàn" },
  { value: "photographer", label: "Nhiếp ảnh gia" },
  { value: "videographer", label: "Quay phim" },
  { value: "bike_rental", label: "Thuê xe đạp" },
  { value: "motorcycle_rental", label: "Thuê xe máy" },
  { value: "car_rental", label: "Thuê ô tô" },
  { value: "special_meals", label: "Bữa ăn đặc biệt" },
  { value: "vegetarian_options", label: "Thực đơn chay" },
  { value: "halal_meals", label: "Thực đơn Halal" },
  { value: "wifi_on_board", label: "WiFi trên xe" },
  { value: "audio_guide", label: "Hướng dẫn âm thanh" },
  { value: "translation_device", label: "Thiết bị phiên dịch" },
  { value: "first_aid_kit", label: "Hộp sơ cứu" },
  { value: "travel_insurance", label: "Bảo hiểm du lịch" },
  { value: "life_jacket", label: "Áo phao" },
  { value: "helmet", label: "Mũ bảo hiểm" },
  { value: "rain_gear", label: "Áo mưa" },
  { value: "sun_protection", label: "Kem chống nắng" },
  { value: "water_bottle", label: "Chai nước" },
  { value: "snacks", label: "Đồ ăn nhẹ" },
  { value: "souvenirs", label: "Quà lưu niệm" },
  { value: "porter_service", label: "Dịch vụ khuân vác" },
  { value: "laundry_service", label: "Giặt ủi" },
  { value: "medical_support", label: "Hỗ trợ y tế" },
  { value: "children_care", label: "Chăm sóc trẻ em" },
  { value: "wheelchair_accessible", label: "Tiếp cận xe lăn" },
  { value: "baby_seat", label: "Ghế em bé" },
];

// ==================== GUIDE LANGUAGES ====================
export const GUIDE_LANGUAGES = [
  { value: "vietnamese", label: "Tiếng Việt", flag: "🇻🇳" },
  { value: "english", label: "English", flag: "🇬🇧" },
  { value: "chinese", label: "中文 (Chinese)", flag: "🇨🇳" },
  { value: "japanese", label: "日本語 (Japanese)", flag: "🇯🇵" },
  { value: "korean", label: "한국어 (Korean)", flag: "🇰🇷" },
  { value: "french", label: "Français (French)", flag: "🇫🇷" },
  { value: "german", label: "Deutsch (German)", flag: "🇩🇪" },
  { value: "spanish", label: "Español (Spanish)", flag: "🇪🇸" },
  { value: "russian", label: "Русский (Russian)", flag: "🇷🇺" },
  { value: "thai", label: "ภาษาไทย (Thai)", flag: "🇹🇭" },
];

// ==================== DIFFICULTY LEVELS ====================
export const DIFFICULTY_LEVELS = [
  { value: "easy", label: "Dễ", description: "Phù hợp mọi lứa tuổi, không yêu cầu thể lực", color: "green" },
  { value: "moderate", label: "Trung bình", description: "Yêu cầu thể lực cơ bản, có thể mệt mỏi", color: "yellow" },
  { value: "hard", label: "Khó", description: "Yêu cầu thể lực tốt, thử thách", color: "red" },
];

// ==================== TOUR TYPES ====================
export const TOUR_TYPES = [
  { value: "group", label: "Tour ghép đoàn", description: "Tham gia cùng khách khác" },
  { value: "private", label: "Tour riêng", description: "Chỉ dành cho nhóm của bạn" },
  { value: "custom", label: "Tour tùy chỉnh", description: "Thiết kế theo yêu cầu" },
];

// ==================== INCLUDED ITEMS ====================
export const INCLUDED_ITEMS = [
  { value: "hotel", label: "Khách sạn" },
  { value: "meals", label: "Bữa ăn" },
  { value: "breakfast", label: "Ăn sáng" },
  { value: "lunch", label: "Ăn trưa" },
  { value: "dinner", label: "Ăn tối" },
  { value: "transport", label: "Phương tiện vận chuyển" },
  { value: "guide", label: "Hướng dẫn viên" },
  { value: "insurance", label: "Bảo hiểm" },
  { value: "entrance_fees", label: "Phí vào cửa" },
  { value: "activities", label: "Hoạt động" },
  { value: "equipment", label: "Thiết bị" },
  { value: "water", label: "Nước uống" },
  { value: "snacks", label: "Đồ ăn nhẹ" },
  { value: "souvenirs", label: "Quà lưu niệm" },
  { value: "photos", label: "Ảnh chụp" },
];

// ==================== EXCLUDED ITEMS ====================
export const EXCLUDED_ITEMS = [
  { value: "flights", label: "Vé máy bay" },
  { value: "visa", label: "Visa" },
  { value: "tips", label: "Tiền tip" },
  { value: "personal_expenses", label: "Chi phí cá nhân" },
  { value: "drinks", label: "Đồ uống" },
  { value: "alcohol", label: "Đồ uống có cồn" },
  { value: "laundry", label: "Giặt ủi" },
  { value: "phone_calls", label: "Điện thoại" },
  { value: "extra_activities", label: "Hoạt động ngoài chương trình" },
  { value: "travel_insurance", label: "Bảo hiểm du lịch mở rộng" },
];

// ==================== TOUR BADGES ====================
export const TOUR_BADGES = [
  { value: "best_seller", label: "Bán chạy nhất" },
  { value: "new", label: "Mới" },
  { value: "hot_deal", label: "Ưu đãi Hot" },
  { value: "recommended", label: "Được đề xuất" },
  { value: "popular", label: "Phổ biến" },
  { value: "luxury", label: "Cao cấp" },
  { value: "budget_friendly", label: "Giá tốt" },
  { value: "family_friendly", label: "Thân thiện gia đình" },
  { value: "eco_friendly", label: "Thân thiện môi trường" },
  { value: "adventure", label: "Phiêu lưu" },
];

// ==================== VISIBILITY OPTIONS ====================
export const VISIBILITY_OPTIONS = [
  { value: "public", label: "Công khai" },
  { value: "private", label: "Riêng tư" },
];

// ==================== STATUS OPTIONS ====================
export const TOUR_STATUS_OPTIONS = [
  { value: "published", label: "Đã xuất bản", color: "green" },
  { value: "archived", label: "Lưu trữ", color: "gray" },
  { value: "disabled", label: "Tạm dừng", color: "red" },
];

// ==================== CURRENCY OPTIONS ====================
export const CURRENCY_OPTIONS = [
  { value: "VND", label: "VND (₫)" },
  { value: "USD", label: "USD ($)" },
  { value: "EUR", label: "EUR (€)" },
];
