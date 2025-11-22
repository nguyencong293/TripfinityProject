import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Star, ThumbsUp, Send, User } from "lucide-react";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getHotelReviewById } from "../../../services/hotelService";
import {
  createReviewReply,
  getReviewReplies,
  toggleReviewLike,
  getLikeCount,
  checkIsLiked,
} from "../../../services/reviewService";
import type { HotelReviewDTO, UserDTO } from "../../../types";

interface ReviewReplyDTO {
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

const ReviewDetailPage: React.FC = () => {
  const navigate = useNavigate();
  const { reviewId } = useParams<{ reviewId: string }>();
  const [review, setReview] = useState<HotelReviewDTO | null>(null);
  const [replies, setReplies] = useState<ReviewReplyDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [replyContent, setReplyContent] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [currentUserId, setCurrentUserId] = useState<number | null>(null);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [reviewLikeCount, setReviewLikeCount] = useState(0);
  const [isReviewLiked, setIsReviewLiked] = useState(false);

  useEffect(() => {
    const init = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) return;
        const user = JSON.parse(userStr);
        setCurrentUserId(user.userId);

        const provider = await getProviderByUserId(user.userId);
        if (provider?.providerId) {
          setProviderId(provider.providerId);
        }
      } catch (error) {
        console.error("Error loading user:", error);
      }
    };
    init();
  }, []);

  useEffect(() => {
    const loadData = async () => {
      if (!reviewId || !currentUserId) return;

      try {
        setLoading(true);
        
        // Load review
        const reviewData = await getHotelReviewById(parseInt(reviewId));
        setReview(reviewData);

        // Load replies
        const repliesData = await getReviewReplies("hotel", parseInt(reviewId), currentUserId);
        setReplies(repliesData);

        // Load review like status
        const likeCount = await getLikeCount("hotel", parseInt(reviewId), null);
        setReviewLikeCount(likeCount);

        const isLiked = await checkIsLiked(currentUserId, "hotel", parseInt(reviewId), null);
        setIsReviewLiked(isLiked);
      } catch (error) {
        console.error("Error loading review:", error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [reviewId, currentUserId]);

  const handleLikeReview = async () => {
    if (!currentUserId || !reviewId) return;

    try {
      const result = await toggleReviewLike({
        userId: currentUserId,
        reviewType: "hotel",
        reviewId: parseInt(reviewId),
        replyId: null,
      });

      setIsReviewLiked(result.isLiked);
      setReviewLikeCount(result.likeCount);
    } catch (error) {
      console.error("Error toggling review like:", error);
    }
  };

  const handleLikeReply = async (replyId: number) => {
    if (!currentUserId || !reviewId) return;

    try {
      const result = await toggleReviewLike({
        userId: currentUserId,
        reviewType: "hotel",
        reviewId: parseInt(reviewId),
        replyId: replyId,
      });

      // Update reply like status
      setReplies(replies.map(r =>
        r.replyId === replyId
          ? { ...r, isLikedByCurrentUser: result.isLiked, likeCount: result.likeCount }
          : r
      ));
    } catch (error) {
      console.error("Error toggling reply like:", error);
    }
  };

  const handleSubmitReply = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentUserId || !reviewId || !replyContent.trim()) return;

    try {
      setSubmitting(true);

      const newReply = await createReviewReply({
        reviewType: "hotel",
        reviewId: parseInt(reviewId),
        replierId: currentUserId,
        content: replyContent.trim(),
        isPublic: true,
        isProvider: providerId ? 1 : 0,
      });

      setReplies([...replies, newReply]);
      setReplyContent("");
    } catch (error) {
      console.error("Error submitting reply:", error);
      alert("Lỗi khi gửi phản hồi");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!review) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <p className="text-gray-500">Không tìm thấy đánh giá</p>
          <button
            onClick={() => navigate(-1)}
            className="mt-4 text-blue-600 hover:underline"
          >
            Quay lại
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="flex items-center gap-4 mb-6">
        <button
          onClick={() => navigate(-1)}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-2xl font-bold">Chi tiết đánh giá</h1>
      </div>

      {/* Review Card */}
      <div className="bg-white rounded-xl border border-gray-200 p-6 mb-6">
        {/* User info */}
        <div className="flex items-start gap-4 mb-4">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-semibold">
            {review.userName?.[0]?.toUpperCase() || <User className="w-6 h-6" />}
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <h3 className="font-semibold text-gray-900">{review.userName || "Khách hàng"}</h3>
              <div className="flex items-center gap-1">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={`w-4 h-4 ${
                      i < (review.rating || 0)
                        ? "fill-yellow-400 text-yellow-400"
                        : "text-gray-300"
                    }`}
                  />
                ))}
              </div>
            </div>
            <p className="text-sm text-gray-500">
              {review.createdAt
                ? new Date(review.createdAt).toLocaleDateString("vi-VN", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })
                : ""}
            </p>
          </div>
        </div>

        {/* Review content */}
        {review.title && (
          <h4 className="font-semibold text-gray-900 mb-2">{review.title}</h4>
        )}
        <p className="text-gray-700 mb-4 whitespace-pre-wrap">{review.content}</p>

        {/* Review images */}
        {review.imageUrls && review.imageUrls.length > 0 && (
          <div className="flex gap-2 mb-4 overflow-x-auto">
            {review.imageUrls.map((url, idx) => (
              <img
                key={idx}
                src={url}
                alt={`Review ${idx + 1}`}
                className="h-24 w-24 rounded-lg object-cover flex-shrink-0"
              />
            ))}
          </div>
        )}

        {/* Review aspects */}
        {review.aspects && (
          <div className="bg-gray-50 rounded-lg p-4 mb-4">
            <p className="text-sm font-semibold text-gray-700 mb-3">Đánh giá chi tiết:</p>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-600">Vệ sinh:</span>
                <span className="font-medium text-gray-900">{review.aspects.cleanliness}/5</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Dịch vụ:</span>
                <span className="font-medium text-gray-900">{review.aspects.service}/5</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Giá trị:</span>
                <span className="font-medium text-gray-900">{review.aspects.valueForMoney}/5</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Vị trí:</span>
                <span className="font-medium text-gray-900">{review.aspects.location}/5</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Tiện nghi:</span>
                <span className="font-medium text-gray-900">{review.aspects.facilities}/5</span>
              </div>
            </div>
          </div>
        )}

        {/* Like button */}
        <button
          onClick={handleLikeReview}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${
            isReviewLiked
              ? "bg-blue-100 text-blue-600"
              : "bg-gray-100 text-gray-600 hover:bg-gray-200"
          }`}
        >
          <ThumbsUp className={`w-4 h-4 ${isReviewLiked ? "fill-current" : ""}`} />
          <span className="text-sm font-medium">{reviewLikeCount} lượt thích</span>
        </button>
      </div>

      {/* Reply form (for supplier only) */}
      {providerId && (
        <div className="bg-white rounded-xl border border-gray-200 p-6 mb-6">
          <h3 className="font-semibold text-gray-900 mb-4">Trả lời đánh giá</h3>
          <form onSubmit={handleSubmitReply}>
            <textarea
              value={replyContent}
              onChange={(e) => setReplyContent(e.target.value)}
              placeholder="Nhập phản hồi của bạn..."
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
              rows={4}
              disabled={submitting}
            />
            <div className="flex justify-end mt-3">
              <button
                type="submit"
                disabled={submitting || !replyContent.trim()}
                className="flex items-center gap-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Send className="w-4 h-4" />
                {submitting ? "Đang gửi..." : "Gửi phản hồi"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Replies list */}
      <div className="bg-white rounded-xl border border-gray-200 p-6">
        <h3 className="font-semibold text-gray-900 mb-4">
          Phản hồi ({replies.length})
        </h3>

        {replies.length === 0 ? (
          <p className="text-gray-500 text-center py-8">Chưa có phản hồi nào</p>
        ) : (
          <div className="space-y-4">
            {replies.map((reply) => (
              <div key={reply.replyId} className="border-l-2 border-blue-500 pl-4 py-2">
                <div className="flex items-start gap-3 mb-2">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-green-500 to-teal-500 flex items-center justify-center text-white text-sm font-semibold">
                    {reply.replierName?.[0]?.toUpperCase() || <User className="w-5 h-5" />}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-gray-900">{reply.replierName || "Người dùng"}</span>
                      {reply.isProvider === 1 && (
                        <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs font-medium rounded">
                          Nhà cung cấp
                        </span>
                      )}
                    </div>
                    <p className="text-sm text-gray-500">
                      {reply.createdAt
                        ? new Date(reply.createdAt).toLocaleDateString("vi-VN")
                        : ""}
                    </p>
                  </div>
                </div>
                <p className="text-gray-700 mb-2 whitespace-pre-wrap">{reply.content}</p>
                <button
                  onClick={() => reply.replyId && handleLikeReply(reply.replyId)}
                  className={`flex items-center gap-1 px-3 py-1 rounded text-sm transition-colors ${
                    reply.isLikedByCurrentUser
                      ? "bg-blue-100 text-blue-600"
                      : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                  }`}
                >
                  <ThumbsUp className={`w-3 h-3 ${reply.isLikedByCurrentUser ? "fill-current" : ""}`} />
                  <span>{reply.likeCount || 0}</span>
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ReviewDetailPage;
