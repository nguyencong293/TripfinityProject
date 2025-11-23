import api from "./api";
import type {
  HotelDTO,
  HotelDashboardStatistics,
  HotelBookingDTO,
  HotelPriceAlertDTO,
  HotelRatingSummaryDTO,
  HotelReviewDTO,
} from "../types";

/**
 * Get all hotels by provider ID
 */
export const getHotelsByProvider = async (
  providerId: number
): Promise<HotelDTO[]> => {
  const response = await api.get<HotelDTO[]>(`/hotels/provider/${providerId}`);
  return response.data;
};

/**
 * Get hotels by provider ID and status
 */
export const getHotelsByProviderAndStatus = async (
  providerId: number,
  status: string
): Promise<HotelDTO[]> => {
  const response = await api.get<HotelDTO[]>(
    `/hotels/provider/${providerId}/status/${status}`
  );
  return response.data;
};

/**
 * Get hotel by ID
 */
export const getHotelById = async (hotelId: number): Promise<HotelDTO> => {
  const response = await api.get<HotelDTO>(`/hotels/${hotelId}`);
  return response.data;
};

/**
 * Create new hotel
 */
export const createHotel = async (
  hotelData: Partial<HotelDTO>
): Promise<HotelDTO> => {
  const response = await api.post<HotelDTO>("/hotels", hotelData);
  return response.data;
};

/**
 * Update hotel
 */
export const updateHotel = async (
  hotelId: number,
  hotelData: Partial<HotelDTO>
): Promise<HotelDTO> => {
  const response = await api.put<HotelDTO>(`/hotels/${hotelId}`, hotelData);
  return response.data;
};

/**
 * Delete hotel
 */
export const deleteHotel = async (hotelId: number): Promise<void> => {
  await api.delete(`/hotels/${hotelId}`);
};

/**
 * Upload hotel thumbnail
 */
export const uploadHotelThumbnail = async (
  hotelId: number,
  file: File
): Promise<HotelDTO> => {
  const formData = new FormData();
  formData.append("file", file);

  const response = await api.post<HotelDTO>(
    `/hotels/${hotelId}/thumbnail`,
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data;
};

/**
 * Upload hotel images
 */
export const uploadHotelImages = async (
  hotelId: number,
  files: File[]
): Promise<HotelDTO> => {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));

  const response = await api.post<HotelDTO>(
    `/hotels/${hotelId}/images`,
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data;
};

/**
 * Delete hotel thumbnail
 */
export const deleteHotelThumbnail = async (
  hotelId: number
): Promise<HotelDTO> => {
  const response = await api.delete<HotelDTO>(`/hotels/${hotelId}/thumbnail`);
  return response.data;
};

/**
 * Delete hotel image
 */
export const deleteHotelImage = async (
  hotelId: number,
  imageUrl: string
): Promise<HotelDTO> => {
  const response = await api.delete<HotelDTO>(`/hotels/${hotelId}/images`, {
    params: { imageUrl },
  });
  return response.data;
};

/**
 * Get Hotel Dashboard Statistics
 * Tính toán thống kê từ các endpoint hiện có
 */
export const getHotelDashboardStatistics = async (
  providerId: number
): Promise<HotelDashboardStatistics> => {
  try {
    // Fetch all data in parallel
    const [hotelsResponse, bookingsResponse, unseenBookingsResponse] =
      await Promise.all([
        api.get<HotelDTO[]>(`/hotels/provider/${providerId}`),
        api.get<HotelBookingDTO[]>(`/hotel-bookings/provider/${providerId}`),
        api.get<HotelBookingDTO[]>(
          `/hotel-bookings/provider/${providerId}/unseen`
        ),
      ]);

    const hotels = hotelsResponse.data;
    const bookings = bookingsResponse.data;
    const unseenBookings = unseenBookingsResponse.data;

    const now = new Date();
    const today = now.toISOString().split("T")[0];
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();
    const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear;

    // ==================== HOTEL STATISTICS ====================
    const totalHotels = hotels.length;

    const hotelsLastMonth = hotels.filter((hotel: HotelDTO) => {
      if (!hotel.createdAt) return false;
      const created = new Date(hotel.createdAt);
      return (
        created.getFullYear() === lastMonthYear &&
        created.getMonth() <= lastMonth
      );
    }).length;

    const totalHotelsChange =
      hotelsLastMonth > 0
        ? ((totalHotels - hotelsLastMonth) / hotelsLastMonth) * 100
        : totalHotels > 0
        ? 100
        : 0;

    // ==================== BOOKING STATISTICS ====================
    const totalBookings = bookings.length;

    const todayBookings = bookings.filter((booking: HotelBookingDTO) => {
      if (!booking.bookingDate) return false;
      return booking.bookingDate.split("T")[0] === today;
    }).length;

    const unseenBookingsCount = unseenBookings.length;

    // ==================== REVENUE STATISTICS ====================
    const confirmedBookings = bookings.filter(
      (booking: HotelBookingDTO) =>
        booking.bookingStatus === "confirmed" ||
        booking.bookingStatus === "completed"
    );

    const allRevenue = confirmedBookings.reduce(
      (sum: number, booking: HotelBookingDTO) =>
        sum + (Number(booking.totalPrice) || 0),
      0
    );

    const monthlyRevenue = confirmedBookings
      .filter((booking: HotelBookingDTO) => {
        if (!booking.bookingDate) return false;
        const date = new Date(booking.bookingDate);
        return (
          date.getMonth() === currentMonth && date.getFullYear() === currentYear
        );
      })
      .reduce(
        (sum: number, booking: HotelBookingDTO) =>
          sum + (Number(booking.totalPrice) || 0),
        0
      );

    const lastMonthRevenue = confirmedBookings
      .filter((booking: HotelBookingDTO) => {
        if (!booking.bookingDate) return false;
        const date = new Date(booking.bookingDate);
        return (
          date.getMonth() === lastMonth && date.getFullYear() === lastMonthYear
        );
      })
      .reduce(
        (sum: number, booking: HotelBookingDTO) =>
          sum + (Number(booking.totalPrice) || 0),
        0
      );

    const revenueChange =
      lastMonthRevenue > 0
        ? ((monthlyRevenue - lastMonthRevenue) / lastMonthRevenue) * 100
        : monthlyRevenue > 0
        ? 100
        : 0;

    // ==================== RATING STATISTICS ====================
    const hotelsWithRating = hotels.filter(
      (hotel: HotelDTO) =>
        hotel.ratingAverage !== undefined && hotel.ratingAverage !== null
    );

    const averageRating =
      hotelsWithRating.length > 0
        ? hotelsWithRating.reduce(
            (sum: number, hotel: HotelDTO) => sum + Number(hotel.ratingAverage),
            0
          ) / hotelsWithRating.length
        : 0;

    // Total reviews (placeholder - có thể enhance bằng cách fetch rating summaries)
    const totalReviews = 0;

    return {
      totalHotels,
      totalHotelsChange,
      totalBookings,
      todayBookings,
      unseenBookings: unseenBookingsCount,
      totalRevenue: allRevenue,
      monthlyRevenue,
      revenueChange,
      averageRating,
      totalReviews,
    };
  } catch (error) {
    console.error("Error fetching hotel dashboard statistics:", error);
    throw error;
  }
};

// ==================== MERGED: Price Alerts ====================
export const getActiveHotelPriceAlertsByProvider = async (
  providerId: number
): Promise<HotelPriceAlertDTO[]> => {
  const res = await api.get<HotelPriceAlertDTO[]>(
    `/hotel-price-alerts/provider/${providerId}/active`
  );
  return res.data;
};

// ==================== MERGED: Rating Summaries ====================
export const getHotelRatingSummariesByProvider = async (
  providerId: number
): Promise<HotelRatingSummaryDTO[]> => {
  const res = await api.get<HotelRatingSummaryDTO[]>(
    `/hotel-rating-summaries/provider/${providerId}`
  );
  return res.data;
};

export const getHotelRatingSummaryByHotel = async (
  hotelId: number
): Promise<HotelRatingSummaryDTO> => {
  const res = await api.get<HotelRatingSummaryDTO>(
    `/hotels/${hotelId}/rating-summary`
  );
  return res.data;
};

// ==================== MERGED: Reviews ====================
export const getHotelReviewsByHotel = async (
  hotelId: number
): Promise<HotelReviewDTO[]> => {
  const res = await api.get<HotelReviewDTO[]>(
    `/hotel-reviews/hotel/${hotelId}`
  );
  return res.data;
};

export const getHotelReviewsCountByProvider = async (
  providerId: number
): Promise<number> => {
  const res = await api.get<{ totalReviews: number }>(
    `/hotel-reviews/provider/${providerId}/count`
  );
  return res.data.totalReviews;
};

export const getHotelReviewById = async (
  reviewId: number
): Promise<HotelReviewDTO> => {
  const res = await api.get<HotelReviewDTO>(`/hotel-reviews/${reviewId}`);
  return res.data;
};
