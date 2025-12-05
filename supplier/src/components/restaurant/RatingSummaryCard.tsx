import React from "react";
import { Star } from "lucide-react";
import type { RestaurantRatingSummaryDTO } from "../../types";
import { useLanguage } from "../../hooks/useLanguage";

interface RatingSummaryCardProps {
  summary: RestaurantRatingSummaryDTO;
  restaurantName?: string; // Optional for future use
}

const RatingSummaryCard: React.FC<RatingSummaryCardProps> = ({
  summary,
}) => {
  const { t } = useLanguage();

  // Calculate percentage for each rating
  const getPercentage = (count: number) => {
    if (summary.totalReviews === 0) return 0;
    return ((count / summary.totalReviews) * 100).toFixed(1);
  };

  // Get color for rating bar
  const getBarColor = (rating: number) => {
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
    { label: t("restaurant_aspect_food_quality"), value: summary.avgFoodQuality },
    { label: t("restaurant_aspect_service"), value: summary.avgService },
    { label: t("restaurant_aspect_ambiance"), value: summary.avgAmbiance },
    { label: t("restaurant_aspect_value"), value: summary.avgValueForMoney },
  ];

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-6">
      <h3 className="text-xl font-semibold mb-4 theme-text-primary">
        {t("rating_summary")}
      </h3>

      {/* Overall Rating */}
      <div className="flex items-center gap-6 mb-6 pb-6 border-b theme-border">
        <div className="text-center">
          <div className="text-5xl font-bold theme-text-primary mb-2">
            {summary.avgOverall?.toFixed(1) || "0.0"}
          </div>
          <div className="flex items-center justify-center gap-1 mb-1">
            {[...Array(5)].map((_, i) => (
              <Star
                key={i}
                className={`w-5 h-5 ${
                  i < Math.round(summary.avgOverall || 0)
                    ? "fill-yellow-400 theme-text-warning"
                    : "icon-disabled"
                }`}
              />
            ))}
          </div>
          <div className="text-sm theme-text-secondary">
            {summary.totalReviews} {t("reviews")}
          </div>
        </div>

        {/* Rating Distribution */}
        <div className="flex-1 space-y-2">
          {ratingDistribution.map((item) => (
            <div key={item.stars} className="flex items-center gap-2">
              <span className="text-sm theme-text-secondary w-8">
                {item.stars}★
              </span>
              <div className="flex-1 h-2 rounded-full theme-bg-secondary overflow-hidden">
                <div
                  className={`h-full ${getBarColor(item.stars)}`}
                  style={{ width: `${getPercentage(item.count)}%` }}
                />
              </div>
              <span className="text-sm theme-text-secondary w-12 text-right">
                {item.count}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Aspect Ratings */}
      <div>
        <h4 className="font-medium mb-3 theme-text-primary">
          {t("rating_aspects")}
        </h4>
        <div className="grid grid-cols-2 gap-4">
          {aspects.map((aspect) => (
            <div key={aspect.label} className="flex items-center justify-between">
              <span className="text-sm theme-text-secondary">
                {aspect.label}
              </span>
              <div className="flex items-center gap-1">
                <span className={`text-sm font-medium ${getAspectColor(aspect.value)}`}>
                  {aspect.value?.toFixed(1) || "N/A"}
                </span>
                <Star className="w-4 h-4 theme-text-warning" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default RatingSummaryCard;
