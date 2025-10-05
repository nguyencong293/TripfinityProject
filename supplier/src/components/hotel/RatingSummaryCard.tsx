import React from "react";
import { Star } from "lucide-react";
import { useTheme } from "../../hooks/useTheme";
import type { HotelRatingSummaryDTO } from "../../types";

interface RatingSummaryCardProps {
  summary: HotelRatingSummaryDTO;
  hotelName: string;
}

const RatingSummaryCard: React.FC<RatingSummaryCardProps> = ({
  summary,
  hotelName,
}) => {
  const { dark } = useTheme();

  // Calculate percentage for each rating
  const getPercentage = (count: number) => {
    if (summary.totalReviews === 0) return 0;
    return ((count / summary.totalReviews) * 100).toFixed(1);
  };

  // Get color for rating bar
  const getBarColor = (rating: number) => {
    if (rating === 5) return "bg-emerald-500";
    if (rating === 4) return "bg-blue-500";
    if (rating === 3) return "bg-yellow-500";
    if (rating === 2) return "bg-orange-500";
    return "bg-red-500";
  };

  // Get aspect color
  const getAspectColor = (value?: number) => {
    if (!value) return dark ? "text-gray-500" : "text-gray-400";
    if (value >= 4) return dark ? "text-emerald-400" : "text-emerald-600";
    if (value >= 3) return dark ? "text-yellow-400" : "text-yellow-600";
    return dark ? "text-red-400" : "text-red-600";
  };

  const ratingDistribution = [
    { stars: 5, count: summary.count5 },
    { stars: 4, count: summary.count4 },
    { stars: 3, count: summary.count3 },
    { stars: 2, count: summary.count2 },
    { stars: 1, count: summary.count1 },
  ];

  const aspects = [
    { label: "Sạch sẽ", value: summary.avgCleanliness },
    { label: "Dịch vụ", value: summary.avgService },
    { label: "Giá trị", value: summary.avgValueForMoney },
    { label: "Vị trí", value: summary.avgLocation },
    { label: "Tiện nghi", value: summary.avgFacilities },
  ];

  return (
    <div
      className={`rounded-xl border p-5 ${
        dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
      }`}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h4
            className={`font-semibold text-base mb-1 ${
              dark ? "text-white" : "text-gray-900"
            }`}
          >
            {hotelName}
          </h4>
          <p className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}>
            {summary.totalReviews} đánh giá
          </p>
        </div>

        {/* Average Rating Badge */}
        <div
          className={`flex flex-col items-center justify-center p-3 rounded-lg ${
            dark ? "bg-emerald-500/20" : "bg-emerald-50"
          }`}
        >
          <div className="flex items-center gap-1 mb-1">
            <Star className="w-5 h-5 text-emerald-500 fill-emerald-500" />
            <span
              className={`text-2xl font-bold ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            >
              {summary.avgRating.toFixed(1)}
            </span>
          </div>
          <p
            className={`text-xs ${
              dark ? "text-emerald-400" : "text-emerald-600"
            }`}
          >
            Trung bình
          </p>
        </div>
      </div>

      {/* Rating Distribution */}
      <div className="mb-4">
        <h5
          className={`text-sm font-semibold mb-3 ${
            dark ? "text-gray-300" : "text-gray-700"
          }`}
        >
          Phân bố đánh giá
        </h5>
        <div className="space-y-2">
          {ratingDistribution.map((item) => (
            <div key={item.stars} className="flex items-center gap-3">
              <div className="flex items-center gap-1 w-16">
                <span
                  className={`text-sm font-medium ${
                    dark ? "text-gray-300" : "text-gray-700"
                  }`}
                >
                  {item.stars}
                </span>
                <Star className="w-3.5 h-3.5 text-yellow-500 fill-yellow-500" />
              </div>

              <div className="flex-1 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div
                  className={`h-full ${getBarColor(item.stars)} transition-all`}
                  style={{ width: `${getPercentage(item.count)}%` }}
                />
              </div>

              <div className="w-16 text-right">
                <span
                  className={`text-sm font-medium ${
                    dark ? "text-gray-400" : "text-gray-600"
                  }`}
                >
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
          <h5
            className={`text-sm font-semibold mb-3 ${
              dark ? "text-gray-300" : "text-gray-700"
            }`}
          >
            Điểm chi tiết
          </h5>
          <div className="grid grid-cols-5 gap-3">
            {aspects.map((aspect) => (
              <div key={aspect.label} className="text-center">
                <p
                  className={`text-xs mb-1 ${
                    dark ? "text-gray-500" : "text-gray-500"
                  }`}
                >
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
