import React from "react";
import {
  Utensils,
  MapPin,
  Star,
  Users,
  DollarSign,
  Eye,
  Edit,
} from "lucide-react";
import type { RestaurantDTO } from "../../types";

export interface RestaurantCardProps {
  restaurant: RestaurantDTO;
  onView: () => void;
  onEdit: () => void;
}

const RestaurantCard: React.FC<RestaurantCardProps> = ({ restaurant, onView, onEdit }) => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case "published":
        return "theme-bg-success theme-text-success border-success";
      case "archived":
        return "theme-bg-warning theme-text-warning border-warning";
      case "disabled":
        return "theme-bg-error theme-text-error border-error";
      default:
        return "theme-bg-info theme-text-info border-info";
    }
  };

  const getPriceLevelLabel = (level: string) => {
    switch (level) {
      case "cheap":
        return "Bình dân";
      case "moderate":
        return "Trung bình";
      case "expensive":
        return "Cao cấp";
      case "luxury":
        return "Sang trọng";
      default:
        return level;
    }
  };

  const formatCurrency = (v: number) =>
    new Intl.NumberFormat("vi-VN").format(v);

  return (
    <div className="rounded-xl border theme-border theme-bg-card overflow-hidden transition-all hover:shadow-lg">
      <div className="relative h-48 theme-bg-secondary">
        {restaurant.thumbnailUrl ? (
          <img
            src={restaurant.thumbnailUrl}
            alt={restaurant.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <Utensils className="w-16 h-16 icon-disabled" />
          </div>
        )}
        <div className="absolute top-3 right-3 flex gap-2">
          {restaurant.priceLevel && (
            <span className="px-3 py-1 rounded-full text-xs font-medium border theme-bg-info theme-text-info border-info">
              {getPriceLevelLabel(restaurant.priceLevel)}
            </span>
          )}
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
              restaurant.restaurantStatus
            )}`}
          >
            {restaurant.restaurantStatus}
          </span>
        </div>
        {restaurant.isFeatured && (
          <div className="absolute top-3 left-3">
            <span className="px-3 py-1 rounded-full text-xs font-medium theme-bg-warning theme-text-warning border border-warning">
              Nổi bật
            </span>
          </div>
        )}
      </div>
      <div className="p-4">
        <h3 className="text-lg font-semibold mb-2 line-clamp-1 theme-text-primary">
          {restaurant.title}
        </h3>
        <div className="space-y-2 mb-4">
          {restaurant.location && (
            <div className="flex items-center gap-2 text-sm">
              <MapPin className="w-4 h-4 icon-disabled" />
              <span className="line-clamp-1 theme-text-secondary">
                {restaurant.location}
              </span>
            </div>
          )}
          <div className="flex items-center gap-4 text-sm">
            {restaurant.ratingAverage !== undefined && restaurant.ratingAverage > 0 && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 theme-text-warning" />
                <span className="font-medium theme-text-secondary">
                  {restaurant.ratingAverage.toFixed(1)}
                </span>
              </div>
            )}
            {restaurant.totalReviews !== undefined && restaurant.totalReviews > 0 && (
              <span className="text-xs theme-text-secondary">
                ({restaurant.totalReviews} đánh giá)
              </span>
            )}
          </div>
          {restaurant.capacity && (
            <div className="flex items-center gap-2 text-sm">
              <Users className="w-4 h-4 icon-disabled" />
              <span className="theme-text-secondary">
                Sức chứa: {restaurant.capacity} người
              </span>
            </div>
          )}
          {restaurant.price && (
            <div className="flex items-center gap-2 text-sm">
              <DollarSign className="w-4 h-4 icon-disabled" />
              <span className="font-medium theme-text-primary">
                {formatCurrency(restaurant.price)} {restaurant.currencyCode || "VND"}
              </span>
            </div>
          )}
          {restaurant.cuisinesJson && restaurant.cuisinesJson.length > 0 && (
            <div className="flex items-center gap-2 text-sm">
              <Utensils className="w-4 h-4 icon-disabled" />
              <span className="line-clamp-1 theme-text-secondary">
                {restaurant.cuisinesJson.slice(0, 2).join(", ")}
                {restaurant.cuisinesJson.length > 2 && ` +${restaurant.cuisinesJson.length - 2}`}
              </span>
            </div>
          )}
        </div>
        <div className="flex gap-2">
          <button
            onClick={onView}
            className="flex-1 px-4 py-2 rounded-lg theme-bg-primary hover:theme-bg-primary-hover theme-text-primary-btn transition-colors flex items-center justify-center gap-2"
          >
            <Eye className="w-4 h-4" />
            Xem
          </button>
          <button
            onClick={onEdit}
            className="flex-1 px-4 py-2 rounded-lg theme-bg-secondary hover:theme-bg-secondary-hover theme-text-primary transition-colors flex items-center justify-center gap-2"
          >
            <Edit className="w-4 h-4" />
            Sửa
          </button>
        </div>
      </div>
    </div>
  );
};

export default RestaurantCard;
