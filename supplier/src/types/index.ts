export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface UserDTO {
  userId?: number;
  email: string;
  passwordHash?: string;
  confirmPassword?: string;
  fullName: string;
  phoneNumber?: string;
  avatarUrl?: string;
  accountRole?: string;
  accountStatus?: string;
  dateOfBirth?: string;
  gender?: string;
  createdAt?: string;
  updatedAt?: string;
}
export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  type?: string;
  userId: number;
  name: string;
  email: string;
}

export interface RawLoginResponse {
  token?: string;
  jwt?: string;
  type?: string;
  userId: number;
  name?: string;
  fullName?: string;
  email: string;
  message?: string;
  [key: string]: unknown;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface VerifyOtpRequest {
  email: string;
  otp: string;
}

export interface ResetPasswordRequest {
  email: string;
  otp: string;
  newPassword: string;
  newConfirmPassword: string;
}

export interface ProviderDTO {
  providerId?: number;
  userId: number;
  companyName: string;
  taxCode: string;
  address: string;
  contactEmail: string;
  contactPhone: string;
  bankAccountNumber?: string;
  bankName?: string;
  logoUrl?: string;
  providerDescription?: string;
  ratingOverall?: number;
  providerStatus?: "pending" | "approved" | "rejected";
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateProviderRequest {
  userId: number;
  companyName: string;
  taxCode: string;
  address: string;
  contactEmail: string;
  contactPhone: string;
  bankAccountNumber?: string;
  bankName?: string;
  providerDescription?: string;
}

export interface HotelDTO {
  hotelId?: number;

  // Required (backend: @NotNull / @NotBlank)
  providerId: number;
  areaId: number;
  title: string;
  price: number;
  pricePerNight?: number;
  currencyCode: string;
  hotelStatus: "published" | "archived" | "disabled";
  visibility: "public_" | "private_";

  // Optional fields
  serviceDescription?: string;
  location?: string;
  startDate?: string; // ISO date (yyyy-MM-dd)
  endDate?: string; // ISO date
  capacity?: number;
  // Max beds per room (>=1)
  maxBedsPerRoom?: number;
  totalRooms?: number; // Total rooms available
  availableRooms?: number; // Calculated: totalRooms - bookedRooms
  availableCapacity?: number; // Calculated: capacity - bookedCapacity
  minParticipants?: number;
  maxParticipants?: number;
  thumbnailUrl?: string;
  imageUrls?: string[];
  ratingAverage?: number; // 0.00 - 5.00
  badges?: string[];
  starRating?: number; // 1 - 5
  propertyType?:
    | "hotel"
    | "resort"
    | "apartment"
    | "villa"
    | "hostel"
    | "guesthouse"
    | "homestay";
  address?: string;
  latitude?: number; // Latitude coordinate (BigDecimal in backend)
  longitude?: number; // Longitude coordinate (BigDecimal in backend)
  checkinTime?: string; // HH:mm:ss
  checkoutTime?: string; // HH:mm:ss

  // Renamed to match backend & test data (IDs referencing separate dictionaries)
  highlightsJson?: number[]; // was highlights
  amenitiesJson?: number[]; // was amenities

  policiesText?: string;
  slug?: string;
  seoTitle?: string;
  seoDescription?: string;
  isFeatured?: boolean;

  // Raw JSON string from backend (you can parse into bookingSettings if needed)


  // Timestamps
  publishedAt?: string; // ISO datetime
  createdAt?: string; // ISO datetime
  updatedAt?: string; // ISO datetime;
}

export interface HotelFilters {
  search?: string;
  area?: string;
  propertyType?: string;
  status?: HotelDTO["hotelStatus"] | "";
  starRating?: number;
  priceMin?: number;
  priceMax?: number;
  visibility?: HotelDTO["visibility"] | "";
}

export interface HotelStats {
  totalHotels: number;
  publishedCount: number;
  draftCount: number;
  averageRating: number;
  totalRooms: number;
  occupancyRate: number;
}

// Hotel Dashboard Statistics
export interface HotelDashboardStatistics {
  // Hotel stats
  totalHotels: number;
  totalHotelsChange: number; // % change from last month

  // Booking stats
  totalBookings: number;
  todayBookings: number;
  unseenBookings: number;

  // Revenue stats
  totalRevenue: number;
  monthlyRevenue: number;
  revenueChange: number; // % change from last month

  // Rating stats
  averageRating: number;
  totalReviews: number;
}

// Booking DTO interface (based on backend)
export interface HotelBookingDTO {
  bookingId?: number;
  userId: number;
  hotelId: number;
  bookingDate?: string; // ISO string
  startDate?: string;
  endDate?: string;
  numAdults: number;
  numChildren?: number;
  totalPrice: number;
  currencyCode?: string;
  bookingStatus?:
    | "pending"
    | "confirmed"
    | "cancelled"
    | "completed"
    | "refunded";
  paymentMethod?: string; // "counter", "zalopay", "momo", "vnpay", "credit_card"
  eTicketUrl?: string;
  qrCodeData?: string;
  createdAt?: string;
  updatedAt?: string;
  providerId?: number;
  channel?: string;
  holdUntil?: string;
  providerSeen?: boolean;
  providerNotes?: string;
  providerConfirmed?: number; // 0=pending, 1=confirmed, 2=cancelled
  providerConfirmedAt?: string;
}

export interface HotelReviewDTO {
  reviewId?: number;
  hotelId: number;
  userId: number;
  rating: number; // 1-5
  title?: string;
  content: string;
  imageUrls?: string[];
  likesCount?: number;
  replyCount?: number;
  reviewStatus?: "approved" | "rejected";
  aspects?: {
    cleanliness: number; // 1-5
    service: number; // 1-5
    valueForMoney: number; // 1-5
    location: number; // 1-5
    facilities: number; // 1-5
  };
  createdAt?: string;
  updatedAt?: string;
}

export interface HotelPriceAlertDTO {
  alertId?: number;
  userId: number;
  hotelId: number;
  targetPrice: number;
  currencyCode?: string;
  isActive?: boolean;
  lastNotifiedAt?: string; // ISO datetime
  createdAt?: string;
  updatedAt?: string;
}

export interface HotelRatingSummaryDTO {
  hotelId: number;
  avgRating: number; // 0.00 - 5.00
  totalReviews: number;
  count1: number; // Số review 1 sao
  count2: number; // Số review 2 sao
  count3: number; // Số review 3 sao
  count4: number; // Số review 4 sao
  count5: number; // Số review 5 sao
  avgCleanliness?: number; // 0.00 - 5.00
  avgService?: number;
  avgValueForMoney?: number;
  avgLocation?: number;
  avgFacilities?: number;
}

// ==========================================
// ATTRACTION TYPES
// ==========================================

export interface AttractionDTO {
  attractionId?: number;

  // Required fields
  providerId: number;
  areaId: number;
  title: string;
  price: number;
  currencyCode: string;
  attractionStatus: "published" | "archived" | "disabled";
  visibility: "public_" | "private_";

  // Optional basic info
  serviceDescription?: string;
  location?: string; // Tỉnh/thành phố
  address?: string; // Địa chỉ đầy đủ
  latitude?: number;
  longitude?: number;
  
  // Date range
  startDate?: string; // ISO date (yyyy-MM-dd)
  endDate?: string; // ISO date
  
  // Capacity
  capacity?: number;
  minParticipants?: number;
  maxParticipants?: number;
  
  // Media
  thumbnailUrl?: string;
  imageUrls?: string[];
  
  // Rating
  ratingAverage?: number; // 0.00 - 5.00
  badges?: string[];
  
  // Attraction type
  attractionType?: 
    | "museum" 
    | "park" 
    | "temple" 
    | "landmark" 
    | "theme_park" 
    | "cultural_site" 
    | "natural_attraction" 
    | "entertainment" 
    | "historical_site" 
    | "other";
  
  // Attraction-specific fields
  averageVisitMinutes?: number; // Thời gian tham quan trung bình
  visitTypesJson?: string[]; // ["guided_tour", "self_guided", "audio_guide", "virtual_tour"]
  availableTimesJson?: string[]; // ["morning", "afternoon", "evening", "night"]
  suitableForJson?: string[]; // ["family", "kids", "elderly", "couples", "groups", "solo", "pets"]
  featuresJson?: number[]; // Feature IDs from attractions_features dictionary
  openingHoursJson?: { [key: string]: string }; // {"monday":"08:00-17:00","tuesday":"08:00-17:00"}
  highlightsJson?: number[]; // Highlight IDs
  tipsText?: string; // Lời khuyên cho du khách
  policiesText?: string; // Chính sách
  
  // SEO
  slug?: string;
  seoTitle?: string;
  seoDescription?: string;
  isFeatured?: boolean;
  
  // Booking settings
  bookingSettingsJson?: string; // Raw JSON string
  
  // Timestamps
  publishedAt?: string; // ISO datetime
  createdAt?: string;
  updatedAt?: string;
}

export interface AttractionFilters {
  search?: string;
  area?: string;
  attractionType?: string;
  status?: AttractionDTO["attractionStatus"] | "";
  priceMin?: number;
  priceMax?: number;
  visibility?: AttractionDTO["visibility"] | "";
  suitableFor?: string; // Filter by audience
}

export interface AttractionStats {
  totalAttractions: number;
  publishedCount: number;
  archivedCount: number;
  averageRating: number;
  totalVisitors: number;
  averageVisitDuration: number; // minutes
}

// Attraction Booking DTO
export interface AttractionBookingDTO {
  bookingId?: number;
  userId: number;
  attractionId: number;
  bookingDate?: string; // ISO string
  visitDate?: string; // Ngày dự kiến tham quan
  visitTime?: string; // Giờ tham quan (HH:mm:ss)
  numAdults: number;
  numChildren?: number;
  totalPrice: number;
  currencyCode?: string;
  bookingStatus?: 
    | "pending" 
    | "confirmed" 
    | "cancelled" 
    | "completed" 
    | "refunded";
  paymentMethod?: string; // "counter", "zalopay", "momo", "vnpay", "credit_card"
  eTicketUrl?: string;
  qrCodeData?: string;
  createdAt?: string;
  updatedAt?: string;
  providerId?: number;
  channel?: string;
  holdUntil?: string;
  providerSeen?: boolean;
  providerNotes?: string;
  providerConfirmed?: number; // 0=pending, 1=confirmed, 2=cancelled
  providerConfirmedAt?: string;
}

// Attraction Review DTO
export interface AttractionReviewDTO {
  reviewId?: number;
  attractionId: number;
  userId: number;
  rating: number; // 1-5
  title?: string;
  content: string;
  imageUrls?: string[];
  likesCount?: number;
  replyCount?: number;
  reviewStatus?: "approved" | "rejected";
  aspects?: {
    experience: number; // 1-5
    valueForMoney: number; // 1-5
    accessibility: number; // 1-5
    facilities: number; // 1-5
    staff: number; // 1-5
  };
  createdAt?: string;
  updatedAt?: string;
}

// Attraction Rating Summary DTO
export interface AttractionRatingSummaryDTO {
  attractionId: number;
  avgRating: number; // 0.00 - 5.00
  totalReviews: number;
  count1: number;
  count2: number;
  count3: number;
  count4: number;
  count5: number;
  avgExperience?: number;
  avgValueForMoney?: number;
  avgAccessibility?: number;
  avgFacilities?: number;
  avgStaff?: number;
}

// ==========================================
// RESTAURANT TYPES
// ==========================================

export interface RestaurantDTO {
  restaurantId?: number;

  // Required fields
  providerId: number;
  areaId: number;
  title: string;
  price: number; // Giá trung bình 1 người
  currencyCode: string;
  restaurantStatus: "published" | "archived" | "disabled";
  visibility: "public_" | "private_";

  // Optional basic info
  serviceDescription?: string;
  location?: string; // Tỉnh/thành phố
  address?: string; // Địa chỉ đầy đủ
  latitude?: number;
  longitude?: number;
  
  // Contact
  phone?: string;
  website?: string;
  
  // Date range (for seasonal restaurants)
  startDate?: string; // ISO date (yyyy-MM-dd)
  endDate?: string; // ISO date
  
  // Pricing
  priceLevel?: "cheap" | "moderate" | "expensive" | "luxury";
  
  // Capacity
  capacity?: number; // Số chỗ ngồi
  minParticipants?: number; // Group booking minimum
  maxParticipants?: number; // Group booking maximum
  
  // Media
  thumbnailUrl?: string;
  imageUrls?: string[];
  
  // Rating
  ratingAverage?: number; // 0.00 - 5.00
  totalReviews?: number; // Total review count
  badges?: string[]; // ["michelin_star", "recommended", "halal_certified"]
  
  // Restaurant-specific fields
  cuisinesJson?: string[]; // ["vietnamese", "chinese", "japanese", "italian", "french"]
  servicesJson?: string[]; // ["dine_in", "takeaway", "delivery", "reservation", "private_room"]
  dietsJson?: string[]; // ["vegetarian", "vegan", "halal", "gluten_free"]
  openingHoursJson?: { [key: string]: string }; // {"monday":"10:00-22:00"}
  menuHighlightsJson?: string[]; // Signature dishes
  ambianceTagsJson?: string[]; // ["romantic", "family_friendly", "casual", "rooftop"]
  paymentMethodsJson?: string[]; // ["cash", "credit_card", "momo", "zalopay"]
  policiesText?: string; // Dress code, reservation, cancellation
  
  // SEO
  slug?: string;
  seoTitle?: string;
  seoDescription?: string;
  isFeatured?: boolean;
  
  // Booking settings
  bookingSettingsJson?: string; // Raw JSON string
  
  // Timestamps
  publishedAt?: string; // ISO datetime
  createdAt?: string;
  updatedAt?: string;
}

export interface RestaurantFilters {
  search?: string;
  area?: string;
  cuisine?: string; // Filter by cuisine type
  priceLevel?: string;
  status?: RestaurantDTO["restaurantStatus"] | "";
  priceMin?: number;
  priceMax?: number;
  visibility?: RestaurantDTO["visibility"] | "";
  diet?: string; // Filter by dietary requirement
  service?: string; // Filter by service type
}

export interface RestaurantStats {
  totalRestaurants: number;
  publishedCount: number;
  archivedCount: number;
  averageRating: number;
  totalReservations: number;
  averagePrice: number;
}

// Restaurant Booking DTO (đặt bàn)
export interface RestaurantBookingDTO {
  bookingId?: number;
  userId: number;
  restaurantId: number;
  bookingDate?: string; // ISO string
  reservationDate?: string; // Ngày đặt bàn
  reservationTime?: string; // Giờ đặt bàn (HH:mm:ss)
  numAdults: number;
  numChildren?: number;
  specialRequests?: string; // Yêu cầu đặc biệt (window seat, birthday, etc)
  totalPrice: number;
  currencyCode?: string;
  bookingStatus?: 
    | "pending" 
    | "confirmed" 
    | "cancelled" 
    | "completed" 
    | "no_show";
  paymentMethod?: string; // "counter", "zalopay", "momo", "vnpay", "credit_card"
  depositAmount?: number; // Tiền đặt cọc
  createdAt?: string;
  updatedAt?: string;
  providerId?: number;
  channel?: string;
  holdUntil?: string;
  providerSeen?: boolean;
  providerNotes?: string;
  providerConfirmed?: number; // 0=pending, 1=confirmed, 2=cancelled
  providerConfirmedAt?: string;
}

// Restaurant Review DTO
export interface RestaurantReviewDTO {
  reviewId?: number;
  restaurantId: number;
  userId: number;
  userName?: string; // User display name
  rating: number; // 1-5
  title?: string;
  content?: string; // Optional text review
  comment?: string; // Alias for content
  imageUrls?: string[];
  likesCount?: number;
  replyCount?: number;
  reviewStatus?: "approved" | "rejected";
  // Restaurant-specific aspect ratings (match database schema)
  aspects?: {
    quality?: number; // 1-5 - Food/product quality
    service?: number; // 1-5 - Service quality
    price?: number; // 1-5 - Price/value rating
    location?: number; // 1-5 - Location convenience
    ambience?: number; // 1-5 - Atmosphere/ambiance
  };
  createdAt?: string;
  updatedAt?: string;
}

// Restaurant Rating Summary DTO
export interface RestaurantRatingSummaryDTO {
  restaurantId: number;
  avgRating: number; // 0.00 - 5.00
  totalReviews: number;
  count1: number;
  count2: number;
  count3: number;
  count4: number;
  count5: number;
  // Restaurant có 5 aspects: quality, service, price, location, ambience
  avgQuality?: number;
  avgService?: number;
  avgPrice?: number;
  avgLocation?: number;
  avgAmbience?: number;
}

// ==========================================
// TOUR TYPES
// ==========================================

export interface TourDTO {
  tourId?: number;

  // Required fields
  providerId: number;
  areaId: number;
  title: string;
  price: number; // Giá tour
  currencyCode: string;
  tourStatus: "published" | "archived" | "disabled";
  visibility: "public" | "private";

  // Optional basic info
  serviceDescription?: string;
  location?: string; // Tỉnh/thành phố
  address?: string; // Địa chỉ đầy đủ
  
  // Coordinates (STANDARDIZED with hotels/attractions/restaurants)
  latitude?: number; // DECIMAL(10,8)
  longitude?: number; // DECIMAL(11,8)
  
  // Date range
  startDate?: string; // ISO date (yyyy-MM-dd)
  endDate?: string; // ISO date
  
  // Capacity
  capacity?: number; // Số chỗ tối đa
  minParticipants?: number; // Số người tối thiểu
  maxParticipants?: number; // Số người tối đa
  
  // Media
  thumbnailUrl?: string;
  imageUrls?: string | string[]; // JSON array of URLs
  
  // Rating
  ratingAverage?: number; // 0.00 - 5.00
  badges?: string | string[]; // JSON array: ["best_seller","eco_friendly","family_friendly","adventure"]
  
  // Tour-specific fields
  durationDays?: number; // Số ngày
  difficultyLevel?: "easy" | "moderate" | "hard"; // Độ khó
  departureLocation?: string; // Điểm khởi hành
  meetingPoint?: string; // Điểm tập trung
  
  // Guide languages (OPTIMIZED: multi-language support)
  guideLanguage?: string; // DEPRECATED - use guideLanguagesJson
  guideLanguagesJson?: string | string[]; // JSON array: ["vietnamese","english","chinese","japanese","korean"]
  
  // Itinerary
  itineraryOverview?: string; // Tổng quan lịch trình
  itineraryDetailsJson?: string | Array<{day: number; title: string; activities: string[]}>; // Chi tiết từng ngày
  
  // Included/Excluded Items (OPTIMIZED: JSON)
  inclusiveItems?: string; // DEPRECATED - use includedJson
  exclusiveItems?: string; // DEPRECATED - use excludedJson
  includedJson?: string | string[]; // JSON: ["hotel","meals","transport","guide","insurance","entrance_fees"]
  excludedJson?: string | string[]; // JSON: ["flights","visa","tips","personal_expenses"]
  
  // Policies
  cancellationPolicy?: string; // Chính sách hủy
  policiesText?: string; // Các chính sách khác
  
  // Tour Types & Categories (NEW)
  tourType?: "group" | "private" | "custom"; // Loại tour
  categoriesJson?: string | string[]; // JSON: ["culture","nature","adventure","food","beach","mountain","city","historical"]
  
  // Additional Services (NEW)
  servicesJson?: string | string[]; // JSON: ["pickup","airport_transfer","photography","bike_rental","special_meals"]
  
  // Booking Settings
  bookingSettingsJson?: string | Record<string, any>; // Cấu hình đặt tour
  
  // SEO
  slug?: string;
  seoTitle?: string;
  seoDescription?: string;
  isFeatured?: boolean;
  
  // Timestamps
  publishedAt?: string; // ISO datetime
  createdAt?: string;
  updatedAt?: string;
}

export interface TourFilters {
  search?: string;
  area?: string;
  difficultyLevel?: string;
  status?: TourDTO["tourStatus"] | "";
  priceMin?: number;
  priceMax?: number;
  visibility?: TourDTO["visibility"] | "";
  durationDays?: number;
}

export interface TourStats {
  totalTours: number;
  publishedCount: number;
  archivedCount: number;
  averageRating: number;
  totalBookings: number;
  averagePrice: number;
}

// Tour Booking DTO
export interface TourBookingDTO {
  bookingId?: number;
  userId: number;
  tourId: number;
  bookingDate?: string; // ISO string
  startDate?: string; // Ngày bắt đầu tour (from backend)
  endDate?: string; // Ngày kết thúc tour (from backend)
  numAdults: number; // Tổng số người (không phân biệt người lớn/trẻ em)
  specialRequests?: string;
  totalPrice: number;
  depositAmount?: number;
  currencyCode?: string;
  paymentMethod?: string;
  bookingStatus?: 
    | "pending" 
    | "confirmed" 
    | "cancelled" 
    | "completed" 
    | "refunded";
  eTicketUrl?: string;
  qrCodeData?: string;
  createdAt?: string;
  updatedAt?: string;
  providerId?: number;
  channel?: string;
  holdUntil?: string;
  providerSeen?: boolean;
  providerNotes?: string;
  providerConfirmed?: number; // 0=pending, 1=confirmed, 2=cancelled
  providerConfirmedAt?: string;
}

// Tour Review DTO
export interface TourReviewDTO {
  reviewId?: number;
  tourId: number;
  userId: number;
  rating: number; // 1-5
  title?: string;
  content: string;
  imageUrls?: string[];
  likesCount?: number;
  replyCount?: number;
  reviewStatus?: "approved" | "rejected";
  aspects?: {
    guideQuality: number; // 1-5 Hướng dẫn viên (DB: guide_quality)
    itineraryQuality: number; // 1-5 Lịch trình (DB: itinerary_quality)
    valueForMoney: number; // 1-5 Giá trị (DB: value_for_money)
    organization: number; // 1-5 Tổ chức
    safety: number; // 1-5 An toàn
  };
  createdAt?: string;
  updatedAt?: string;
}

// Tour Rating Summary DTO
export interface TourRatingSummaryDTO {
  tourId: number;
  avgRating: number; // 0.00 - 5.00
  totalReviews: number;
  count1: number;
  count2: number;
  count3: number;
  count4: number;
  count5: number;
  avgGuideQuality?: number; // Average guide_quality
  avgItineraryQuality?: number; // Average itinerary_quality
  avgValueForMoney?: number; // Average value_for_money
  avgOrganization?: number; // Average organization
  avgSafety?: number; // Average safety
}

