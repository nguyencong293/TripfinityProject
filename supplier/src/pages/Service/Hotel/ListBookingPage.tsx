import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, CheckCircle, XCircle, ChevronLeft, Calendar, Loader2 } from "lucide-react";
import { useTheme } from "../../../hooks/useTheme";
import type { HotelBookingDTO, HotelDTO, UserDTO } from "../../../types";
import { useLanguage } from "../../../hooks/useLanguage";
import api from "../../../services/api";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getHotelsByProvider } from "../../../services/hotelService";
import ConfirmModal from "../../../components/common/ConfirmModal";

const ListBookingPage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const { t } = useLanguage();
  const [bookings, setBookings] = useState<HotelBookingDTO[]>([]);
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [userCache, setUserCache] = useState<Map<number, UserDTO>>(new Map());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<0 | 1 | 2>(0); // 0=pending, 1=confirmed, 2=cancelled
  const [actionLoading, setActionLoading] = useState<number | null>(null); // bookingId being processed
  const [modalState, setModalState] = useState<{
    isOpen: boolean;
    type: "confirm" | "cancel";
    bookingId: number | null;
  }>({ isOpen: false, type: "confirm", bookingId: null });

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        setError(null);

        // Get provider ID
        const userStr = localStorage.getItem("user");
        if (!userStr) {
          setError("User not found");
          return;
        }
        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (!provider?.providerId) {
          setError("Provider not found");
          return;
        }

        // Load hotels and bookings
        const [hotelsData, bookingsRes] = await Promise.all([
          getHotelsByProvider(provider.providerId),
          api.get<HotelBookingDTO[]>(`/hotel-bookings/provider/${provider.providerId}`)
        ]);

        setHotels(hotelsData);
        const bookingsData = bookingsRes.data || [];
        setBookings(bookingsData);

        // Fetch user info
        const uniqueUserIds = Array.from(new Set(bookingsData.map(b => b.userId)));
        const usersMap = new Map<number, UserDTO>();
        await Promise.all(
          uniqueUserIds.map(async (userId) => {
            try {
              const userData = await getUserById(userId);
              usersMap.set(userId, userData);
            } catch (e) {
              console.error(`Failed to fetch user ${userId}:`, e);
            }
          })
        );
        setUserCache(usersMap);
      } catch (e) {
        console.error("Error loading bookings:", e);
        setError(e instanceof Error ? e.message : "Failed to load bookings");
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  type ColumnKey =
    | "bookingId"
    | "hotelName"
    | "userName"
    | "userPhone"
    | "checkIn"
    | "checkOut"
    | "guests"
    | "totalPrice"
    | "paymentMethod"
    | "bookingStatus"
    | "createdAt"
    | "actions";

  const columns: Array<{ key: ColumnKey; label: string }> = useMemo(
    () => [
      { key: "bookingId", label: "ID" },
      { key: "hotelName", label: t("hotel_name") || "Khách sạn" },
      { key: "userName", label: t("customer_name") || "Tên khách" },
      { key: "userPhone", label: t("phone_number") || "Số điện thoại" },
      { key: "checkIn", label: t("checkin_date") || "Ngày nhận" },
      { key: "checkOut", label: t("checkout_date") || "Ngày trả" },
      { key: "guests", label: t("guests") || "Số khách" },
      { key: "totalPrice", label: t("total_amount") || "Tổng tiền" },
      { key: "paymentMethod", label: t("payment_status") || "Thanh toán" },
      { key: "bookingStatus", label: "Trạng thái" },
      { key: "createdAt", label: "Ngày đặt" },
      { key: "actions", label: t("hotel_list_col_actions") || "Thao tác" },
    ],
    [t]
  );

  const formatDate = (s?: string) => s ? new Date(s).toLocaleDateString("vi-VN") : "N/A";
  const formatDateTime = (s?: string) => s ? new Date(s).toLocaleString("vi-VN", { 
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric', 
    hour: '2-digit', 
    minute: '2-digit' 
  }) : "N/A";
  const formatCurrency = (v?: number) => new Intl.NumberFormat("vi-VN").format(v || 0);

  // Filter bookings by provider_confirmed status and sort by newest first
  const filteredBookings = useMemo(() => {
    return bookings
      .filter(b => b.providerConfirmed === activeTab)
      .sort((a, b) => {
        const dateA = new Date(a.createdAt || 0).getTime();
        const dateB = new Date(b.createdAt || 0).getTime();
        return dateB - dateA; // Newest first
      });
  }, [bookings, activeTab]);

  const getTabCount = (status: 0 | 1 | 2) => {
    return bookings.filter(b => b.providerConfirmed === status).length;
  };

  const handleConfirmBooking = async (bookingId: number) => {
    setModalState({ isOpen: true, type: "confirm", bookingId });
  };

  const handleCancelBooking = async (bookingId: number) => {
    setModalState({ isOpen: true, type: "cancel", bookingId });
  };

  const executeAction = async () => {
    if (!modalState.bookingId) return;

    try {
      setActionLoading(modalState.bookingId);
      
      if (modalState.type === "confirm") {
        await api.patch(`/hotel-bookings/${modalState.bookingId}/confirm`);
      } else {
        await api.patch(`/hotel-bookings/${modalState.bookingId}/cancel`);
      }
      
      // Refresh bookings list
      const userStr = localStorage.getItem("user");
      if (userStr) {
        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (provider?.providerId) {
          const bookingsRes = await api.get<HotelBookingDTO[]>(`/hotel-bookings/provider/${provider.providerId}`);
          setBookings(bookingsRes.data || []);
        }
      }
      
      setModalState({ isOpen: false, type: "confirm", bookingId: null });
    } catch (e) {
      console.error(`Error ${modalState.type}ing booking:`, e);
      alert(
        modalState.type === "confirm"
          ? t("booking_confirmed_error") || "Lỗi khi xác nhận đặt phòng"
          : t("booking_cancelled_error") || "Lỗi khi hủy đặt phòng"
      );
    } finally {
      setActionLoading(null);
    }
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: dark ? "bg-orange-500/20 text-orange-400 border-orange-500/30" : "bg-orange-100 text-orange-700 border-orange-300",
      confirmed: dark ? "bg-blue-500/20 text-blue-400 border-blue-500/30" : "bg-blue-100 text-blue-700 border-blue-300",
      completed: dark ? "bg-green-500/20 text-green-400 border-green-500/30" : "bg-green-100 text-green-700 border-green-300",
      cancelled: dark ? "bg-red-500/20 text-red-400 border-red-500/30" : "bg-red-100 text-red-700 border-red-300",
      refunded: dark ? "bg-purple-500/20 text-purple-400 border-purple-500/30" : "bg-purple-100 text-purple-700 border-purple-300",
    };
    return colors[status] || (dark ? "bg-gray-500/20 text-gray-300" : "bg-gray-100 text-gray-700");
  };

  const cell = (b: HotelBookingDTO, key: ColumnKey): React.ReactNode => {
    const hotel = hotels.find(h => h.hotelId === b.hotelId);
    const user = userCache.get(b.userId);

    switch (key) {
      case "bookingId":
        return <span className="font-mono font-bold">#{b.bookingId}</span>;
      case "hotelName":
        return hotel?.title || `Hotel ID: ${b.hotelId}`;
      case "userName":
        return user?.fullName || `User ID: ${b.userId}`;
      case "userPhone":
        return user?.phoneNumber || "-";
      case "checkIn":
        return formatDate(b.startDate);
      case "checkOut":
        return formatDate(b.endDate);
      case "guests":
        return `${b.numAdults} ${t("adults_suffix") || "người"}${b.numChildren ? `, ${b.numChildren} ${t("children_suffix") || "trẻ em"}` : ""}`;
      case "totalPrice":
        return (
          <span className={dark ? "text-emerald-400 font-bold" : "text-emerald-700 font-bold"}>
            {formatCurrency(b.totalPrice)} {b.currencyCode || "VND"}
          </span>
        );
      case "paymentMethod":
        if (!b.paymentMethod || b.paymentMethod === "counter") {
          return (
            <span className={`px-2 py-1 rounded-full text-xs font-medium border ${dark ? "bg-yellow-500/20 text-yellow-400 border-yellow-500/30" : "bg-yellow-100 text-yellow-700 border-yellow-300"}`}>
              {t("payment_counter") || "Tại quầy"}
            </span>
          );
        }
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium border ${dark ? "bg-green-500/20 text-green-400 border-green-500/30" : "bg-green-100 text-green-700 border-green-300"}`}>
            {t("payment_online") || "Đã thanh toán"}
          </span>
        );
      case "bookingStatus": {
        const providerStatus = b.providerConfirmed === 0 ? "pending" : b.providerConfirmed === 1 ? "confirmed" : "cancelled";
        const providerLabel = b.providerConfirmed === 0 ? (t("booking_status_pending") || "Chờ xác nhận") : b.providerConfirmed === 1 ? (t("booking_status_confirmed") || "Đã xác nhận") : (t("booking_status_cancelled") || "Đã hủy");
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getStatusColor(providerStatus)}`}>
            {providerLabel}
          </span>
        );
      }
      case "createdAt":
        return <span className="text-sm">{formatDateTime(b.createdAt)}</span>;
      case "actions": {
        const isProcessing = actionLoading === b.bookingId;
        return (
          <div className="flex items-center gap-2">
            <button
              onClick={() => navigate(`/supplier/service/hotel/bookings/${b.bookingId}`)}
              className={`p-1.5 rounded transition-colors ${
                dark
                  ? "hover:bg-blue-500/20 text-blue-400"
                  : "hover:bg-blue-50 text-blue-600"
              }`}
              title={t("view_detail") || "Xem chi tiết"}
              disabled={isProcessing}
            >
              <Eye className="w-4 h-4" />
            </button>
            {b.providerConfirmed === 0 && (
              <button
                onClick={() => handleConfirmBooking(b.bookingId!)}
                disabled={isProcessing}
                className={`p-1.5 rounded transition-colors ${
                  isProcessing
                    ? "opacity-50 cursor-not-allowed"
                    : dark
                    ? "hover:bg-green-500/20 text-green-400"
                    : "hover:bg-green-50 text-green-600"
                }`}
                title={t("confirm_booking") || "Xác nhận"}
              >
                {isProcessing ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : (
                  <CheckCircle className="w-4 h-4" />
                )}
              </button>
            )}
            {(b.providerConfirmed === 0 || b.providerConfirmed === 1) && (
              <button
                onClick={() => handleCancelBooking(b.bookingId!)}
                disabled={isProcessing}
                className={`p-1.5 rounded transition-colors ${
                  isProcessing
                    ? "opacity-50 cursor-not-allowed"
                    : dark
                    ? "hover:bg-red-500/20 text-red-400"
                    : "hover:bg-red-50 text-red-600"
                }`}
                title={t("cancel_booking") || "Hủy"}
              >
                {isProcessing ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : (
                  <XCircle className="w-4 h-4" />
                )}
              </button>
            )}
          </div>
        );
      }
      default:
        return "";
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className={`p-4 rounded-lg ${dark ? "bg-red-500/20 text-red-400" : "bg-red-50 text-red-700"}`}>
          {error}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate("/supplier/service/hotel")}
            className={`p-2 rounded-lg transition-colors ${
              dark
                ? "hover:bg-gray-700 text-gray-300"
                : "hover:bg-gray-100 text-gray-700"
            }`}
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <div className="flex items-center gap-3">
            <Calendar className={`w-8 h-8 ${dark ? "text-blue-400" : "text-blue-600"}`} />
            <div>
              <h1 className={`text-3xl font-bold ${dark ? "text-white" : "text-gray-900"}`}>
                {t("booking_list_title") || "Danh sách đặt phòng"}
              </h1>
              <p className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}>
                {bookings.filter(b => b.providerConfirmed === 0).length} {t("bookings_count_suffix") || "đơn chờ xác nhận"}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className={`flex gap-2 p-1 rounded-lg ${dark ? "bg-gray-800" : "bg-gray-100"}`}>
        <button
          onClick={() => setActiveTab(0)}
          className={`flex-1 px-4 py-2.5 rounded-md font-medium transition-all ${
            activeTab === 0
              ? dark
                ? "bg-orange-500/20 text-orange-400 shadow-sm"
                : "bg-white text-orange-700 shadow-sm"
              : dark
              ? "text-gray-400 hover:text-gray-300"
              : "text-gray-600 hover:text-gray-900"
          }`}
        >
          <span>{t("booking_status_pending") || "Chờ xác nhận"}</span>
          <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${
            activeTab === 0
              ? dark ? "bg-orange-500/30" : "bg-orange-100"
              : dark ? "bg-gray-700" : "bg-gray-200"
          }`}>
            {getTabCount(0)}
          </span>
        </button>
        <button
          onClick={() => setActiveTab(1)}
          className={`flex-1 px-4 py-2.5 rounded-md font-medium transition-all ${
            activeTab === 1
              ? dark
                ? "bg-green-500/20 text-green-400 shadow-sm"
                : "bg-white text-green-700 shadow-sm"
              : dark
              ? "text-gray-400 hover:text-gray-300"
              : "text-gray-600 hover:text-gray-900"
          }`}
        >
          <span>{t("booking_status_confirmed") || "Đã xác nhận"}</span>
          <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${
            activeTab === 1
              ? dark ? "bg-green-500/30" : "bg-green-100"
              : dark ? "bg-gray-700" : "bg-gray-200"
          }`}>
            {getTabCount(1)}
          </span>
        </button>
        <button
          onClick={() => setActiveTab(2)}
          className={`flex-1 px-4 py-2.5 rounded-md font-medium transition-all ${
            activeTab === 2
              ? dark
                ? "bg-red-500/20 text-red-400 shadow-sm"
                : "bg-white text-red-700 shadow-sm"
              : dark
              ? "text-gray-400 hover:text-gray-300"
              : "text-gray-600 hover:text-gray-900"
          }`}
        >
          <span>{t("booking_status_cancelled") || "Đã hủy"}</span>
          <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${
            activeTab === 2
              ? dark ? "bg-red-500/30" : "bg-red-100"
              : dark ? "bg-gray-700" : "bg-gray-200"
          }`}>
            {getTabCount(2)}
          </span>
        </button>
      </div>

      {/* Table */}
      <div className={`rounded-xl border overflow-hidden ${dark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"}`}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className={dark ? "bg-gray-700/50" : "bg-gray-50"}>
              <tr>
                {columns.map((col) => (
                  <th
                    key={col.key}
                    className={`px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider ${
                      dark ? "text-gray-300" : "text-gray-700"
                    }`}
                  >
                    {col.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
              {filteredBookings.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className="px-4 py-8 text-center">
                    <Calendar className={`w-12 h-12 mx-auto mb-3 ${dark ? "text-gray-600" : "text-gray-300"}`} />
                    <p className={dark ? "text-gray-400" : "text-gray-500"}>
                      {activeTab === 0 && (t("no_pending_bookings") || "Chưa có đơn chờ xác nhận")}
                      {activeTab === 1 && (t("no_confirmed_bookings") || "Chưa có đơn đã xác nhận")}
                      {activeTab === 2 && (t("no_cancelled_bookings") || "Chưa có đơn đã hủy")}
                    </p>
                  </td>
                </tr>
              ) : (
                filteredBookings.map((b) => (
                  <tr
                    key={b.bookingId}
                    className={`transition-colors ${
                      dark ? "hover:bg-gray-700/50" : "hover:bg-gray-50"
                    }`}
                  >
                    {columns.map((col) => (
                      <td
                        key={col.key}
                        className={`px-4 py-3 text-sm ${
                          dark ? "text-gray-300" : "text-gray-900"
                        }`}
                      >
                        {cell(b, col.key)}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Confirm Modal */}
      <ConfirmModal
        isOpen={modalState.isOpen}
        onClose={() => setModalState({ isOpen: false, type: "confirm", bookingId: null })}
        onConfirm={executeAction}
        title={
          modalState.type === "confirm"
            ? t("confirm_booking") || "Xác nhận đặt phòng"
            : t("cancel_booking") || "Hủy đặt phòng"
        }
        message={
          modalState.type === "confirm"
            ? t("confirm_booking_message") || "Bạn có chắc chắn muốn xác nhận đặt phòng này không?"
            : t("confirm_cancel_booking") || "Bạn có chắc chắn muốn hủy đặt phòng này không?"
        }
        confirmText={
          modalState.type === "confirm"
            ? t("confirm_booking") || "Xác nhận"
            : t("cancel_booking") || "Hủy đặt phòng"
        }
        cancelText={t("back") || "Quay lại"}
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading === modalState.bookingId}
      />
    </div>
  );
};

export default ListBookingPage;
