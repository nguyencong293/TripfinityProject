import { Star } from "lucide-react";
import type { HotelReviewDTO } from "../../types";
import type React from "react";
import { useLanguage } from "../../hooks/useLanguage";

// ==================== SECTION 7: REVIEW CARD COMPONENT ====================
interface ReviewCardProps {
  review: HotelReviewDTO;
  hotelName: string;
}

const ReviewCard: React.FC<ReviewCardProps> = ({ review, hotelName }) => {
  const { t } = useLanguage();
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
            {hotelName} • {t("user_id")}: {review.userId}
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
          <span className="theme-text-secondary">
            👍 {review.likesCount || 0} {t("likes")}
          </span>
          <span className="theme-text-secondary">
            💬 {review.replyCount || 0} {t("replies")}
          </span>
        </div>
        <button
          className="text-xs font-medium transition-colors link-brand"
          onClick={() => console.log("View review details:", review.reviewId)}
        >
          {t("view_details")}
        </button>
      </div>
    </div>
  );
};

export default ReviewCard;
