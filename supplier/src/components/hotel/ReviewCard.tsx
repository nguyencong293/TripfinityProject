import { Star, ThumbsUp } from "lucide-react";
import type { HotelReviewDTO } from "../../types";
import type React from "react";
import { useLanguage } from "../../hooks/useLanguage";
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { toggleReviewLike, checkIsLiked } from "../../services/reviewService";
import { getUserById } from "../../services/providerService";

// ==================== SECTION 7: REVIEW CARD COMPONENT ====================
interface ReviewCardProps {
  review: HotelReviewDTO;
  hotelName: string;
  readOnly?: boolean;
}

const ReviewCard: React.FC<ReviewCardProps> = ({ review, hotelName, readOnly = false }) => {
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [userName, setUserName] = useState<string>("");
  const [isLiked, setIsLiked] = useState(false);
  const currentUserId = Number(localStorage.getItem("userId"));

  console.log("🔍 ReviewCard render:", {
    reviewId: review.reviewId,
    likesCount: review.likesCount,
    replyCount: review.replyCount,
    readOnly,
    currentUserId
  });

  useEffect(() => {
    const fetchUserName = async () => {
      try {
        const user = await getUserById(review.userId);
        setUserName(user.fullName || "Khách hàng");
      } catch (error) {
        console.error("Error fetching user:", error);
        setUserName("Khách hàng");
      }
    };
    fetchUserName();
  }, [review.userId]);

  useEffect(() => {
    const fetchLikeStatus = async () => {
      if (!currentUserId || !review.reviewId) return;
      try {
        const liked = await checkIsLiked(
          currentUserId,
          "hotel",
          review.reviewId
        );
        console.log("✅ Like status fetched:", { reviewId: review.reviewId, liked });
        setIsLiked(liked);
      } catch (error) {
        console.error("❌ Error fetching like status:", error);
      }
    };
    fetchLikeStatus();
  }, [currentUserId, review.reviewId]);

  const handleLike = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!currentUserId) return;

    try {
      const result = await toggleReviewLike({
        userId: currentUserId,
        reviewType: "hotel",
        reviewId: review.reviewId!,
      });
      setIsLiked(result.isLiked);
    } catch (error) {
      console.error("Error toggling like:", error);
    }
  };

  const handleViewDetail = () => {
    navigate(`/supplier/service/hotel/reviews/${review.reviewId}`);
  };
  const renderStars = (rating: number) => {
    return (
      <div className="flex gap-0.5">
        {[1, 2, 3, 4, 5].map((star) => (
          <Star
            key={star}
            className={`w-4 h-4 ${
              star <= rating ? "icon-primary" : "icon-disabled"
            }`}
          />
        ))}
      </div>
    );
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("vi-VN", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  };

  const getAspectColor = (score: number) => {
    if (score >= 4) return "theme-text-success";
    if (score >= 3) return "theme-text-warning";
    return "theme-text-error";
  };

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4 transition-all hover:shadow-md">
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            {renderStars(review.rating)}
            {review.title && (
              <h4 className="font-semibold text-sm theme-text-primary">
                {review.title}
              </h4>
            )}
          </div>
          <p className="text-xs theme-text-secondary">
            {hotelName} • {userName}
          </p>
        </div>
        <span className="text-xs theme-text-secondary">
          {formatDate(review.createdAt)}
        </span>
      </div>

      {/* Content */}
      <p className="text-sm mb-3 line-clamp-2 theme-text-primary">
        {review.content}
      </p>

      {/* Aspects */}
      {review.aspects && (
        <div className="grid grid-cols-5 gap-2 mb-3">
          {[
            {
              label: t("hotel_aspect_cleanliness"),
              value: review.aspects.cleanliness,
            },
            { label: t("hotel_aspect_service"), value: review.aspects.service },
            {
              label: t("hotel_aspect_value"),
              value: review.aspects.valueForMoney,
            },
            {
              label: t("hotel_aspect_location"),
              value: review.aspects.location,
            },
            {
              label: t("hotel_aspect_facilities"),
              value: review.aspects.facilities,
            },
          ].map((aspect) => (
            <div key={aspect.label} className="text-center">
              <p className="text-xs mb-0.5 theme-text-secondary">
                {aspect.label}
              </p>
              <p
                className={`text-sm font-semibold ${getAspectColor(
                  aspect.value
                )}`}
              >
                {aspect.value.toFixed(1)}
              </p>
            </div>
          ))}
        </div>
      )}

      {/* Footer */}
      <div className="flex items-center justify-between pt-3 border-t theme-divider">
        <div className="flex items-center gap-3 text-xs">
          {readOnly ? (
            <div className="flex items-center gap-3">
              <div className={`flex items-center gap-1 ${isLiked ? "text-emerald-600" : "text-gray-400"}`}>
                <ThumbsUp className={`w-3.5 h-3.5 ${isLiked ? "fill-current" : ""}`} />
              </div>
              <span className="theme-text-secondary">
                💬 {review.replyCount || 0} phản hồi
              </span>
            </div>
          ) : (
            <>
              <button
                onClick={handleLike}
                className={`flex items-center gap-1 transition-colors ${
                  isLiked ? "text-emerald-600" : "text-gray-400 hover:text-emerald-600"
                }`}
                title={isLiked ? "Đã thích" : "Thích đánh giá"}
              >
                <ThumbsUp className={`w-3.5 h-3.5 ${isLiked ? "fill-current" : ""}`} />
              </button>
              <span className="theme-text-secondary">
                💬 {review.replyCount || 0} phản hồi
              </span>
            </>
          )}
        </div>
        <button
          className="text-xs font-medium transition-colors link-brand"
          onClick={handleViewDetail}
        >
          {t("view_details")}
        </button>
      </div>
    </div>
  );
};

export default ReviewCard;
