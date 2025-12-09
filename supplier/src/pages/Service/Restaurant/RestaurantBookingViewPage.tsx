import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Calendar,
  User,
  Phone,
  Mail,
  MapPin,
  DollarSign,
  CreditCard,
  CheckCircle,
  XCircle,
  Clock,
  UtensilsCrossed,
  Users,
  Loader2,
  AlertCircle,
  MessageSquare,
} from "lucide-react";
import { useLanguage } from "../../../hooks/useLanguage";
import type { RestaurantBookingDTO, RestaurantDTO, UserDTO } from "../../../types";
import api from "../../../services/api";
import { getUserById } from "../../../services/providerService";
import ConfirmModal from "../../../components/common/ConfirmModal";

const RestaurantBookingViewPage: React.FC = () => {
  const { bookingId } = useParams<{ bookingId: string }>();
  const navigate = useNavigate();
  const { t } = useLanguage();
  
  const [booking, setBooking] = useState<RestaurantBookingDTO | null>(null);
  const [restaurant, setRestaurant] = useState<RestaurantDTO | null>(null);
  const [user, setUser] = useState<UserDTO | null>(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [modalState, setModalState] = useState<{
    isOpen: boolean;
    type: "confirm" | "cancel";
  }>({ isOpen: false, type: "confirm" });

  useEffect(() => {
    if (!bookingId) return;
    
    const loadBookingDetails = async () => {
      try {
        setLoading(true);
        setError(null);

        // Fetch booking details
        const bookingRes = await api.get<RestaurantBookingDTO>(`/restaurant-bookings/${bookingId}`);
        const bookingData = bookingRes.data;
        setBooking(bookingData);

        // Fetch restaurant details
        if (bookingData.restaurantId) {
          const restaurantRes = await api.get<RestaurantDTO>(`/restaurants/${bookingData.restaurantId}`);
          setRestaurant(restaurantRes.data);
        }

        // Fetch user details
        if (bookingData.userId) {
          const userData = await getUserById(bookingData.userId);
          setUser(userData);
        }
      } catch (e) {
        console.error("Error loading booking details:", e);
        setError(e instanceof Error ? e.message : "Failed to load booking details");
      } finally {
        setLoading(false);
      }
    };

    loadBookingDetails();
  }, [bookingId]);

  const handleConfirmBooking = async () => {
    if (!bookingId || !booking) return;
    setModalState({ isOpen: true, type: "confirm" });
  };

  const handleCancelBooking = async () => {
    if (!bookingId || !booking) return;
    setModalState({ isOpen: true, type: "cancel" });
  };

  const executeAction = async () => {
    if (!bookingId) return;

    try {
      setActionLoading(true);
      
      if (modalState.type === "confirm") {
        await api.patch(`/restaurant-bookings/${bookingId}/status/confirmed`);
      } else {
        await api.patch(`/restaurant-bookings/${bookingId}/status/cancelled`);
      }
      
      // Refresh booking data
      const bookingRes = await api.get<RestaurantBookingDTO>(`/restaurant-bookings/${bookingId}`);
      setBooking(bookingRes.data);
      
      setModalState({ isOpen: false, type: "confirm" });
    } catch (e) {
      console.error(`Error ${modalState.type}ing booking:`, e);
      alert(
        modalState.type === "confirm"
          ? t("booking_confirmed_error") || "Lỗi khi xác nhận đặt bàn"
          : t("booking_cancelled_error") || "Lỗi khi hủy đặt bàn"
      );
    } finally {
      setActionLoading(false);
    }
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return "N/A";
    return new Date(dateStr).toLocaleDateString("vi-VN");
  };

  const formatDateTime = (dateStr?: string) => {
    if (!dateStr) return "N/A";
    return new Date(dateStr).toLocaleString("vi-VN");
  };

  const formatTime = (timeStr?: string) => {
    if (!timeStr) return "N/A";
    return timeStr.substring(0, 5); // HH:mm:ss -> HH:mm
  };

  const formatCurrency = (amount?: number, currency?: string) => {
    if (amount === undefined) return "N/A";
    return `${amount.toLocaleString("vi-VN")} ${currency || "VND"}`;
  };

  const getPaymentMethodLabel = (method?: string) => {
    if (!method || method === "counter") {
      return t("payment_counter") || "Thanh toán tại quầy";
    }
    const methodMap: Record<string, string> = {
      zalopay: "ZaloPay",
      vnpay: "VNPay",
      momo: "MoMo",
      visa: "Visa",
      mastercard: "Mastercard",
      paypal: "PayPal",
    };
    return methodMap[method.toLowerCase()] || method.toUpperCase();
  };

  const getStatusBadge = (status?: string) => {
    const statusConfig: Record<string, { label: string; className: string }> = {
      pending: { label: "Chờ xác nhận", className: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300" },
      confirmed: { label: "Đã xác nhận", className: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300" },
      cancelled: { label: "Đã hủy", className: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300" },
      completed: { label: "Hoàn thành", className: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300" },
      no_show: { label: "Không đến", className: "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300" },
    };
    const config = statusConfig[status || "pending"] || statusConfig.pending;
    return (
      <span className={`px-3 py-1 rounded-full text-sm font-medium ${config.className}`}>
        {config.label}
      </span>
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
      </div>
    );
  }

  if (error || !booking) {
    return (
      <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="rounded-xl border theme-border theme-bg-card p-6 text-center">
          <AlertCircle className="w-12 h-12 mx-auto mb-4 text-red-500" />
          <p className="text-lg theme-text-primary mb-4">{error || "Không tìm thấy thông tin đặt bàn"}</p>
          <button
            onClick={() => navigate("/supplier/service/restaurant/bookings")}
            className="btn-primary"
          >
            {t("back") || "Quay lại"}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate("/supplier/service/restaurant/bookings")}
            className="p-2 rounded-lg theme-border border hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold theme-text-primary">
              {t("booking_details") || "Chi tiết đặt bàn"} #{booking.bookingId}
            </h1>
            <p className="text-sm theme-text-secondary mt-1">
              {t("created_at") || "Tạo lúc"}: {formatDateTime(booking.createdAt)}
            </p>
          </div>
        </div>
        <div>{getStatusBadge(booking.bookingStatus)}</div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content - 2 columns */}
        <div className="lg:col-span-2 space-y-6">
          {/* Restaurant Information */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <UtensilsCrossed className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("restaurant_information") || "Thông tin nhà hàng"}
              </h2>
            </div>
            {restaurant ? (
              <div className="space-y-3">
                <div className="flex items-start gap-3">
                  {restaurant.thumbnailUrl && (
                    <img
                      src={restaurant.thumbnailUrl}
                      alt={restaurant.title}
                      className="w-24 h-24 rounded-lg object-cover"
                    />
                  )}
                  <div>
                    <h3 className="font-semibold theme-text-primary text-lg">{restaurant.title}</h3>
                    <div className="flex items-center gap-2 mt-2 text-sm theme-text-secondary">
                      <MapPin className="w-4 h-4" />
                      <span>{restaurant.location || restaurant.address}</span>
                    </div>
                    {restaurant.phone && (
                      <div className="flex items-center gap-2 mt-1 text-sm theme-text-secondary">
                        <Phone className="w-4 h-4" />
                        <span>{restaurant.phone}</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ) : (
              <p className="theme-text-secondary">Đang tải thông tin nhà hàng...</p>
            )}
          </div>

          {/* Customer Information */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <User className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("customer_information") || "Thông tin khách hàng"}
              </h2>
            </div>
            {user ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-center gap-3">
                  <User className="w-5 h-5 theme-text-secondary" />
                  <div>
                    <p className="text-sm theme-text-secondary">{t("full_name") || "Họ tên"}</p>
                    <p className="font-medium theme-text-primary">{user.fullName}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <Phone className="w-5 h-5 theme-text-secondary" />
                  <div>
                    <p className="text-sm theme-text-secondary">{t("phone_number") || "Số điện thoại"}</p>
                    <p className="font-medium theme-text-primary">{user.phoneNumber || "N/A"}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <Mail className="w-5 h-5 theme-text-secondary" />
                  <div>
                    <p className="text-sm theme-text-secondary">Email</p>
                    <p className="font-medium theme-text-primary">{user.email}</p>
                  </div>
                </div>
              </div>
            ) : (
              <p className="theme-text-secondary">Đang tải thông tin khách hàng...</p>
            )}
          </div>

          {/* Booking Details */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <Calendar className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("booking_information") || "Thông tin đặt bàn"}
              </h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-3">
                <Calendar className="w-5 h-5 theme-text-secondary" />
                <div>
                  <p className="text-sm theme-text-secondary">{t("reservation_date") || "Ngày đặt bàn"}</p>
                  <p className="font-medium theme-text-primary">{formatDate(booking.reservationDate)}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Clock className="w-5 h-5 theme-text-secondary" />
                <div>
                  <p className="text-sm theme-text-secondary">{t("reservation_time") || "Giờ đặt bàn"}</p>
                  <p className="font-medium theme-text-primary">{formatTime(booking.reservationTime)}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Users className="w-5 h-5 theme-text-secondary" />
                <div>
                  <p className="text-sm theme-text-secondary">{t("guests") || "Số khách"}</p>
                  <p className="font-medium theme-text-primary">
                    {booking.numAdults} người
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Clock className="w-5 h-5 theme-text-secondary" />
                <div>
                  <p className="text-sm theme-text-secondary">{t("booking_date") || "Ngày đặt"}</p>
                  <p className="font-medium theme-text-primary">{formatDateTime(booking.bookingDate)}</p>
                </div>
              </div>
            </div>

            {/* Special Requests */}
            {booking.specialRequests && (
              <div className="mt-4 pt-4 border-t theme-border">
                <div className="flex items-start gap-3">
                  <MessageSquare className="w-5 h-5 theme-text-secondary mt-0.5" />
                  <div>
                    <p className="text-sm theme-text-secondary mb-1">{t("special_requests") || "Yêu cầu đặc biệt"}</p>
                    <p className="theme-text-primary">{booking.specialRequests}</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Sidebar - 1 column */}
        <div className="space-y-6">
          {/* Payment Summary */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <DollarSign className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("payment_summary") || "Tổng quan thanh toán"}
              </h2>
            </div>
            <div className="space-y-3">
              {booking.depositAmount && booking.depositAmount > 0 && (
                <div className="flex justify-between items-center pb-2 border-b theme-border">
                  <span className="text-sm theme-text-secondary">{t("deposit_amount") || "Tiền đặt cọc"}</span>
                  <span className="text-sm font-medium theme-text-primary">
                    {formatCurrency(booking.depositAmount, booking.currencyCode)}
                  </span>
                </div>
              )}
              <div className="flex justify-between items-center pb-3 border-b theme-border">
                <span className="theme-text-secondary">{t("total_amount") || "Tổng tiền"}</span>
                <span className="font-semibold text-lg theme-text-primary">
                  {formatCurrency(booking.totalPrice, booking.currencyCode)}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <CreditCard className="w-4 h-4 theme-text-secondary" />
                <span className="text-sm theme-text-secondary">{t("payment_method") || "Phương thức"}</span>
                <span className="text-sm font-medium theme-text-primary ml-auto">
                  {getPaymentMethodLabel(booking.paymentMethod)}
                </span>
              </div>
            </div>
          </div>

          {/* Confirmation Status */}
          {booking.providerConfirmed === 1 && booking.providerConfirmedAt && (
            <div className="rounded-xl border border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20 p-6">
              <div className="flex items-center gap-2 mb-2">
                <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400" />
                <h3 className="font-semibold text-green-900 dark:text-green-100">
                  {t("booking_confirmed") || "Đã xác nhận"}
                </h3>
              </div>
              <p className="text-sm text-green-700 dark:text-green-300">
                {t("confirmed_at") || "Xác nhận lúc"}: {formatDateTime(booking.providerConfirmedAt)}
              </p>
            </div>
          )}

          {/* Action Buttons */}
          <div className="space-y-3">
            {booking.providerConfirmed === 0 && (
              <button
                onClick={handleConfirmBooking}
                disabled={actionLoading}
                className="w-full btn-primary flex items-center justify-center gap-2 py-3"
              >
                {actionLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <CheckCircle className="w-5 h-5" />
                    <span>{t("confirm_booking") || "Xác nhận đặt bàn"}</span>
                  </>
                )}
              </button>
            )}
            {(booking.providerConfirmed === 0 || booking.providerConfirmed === 1) && (
              <button
                onClick={handleCancelBooking}
                disabled={actionLoading}
                className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-lg border-2 border-red-500 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {actionLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <XCircle className="w-5 h-5" />
                    <span>{t("cancel_booking") || "Hủy đặt bàn"}</span>
                  </>
                )}
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Confirm Modal */}
      <ConfirmModal
        isOpen={modalState.isOpen}
        onClose={() => setModalState({ isOpen: false, type: "confirm" })}
        onConfirm={executeAction}
        title={
          modalState.type === "confirm"
            ? t("confirm_booking") || "Xác nhận đặt bàn"
            : t("cancel_booking") || "Hủy đặt bàn"
        }
        message={
          modalState.type === "confirm"
            ? t("confirm_booking_message") || "Bạn có chắc chắn muốn xác nhận đặt bàn này không?"
            : t("confirm_cancel_booking") || "Bạn có chắc chắn muốn hủy đặt bàn này không?"
        }
        confirmText={
          modalState.type === "confirm"
            ? t("confirm_booking") || "Xác nhận"
            : t("cancel_booking") || "Hủy đặt bàn"
        }
        cancelText={t("back") || "Quay lại"}
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading}
      />
    </div>
  );
};

export default RestaurantBookingViewPage;
