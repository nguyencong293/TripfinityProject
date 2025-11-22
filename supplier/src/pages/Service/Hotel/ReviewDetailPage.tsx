import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Star, ThumbsUp, Send, User, Edit2, Trash2, X, Check } from "lucide-react";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getHotelReviewById } from "../../../services/hotelService";
import {
  createReviewReply,
  getReviewReplies,
  updateReviewReply,
  deleteReviewReply,
  toggleReviewLike,
  getLikeCount,
  checkIsLiked,
  type ReviewReplyDTO,
} from "../../../services/reviewService";
import type { HotelReviewDTO, UserDTO } from "../../../types";

const ReviewDetailPage: React.FC = () => {
  const navigate = useNavigate();
  const { reviewId } = useParams<{ reviewId: string }>();
  const [review, setReview] = useState<HotelReviewDTO | null>(null);
  const [reviewUser, setReviewUser] = useState<UserDTO | null>(null);
  const [replies, setReplies] = useState<ReviewReplyDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [replyContent, setReplyContent] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [currentUserId, setCurrentUserId] = useState<number | null>(null);
  const [providerId, setProviderId] = useState<number | null>(null);
  const [reviewLikeCount, setReviewLikeCount] = useState(0);
  const [isReviewLiked, setIsReviewLiked] = useState(false);
  const [editingReplyId, setEditingReplyId] = useState<number | null>(null);
  const [editContent, setEditContent] = useState("");


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
        console.error("Error initializing:", error);
      }
    };
    init();
  }, []);

  useEffect(() => {
    const loadReviewData = async () => {
      if (!reviewId || !currentUserId) return;

      try {
        setLoading(true);

        // Load review
        const reviewData = await getHotelReviewById(parseInt(reviewId));
        setReview(reviewData);

        // Load review user
        if (reviewData.userId) {
          const userData = await getUserById(reviewData.userId);
          setReviewUser(userData);
        }

        // Load replies
        const repliesData = await getReviewReplies("hotel", parseInt(reviewId), currentUserId);
        setReplies(repliesData);

        // Load review like count and status
        const likeCount = await getLikeCount("hotel", parseInt(reviewId));
        setReviewLikeCount(likeCount);

        const isLiked = await checkIsLiked(currentUserId, "hotel", parseInt(reviewId));
        setIsReviewLiked(isLiked);
      } catch (error) {
        console.error("Error loading review data:", error);
      } finally {
        setLoading(false);
      }
    };

    loadReviewData();
  }, [reviewId, currentUserId]);

  const handleLikeReview = async () => {
    if (!currentUserId || !reviewId) return;

    try {
      const result = await toggleReviewLike({
        userId: currentUserId,
        reviewType: "hotel",
        reviewId: parseInt(reviewId),
      });

      setIsReviewLiked(result.isLiked);
      setReviewLikeCount(result.likeCount);
    } catch (error) {
      console.error("Error toggling like:", error);
    }
  };

  const handleSubmitReply = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentUserId || !reviewId || !replyContent.trim() || !providerId) return;

    try {
      setSubmitting(true);

      const newReply = await createReviewReply({
        reviewType: "hotel",
        reviewId: parseInt(reviewId),
        replierId: currentUserId,
        content: replyContent.trim(),
        isPublic: true,
        isProvider: 1, // Supplier reply
      });

      setReplies((prev) => [...prev, newReply]);
      setReplyContent("");
    } catch (error) {
      console.error("Error submitting reply:", error);
      alert("Có lỗi khi gửi phản hồi. Vui lòng thử lại.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleStartEdit = (replyId: number, content: string) => {
    setEditingReplyId(replyId);
    setEditContent(content);
  };

  const handleCancelEdit = () => {
    setEditingReplyId(null);
    setEditContent("");
  };

  const handleSaveEdit = async (replyId: number) => {
    if (!editContent.trim()) return;

    try {
      const updated = await updateReviewReply(replyId, editContent.trim());
      setReplies((prev) =>
        prev.map((r) => (r.replyId === replyId ? { ...r, content: updated.content } : r))
      );
      setEditingReplyId(null);
      setEditContent("");
    } catch (error) {
      console.error("Error updating reply:", error);
      alert("Có lỗi khi cập nhật phản hồi.");
    }
  };

  const handleDeleteReply = async (replyId: number) => {
    if (!confirm("Bạn có chắc muốn xóa phản hồi này?")) return;

    try {
      await deleteReviewReply(replyId);
      setReplies((prev) => prev.filter((r) => r.replyId !== replyId));
    } catch (error) {
      console.error("Error deleting reply:", error);
      alert("Có lỗi khi xóa phản hồi.");
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  if (!review) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Không tìm thấy đánh giá
          </h2>
          <button
            onClick={() => navigate(-1)}
            className="text-emerald-600 hover:text-emerald-700"
          >
            Quay lại
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Quay lại
        </button>
        <h1 className="text-3xl font-bold text-gray-900">Chi tiết đánh giá</h1>
      </div>

      {/* Review Detail */}
      <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
        {/* User info */}
        <div className="flex items-start gap-4 mb-6">
          <div className="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
            {reviewUser?.fullName?.[0]?.toUpperCase() || <User className="w-8 h-8" />}
          </div>
          <div className="flex-1">
            <div className="flex items-center justify-between flex-wrap gap-2">
              <div>
                <h2 className="text-xl font-bold text-gray-900">
                  {reviewUser?.fullName || "Khách hàng"}
                </h2>
                <p className="text-sm text-gray-600">
                  {review.createdAt
                    ? new Date(review.createdAt).toLocaleDateString("vi-VN", {
                        year: "numeric",
                        month: "long",
                        day: "numeric",
                        hour: "2-digit",
                        minute: "2-digit",
                      })
                    : ""}
                </p>
              </div>
              <div className="flex items-center gap-1">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={`w-6 h-6 ${
                      i < (review.rating || 0)
                        ? "fill-yellow-400 text-yellow-400"
                        : "text-gray-300"
                    }`}
                  />
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Review content */}
        {review.title && (
          <h3 className="text-xl font-semibold text-gray-900 mb-3">
            {review.title}
          </h3>
        )}
        <p className="text-gray-700 mb-6 whitespace-pre-wrap leading-relaxed">
          {review.content}
        </p>

        {/* Review images */}
        {review.imageUrls && review.imageUrls.length > 0 && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
            {review.imageUrls.map((url, idx) => (
              <img
                key={idx}
                src={url}
                alt={`Review ${idx + 1}`}
                className="w-full h-40 rounded-lg object-cover cursor-pointer hover:opacity-90 transition-opacity"
                onClick={() => window.open(url, "_blank")}
              />
            ))}
          </div>
        )}

        {/* Review aspects */}
        {review.aspects && (
          <div className="bg-gray-50 rounded-lg p-4 mb-6">
            <h4 className="font-semibold text-gray-900 mb-3">Đánh giá chi tiết</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {[
                { label: "Vệ sinh", value: review.aspects.cleanliness },
                { label: "Dịch vụ", value: review.aspects.service },
                { label: "Giá trị", value: review.aspects.valueForMoney },
                { label: "Vị trí", value: review.aspects.location },
                { label: "Tiện nghi", value: review.aspects.facilities },
              ].map((aspect) => (
                <div key={aspect.label} className="flex items-center justify-between">
                  <span className="text-sm text-gray-700">{aspect.label}</span>
                  <div className="flex items-center gap-1">
                    {Array.from({ length: 5 }).map((_, i) => (
                      <Star
                        key={i}
                        className={`w-4 h-4 ${
                          i < (aspect.value || 0)
                            ? "fill-yellow-400 text-yellow-400"
                            : "text-gray-300"
                        }`}
                      />
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Like button */}
        <div className="flex items-center gap-4 pt-4 border-t border-gray-200">
          <button
            onClick={handleLikeReview}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors ${
              isReviewLiked
                ? "bg-emerald-100 text-emerald-700"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            <ThumbsUp className={`w-5 h-5 ${isReviewLiked ? "fill-current" : ""}`} />
            {reviewLikeCount} Thích
          </button>
          <span className="text-sm text-gray-600">
            {replies.length} phản hồi
          </span>
        </div>
      </div>

      {/* Reply form (only for supplier/provider) */}
      {providerId && (
        <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Phản hồi đánh giá
          </h3>
          <form onSubmit={handleSubmitReply}>
            <textarea
              value={replyContent}
              onChange={(e) => setReplyContent(e.target.value)}
              placeholder="Viết phản hồi của bạn..."
              rows={4}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent resize-none"
              disabled={submitting}
            />
            <div className="flex justify-end mt-3">
              <button
                type="submit"
                disabled={submitting || !replyContent.trim()}
                className="flex items-center gap-2 px-6 py-2 bg-emerald-600 text-white rounded-lg font-medium hover:bg-emerald-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Send className="w-4 h-4" />
                {submitting ? "Đang gửi..." : "Gửi phản hồi"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Replies list */}
      {replies.length > 0 && (
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Phản hồi ({replies.length})
          </h3>
          <div className="space-y-4">
            {replies.map((reply) => {
              const isEditing = editingReplyId === reply.replyId;
              const isOwnReply = reply.replierId === currentUserId;

              return (
                <div
                  key={reply.replyId}
                  className={`p-4 rounded-lg ${
                    reply.isProvider === 1
                      ? "bg-emerald-50 border border-emerald-200"
                      : "bg-gray-50"
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-emerald-500 to-teal-500 flex items-center justify-center text-white font-semibold flex-shrink-0">
                      {reply.replierName?.[0]?.toUpperCase() || <User className="w-5 h-5" />}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">
                          {reply.replierName || "Người dùng"}
                        </span>
                        {reply.isProvider === 1 && (
                          <span className="px-2 py-0.5 bg-emerald-600 text-white text-xs font-medium rounded-full">
                            Nhà cung cấp
                          </span>
                        )}
                        <span className="text-sm text-gray-500">
                          {reply.createdAt
                            ? new Date(reply.createdAt).toLocaleDateString("vi-VN", {
                                month: "short",
                                day: "numeric",
                                year: "numeric",
                              })
                            : ""}
                        </span>
                      </div>
                      
                      {isEditing ? (
                        <div className="space-y-2">
                          <textarea
                            value={editContent}
                            onChange={(e) => setEditContent(e.target.value)}
                            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-emerald-500"
                            rows={3}
                          />
                          <div className="flex gap-2">
                            <button
                              onClick={() => handleSaveEdit(reply.replyId!)}
                              className="px-3 py-1 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 flex items-center gap-1 text-sm"
                            >
                              <Check className="w-4 h-4" />
                              Lưu
                            </button>
                            <button
                              onClick={handleCancelEdit}
                              className="px-3 py-1 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 flex items-center gap-1 text-sm"
                            >
                              <X className="w-4 h-4" />
                              Hủy
                            </button>
                          </div>
                        </div>
                      ) : (
                        <>
                          <p className="text-gray-700 mb-2 whitespace-pre-wrap">
                            {reply.content}
                          </p>
                          <div className="flex items-center gap-3">
                            {isOwnReply && (
                              <>
                                <button
                                  onClick={() => handleStartEdit(reply.replyId!, reply.content)}
                                  className="flex items-center gap-1 text-sm font-medium text-blue-600 hover:text-blue-700"
                                >
                                  <Edit2 className="w-4 h-4" />
                                  Sửa
                                </button>
                                <button
                                  onClick={() => handleDeleteReply(reply.replyId!)}
                                  className="flex items-center gap-1 text-sm font-medium text-red-600 hover:text-red-700"
                                >
                                  <Trash2 className="w-4 h-4" />
                                  Xóa
                                </button>
                              </>
                            )}
                          </div>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};

export default ReviewDetailPage;
