import React from "react";
import { Star } from "lucide-react";
import type { HotelRatingSummaryDTO } from "../../types";
import { useLanguage } from "../../hooks/useLanguage";

interface RatingSummaryCardProps {
  summary: HotelRatingSummaryDTO;
  hotelName: string;
}

const RatingSummaryCard: React.FC<RatingSummaryCardProps> = ({
  summary,
  hotelName,
}) => {
  const { t } = useLanguage();
  // Calculate percentage for each rating
  const getPercentage = (count: number) => {
    if (summary.totalReviews === 0) return 0;
    return ((count / summary.totalReviews) * 100).toFixed(1);
  };

  // Get color for rating bar
  const getBarColor = (rating: number) => {
    // Map to theme-friendly colors; keeping semantic hues
    if (rating === 5) return "theme-bg-success";
    if (rating === 4) return "theme-bg-info";
    if (rating === 3) return "theme-bg-warning";
    if (rating === 2) return "theme-bg-warning";
    return "theme-bg-error";
  };

  // Get aspect color
  const getAspectColor = (value?: number) => {
    if (!value) return "theme-text-secondary";
    if (value >= 4) return "theme-text-success";
    if (value >= 3) return "theme-text-warning";
    return "theme-text-error";
  };

  const ratingDistribution = [
    { stars: 5, count: summary.count5 },
    { stars: 4, count: summary.count4 },
    { stars: 3, count: summary.count3 },
    { stars: 2, count: summary.count2 },
    { stars: 1, count: summary.count1 },
  ];

  const aspects = [
    { label: t("hotel_aspect_cleanliness"), value: summary.avgCleanliness },
    { label: t("hotel_aspect_service"), value: summary.avgService },
    { label: t("hotel_aspect_value"), value: summary.avgValueForMoney },
    { label: t("hotel_aspect_location"), value: summary.avgLocation },
    { label: t("hotel_aspect_facilities"), value: summary.avgFacilities },
  ];

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-5">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h4 className="font-semibold text-base mb-1 theme-text-primary">
            {hotelName}
          </h4>
          <p className="text-sm theme-text-secondary">
            {summary.totalReviews} {t("hotel_rating_total_reviews_suffix")}
          </p>
        </div>

        {/* Average Rating Badge */}
        <div className="flex flex-col items-center justify-center p-3 rounded-lg theme-bg-success">
          <div className="flex items-center gap-1 mb-1">
            <Star className="w-5 h-5 theme-text-success" />
            <span className="text-2xl font-bold theme-text-success">
              {summary.avgRating.toFixed(1)}
            </span>
          </div>
          <p className="text-xs theme-text-success">
            {t("hotel_rating_average")}
          </p>
        </div>
      </div>

      {/* Rating Distribution */}
      <div className="mb-4">
        <h5 className="text-sm font-semibold mb-3 theme-text-primary">
          {t("hotel_rating_distribution")}
        </h5>
        <div className="space-y-2">
          {ratingDistribution.map((item) => (
            <div key={item.stars} className="flex items-center gap-3">
              <div className="flex items-center gap-1 w-16">
                <span className="text-sm font-medium theme-text-primary">
                  {item.stars}
                </span>
                <Star className="w-3.5 h-3.5 icon-primary" />
              </div>

              <div className="flex-1 h-2 theme-bg-skeleton rounded-full overflow-hidden">
                <div
                  className={`h-full ${getBarColor(item.stars)} transition-all`}
                  style={{ width: `${getPercentage(item.count)}%` }}
                />
              </div>

              <div className="w-16 text-right">
                <span className="text-sm font-medium theme-text-secondary">
                  {item.count} ({getPercentage(item.count)}%)
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Aspect Scores */}
      {(summary.avgCleanliness ||
        summary.avgService ||
        summary.avgValueForMoney ||
        summary.avgLocation ||
        summary.avgFacilities) && (
        <div>
          <h5 className="text-sm font-semibold mb-3 theme-text-primary">
            {t("hotel_rating_detail_scores")}
          </h5>
          <div className="grid grid-cols-5 gap-3">
            {aspects.map((aspect) => (
              <div key={aspect.label} className="text-center">
                <p className="text-xs mb-1 theme-text-secondary">
                  {aspect.label}
                </p>
                <p
                  className={`text-lg font-bold ${getAspectColor(
                    aspect.value
                  )}`}
                >
                  {aspect.value ? aspect.value.toFixed(1) : "N/A"}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default RatingSummaryCard;
