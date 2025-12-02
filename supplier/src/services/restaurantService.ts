import api from "./api";
import type {
  RestaurantDTO,
  RestaurantBookingDTO,
  RestaurantRatingSummaryDTO,
  RestaurantReviewDTO,
} from "../types";

/**
 * Get all restaurants by provider ID
 */
export const getRestaurantsByProvider = async (
  providerId: number
): Promise<RestaurantDTO[]> => {
  const response = await api.get<RestaurantDTO[]>(
    `/restaurants/provider/${providerId}`
  );
  return response.data;
};

/**
 * Get restaurants by provider ID and status
 */
export const getRestaurantsByProviderAndStatus = async (
  providerId: number,
  status: string
): Promise<RestaurantDTO[]> => {
  const response = await api.get<RestaurantDTO[]>(
    `/restaurants/provider/${providerId}/status/${status}`
  );
  return response.data;
};

/**
 * Get restaurant by ID
 */
export const getRestaurantById = async (
  restaurantId: number
): Promise<RestaurantDTO> => {
  const response = await api.get<RestaurantDTO>(`/restaurants/${restaurantId}`);
  return response.data;
};

/**
 * Create new restaurant
 */
export const createRestaurant = async (
  restaurantData: Partial<RestaurantDTO>
): Promise<RestaurantDTO> => {
  const response = await api.post<RestaurantDTO>(
    "/restaurants",
    restaurantData
  );
  return response.data;
};

/**
 * Update restaurant
 */
export const updateRestaurant = async (
  restaurantId: number,
  restaurantData: Partial<RestaurantDTO>
): Promise<RestaurantDTO> => {
  const response = await api.put<RestaurantDTO>(
    `/restaurants/${restaurantId}`,
    restaurantData
  );
  return response.data;
};

/**
 * Delete restaurant
 */
export const deleteRestaurant = async (restaurantId: number): Promise<void> => {
  await api.delete(`/restaurants/${restaurantId}`);
};

/**
 * Upload restaurant thumbnail
 */
export const uploadRestaurantThumbnail = async (
  restaurantId: number,
  file: File
): Promise<RestaurantDTO> => {
  const formData = new FormData();
  formData.append("file", file);

  const response = await api.post<RestaurantDTO>(
    `/restaurants/${restaurantId}/thumbnail`,
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
 * Upload restaurant images
 */
export const uploadRestaurantImages = async (
  restaurantId: number,
  files: File[]
): Promise<RestaurantDTO> => {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));

  const response = await api.post<RestaurantDTO>(
    `/restaurants/${restaurantId}/images`,
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
 * Delete restaurant image
 */
export const deleteRestaurantImage = async (
  restaurantId: number,
  imageUrl: string
): Promise<RestaurantDTO> => {
  const response = await api.delete<RestaurantDTO>(
    `/restaurants/${restaurantId}/images`,
    {
      params: { imageUrl },
    }
  );
  return response.data;
};

// ==========================================
// BOOKING SERVICES
// ==========================================

/**
 * Get all bookings for provider's restaurants
 */
export const getRestaurantBookingsByProvider = async (
  providerId: number
): Promise<RestaurantBookingDTO[]> => {
  const response = await api.get<RestaurantBookingDTO[]>(
    `/restaurant-bookings/provider/${providerId}`
  );
  return response.data;
};

/**
 * Get booking by ID
 */
export const getRestaurantBookingById = async (
  bookingId: number
): Promise<RestaurantBookingDTO> => {
  const response = await api.get<RestaurantBookingDTO>(
    `/restaurant-bookings/${bookingId}`
  );
  return response.data;
};

/**
 * Confirm booking (provider action)
 */
export const confirmRestaurantBooking = async (
  bookingId: number
): Promise<RestaurantBookingDTO> => {
  const response = await api.patch<RestaurantBookingDTO>(
    `/restaurant-bookings/${bookingId}/confirm`
  );
  return response.data;
};

/**
 * Cancel booking (provider action)
 */
export const cancelRestaurantBooking = async (
  bookingId: number
): Promise<RestaurantBookingDTO> => {
  const response = await api.patch<RestaurantBookingDTO>(
    `/restaurant-bookings/${bookingId}/cancel`
  );
  return response.data;
};

// ==========================================
// REVIEW & RATING SERVICES
// ==========================================

/**
 * Get reviews by restaurant ID
 */
export const getRestaurantReviewsByRestaurant = async (
  restaurantId: number
): Promise<RestaurantReviewDTO[]> => {
  console.log(
    `🔍 getRestaurantReviewsByRestaurant called for restaurant ${restaurantId}`
  );
  const response = await api.get<RestaurantReviewDTO[]>(
    `/restaurant-reviews/restaurant/${restaurantId}`
  );
  console.log(
    `✅ getRestaurantReviewsByRestaurant returned ${response.data.length} reviews`
  );
  return response.data;
};

/**
 * Get reviews count by provider ID
 */
export const getRestaurantReviewsCountByProvider = async (
  providerId: number
): Promise<number> => {
  const response = await api.get<number>(
    `/restaurant-reviews/provider/${providerId}/count`
  );
  return response.data;
};

/**
 * Get rating summary by restaurant ID
 */
export const getRestaurantRatingSummaryByRestaurant = async (
  restaurantId: number
): Promise<RestaurantRatingSummaryDTO> => {
  const response = await api.get<RestaurantRatingSummaryDTO>(
    `/restaurant-reviews/restaurant/${restaurantId}/summary`
  );
  return response.data;
};

/**
 * Get rating summaries by provider ID
 */
export const getRestaurantRatingSummariesByProvider = async (
  providerId: number
): Promise<RestaurantRatingSummaryDTO[]> => {
  const response = await api.get<RestaurantRatingSummaryDTO[]>(
    `/restaurant-reviews/provider/${providerId}/summaries`
  );
  return response.data;
};

/**
 * Reply to a review (provider action)
 */
export const replyToRestaurantReview = async (
  reviewId: number,
  replyContent: string
): Promise<void> => {
  await api.post(`/restaurant-reviews/${reviewId}/reply`, {
    content: replyContent,
  });
};
