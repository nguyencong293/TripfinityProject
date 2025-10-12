import React from "react";
import { AlertCircle, TrendingDown, Clock, User } from "lucide-react";
import type { HotelPriceAlertDTO } from "../../types";

interface PriceAlertCardProps {
  alert: HotelPriceAlertDTO;
  hotelName: string;
  currentPrice?: number;
}

const PriceAlertCard: React.FC<PriceAlertCardProps> = ({
  alert,
  hotelName,
  currentPrice,
}) => {
  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A";
    return new Intl.DateTimeFormat("vi-VN", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    }).format(new Date(dateString));
  };

  const formatPrice = (price: number, currency: string = "VND") => {
    return `${price.toLocaleString("vi-VN")} ${currency}`;
  };

  // Calculate price difference
  const priceDifference =
    currentPrice !== undefined ? currentPrice - alert.targetPrice : undefined;
  const isTriggered =
    priceDifference !== undefined && currentPrice! <= alert.targetPrice;

  return (
    <div
      className={
        "rounded-xl border theme-border p-4 transition-all " +
        (isTriggered ? "theme-bg-error" : "theme-bg-card")
      }
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-semibold text-sm theme-text-primary">
              {hotelName}
            </h4>
            {isTriggered && (
              <span className="px-2 py-0.5 text-xs font-medium rounded-full theme-bg-error theme-text-error">
                Đã kích hoạt
              </span>
            )}
            {!alert.isActive && (
              <span className="px-2 py-0.5 text-xs font-medium rounded-full theme-bg-secondary theme-text-secondary">
                Tạm dừng
              </span>
            )}
          </div>
          <p className="text-xs theme-text-secondary">
            Alert ID: #{alert.alertId} • User ID: {alert.userId}
          </p>
        </div>
        <div
          className={`p-2 rounded-lg ${
            isTriggered ? "theme-bg-error" : "theme-bg-warning"
          }`}
        >
          {isTriggered ? (
            <AlertCircle className="w-5 h-5 theme-text-error" />
          ) : (
            <TrendingDown className="w-5 h-5 theme-text-warning" />
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 mb-3">
        <div>
          <p className="text-xs mb-1 theme-text-secondary">Giá mục tiêu</p>
          <p className="text-sm font-semibold theme-text-warning">
            {formatPrice(alert.targetPrice, alert.currencyCode || "VND")}
          </p>
        </div>

        {currentPrice !== undefined && (
          <div>
            <p className="text-xs mb-1 theme-text-secondary">Giá hiện tại</p>
            <p
              className={`text-sm font-semibold ${
                isTriggered ? "theme-text-error" : "theme-text-success"
              }`}
            >
              {formatPrice(currentPrice, alert.currencyCode || "VND")}
            </p>
          </div>
        )}
      </div>

      {priceDifference !== undefined && (
        <div
          className={`mb-3 p-2 rounded-lg text-xs ${
            isTriggered
              ? "theme-bg-error theme-text-error"
              : "theme-bg-success theme-text-success"
          }`}
        >
          {isTriggered ? (
            <span>
              ⚠️ Giá đã giảm xuống {formatPrice(Math.abs(priceDifference))}
            </span>
          ) : (
            <span>✓ Giá cao hơn mục tiêu {formatPrice(priceDifference)}</span>
          )}
        </div>
      )}

      <div className="flex items-center gap-4 text-xs">
        <div className="flex items-center gap-1">
          <Clock className="w-3.5 h-3.5 icon-primary" />
          <span className="theme-text-secondary">
            {formatDate(alert.createdAt)}
          </span>
        </div>

        {alert.lastNotifiedAt && (
          <div className="flex items-center gap-1">
            <User className="w-3.5 h-3.5 icon-primary" />
            <span className="theme-text-secondary">
              Đã thông báo: {formatDate(alert.lastNotifiedAt)}
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

export default PriceAlertCard;
