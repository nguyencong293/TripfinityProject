import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, CheckCircle, XCircle, ChevronLeft, Calendar, Loader2 } from "lucide-react";
import { useTheme } from "../../../hooks/useTheme";
import type { TourBookingDTO, TourDTO, UserDTO } from "../../../types";
import api from "../../../services/api";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getToursByProvider } from "../../../services/tourService";
import ConfirmModal from "../../../components/common/ConfirmModal";

const ListTourBookingPage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const [bookings, setBookings] = useState<TourBookingDTO[]>([]);
  const [tours, setTours] = useState<TourDTO[]>([]);
  const [userCache, setUserCache] = useState<Map<number, UserDTO>>(new Map());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<0 | 1 | 2>(0); // 0=pending, 1=confirmed, 2=cancelled
  const [actionLoading, setActionLoading] = useState<number | null>(null);
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

        const [toursData, bookingsRes] = await Promise.all([
          getToursByProvider(provider.providerId),
          api.get<TourBookingDTO[]>(`/tour-bookings/provider/${provider.providerId}`)
        ]);

        setTours(toursData);
        const bookingsData = bookingsRes.data || [];
        console.log("📦 Raw bookings data:", bookingsData);
        console.log("📦 First booking:", bookingsData[0]);
        setBookings(bookingsData);

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
        console.error("Error loading tour bookings:", e);
        setError(e instanceof Error ? e.message : "Failed to load tour bookings");
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  type ColumnKey =
    | "bookingId"
    | "tourName"
    | "userName"
    | "userPhone"
    | "startDate"
    | "endDate"
    | "people"
    | "totalPrice"
    | "paymentMethod"
    | "bookingStatus"
    | "createdAt"
    | "actions";

  const columns: Array<{ key: ColumnKey; label: string }> = useMemo(
    () => [
      { key: "bookingId", label: "ID" },
      { key: "tourName", label: "Tour" },
      { key: "userName", label: "Tên khách" },
      { key: "userPhone", label: "Số điện thoại" },
      { key: "startDate", label: "Ngày bắt đầu" },
      { key: "endDate", label: "Ngày kết thúc" },
      { key: "people", label: "Số người" },
      { key: "totalPrice", label: "Tổng tiền" },
      { key: "paymentMethod", label: "Phương thức thanh toán" },
      { key: "bookingStatus", label: "Trạng thái" },
      { key: "createdAt", label: "Ngày đặt" },
      { key: "actions", label: "Thao tác" },
    ],
    []
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

  const filteredBookings = useMemo(() => {
    console.log("🔍 Filtering bookings - activeTab:", activeTab);
    console.log("🔍 All bookings:", bookings.map(b => ({ id: b.bookingId, providerConfirmed: b.providerConfirmed })));
    const filtered = bookings
      .filter(b => b.providerConfirmed === activeTab)
      .sort((a, b) => {
        const dateA = new Date(a.createdAt || 0).getTime();
        const dateB = new Date(b.createdAt || 0).getTime();
        return dateB - dateA;
      });
    console.log("✅ Filtered bookings count:", filtered.length);
    return filtered;
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
        await api.patch(`/tour-bookings/${modalState.bookingId}/confirm`);
      } else {
        await api.patch(`/tour-bookings/${modalState.bookingId}/cancel`);
      }
      
      const userStr = localStorage.getItem("user");
      if (userStr) {
        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (provider?.providerId) {
          const bookingsRes = await api.get<TourBookingDTO[]>(`/tour-bookings/provider/${provider.providerId}`);
          setBookings(bookingsRes.data || []);
        }
      }
      
      setModalState({ isOpen: false, type: "confirm", bookingId: null });
    } catch (e) {
      console.error(`Error ${modalState.type}ing tour booking:`, e);
      alert(
        modalState.type === "confirm"
          ? "Lỗi khi xác nhận đặt tour"
          : "Lỗi khi hủy đặt tour"
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

  const cell = (b: TourBookingDTO, key: ColumnKey): React.ReactNode => {
    const tour = tours.find(t => t.tourId === b.tourId);
    const user = userCache.get(b.userId);

    switch (key) {
      case "bookingId":
        return <span className="font-mono font-bold">#{b.bookingId}</span>;
      case "tourName":
        return (
          <div>
            <div className="font-medium">{tour?.title || `Tour #${b.tourId}`}</div>
            {tour?.location && <div className="text-xs opacity-60">{tour.location}</div>}
          </div>
        );
      case "userName":
        return (
          <div>
            <div className="font-medium">{user?.fullName || "N/A"}</div>
            {user?.email && <div className="text-xs opacity-60">{user.email}</div>}
          </div>
        );
      case "userPhone":
        return user?.phoneNumber || "N/A";
      case "startDate":
        return formatDate(b.startDate);
      case "endDate":
        return formatDate(b.endDate);
      case "people":
        return `${b.numAdults || 0} người`;
      case "totalPrice":
        return (
          <div className="font-semibold">
            {formatCurrency(b.totalPrice)} {b.currencyCode || 'VND'}
          </div>
        );
      case "paymentMethod": {
        if (!b.paymentMethod || b.paymentMethod === 'counter') {
          return (
            <span className={`px-2 py-1 rounded text-xs font-medium ${dark ? 'bg-yellow-500/20 text-yellow-400' : 'bg-yellow-100 text-yellow-700'}`}>
              💵 Thanh toán tại quầy
            </span>
          );
        }
        const methodLabel = b.paymentMethod === 'zalopay' ? 'ZaloPay' : 
                          b.paymentMethod === 'vnpay' ? 'VNPay' : 
                          b.paymentMethod.toUpperCase();
        return (
          <span className={`px-2 py-1 rounded text-xs font-medium ${dark ? 'bg-green-500/20 text-green-400' : 'bg-green-100 text-green-700'}`}>
            ✅ {methodLabel}
          </span>
        );
      }
      case "bookingStatus": {
        const statusLabel: Record<string, string> = {
          pending: "Chờ xác nhận",
          confirmed: "Đã xác nhận",
          completed: "Hoàn thành",
          cancelled: "Đã hủy",
          refunded: "Đã hoàn tiền",
        };
        return (
          <span className={`px-2 py-1 rounded text-xs font-medium border ${getStatusColor(b.bookingStatus || 'pending')}`}>
            {statusLabel[b.bookingStatus || 'pending'] || b.bookingStatus}
          </span>
        );
      }
      case "createdAt":
        return (
          <div className="text-sm">
            <div>{formatDateTime(b.createdAt)}</div>
          </div>
        );
      case "actions":
        return (
          <div className="flex gap-2">
            <button
              onClick={() => navigate(`/supplier/service/tour/bookings/${b.bookingId}`)}
              className={`p-2 rounded transition ${
                dark
                  ? "bg-blue-600/20 text-blue-400 hover:bg-blue-600/30"
                  : "bg-blue-50 text-blue-600 hover:bg-blue-100"
              }`}
              title="Xem chi tiết"
            >
              <Eye size={16} />
            </button>
            {b.providerConfirmed === 0 && (
              <>
                <button
                  onClick={() => b.bookingId && handleConfirmBooking(b.bookingId)}
                  disabled={actionLoading === b.bookingId}
                  className={`p-2 rounded transition ${
                    dark
                      ? "bg-green-600/20 text-green-400 hover:bg-green-600/30 disabled:opacity-40"
                      : "bg-green-50 text-green-600 hover:bg-green-100 disabled:opacity-40"
                  }`}
                  title="Xác nhận"
                >
                  {actionLoading === b.bookingId ? <Loader2 size={16} className="animate-spin" /> : <CheckCircle size={16} />}
                </button>
                <button
                  onClick={() => b.bookingId && handleCancelBooking(b.bookingId)}
                  disabled={actionLoading === b.bookingId}
                  className={`p-2 rounded transition ${
                    dark
                      ? "bg-red-600/20 text-red-400 hover:bg-red-600/30 disabled:opacity-40"
                      : "bg-red-50 text-red-600 hover:bg-red-100 disabled:opacity-40"
                  }`}
                  title="Hủy"
                >
                  {actionLoading === b.bookingId ? <Loader2 size={16} className="animate-spin" /> : <XCircle size={16} />}
                </button>
              </>
            )}
          </div>
        );
      default:
        return null;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <p className="text-red-500 mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 bg-primary-500 text-white rounded hover:bg-primary-600"
          >
            Thử lại
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={`min-h-screen p-6 ${dark ? "bg-gray-900 text-white" : "bg-gray-50 text-gray-900"}`}>
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-6 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate("/supplier/service/tour")}
              className={`p-2 rounded-lg transition ${
                dark ? "bg-gray-800 hover:bg-gray-700" : "bg-white hover:bg-gray-100"
              }`}
            >
              <ChevronLeft size={20} />
            </button>
            <div>
              <h1 className="text-2xl font-bold flex items-center gap-2">
                <Calendar className="text-primary-500" size={28} />
                Danh sách đặt tour
              </h1>
              <p className="text-sm opacity-60 mt-1">
                Quản lý các booking tour của bạn
              </p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className={`mb-6 border-b ${dark ? "border-gray-700" : "border-gray-200"}`}>
          <div className="flex gap-4">
            {[
              { id: 0, label: "Chờ xác nhận", count: getTabCount(0) },
              { id: 1, label: "Đã xác nhận", count: getTabCount(1) },
              { id: 2, label: "Đã hủy", count: getTabCount(2) },
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as 0 | 1 | 2)}
                className={`px-4 py-3 font-medium transition relative ${
                  activeTab === tab.id
                    ? dark
                      ? "text-primary-400"
                      : "text-primary-600"
                    : "opacity-60 hover:opacity-100"
                }`}
              >
                {tab.label}
                {tab.count > 0 && (
                  <span className={`ml-2 px-2 py-0.5 rounded-full text-xs font-semibold ${
                    activeTab === tab.id
                      ? dark ? "bg-primary-500/20 text-primary-300" : "bg-primary-100 text-primary-700"
                      : dark ? "bg-gray-700 text-gray-300" : "bg-gray-200 text-gray-600"
                  }`}>
                    {tab.count}
                  </span>
                )}
                {activeTab === tab.id && (
                  <div className={`absolute bottom-0 left-0 right-0 h-0.5 ${
                    dark ? "bg-primary-400" : "bg-primary-600"
                  }`} />
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        {filteredBookings.length === 0 ? (
          <div className={`text-center py-16 rounded-xl ${dark ? "bg-gray-800" : "bg-white"}`}>
            <Calendar className="w-16 h-16 mx-auto mb-4 opacity-30" />
            <p className="text-lg opacity-60">Không có booking nào</p>
          </div>
        ) : (
          <div className={`rounded-xl overflow-hidden shadow-sm ${dark ? "bg-gray-800" : "bg-white"}`}>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className={dark ? "bg-gray-700/50" : "bg-gray-50"}>
                  <tr>
                    {columns.map((col) => (
                      <th
                        key={col.key}
                        className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider"
                      >
                        {col.label}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className={`divide-y ${dark ? "divide-gray-700" : "divide-gray-200"}`}>
                  {filteredBookings.map((booking) => (
                    <tr
                      key={booking.bookingId}
                      className={`transition ${
                        dark ? "hover:bg-gray-700/30" : "hover:bg-gray-50"
                      }`}
                    >
                      {columns.map((col) => (
                        <td key={col.key} className="px-4 py-3 text-sm">
                          {cell(booking, col.key)}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Confirm Modal */}
      <ConfirmModal
        isOpen={modalState.isOpen}
        onClose={() => setModalState({ isOpen: false, type: "confirm", bookingId: null })}
        onConfirm={executeAction}
        title={modalState.type === "confirm" ? "Xác nhận đặt tour" : "Hủy đặt tour"}
        message={
          modalState.type === "confirm"
            ? "Bạn có chắc chắn muốn xác nhận đặt tour này?"
            : "Bạn có chắc chắn muốn hủy đặt tour này? Thao tác này không thể hoàn tác."
        }
        confirmText={modalState.type === "confirm" ? "Xác nhận" : "Hủy booking"}
        loading={actionLoading !== null}
      />
    </div>
  );
};

export default ListTourBookingPage;
