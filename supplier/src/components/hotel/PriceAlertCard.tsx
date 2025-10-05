import React from "react";
import { AlertCircle, TrendingDown, Clock, User } from "lucide-react";
import { useTheme } from "../../hooks/useTheme";
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
  const { dark } = useTheme();

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
      className={`rounded-xl border p-4 transition-all ${
        isTriggered
          ? dark
            ? "bg-red-500/10 border-red-500/30"
            : "bg-red-50 border-red-200"
          : dark
          ? "bg-gray-800/50 border-gray-700"
          : "bg-white border-gray-200"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h4
              className={`font-semibold text-sm ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              {hotelName}
            </h4>
            {isTriggered && (
              <span className="px-2 py-0.5 text-xs font-medium bg-red-500 text-white rounded-full">
                Đã kích hoạt
              </span>
            )}
            {!alert.isActive && (
              <span
                className={`px-2 py-0.5 text-xs font-medium rounded-full ${
                  dark
                    ? "bg-gray-700 text-gray-400"
                    : "bg-gray-200 text-gray-600"
                }`}
              >
                Tạm dừng
              </span>
            )}
          </div>
          <p className={`text-xs ${dark ? "text-gray-400" : "text-gray-600"}`}>
            Alert ID: #{alert.alertId} • User ID: {alert.userId}
          </p>
        </div>
        <div
          className={`p-2 rounded-lg ${
            isTriggered
              ? dark
                ? "bg-red-500/20"
                : "bg-red-100"
              : dark
              ? "bg-orange-500/20"
              : "bg-orange-100"
          }`}
        >
          {isTriggered ? (
            <AlertCircle className="w-5 h-5 text-red-500" />
          ) : (
            <TrendingDown className="w-5 h-5 text-orange-500" />
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 mb-3">
        <div>
          <p
            className={`text-xs mb-1 ${
              dark ? "text-gray-400" : "text-gray-500"
            }`}
          >
            Giá mục tiêu
          </p>
          <p
            className={`text-sm font-semibold ${
              dark ? "text-orange-400" : "text-orange-600"
            }`}
          >
            {formatPrice(alert.targetPrice, alert.currencyCode || "VND")}
          </p>
        </div>

        {currentPrice !== undefined && (
          <div>
            <p
              className={`text-xs mb-1 ${
                dark ? "text-gray-400" : "text-gray-500"
              }`}
            >
              Giá hiện tại
            </p>
            <p
              className={`text-sm font-semibold ${
                isTriggered
                  ? "text-red-500"
                  : dark
                  ? "text-emerald-400"
                  : "text-emerald-600"
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
              ? dark
                ? "bg-red-500/10 text-red-400"
                : "bg-red-50 text-red-700"
              : dark
              ? "bg-emerald-500/10 text-emerald-400"
              : "bg-emerald-50 text-emerald-700"
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
          <Clock
            className={`w-3.5 h-3.5 ${
              dark ? "text-gray-500" : "text-gray-400"
            }`}
          />
          <span className={dark ? "text-gray-400" : "text-gray-600"}>
            {formatDate(alert.createdAt)}
          </span>
        </div>

        {alert.lastNotifiedAt && (
          <div className="flex items-center gap-1">
            <User
              className={`w-3.5 h-3.5 ${
                dark ? "text-gray-500" : "text-gray-400"
              }`}
            />
            <span className={dark ? "text-gray-400" : "text-gray-600"}>
              Đã thông báo: {formatDate(alert.lastNotifiedAt)}
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

export default PriceAlertCard;
