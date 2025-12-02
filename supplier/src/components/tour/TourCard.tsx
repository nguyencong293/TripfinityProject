import React from "react";
import {
  MapPin,
  Calendar,
  Users,
  DollarSign,
  Eye,
  Edit,
} from "lucide-react";
import type { TourDTO } from "../../types";

export interface TourCardProps {
  tour: TourDTO;
  onView: () => void;
  onEdit: () => void;
}

const TourCard: React.FC<TourCardProps> = ({ tour, onView, onEdit }) => {
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

  const getDifficultyColor = (level?: string) => {
    switch (level) {
      case "easy":
        return "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400";
      case "moderate":
        return "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400";
      case "hard":
        return "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400";
      default:
        return "bg-gray-100 text-gray-700 dark:bg-gray-900/30 dark:text-gray-400";
    }
  };

  const getDifficultyLabel = (level?: string) => {
    switch (level) {
      case "easy":
        return "Dễ";
      case "moderate":
        return "Trung bình";
      case "hard":
        return "Khó";
      default:
        return "Chưa rõ";
    }
  };

  const formatCurrency = (v: number) =>
    new Intl.NumberFormat("vi-VN").format(v);

  return (
    <div className="rounded-xl border theme-border theme-bg-card overflow-hidden transition-all hover:shadow-lg">
      <div className="relative h-48 theme-bg-secondary">
        {tour.thumbnailUrl ? (
          <img
            src={tour.thumbnailUrl}
            alt={tour.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <MapPin className="w-16 h-16 icon-disabled" />
          </div>
        )}
        <div className="absolute top-3 right-3 flex gap-2">
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
              tour.tourStatus || "published"
            )}`}
          >
            {tour.tourStatus === "published"
              ? "Đã xuất bản"
              : tour.tourStatus === "archived"
              ? "Đã lưu trữ"
              : tour.tourStatus === "disabled"
              ? "Vô hiệu hóa"
              : "Không xác định"}
          </span>
          {tour.difficultyLevel && (
            <span
              className={`px-3 py-1 rounded-full text-xs font-medium ${getDifficultyColor(
                tour.difficultyLevel
              )}`}
            >
              {getDifficultyLabel(tour.difficultyLevel)}
            </span>
          )}
        </div>
      </div>

      <div className="p-5">
        <h3 className="font-semibold theme-text-primary text-h3-mobile sm:text-h3-tablet mb-2 line-clamp-2">
          {tour.title}
        </h3>

        <div className="flex flex-col gap-2 theme-text-secondary text-body2-mobile sm:text-body2-tablet">
          <div className="flex items-center gap-2">
            <MapPin className="w-4 h-4 flex-shrink-0" />
            <span className="line-clamp-1">{tour.location || "Chưa có"}</span>
          </div>

          <div className="flex items-center gap-2">
            <Calendar className="w-4 h-4 flex-shrink-0" />
            <span>
              {tour.durationDays
                ? `${tour.durationDays} ngày`
                : "Chưa có lịch trình"}
            </span>
          </div>

          <div className="flex items-center gap-2">
            <Users className="w-4 h-4 flex-shrink-0" />
            <span>
              {tour.capacity
                ? `${tour.capacity} người`
                : "Chưa xác định sức chứa"}
            </span>
          </div>

          <div className="flex items-center gap-2">
            <DollarSign className="w-4 h-4 flex-shrink-0" />
            <span className="font-semibold theme-text-primary">
              {formatCurrency(tour.price)} {tour.currencyCode || "VND"}
            </span>
          </div>
        </div>

        <div className="flex gap-2 mt-4">
          <button
            onClick={onView}
            className="flex-1 px-4 py-2 rounded border theme-border theme-text-primary hover:bg-light-secondary dark:hover:bg-dark-secondary transition-colors flex items-center justify-center gap-2"
          >
            <Eye className="w-4 h-4" />
            <span>Xem</span>
          </button>
          <button
            onClick={onEdit}
            className="flex-1 px-4 py-2 rounded bg-light-primary dark:bg-dark-primary text-white hover:opacity-90 transition-opacity flex items-center justify-center gap-2"
          >
            <Edit className="w-4 h-4" />
            <span>Sửa</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default TourCard;
