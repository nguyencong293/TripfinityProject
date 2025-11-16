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
  bookingSettingsJson?: string;

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
  providerConfirmed?: boolean;
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
