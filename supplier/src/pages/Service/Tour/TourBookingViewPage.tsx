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
import type { TourBookingDTO, TourDTO, UserDTO } from "../../../types";
import api from "../../../services/api";
import { getUserById } from "../../../services/providerService";
import ConfirmModal from "../../../components/common/ConfirmModal";

const TourBookingViewPage: React.FC = () => {
  const { bookingId } = useParams<{ bookingId: string }>();
  const navigate = useNavigate();
  
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
        setError(e instanceof Error ? e.message : "Failed to load tour booking details");
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
          ? "Lỗi khi xác nhận đặt tour"
          : "Lỗi khi hủy đặt tour"
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

  const formatCurrency = (amount?: number, currency?: string) => {
    if (amount === undefined) return "N/A";
    return `${amount.toLocaleString("vi-VN")} ${currency || "VND"}`;
  };

  const getPaymentMethodLabel = (method?: string) => {
    if (!method || method === "counter") {
      return "Thanh toán tại quầy";
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
      refunded: { label: "Đã hoàn tiền", className: "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300" },
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
          <p className="text-lg theme-text-primary mb-4">{error || "Không tìm thấy thông tin đặt tour"}</p>
          <button
            onClick={() => navigate("/supplier/service/tour")}
            className="btn-primary"
          >
            Quay lại Dashboard
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
            className="p-2 rounded-lg theme-border border hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold theme-text-primary">
              Chi tiết đặt tour #{booking.bookingId}
            </h1>
            <p className="text-sm theme-text-secondary mt-1">
              Tạo lúc: {formatDateTime(booking.createdAt)}
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
                Thông tin tour
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
                        <span>{tour.durationDays} ngày</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ) : (
              <p className="theme-text-secondary">Đang tải thông tin tour...</p>
            )}
          </div>

          {/* Customer Information */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <User className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                Thông tin khách hàng
              </h2>
            </div>
            {user ? (
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label className="text-sm theme-text-secondary">Họ và tên</label>
                  <p className="font-medium theme-text-primary">{user?.fullName || "N/A"}</p>
                </div>
                <div>
                  <label className="text-sm theme-text-secondary">Email</label>
                  <div className="flex items-center gap-2">
                    <Mail className="w-4 h-4 theme-text-secondary" />
                    <p className="font-medium theme-text-primary">{user?.email || "N/A"}</p>
                  </div>
                </div>
                <div>
                  <label className="text-sm theme-text-secondary">Số điện thoại</label>
                  <div className="flex items-center gap-2">
                    <Phone className="w-4 h-4 theme-text-secondary" />
                    <p className="font-medium theme-text-primary">{user?.phoneNumber || "N/A"}</p>
                  </div>
                </div>
                <div>
                  <label className="text-sm theme-text-secondary">Số người</label>
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4 theme-text-secondary" />
                    <p className="font-medium theme-text-primary">
                      {booking.numAdults || 0} người
                    </p>
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
                Chi tiết đặt tour
              </h2>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className="text-sm theme-text-secondary">Ngày bắt đầu</label>
                <p className="font-medium theme-text-primary">{formatDate(booking.startDate)}</p>
              </div>
              <div>
                <label className="text-sm theme-text-secondary">Ngày kết thúc</label>
                <p className="font-medium theme-text-primary">{formatDate(booking.endDate)}</p>
              </div>
              <div>
                <label className="text-sm theme-text-secondary">Trạng thái booking</label>
                <p className="font-medium theme-text-primary">
                  {booking.bookingStatus === 'pending' ? 'Chờ xác nhận' :
                   booking.bookingStatus === 'confirmed' ? 'Đã xác nhận' :
                   booking.bookingStatus === 'cancelled' ? 'Đã hủy' :
                   booking.bookingStatus === 'completed' ? 'Hoàn thành' :

                   booking.bookingStatus}
                </p>
              </div>
              <div>
                <label className="text-sm theme-text-secondary">Đã xem</label>
                <p className="font-medium theme-text-primary">
                  {booking.providerSeen ? "Đã xem" : "Chưa xem"}
                </p>
              </div>
            </div>

            {booking.specialRequests && (
              <div className="mt-4">
                <label className="text-sm theme-text-secondary">Yêu cầu đặc biệt</label>
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
                Thanh toán
              </h2>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="theme-text-secondary">Tổng tiền</span>
                <span className="font-semibold theme-text-primary">
                  {formatCurrency(booking.totalPrice, booking.currencyCode)}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="theme-text-secondary">Phương thức</span>
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
                <span className="font-medium">Xác nhận đặt tour</span>
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
                <span className="font-medium">Hủy đặt tour</span>
              </button>
            </div>
          )}

          {/* Booking Timeline */}
          <div className="rounded-xl border theme-border theme-bg-card p-6">
            <div className="flex items-center gap-2 mb-4">
              <Clock className="w-5 h-5 icon-brand" />
              <h2 className="text-lg font-semibold theme-text-primary">
                Timeline
              </h2>
            </div>
            <div className="space-y-3">
              <div className="flex gap-3">
                <div className="flex flex-col items-center">
                  <div className="w-2 h-2 rounded-full bg-blue-500" />
                  <div className="w-px h-full bg-gray-300 dark:bg-gray-600" />
                </div>
                <div className="flex-1 pb-4">
                  <p className="font-medium theme-text-primary">Đặt tour</p>
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
                    <p className="font-medium theme-text-primary">Cập nhật</p>
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
        title={modalState.type === "confirm" ? "Xác nhận đặt tour" : "Hủy đặt tour"}
        message={
          modalState.type === "confirm"
            ? "Bạn có chắc chắn muốn xác nhận đặt tour này? Khách hàng sẽ nhận được thông báo xác nhận."
            : "Bạn có chắc chắn muốn hủy đặt tour này? Thao tác này không thể hoàn tác."
        }
        confirmText={modalState.type === "confirm" ? "Xác nhận" : "Hủy booking"}
        loading={actionLoading}
      />
    </div>
  );
};

export default TourBookingViewPage;
