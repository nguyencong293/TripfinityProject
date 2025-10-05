import { Star } from "lucide-react";
import type { HotelReviewDTO } from "../../types";
import type React from "react";
import { useTheme } from "../../hooks/useTheme";

// ==================== SECTION 7: REVIEW CARD COMPONENT ====================
interface ReviewCardProps {
  review: HotelReviewDTO;
  hotelName: string;
}

const ReviewCard: React.FC<ReviewCardProps> = ({ review, hotelName }) => {
  const { dark } = useTheme();

  const renderStars = (rating: number) => {
    return (
      <div className="flex gap-0.5">
        {[1, 2, 3, 4, 5].map((star) => (
          <Star
            key={star}
            className={`w-4 h-4 ${
              star <= rating
                ? "text-yellow-500 fill-yellow-500"
                : dark
                ? "text-gray-600"
                : "text-gray-300"
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
    if (score >= 4) return "text-emerald-500";
    if (score >= 3) return "text-yellow-500";
    return "text-red-500";
  };

  return (
    <div
      className={`rounded-xl border p-4 transition-all hover:shadow-md ${
        dark
          ? "bg-gray-800/50 border-gray-700 hover:border-purple-500/50"
          : "bg-white border-gray-200 hover:border-purple-500/50"
      }`}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            {renderStars(review.rating)}
            {review.title && (
              <h4
                className={`font-semibold text-sm ${
                  dark ? "text-white" : "text-gray-900"
                }`}
              >
                {review.title}
              </h4>
            )}
          </div>
          <p className={`text-xs ${dark ? "text-gray-400" : "text-gray-600"}`}>
            {hotelName} • User ID: {review.userId}
          </p>
        </div>
        <span className={`text-xs ${dark ? "text-gray-500" : "text-gray-500"}`}>
          {formatDate(review.createdAt)}
        </span>
      </div>

      {/* Content */}
      <p
        className={`text-sm mb-3 line-clamp-2 ${
          dark ? "text-gray-300" : "text-gray-700"
        }`}
      >
        {review.content}
      </p>

      {/* Aspects */}
      {review.aspects && (
        <div className="grid grid-cols-5 gap-2 mb-3">
          {[
            { label: "Sạch sẽ", value: review.aspects.cleanliness },
            { label: "Dịch vụ", value: review.aspects.service },
            { label: "Giá trị", value: review.aspects.valueForMoney },
            { label: "Vị trí", value: review.aspects.location },
            { label: "Tiện nghi", value: review.aspects.facilities },
          ].map((aspect) => (
            <div key={aspect.label} className="text-center">
              <p
                className={`text-xs mb-0.5 ${
                  dark ? "text-gray-500" : "text-gray-500"
                }`}
              >
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
      <div className="flex items-center justify-between pt-3 border-t border-gray-200 dark:border-gray-700">
        <div className="flex items-center gap-3 text-xs">
          <span className={dark ? "text-gray-400" : "text-gray-600"}>
            👍 {review.likesCount || 0} lượt thích
          </span>
          <span className={dark ? "text-gray-400" : "text-gray-600"}>
            💬 {review.replyCount || 0} phản hồi
          </span>
        </div>
        <button
          className={`text-xs font-medium transition-colors ${
            dark
              ? "text-purple-400 hover:text-purple-300"
              : "text-purple-600 hover:text-purple-700"
          }`}
          onClick={() => console.log("View review details:", review.reviewId)}
        >
          Xem chi tiết
        </button>
      </div>
    </div>
  );
};

export default ReviewCard;
