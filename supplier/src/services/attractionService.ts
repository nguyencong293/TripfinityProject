import api from "./api";
import type {
  AttractionDTO,
  AttractionBookingDTO,
  AttractionRatingSummaryDTO,
  AttractionReviewDTO,
} from "../types";

/**
 * Get all attractions by provider ID
 */
export const getAttractionsByProvider = async (
  providerId: number
): Promise<AttractionDTO[]> => {
  const response = await api.get<AttractionDTO[]>(
    `/attractions/provider/${providerId}`
  );
  return response.data;
};

/**
 * Get attractions by provider ID and status
 */
export const getAttractionsByProviderAndStatus = async (
  providerId: number,
  status: string
): Promise<AttractionDTO[]> => {
  const response = await api.get<AttractionDTO[]>(
    `/attractions/provider/${providerId}/status/${status}`
  );
  return response.data;
};

/**
 * Get attraction by ID
 */
export const getAttractionById = async (
  attractionId: number
): Promise<AttractionDTO> => {
  const response = await api.get<AttractionDTO>(`/attractions/${attractionId}`);
  return response.data;
};

/**
 * Create new attraction
 */
export const createAttraction = async (
  attractionData: Partial<AttractionDTO>
): Promise<AttractionDTO> => {
  const response = await api.post<AttractionDTO>(
    "/attractions",
    attractionData
  );
  return response.data;
};

/**
 * Update attraction
 */
export const updateAttraction = async (
  attractionId: number,
  attractionData: Partial<AttractionDTO>
): Promise<AttractionDTO> => {
  const response = await api.put<AttractionDTO>(
    `/attractions/${attractionId}`,
    attractionData
  );
  return response.data;
};

/**
 * Delete attraction
 */
export const deleteAttraction = async (attractionId: number): Promise<void> => {
  await api.delete(`/attractions/${attractionId}`);
};

/**
 * Upload attraction thumbnail
 */
export const uploadAttractionThumbnail = async (
  attractionId: number,
  file: File
): Promise<AttractionDTO> => {
  const formData = new FormData();
  formData.append("file", file);

  const response = await api.post<AttractionDTO>(
    `/attractions/${attractionId}/thumbnail`,
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
 * Upload attraction images
 */
export const uploadAttractionImages = async (
  attractionId: number,
  files: File[]
): Promise<AttractionDTO> => {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));

  const response = await api.post<AttractionDTO>(
    `/attractions/${attractionId}/images`,
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
 * Delete attraction image
 */
export const deleteAttractionImage = async (
  attractionId: number,
  imageUrl: string
): Promise<AttractionDTO> => {
  const response = await api.delete<AttractionDTO>(
    `/attractions/${attractionId}/images`,
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
 * Get all bookings for provider's attractions
 */
export const getAttractionBookingsByProvider = async (
  providerId: number
): Promise<AttractionBookingDTO[]> => {
  const response = await api.get<AttractionBookingDTO[]>(
    `/attraction-bookings/provider/${providerId}`
  );
  return response.data;
};

/**
 * Get booking by ID
 */
export const getAttractionBookingById = async (
  bookingId: number
): Promise<AttractionBookingDTO> => {
  const response = await api.get<AttractionBookingDTO>(
    `/attraction-bookings/${bookingId}`
  );
  return response.data;
};

/**
 * Confirm booking (provider action)
 */
export const confirmAttractionBooking = async (
  bookingId: number
): Promise<AttractionBookingDTO> => {
  const response = await api.patch<AttractionBookingDTO>(
    `/attraction-bookings/${bookingId}/confirm`
  );
  return response.data;
};

/**
 * Cancel booking (provider action)
 */
export const cancelAttractionBooking = async (
  bookingId: number
): Promise<AttractionBookingDTO> => {
  const response = await api.patch<AttractionBookingDTO>(
    `/attraction-bookings/${bookingId}/cancel`
  );
  return response.data;
};

// ==========================================
// REVIEW & RATING SERVICES
// ==========================================

/**
 * Get review by ID
 */
export const getAttractionReviewById = async (
  reviewId: number
): Promise<AttractionReviewDTO> => {
  const response = await api.get<AttractionReviewDTO>(
    `/attraction-reviews/${reviewId}`
  );
  return response.data;
};

/**
 * Get reviews by attraction ID
 */
export const getAttractionReviewsByAttraction = async (
  attractionId: number
): Promise<AttractionReviewDTO[]> => {
  console.log(
    `🔍 getAttractionReviewsByAttraction called for attraction ${attractionId}`
  );
  const response = await api.get<AttractionReviewDTO[]>(
    `/attraction-reviews/attraction/${attractionId}`
  );
  console.log(
    `✅ getAttractionReviewsByAttraction returned ${response.data.length} reviews`
  );
  return response.data;
};

/**
 * Get reviews count by provider ID
 */
export const getAttractionReviewsCountByProvider = async (
  providerId: number
): Promise<number> => {
  const response = await api.get<{ totalReviews: number }>(
    `/attraction-reviews/provider/${providerId}/count`
  );
  return response.data.totalReviews;
};

/**
 * Get rating summary by attraction ID
 */
export const getAttractionRatingSummaryByAttraction = async (
  attractionId: number
): Promise<AttractionRatingSummaryDTO> => {
  const response = await api.get<AttractionRatingSummaryDTO>(
    `/attractions/${attractionId}/rating-summary`
  );
  return response.data;
};

/**
 * Get rating summaries by provider ID
 */
export const getAttractionRatingSummariesByProvider = async (
  providerId: number
): Promise<AttractionRatingSummaryDTO[]> => {
  const response = await api.get<AttractionRatingSummaryDTO[]>(
    `/attraction-reviews/provider/${providerId}/summaries`
  );
  return response.data;
};

/**
 * Reply to a review (provider action)
 */
export const replyToAttractionReview = async (
  reviewId: number,
  replyContent: string
): Promise<void> => {
  await api.post(`/attraction-reviews/${reviewId}/reply`, {
    content: replyContent,
  });
};
