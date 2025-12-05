import React from "react";
import { Star, User, ThumbsUp, MessageCircle } from "lucide-react";
import type { RestaurantReviewDTO } from "../../types";
import { useLanguage } from "../../hooks/useLanguage";

interface ReviewCardProps {
  review: RestaurantReviewDTO;
  onReply?: () => void;
}

const ReviewCard: React.FC<ReviewCardProps> = ({ review, onReply }) => {
  const { t } = useLanguage();

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("vi-VN", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }).format(date);
  };

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-6">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-full theme-bg-secondary flex items-center justify-center">
            <User className="w-6 h-6 icon-disabled" />
          </div>
          <div>
            <h4 className="font-semibold theme-text-primary">
              {review.userName || "Anonymous"}
            </h4>
            <p className="text-sm theme-text-secondary">
              {formatDate(review.createdAt || "")}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1">
          {[...Array(5)].map((_, i) => (
            <Star
              key={i}
              className={`w-5 h-5 ${
                i < (review.rating || 0)
                  ? "fill-yellow-400 theme-text-warning"
                  : "icon-disabled"
              }`}
            />
          ))}
        </div>
      </div>

      {/* Review Content */}
      <div className="mb-4">
        <p className="theme-text-primary whitespace-pre-wrap">
          {review.comment || t("no_comment")}
        </p>
      </div>

      {/* Aspect Ratings */}
      {(review.foodQuality || review.service || review.ambiance || review.valueForMoney) && (
        <div className="grid grid-cols-2 gap-3 mb-4 p-3 rounded-lg theme-bg-secondary">
          {review.foodQuality && (
            <div className="flex items-center justify-between text-sm">
              <span className="theme-text-secondary">{t("restaurant_aspect_food_quality")}:</span>
              <div className="flex items-center gap-1">
                <span className="font-medium theme-text-primary">{review.foodQuality}</span>
                <Star className="w-4 h-4 theme-text-warning" />
              </div>
            </div>
          )}
          {review.service && (
            <div className="flex items-center justify-between text-sm">
              <span className="theme-text-secondary">{t("restaurant_aspect_service")}:</span>
              <div className="flex items-center gap-1">
                <span className="font-medium theme-text-primary">{review.service}</span>
                <Star className="w-4 h-4 theme-text-warning" />
              </div>
            </div>
          )}
          {review.ambiance && (
            <div className="flex items-center justify-between text-sm">
              <span className="theme-text-secondary">{t("restaurant_aspect_ambiance")}:</span>
              <div className="flex items-center gap-1">
                <span className="font-medium theme-text-primary">{review.ambiance}</span>
                <Star className="w-4 h-4 theme-text-warning" />
              </div>
            </div>
          )}
          {review.valueForMoney && (
            <div className="flex items-center justify-between text-sm">
              <span className="theme-text-secondary">{t("restaurant_aspect_value")}:</span>
              <div className="flex items-center gap-1">
                <span className="font-medium theme-text-primary">{review.valueForMoney}</span>
                <Star className="w-4 h-4 theme-text-warning" />
              </div>
            </div>
          )}
        </div>
      )}

      {/* Actions */}
      <div className="flex items-center gap-4 text-sm">
        <button className="flex items-center gap-2 theme-text-secondary hover:theme-text-primary transition-colors">
          <ThumbsUp className="w-4 h-4" />
          <span>{review.likesCount || 0}</span>
        </button>
        {onReply && (
          <button
            onClick={onReply}
            className="flex items-center gap-2 theme-text-secondary hover:theme-text-primary transition-colors"
          >
            <MessageCircle className="w-4 h-4" />
            <span>{t("reply")}</span>
          </button>
        )}
      </div>
    </div>
  );
};

export default ReviewCard;
