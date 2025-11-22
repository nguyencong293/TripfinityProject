import api from "./api";

export interface ReviewReplyDTO {
  replyId?: number;
  reviewType: string;
  reviewId: number;
  replierId: number;
  replierName?: string;
  replierAvatar?: string;
  content: string;
  isPublic: boolean;
  isProvider: number;
  likeCount?: number;
  isLikedByCurrentUser?: boolean;
  createdAt?: string;
}

export interface ReviewLikeDTO {
  likeId?: number;
  userId: number;
  reviewType: string;
  reviewId: number;
  replyId?: number;
}

/**
 * Create a reply to a review
 */
export const createReviewReply = async (
  data: Omit<ReviewReplyDTO, "replyId" | "replierName" | "replierAvatar" | "likeCount" | "isLikedByCurrentUser" | "createdAt">
): Promise<ReviewReplyDTO> => {
  const response = await api.post<ReviewReplyDTO>("/review-replies", data);
  return response.data;
};

/**
 * Get all replies for a review
 */
export const getReviewReplies = async (
  reviewType: string,
  reviewId: number,
  currentUserId?: number
): Promise<ReviewReplyDTO[]> => {
  const params: Record<string, string | number> = { reviewType, reviewId };
  if (currentUserId) {
    params.currentUserId = currentUserId;
  }
  const response = await api.get<ReviewReplyDTO[]>("/review-replies", { params });
  return response.data;
};

/**
 * Get reply count for a review
 */
export const getReplyCount = async (
  reviewType: string,
  reviewId: number
): Promise<number> => {
  const response = await api.get<number>("/review-replies/count", {
    params: { reviewType, reviewId },
  });
  return response.data;
};

/**
 * Toggle like on a review or reply
 */
export const toggleReviewLike = async (
  data: ReviewLikeDTO
): Promise<{ isLiked: boolean; likeCount: number }> => {
  const response = await api.post<{ isLiked: boolean; likeCount: number }>(
    "/review-likes/toggle",
    data
  );
  return response.data;
};

/**
 * Get like count for a review or reply
 */
export const getLikeCount = async (
  reviewType: string,
  reviewId: number,
  replyId?: number
): Promise<number> => {
  const params: Record<string, string | number> = { reviewType, reviewId };
  if (replyId !== undefined) {
    params.replyId = replyId;
  }
  const response = await api.get<number>("/review-likes/count", { params });
  return response.data;
};

/**
 * Check if user has liked a review or reply
 */
export const checkIsLiked = async (
  userId: number,
  reviewType: string,
  reviewId: number,
  replyId?: number
): Promise<boolean> => {
  const params: Record<string, string | number> = { userId, reviewType, reviewId };
  if (replyId !== undefined) {
    params.replyId = replyId;
  }
  const response = await api.get<boolean>("/review-likes/check", { params });
  return response.data;
};
