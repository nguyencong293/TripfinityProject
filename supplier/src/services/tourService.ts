import api from "./api";
import type {
  TourDTO,
  TourBookingDTO,
  TourRatingSummaryDTO,
  TourReviewDTO,
} from "../types";

/**
 * Get all tours by provider ID
 */
export const getToursByProvider = async (
  providerId: number
): Promise<TourDTO[]> => {
  const response = await api.get<TourDTO[]>(
    `/tours/provider/${providerId}`
  );
  return response.data;
};

/**
 * Get tours by provider ID and status
 */
export const getToursByProviderAndStatus = async (
  providerId: number,
  status: string
): Promise<TourDTO[]> => {
  const response = await api.get<TourDTO[]>(
    `/tours/provider/${providerId}/status/${status}`
  );
  return response.data;
};

/**
 * Get tour by ID
 */
export const getTourById = async (
  tourId: number
): Promise<TourDTO> => {
  const response = await api.get<TourDTO>(`/tours/${tourId}`);
  return response.data;
};

/**
 * Create new tour
 */
export const createTour = async (
  tourData: Partial<TourDTO>
): Promise<TourDTO> => {
  const response = await api.post<TourDTO>(
    "/tours",
    tourData
  );
  return response.data;
};

/**
 * Update tour
 */
export const updateTour = async (
  tourId: number,
  tourData: Partial<TourDTO>
): Promise<TourDTO> => {
  const response = await api.put<TourDTO>(
    `/tours/${tourId}`,
    tourData
  );
  return response.data;
};

/**
 * Delete tour
 */
export const deleteTour = async (tourId: number): Promise<void> => {
  await api.delete(`/tours/${tourId}`);
};

/**
 * Upload tour thumbnail
 */
export const uploadTourThumbnail = async (
  tourId: number,
  file: File
): Promise<TourDTO> => {
  const formData = new FormData();
  formData.append("file", file);

  const response = await api.post<TourDTO>(
    `/tours/${tourId}/thumbnail`,
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
 * Upload tour images
 */
export const uploadTourImages = async (
  tourId: number,
  files: File[]
): Promise<TourDTO> => {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));

  const response = await api.post<TourDTO>(
    `/tours/${tourId}/images`,
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
 * Delete tour image
 */
export const deleteTourImage = async (
  tourId: number,
  imageUrl: string
): Promise<TourDTO> => {
  const response = await api.delete<TourDTO>(
    `/tours/${tourId}/images`,
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
 * Get all bookings for provider's tours
 */
export const getTourBookingsByProvider = async (
  providerId: number
): Promise<TourBookingDTO[]> => {
  const response = await api.get<TourBookingDTO[]>(
    `/tour-bookings/provider/${providerId}`
  );
  return response.data;
};

/**
 * Get booking by ID
 */
export const getTourBookingById = async (
  bookingId: number
): Promise<TourBookingDTO> => {
  const response = await api.get<TourBookingDTO>(
    `/tour-bookings/${bookingId}`
  );
  return response.data;
};

/**
 * Confirm booking (provider action)
 */
export const confirmTourBooking = async (
  bookingId: number
): Promise<TourBookingDTO> => {
  const response = await api.patch<TourBookingDTO>(
    `/tour-bookings/${bookingId}/confirm`
  );
  return response.data;
};

/**
 * Cancel booking (provider action)
 */
export const cancelTourBooking = async (
  bookingId: number
): Promise<TourBookingDTO> => {
  const response = await api.patch<TourBookingDTO>(
    `/tour-bookings/${bookingId}/cancel`
  );
  return response.data;
};

// ==========================================
// REVIEW & RATING SERVICES
// ==========================================

/**
 * Get reviews by tour ID
 */
export const getTourReviewsByTour = async (
  tourId: number
): Promise<TourReviewDTO[]> => {
  console.log(
    `🔍 getTourReviewsByTour called for tour ${tourId}`
  );
  const response = await api.get<TourReviewDTO[]>(
    `/tour-reviews/tour/${tourId}`
  );
  console.log(
    `✅ getTourReviewsByTour returned ${response.data.length} reviews`
  );
  return response.data;
};

/**
 * Get reviews count by provider ID
 */
export const getTourReviewsCountByProvider = async (
  providerId: number
): Promise<number> => {
  const response = await api.get<number>(
    `/tour-reviews/provider/${providerId}/count`
  );
  return response.data;
};

/**
 * Get rating summary by tour ID
 */
export const getTourRatingSummaryByTour = async (
  tourId: number
): Promise<TourRatingSummaryDTO> => {
  const response = await api.get<TourRatingSummaryDTO>(
    `/tour-reviews/tour/${tourId}/summary`
  );
  return response.data;
};

/**
 * Get rating summaries by provider ID
 */
export const getTourRatingSummariesByProvider = async (
  providerId: number
): Promise<TourRatingSummaryDTO[]> => {
  const response = await api.get<TourRatingSummaryDTO[]>(
    `/tour-reviews/provider/${providerId}/summaries`
  );
  return response.data;
};

/**
 * Reply to a review (provider action)
 */
export const replyToTourReview = async (
  reviewId: number,
  replyContent: string
): Promise<void> => {
  await api.post(`/tour-reviews/${reviewId}/reply`, {
    content: replyContent,
  });
};
