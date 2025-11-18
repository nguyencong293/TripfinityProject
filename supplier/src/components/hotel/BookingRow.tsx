import React from "react";
import { Calendar, Users, Clock, Eye, CheckCircle, XCircle, User, Phone, Hotel as HotelIcon } from "lucide-react";
import type { HotelBookingDTO } from "../../types";
import { useLanguage } from "../../hooks/useLanguage";

export interface BookingRowProps {
  booking: HotelBookingDTO;
  hotelName?: string;
  userName?: string;
  userPhone?: string;
  onView?: () => void;
  onConfirm?: () => void;
  onCancel?: () => void;
}

const BookingRow: React.FC<BookingRowProps> = ({ booking, hotelName, userName, userPhone, onView, onConfirm, onCancel }) => {
  const { t } = useLanguage();
  
  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: "bg-orange-100 text-orange-700 border-orange-300",
      confirmed: "bg-blue-100 text-blue-700 border-blue-300",
      completed: "bg-green-100 text-green-700 border-green-300",
      cancelled: "bg-red-100 text-red-700 border-red-300",
      refunded: "bg-purple-100 text-purple-700 border-purple-300",
    };
    return colors[status] || "theme-bg-secondary theme-text-secondary theme-border";
  };

  const getStatusLabel = (status: string) => {
    const labels: Record<string, string> = {
      pending: t("booking_status_pending") || "Chờ xác nhận",
      confirmed: t("booking_status_confirmed") || "Đã xác nhận",
      completed: t("booking_status_completed") || "Hoàn thành",
      cancelled: t("booking_status_cancelled") || "Đã hủy",
      refunded: t("booking_status_refunded") || "Đã hoàn tiền",
    };
    return labels[status] || status;
  };
  
  const formatDate = (s?: string) => s ? new Date(s).toLocaleDateString("vi-VN") : "N/A";
  const formatDateTime = (s?: string) => s ? new Date(s).toLocaleString("vi-VN", { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : "N/A";
  const formatCurrency = (v?: number) => new Intl.NumberFormat("vi-VN").format(v || 0);
    
  const getPaymentStatusLabel = (method?: string) => {
    if (!method || method === "counter") {
      return { label: t("payment_counter") || "Thanh toán tại quầy", sublabel: t("payment_counter_desc") || "Chưa thanh toán", color: "bg-yellow-100 text-yellow-800 border-yellow-300", icon: "💵" };
    }
    return { label: t("payment_online") || "Thanh toán online", sublabel: method.toUpperCase() + " - " + (t("payment_completed") || "Đã thanh toán"), color: "bg-green-100 text-green-800 border-green-300", icon: "✅" };
  };

  const paymentInfo = getPaymentStatusLabel(booking.paymentMethod);

  return (
    <div className={`p-5 rounded-xl border-2 transition-all hover:shadow-lg ${!booking.providerSeen ? "bg-blue-50 border-blue-400 ring-2 ring-blue-200" : "theme-bg-card theme-border hover:border-gray-300"}`}>
      <div className="flex items-start justify-between mb-4 pb-4 border-b theme-border">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2 flex-wrap">
            <h3 className="text-xl font-bold theme-text-primary">#{booking.bookingId}</h3>
            {!booking.providerSeen && <span className="px-2.5 py-1 text-xs font-bold bg-red-500 text-white rounded-full animate-pulse shadow-sm">{t("hotel_booking_new_badge") || "MỚI"}</span>}
            <span className={`px-3 py-1 text-xs font-semibold rounded-full border-2 ${getStatusColor(booking.bookingStatus || "pending")}`}>{getStatusLabel(booking.bookingStatus || "pending")}</span>
          </div>
          <div className="flex items-center gap-2 text-sm theme-text-secondary">
            <Clock className="w-4 h-4" />
            <span className="font-medium">{formatDateTime(booking.createdAt)}</span>
          </div>
        </div>
      </div>

      {hotelName && (
        <div className="mb-4 p-3 rounded-lg bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200">
          <div className="flex items-center gap-2">
            <HotelIcon className="w-5 h-5 text-blue-600" />
            <div>
              <p className="text-xs text-blue-600 font-medium mb-0.5">{t("hotel_name") || "Khách sạn"}</p>
              <p className="text-base font-bold text-blue-900">{hotelName}</p>
            </div>
          </div>
        </div>
      )}

      <div className="mb-4 p-3 rounded-lg bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200">
        <p className="text-xs text-green-600 font-medium mb-2">{t("customer_info") || "Thông tin khách hàng"}</p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
          <div className="flex items-center gap-2">
            <User className="w-4 h-4 text-green-600 flex-shrink-0" />
            <span className="text-sm font-semibold text-green-900">{userName || `User ID: ${booking.userId}`}</span>
          </div>
          {userPhone && (
            <div className="flex items-center gap-2">
              <Phone className="w-4 h-4 text-green-600 flex-shrink-0" />
              <span className="text-sm font-semibold text-green-900">{userPhone}</span>
            </div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
        <div className="flex items-start gap-2 p-3 rounded-lg theme-bg-secondary">
          <Calendar className="w-5 h-5 mt-0.5 text-green-600 flex-shrink-0" />
          <div className="min-w-0 flex-1">
            <p className="text-xs theme-text-secondary font-medium mb-1">{t("checkin_date") || "Ngày nhận phòng"}</p>
            <p className="font-bold theme-text-primary text-base truncate">{formatDate(booking.startDate)}</p>
          </div>
        </div>
        <div className="flex items-start gap-2 p-3 rounded-lg theme-bg-secondary">
          <Calendar className="w-5 h-5 mt-0.5 text-red-600 flex-shrink-0" />
          <div className="min-w-0 flex-1">
            <p className="text-xs theme-text-secondary font-medium mb-1">{t("checkout_date") || "Ngày trả phòng"}</p>
            <p className="font-bold theme-text-primary text-base truncate">{formatDate(booking.endDate)}</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
        <div className="flex items-start gap-2 p-3 rounded-lg theme-bg-secondary">
          <Users className="w-5 h-5 mt-0.5 text-blue-600 flex-shrink-0" />
          <div className="min-w-0 flex-1">
            <p className="text-xs theme-text-secondary font-medium mb-1">{t("guests") || "Số khách"}</p>
            <p className="font-bold theme-text-primary text-base">{booking.numAdults} {t("adults_suffix") || "người lớn"}{booking.numChildren ? `, ${booking.numChildren} ${t("children_suffix") || "trẻ em"}` : ""}</p>
          </div>
        </div>
        <div className={`flex items-start gap-2 p-3 rounded-lg border-2 ${paymentInfo.color}`}>
          <span className="text-xl">{paymentInfo.icon}</span>
          <div className="min-w-0 flex-1">
            <p className="text-xs font-semibold mb-1 opacity-80">{t("payment_status") || "Thông tin thanh toán"}</p>
            <p className="font-bold text-sm leading-tight">{paymentInfo.label}</p>
            <p className="text-xs mt-0.5 opacity-75">{paymentInfo.sublabel}</p>
          </div>
        </div>
      </div>

      <div className="mb-4 p-4 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 shadow-lg">
        <div className="flex items-center justify-between">
          <span className="text-sm font-semibold text-white opacity-90">{t("total_amount") || "Tổng tiền"}</span>
          <div className="text-right">
            <span className="text-2xl font-black text-white block">{formatCurrency(booking.totalPrice)}</span>
            <span className="text-sm font-medium text-white opacity-90">{booking.currencyCode || "VND"}</span>
          </div>
        </div>
      </div>

      {booking.providerNotes && (
        <div className="mb-4 p-3 rounded-lg bg-amber-50 border-2 border-amber-300">
          <p className="text-xs font-bold text-amber-800 mb-1.5 flex items-center gap-1">📝 {t("provider_notes") || "Ghi chú / Yêu cầu đặc biệt"}</p>
          <p className="text-sm text-amber-900 font-medium leading-relaxed">{booking.providerNotes}</p>
        </div>
      )}

      <div className="flex items-center gap-2 flex-wrap pt-3 border-t theme-border">
        {onView && <button onClick={onView} className="flex items-center gap-2 px-4 py-2 text-sm font-semibold theme-text-primary hover:theme-text-brand bg-white hover:bg-blue-50 border-2 theme-border hover:border-blue-300 rounded-lg transition-all shadow-sm hover:shadow"><Eye className="w-4 h-4" />{t("view_detail") || "Xem chi tiết"}</button>}
        {booking.providerConfirmed === 0 && onConfirm && <button onClick={onConfirm} className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-green-600 hover:bg-green-700 rounded-lg transition-all shadow-sm hover:shadow-md"><CheckCircle className="w-4 h-4" />{t("confirm_booking") || "Xác nhận đặt phòng"}</button>}
        {(booking.providerConfirmed === 0 || booking.providerConfirmed === 1) && onCancel && <button onClick={onCancel} className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-lg transition-all shadow-sm hover:shadow-md"><XCircle className="w-4 h-4" />{t("cancel_booking") || "Hủy đặt phòng"}</button>}
      </div>
    </div>
  );
};

export default BookingRow;
