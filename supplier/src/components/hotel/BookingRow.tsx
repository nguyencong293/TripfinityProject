import React from "react";
import type { HotelBookingDTO } from "../../types";
import { useLanguage } from "../../hooks/useLanguage";

export interface BookingRowProps {
  booking: HotelBookingDTO;
}

const BookingRow: React.FC<BookingRowProps> = ({ booking }) => {
  const { t } = useLanguage();
  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: "theme-bg-warning theme-text-warning border-warning",
      confirmed: "theme-bg-info theme-text-info border-info",
      completed: "theme-bg-success theme-text-success border-success",
      cancelled: "theme-bg-error theme-text-error border-error",
      refunded: "theme-bg-info theme-text-info border-info",
    };
    return (
      colors[status] || "theme-bg-secondary theme-text-secondary theme-border"
    );
  };
  const formatDate = (s?: string) =>
    s ? new Date(s).toLocaleDateString("vi-VN") : "N/A";
  const formatCurrency = (v?: number) =>
    new Intl.NumberFormat("vi-VN").format(v || 0);
  return (
    <div
      className={`p-4 rounded-lg border transition-colors ${
        !booking.providerSeen
          ? "theme-bg-info border-info"
          : "theme-bg-card theme-border"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-semibold theme-text-primary">
              #{booking.bookingId}
            </h4>
            {!booking.providerSeen && (
              <span className="px-2 py-0.5 text-xs font-medium theme-bg-info theme-text-info rounded-full">
                {t("hotel_booking_new_badge")}
              </span>
            )}
          </div>
          <p className="text-sm theme-text-secondary">
            {t("user_id")}: {booking.userId}
          </p>
        </div>
        <span
          className={`px-3 py-1 text-xs font-medium rounded-full border ${getStatusColor(
            booking.bookingStatus || "pending"
          )}`}
        >
          {booking.bookingStatus || "pending"}
        </span>
      </div>
      <div className="grid grid-cols-2 gap-3 text-sm">
        <div>
          <p className="mb-1 theme-text-secondary">{t("checkin_date")}</p>
          <p className="font-medium theme-text-primary">
            {formatDate(booking.startDate)}
          </p>
        </div>
        <div>
          <p className="mb-1 theme-text-secondary">{t("checkout_date")}</p>
          <p className="font-medium theme-text-primary">
            {formatDate(booking.endDate)}
          </p>
        </div>
        <div>
          <p className="mb-1 theme-text-secondary">{t("guests")}</p>
          <p className="font-medium theme-text-primary">
            {booking.numAdults} {t("adults_suffix")}
            {booking.numChildren
              ? `, ${booking.numChildren} ${t("children_suffix")}`
              : ""}
          </p>
        </div>
        <div>
          <p className="mb-1 theme-text-secondary">{t("total_amount")}</p>
          <p className="font-semibold theme-text-brand">
            {formatCurrency(booking.totalPrice)} {booking.currencyCode || "VND"}
          </p>
        </div>
      </div>
      {booking.providerNotes && (
        <div className="mt-3 p-2 rounded theme-bg-secondary">
          <p className="text-xs theme-text-secondary">
            {t("note_prefix")} {booking.providerNotes}
          </p>
        </div>
      )}
    </div>
  );
};

export default BookingRow;
