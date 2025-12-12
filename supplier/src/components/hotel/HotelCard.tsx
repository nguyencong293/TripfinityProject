import React from "react";
import {
  Hotel as HotelIcon,
  MapPin,
  Star,
  Users,
  DollarSign,
  Eye,
  Edit,
} from "lucide-react";
import type { HotelDTO } from "../../types";

export interface HotelCardProps {
  hotel: HotelDTO;
  onView: () => void;
  onEdit: () => void;
}

const HotelCard: React.FC<HotelCardProps> = ({ hotel, onView, onEdit }) => {
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
  const formatCurrency = (v: number) =>
    new Intl.NumberFormat("vi-VN").format(v);
  return (
    <div className="rounded-xl border theme-border theme-bg-card overflow-hidden transition-all hover:shadow-lg">
      <div className="relative h-48 theme-bg-secondary">
        {hotel.thumbnailUrl ? (
          <img
            src={hotel.thumbnailUrl}
            alt={hotel.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <HotelIcon className="w-16 h-16 icon-disabled" />
          </div>
        )}
        <div className="absolute top-3 right-3">
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
              hotel.hotelStatus
            )}`}
          >
            {hotel.hotelStatus}
          </span>
        </div>
      </div>
      <div className="p-4">
        <h3 className="text-lg font-semibold mb-2 line-clamp-1 theme-text-primary">
          {hotel.title}
        </h3>
        <div className="space-y-2 mb-4">
          {hotel.location && (
            <div className="flex items-center gap-2 text-sm">
              <MapPin className="w-4 h-4 icon-disabled" />
              <span className="line-clamp-1 theme-text-secondary">
                {hotel.location}
              </span>
            </div>
          )}
          <div className="flex items-center gap-4 text-sm">
            {hotel.starRating && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 theme-text-warning" />
                <span className="font-medium theme-text-secondary">
                  {hotel.starRating} sao
                </span>
              </div>
            )}
            {typeof hotel.ratingAverage === 'number' && hotel.ratingAverage > 0 && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 theme-text-warning" />
                <span className="font-medium theme-text-secondary">
                  {hotel.ratingAverage.toFixed(1)}
                </span>
              </div>
            )}
          </div>
          {hotel.capacity && (
            <div className="flex items-center gap-2 text-sm">
              <Users className="w-4 h-4 icon-disabled" />
              <span className="theme-text-secondary">
                Sức chứa: {hotel.capacity} người
              </span>
            </div>
          )}
          {hotel.totalRooms && (
            <div className="flex items-center gap-2 text-sm">
              <HotelIcon className="w-4 h-4 icon-disabled" />
              <span className="theme-text-secondary">
                {hotel.totalRooms} phòng
              </span>
            </div>
          )}
          <div className="flex items-center gap-2 text-sm">
            <DollarSign className="w-4 h-4 icon-disabled" />
            <span className="font-semibold theme-text-brand">
              {`${formatCurrency(hotel.price)} ${hotel.currencyCode}`}
              {hotel.pricePerNight !== undefined && hotel.pricePerNight !== null
                ? ` + ${formatCurrency(hotel.pricePerNight)} ${
                    hotel.currencyCode
                  } / đêm`
                : ""}
            </span>
          </div>
        </div>
        <div className="flex gap-2">
          <button
            onClick={onView}
            className="flex-1 btn-secondary btn-text-responsive flex items-center justify-center gap-2"
          >
            <Eye className="w-4 h-4" /> Xem
          </button>
          <button
            onClick={onEdit}
            className="flex-1 btn-primary btn-text-responsive flex items-center justify-center gap-2"
          >
            <Edit className="w-4 h-4" /> Sửa
          </button>
        </div>
      </div>
    </div>
  );
};

export default HotelCard;
