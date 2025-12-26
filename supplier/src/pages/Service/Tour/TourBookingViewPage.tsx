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
  Users,
  Loader2,
  AlertCircle,
  Map,
} from "lucide-react";
import { useLanguage } from "../../../hooks/useLanguage";
import type { TourBookingDTO, TourDTO, UserDTO } from "../../../types";
import api from "../../../services/api";
import { getUserById } from "../../../services/providerService";
import ConfirmModal from "../../../components/common/ConfirmModal";

const TourBookingViewPage: React.FC = () => {
  const { bookingId } = useParams<{ bookingId: string }>();
  const navigate = useNavigate();
  const { t } = useLanguage();
  
  const [booking, setBooking] = useState<TourBookingDTO | null>(null);
  const [tour, setTour] = useState<TourDTO | null>(null);
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

        const bookingRes = await api.get<TourBookingDTO>(`/tour-bookings/${bookingId}`);
        const bookingData = bookingRes.data;
        setBooking(bookingData);

        if (bookingData.tourId) {
          const tourRes = await api.get<TourDTO>(`/tours/${bookingData.tourId}`);
          setTour(tourRes.data);
        }

        if (bookingData.userId) {
          const userData = await getUserById(bookingData.userId);
          setUser(userData);
        }
      } catch (e) {
        console.error("Error loading tour booking details:", e);
        setError(e instanceof Error ? e.message : t("tour_booking_error_load_detail"));
      } finally {
        setLoading(false);
      }
    };

    loadBookingDetails();
  }, [bookingId, t]);

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
        await api.patch(`/tour-bookings/${bookingId}/confirm`);
      } else {
        await api.patch(`/tour-bookings/${bookingId}/cancel`);
      }
      
      const bookingRes = await api.get<TourBookingDTO>(`/tour-bookings/${bookingId}`);
      setBooking(bookingRes.data);
      
      setModalState({ isOpen: false, type: "confirm" });
    } catch (e) {
      console.error(`Error ${modalState.type}ing tour booking:`, e);
      alert(
        modalState.type === "confirm"
          ? t("tour_booking_error_confirm")
          : t("tour_booking_error_cancel")
      );
    } finally {
      setActionLoading(false);
    }
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return t("tour_na");
    return new Date(dateStr).toLocaleDateString("vi-VN");
  };

  const formatDateTime = (dateStr?: string) => {
    if (!dateStr) return t("tour_na");
    return new Date(dateStr).toLocaleString("vi-VN");
  };

  const formatCurrency = (amount?: number, currency?: string) => {
    if (amount === undefined) return t("tour_na");
    return `${amount.toLocaleString("vi-VN")} ${currency || "VND"}`;
  };

  const getPaymentMethodLabel = (method?: string) => {
    if (!method || method === "counter") {
      return t("tour_payment_counter");
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
      pending: { label: t("tour_booking_status_pending"), className: "theme-bg-warning theme-text-warning" },
      confirmed: { label: t("tour_booking_status_confirmed"), className: "theme-bg-success theme-text-success" },
      cancelled: { label: t("tour_booking_status_cancelled"), className: "theme-bg-error theme-text-error" },
      completed: { label: t("tour_booking_status_completed"), className: "theme-bg-info theme-text-info" },
      refunded: { label: t("tour_booking_status_refunded"), className: "theme-bg-secondary theme-text-secondary" },
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
        <Loader2 className="w-8 h-8 animate-spin icon-brand" />
      </div>
    );
  }

  if (error || !booking) {
    return (
      <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="rounded-xl border theme-border theme-bg-card p-6 text-center">
          <AlertCircle className="w-12 h-12 mx-auto mb-4 theme-text-error" />
          <p className="text-lg theme-text-primary mb-4">{error || t("tour_booking_not_found")}</p>
          <button
            onClick={() => navigate("/supplier/service/tour")}
            className="btn-primary"
          >
            {t("back_to_dashboard")}
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
            onClick={() => navigate(-1)}
            className="p-2 rounded-lg theme-border border theme-hover transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold theme-text-primary">
              {t("tour_booking_detail_title")} #{booking.bookingId}
            </h1>
            <p className="text-sm theme-text-secondary mt-1">
              {t("tour_created_at")}: {formatDateTime(booking.createdAt)}
            </p>
          </div>
        </div>
        <div>{getStatusBadge(booking.bookingStatus)}</div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content - 2 columns */}
        <div className="lg:col-span-2 space-y-6">
          {/* Tour Information */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <Map className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("tour_booking_tour_info")}
              </h2>
            </div>
            {tour ? (
              <div className="space-y-3">
                <div className="flex items-start gap-3">
                  {tour.thumbnailUrl && (
                    <img
                      src={tour.thumbnailUrl}
                      alt={tour.title}
                      className="w-24 h-24 rounded-lg object-cover"
                    />
                  )}
                  <div>
                    <h3 className="font-semibold theme-text-primary text-lg">{tour.title}</h3>
                    <div className="flex items-center gap-2 mt-2 text-sm theme-text-secondary">
                      <MapPin className="w-4 h-4" />
                      <span>{tour.location}</span>
                    </div>
                    {tour.durationDays && (
                      <div className="flex items-center gap-2 mt-1 text-sm theme-text-secondary">
                        <Clock className="w-4 h-4" />
                        <span>{tour.durationDays} {t("tour_days")}</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ) : (
              <p className="theme-text-secondary">{t("tour_booking_loading_tour")}</p>
            )}
          </div>

          {/* Customer Information */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <User className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("tour_booking_customer_info")}
              </h2>
            </div>
            {user ? (
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label className="text-sm theme-text-secondary">{t("tour_booking_customer_name")}</label>
                  <p className="font-medium theme-text-primary">{user?.fullName || t("tour_na")}</p>
                </div>
                <div>
                  <label className="text-sm theme-text-secondary">{t("email")}</label>
                  <div className="flex items-center gap-2">
                    <Mail className="w-4 h-4 theme-text-secondary" />
                    <p className="font-medium theme-text-primary">{user?.email || t("tour_na")}</p>
                  </div>
                </div>
                <div>
                  <label className="text-sm theme-text-secondary">{t("tour_booking_customer_phone")}</label>
                  <div className="flex items-center gap-2">
                    <Phone className="w-4 h-4 theme-text-secondary" />
                    <p className="font-medium theme-text-primary">{user?.phoneNumber || t("tour_na")}</p>
                  </div>
                </div>
                <div>
                  <label className="text-sm theme-text-secondary">{t("tour_booking_num_people")}</label>
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4 theme-text-secondary" />
                    <p className="font-medium theme-text-primary">
                      {booking.numAdults || 0} {t("tour_guest")}
                    </p>
                  </div>
                </div>
              </div>
            ) : (
              <p className="theme-text-secondary">{t("tour_booking_loading_customer")}</p>
            )}
          </div>

          {/* Booking Details */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <Calendar className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("tour_booking_details")}
              </h2>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className="text-sm theme-text-secondary">{t("tour_col_start_date")}</label>
                <p className="font-medium theme-text-primary">{formatDate(booking.startDate)}</p>
              </div>
              <div>
                <label className="text-sm theme-text-secondary">{t("tour_col_end_date")}</label>
                <p className="font-medium theme-text-primary">{formatDate(booking.endDate)}</p>
              </div>
              <div>
                <label className="text-sm theme-text-secondary">{t("tour_booking_status")}</label>
                <p className="font-medium theme-text-primary">
                  {booking.bookingStatus === 'pending' ? t("tour_booking_status_pending") :
                   booking.bookingStatus === 'confirmed' ? t("tour_booking_status_confirmed") :
                   booking.bookingStatus === 'cancelled' ? t("tour_booking_status_cancelled") :
                   booking.bookingStatus === 'completed' ? t("tour_booking_status_completed") :
                   booking.bookingStatus}
                </p>
              </div>
              <div>
                <label className="text-sm theme-text-secondary">{t("tour_booking_provider_seen")}</label>
                <p className="font-medium theme-text-primary">
                  {booking.providerSeen ? t("tour_booking_seen") : t("tour_booking_unseen")}
                </p>
              </div>
            </div>

            {booking.specialRequests && (
              <div className="mt-4">
                <label className="text-sm theme-text-secondary">{t("tour_booking_special_requests")}</label>
                <p className="font-medium theme-text-primary mt-1 whitespace-pre-wrap">
                  {booking.specialRequests}
                </p>
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
                {t("tour_booking_payment")}
              </h2>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="theme-text-secondary">{t("tour_booking_total_price")}</span>
                <span className="font-semibold theme-text-primary">
                  {formatCurrency(booking.totalPrice, booking.currencyCode)}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="theme-text-secondary">{t("tour_booking_payment_method")}</span>
                <div className="flex items-center gap-2">
                  <CreditCard className="w-4 h-4 theme-text-secondary" />
                  <span className="font-medium theme-text-primary">
                    {getPaymentMethodLabel(booking.paymentMethod)}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Actions */}
          {booking.providerConfirmed === 0 && (
            <div className="space-y-3">
              <button
                onClick={handleConfirmBooking}
                disabled={actionLoading}
                className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {actionLoading && modalState.type === "confirm" ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <CheckCircle className="w-5 h-5" />
                )}
                <span className="font-medium">{t("tour_booking_confirm_action")}</span>
              </button>
              
              <button
                onClick={handleCancelBooking}
                disabled={actionLoading}
                className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {actionLoading && modalState.type === "cancel" ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <XCircle className="w-5 h-5" />
                )}
                <span className="font-medium">{t("tour_booking_cancel_action")}</span>
              </button>
            </div>
          )}

          {/* Booking Timeline */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <Clock className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                {t("tour_booking_timeline")}
              </h2>
            </div>
            <div className="space-y-3">
              <div className="flex gap-3">
                <div className="flex flex-col items-center">
                  <div className="w-2 h-2 rounded-full bg-blue-500" />
                  <div className="w-px h-full bg-gray-300 dark:bg-gray-600" />
                </div>
                <div className="flex-1 pb-4">
                  <p className="font-medium theme-text-primary">{t("tour_booking_created")}</p>
                  <p className="text-sm theme-text-secondary">
                    {formatDateTime(booking.createdAt)}
                  </p>
                </div>
              </div>

              {booking.updatedAt && booking.updatedAt !== booking.createdAt && (
                <div className="flex gap-3">
                  <div className="flex flex-col items-center">
                    <div className="w-2 h-2 rounded-full bg-blue-500" />
                    <div className="w-px h-full bg-gray-300 dark:bg-gray-600" />
                  </div>
                  <div className="flex-1 pb-4">
                    <p className="font-medium theme-text-primary">{t("tour_booking_updated")}</p>
                    <p className="text-sm theme-text-secondary">
                      {formatDateTime(booking.updatedAt)}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Confirm Modal */}
      <ConfirmModal
        isOpen={modalState.isOpen}
        onClose={() => setModalState({ isOpen: false, type: "confirm" })}
        onConfirm={executeAction}
        title={modalState.type === "confirm" ? t("tour_booking_confirm_title") : t("tour_booking_cancel_title")}
        message={
          modalState.type === "confirm"
            ? t("tour_booking_confirm_message_detail")
            : t("tour_booking_cancel_message_detail")
        }
        confirmText={modalState.type === "confirm" ? t("tour_booking_confirm") : t("tour_booking_cancel")}
        loading={actionLoading}
      />
    </div>
  );
};

export default TourBookingViewPage;
