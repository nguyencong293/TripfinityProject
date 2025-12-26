import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Star, ThumbsUp, Send, User, Edit2, Trash2, X, Check } from "lucide-react";
import { useLanguage } from "../../../hooks/useLanguage";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getTourReviewById } from "../../../services/tourService";
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
import type { TourReviewDTO, UserDTO } from "../../../types";

const ReviewDetailPage: React.FC = () => {
  const navigate = useNavigate();
  const { reviewId } = useParams<{ reviewId: string }>();
  const { t } = useLanguage();
  const [review, setReview] = useState<TourReviewDTO | null>(null);
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
        const reviewData = await getTourReviewById(parseInt(reviewId));
        setReview(reviewData);

        // Load review user
        if (reviewData.userId) {
          const userData = await getUserById(reviewData.userId);
          setReviewUser(userData);
        }

        // Load replies
        const repliesData = await getReviewReplies("tour", parseInt(reviewId), currentUserId);
        setReplies(repliesData);

        // Load review like count and status
        const likeCount = await getLikeCount("tour", parseInt(reviewId));
        setReviewLikeCount(likeCount);

        const isLiked = await checkIsLiked(currentUserId, "tour", parseInt(reviewId));
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
        reviewType: "tour",
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
        reviewType: "tour",
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
      alert(t("tour_review_error_send"));
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
      alert(t("tour_review_error_update"));
    }
  };

  const handleDeleteReply = async (replyId: number) => {
    if (!confirm(t("tour_review_confirm_delete"))) return;

    try {
      await deleteReviewReply(replyId);
      setReplies((prev) => prev.filter((r) => r.replyId !== replyId));
    } catch (error) {
      console.error("Error deleting reply:", error);
      alert(t("tour_review_error_delete"));
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen theme-bg-primary flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand-primary"></div>
      </div>
    );
  }

  if (!review) {
    return (
      <div className="min-h-screen theme-bg-primary flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold theme-text-primary mb-2">
            {t("tour_review_not_found")}
          </h2>
          <button
            onClick={() => navigate(-1)}
            className="theme-text-brand hover:opacity-80"
          >
            {t("back")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen theme-bg-primary p-6">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center theme-text-secondary hover:theme-text-primary mb-4"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          {t("back")}
        </button>
        <h1 className="text-3xl font-bold theme-text-primary">{t("tour_review_detail_title")}</h1>
      </div>

      {/* Review Detail */}
      <div className="theme-bg-card rounded-lg shadow-sm p-6 mb-6">
        {/* User info */}
        <div className="flex items-start gap-4 mb-6">
          <div className="w-16 h-16 rounded-full bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
            {reviewUser?.fullName?.[0]?.toUpperCase() || <User className="w-8 h-8" />}
          </div>
          <div className="flex-1">
            <div className="flex items-center justify-between flex-wrap gap-2">
              <div>
                <h2 className="text-xl font-bold theme-text-primary">
                  {reviewUser?.fullName || t("tour_review_customer")}
                </h2>
                <p className="text-sm theme-text-secondary">
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
          <h3 className="text-xl font-semibold theme-text-primary mb-3">
            {review.title}
          </h3>
        )}
        <p className="theme-text-primary mb-6 whitespace-pre-wrap leading-relaxed">
          {review.content}
        </p>

        {/* Review images */}
        {review.imageUrls && review.imageUrls.length > 0 && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
            {review.imageUrls.map((url, idx) => (
              <img
                key={idx}
                src={url}
                alt={`${t("tour_review_image")} ${idx + 1}`}
                className="w-full h-40 rounded-lg object-cover cursor-pointer hover:opacity-90 transition-opacity"
                onClick={() => window.open(url, "_blank")}
              />
            ))}
          </div>
        )}

        {/* Review aspects */}
        {review.aspects && (
          <div className="theme-bg-secondary rounded-lg p-4 mb-6">
            <h4 className="font-semibold theme-text-primary mb-3">{t("tour_review_aspects_title")}</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {[
                { label: t("tour_review_aspect_guide"), value: review.aspects.guideQuality },
                { label: t("tour_review_aspect_itinerary"), value: review.aspects.itineraryQuality },
                { label: t("tour_review_aspect_value"), value: review.aspects.valueForMoney },
                { label: t("tour_review_aspect_organization"), value: review.aspects.organization },
                { label: t("tour_review_aspect_safety"), value: review.aspects.safety },
              ].map((aspect) => (
                <div key={aspect.label} className="flex items-center justify-between">
                  <span className="text-sm theme-text-primary">{aspect.label}</span>
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
        <div className="flex items-center gap-4 pt-4 border-t theme-border">
          <button
            onClick={handleLikeReview}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors ${
              isReviewLiked
                ? "theme-bg-brand theme-text-brand-contrast"
                : "theme-bg-secondary theme-text-secondary theme-hover"
            }`}
          >
            <ThumbsUp className={`w-5 h-5 ${isReviewLiked ? "fill-current" : ""}`} />
            {reviewLikeCount} {t("tour_review_likes")}
          </button>
          <span className="text-sm theme-text-secondary">
            {replies.length} {t("tour_review_replies")}
          </span>
        </div>
      </div>

      {/* Reply form (only for supplier/provider) */}
      {providerId && (
        <div className="theme-bg-card rounded-lg shadow-sm p-6 mb-6">
          <h3 className="text-lg font-semibold theme-text-primary mb-4">
            {t("tour_review_reply_title")}
          </h3>
          <form onSubmit={handleSubmitReply}>
            <textarea
              value={replyContent}
              onChange={(e) => setReplyContent(e.target.value)}
              placeholder={t("tour_review_reply_placeholder")}
              rows={4}
              className="w-full px-4 py-3 border theme-border rounded-lg focus:ring-2 focus:ring-brand-primary focus:border-transparent resize-none theme-bg-primary theme-text-primary"
              disabled={submitting}
            />
            <div className="flex justify-end mt-3">
              <button
                type="submit"
                disabled={submitting || !replyContent.trim()}
                className="flex items-center gap-2 px-6 py-2 btn-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Send className="w-4 h-4" />
                {submitting ? t("tour_review_sending") : t("tour_review_send")}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Replies list */}
      {replies.length > 0 && (
        <div className="theme-bg-card rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold theme-text-primary mb-4">
            {t("tour_review_replies")} ({replies.length})
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
                      ? "theme-bg-brand/10 border theme-border-brand"
                      : "theme-bg-secondary"
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center text-white font-semibold flex-shrink-0">
                      {reply.replierName?.[0]?.toUpperCase() || <User className="w-5 h-5" />}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold theme-text-primary">
                          {reply.replierName || t("tour_review_user")}
                        </span>
                        {reply.isProvider === 1 && (
                          <span className="px-2 py-0.5 theme-bg-brand theme-text-brand-contrast text-xs font-medium rounded-full">
                            {t("tour_review_provider")}
                          </span>
                        )}
                        <span className="text-sm theme-text-secondary">
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
                        <div className="mt-2">
                          <textarea
                            value={editContent}
                            onChange={(e) => setEditContent(e.target.value)}
                            className="w-full px-3 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-brand-primary focus:border-transparent resize-none theme-bg-primary theme-text-primary"
                            rows={3}
                          />
                          <div className="flex gap-2 mt-2">
                            <button
                              onClick={() => handleSaveEdit(reply.replyId!)}
                              className="flex items-center gap-1 px-3 py-1 btn-primary text-sm"
                            >
                              <Check className="w-4 h-4" />
                              {t("save")}
                            </button>
                            <button
                              onClick={handleCancelEdit}
                              className="flex items-center gap-1 px-3 py-1 btn-outline text-sm"
                            >
                              <X className="w-4 h-4" />
                              {t("cancel")}
                            </button>
                          </div>
                        </div>
                      ) : (
                        <>
                          <p className="theme-text-primary whitespace-pre-wrap">
                            {reply.content}
                          </p>
                          {isOwnReply && (
                            <div className="flex gap-2 mt-2">
                              <button
                                onClick={() => handleStartEdit(reply.replyId!, reply.content)}
                                className="flex items-center gap-1 text-sm theme-text-secondary hover:theme-text-brand"
                              >
                                <Edit2 className="w-4 h-4" />
                                {t("edit")}
                              </button>
                              <button
                                onClick={() => handleDeleteReply(reply.replyId!)}
                                className="flex items-center gap-1 text-sm theme-text-secondary hover:theme-text-error"
                              >
                                <Trash2 className="w-4 h-4" />
                                {t("delete")}
                              </button>
                            </div>
                          )}
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
