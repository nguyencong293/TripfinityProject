import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, CheckCircle, XCircle, ChevronLeft, Calendar, Loader2 } from "lucide-react";
import { useLanguage } from "../../../hooks/useLanguage";
import type { TourBookingDTO, TourDTO, UserDTO } from "../../../types";
import api from "../../../services/api";
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import { getToursByProvider } from "../../../services/tourService";
import ConfirmModal from "../../../components/common/ConfirmModal";

const ListTourBookingPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
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
          setError(t("error_user_not_found"));
          return;
        }
        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (!provider?.providerId) {
          setError(t("error_provider_not_found"));
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
        setError(e instanceof Error ? e.message : t("tour_booking_error_load"));
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, [t]);

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
      { key: "bookingId", label: t("tour_col_id") },
      { key: "tourName", label: t("tour_col_name") },
      { key: "userName", label: t("tour_booking_customer_name") },
      { key: "userPhone", label: t("tour_booking_customer_phone") },
      { key: "startDate", label: t("tour_col_start_date") },
      { key: "endDate", label: t("tour_col_end_date") },
      { key: "people", label: t("tour_booking_num_people") },
      { key: "totalPrice", label: t("tour_booking_total_price") },
      { key: "paymentMethod", label: t("tour_booking_payment_method") },
      { key: "bookingStatus", label: t("status") },
      { key: "createdAt", label: t("tour_booking_created_at") },
      { key: "actions", label: t("actions") },
    ],
    [t]
  );

  const formatDate = (s?: string) => s ? new Date(s).toLocaleDateString("vi-VN") : t("tour_na");
  const formatDateTime = (s?: string) => s ? new Date(s).toLocaleString("vi-VN", { 
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric', 
    hour: '2-digit', 
    minute: '2-digit' 
  }) : t("tour_na");
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
          ? t("tour_booking_error_confirm")
          : t("tour_booking_error_cancel")
      );
    } finally {
      setActionLoading(null);
    }
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: "theme-bg-warning theme-text-warning theme-border-warning",
      confirmed: "theme-bg-info theme-text-info theme-border-info",
      completed: "theme-bg-success theme-text-success theme-border-success",
      cancelled: "theme-bg-error theme-text-error theme-border-error",
      refunded: "bg-purple-100 text-purple-700 border-purple-300 dark:bg-purple-900/30 dark:text-purple-300 dark:border-purple-500/30",
    };
    return colors[status] || "theme-bg-secondary theme-text-secondary";
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
            {tour?.location && <div className="text-xs theme-text-secondary">{tour.location}</div>}
          </div>
        );
      case "userName":
        return (
          <div>
            <div className="font-medium">{user?.fullName || t("tour_na")}</div>
            {user?.email && <div className="text-xs theme-text-secondary">{user.email}</div>}
          </div>
        );
      case "userPhone":
        return user?.phoneNumber || t("tour_na");
      case "startDate":
        return formatDate(b.startDate);
      case "endDate":
        return formatDate(b.endDate);
      case "people":
        return `${b.numAdults || 0} ${t("tour_guest")}`;
      case "totalPrice":
        return (
          <div className="font-semibold">
            {formatCurrency(b.totalPrice)} {b.currencyCode || 'VND'}
          </div>
        );
      case "paymentMethod": {
        if (!b.paymentMethod || b.paymentMethod === 'counter') {
          return (
            <span className="px-2 py-1 rounded text-xs font-medium theme-bg-warning theme-text-warning">
              💵 {t("tour_payment_counter")}
            </span>
          );
        }
        const methodLabel = b.paymentMethod === 'zalopay' ? 'ZaloPay' : 
                          b.paymentMethod === 'vnpay' ? 'VNPay' : 
                          b.paymentMethod.toUpperCase();
        return (
          <span className="px-2 py-1 rounded text-xs font-medium theme-bg-success theme-text-success">
            ✅ {methodLabel}
          </span>
        );
      }
      case "bookingStatus": {
        const statusLabel: Record<string, string> = {
          pending: t("tour_booking_status_pending"),
          confirmed: t("tour_booking_status_confirmed"),
          completed: t("tour_booking_status_completed"),
          cancelled: t("tour_booking_status_cancelled"),
          refunded: t("tour_booking_status_refunded"),
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
              className="p-2 rounded transition theme-bg-info theme-text-info hover:opacity-80"
              title={t("view_detail")}
            >
              <Eye size={16} />
            </button>
            {b.providerConfirmed === 0 && (
              <>
                <button
                  onClick={() => b.bookingId && handleConfirmBooking(b.bookingId)}
                  disabled={actionLoading === b.bookingId}
                  className="p-2 rounded transition theme-bg-success theme-text-success hover:opacity-80 disabled:opacity-40"
                  title={t("tour_booking_confirm")}
                >
                  {actionLoading === b.bookingId ? <Loader2 size={16} className="animate-spin" /> : <CheckCircle size={16} />}
                </button>
                <button
                  onClick={() => b.bookingId && handleCancelBooking(b.bookingId)}
                  disabled={actionLoading === b.bookingId}
                  className="p-2 rounded transition theme-bg-error theme-text-error hover:opacity-80 disabled:opacity-40"
                  title={t("tour_booking_cancel")}
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
        <Loader2 className="w-8 h-8 animate-spin icon-brand" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <p className="theme-text-error mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 btn-primary"
          >
            {t("try_again")}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen p-6 theme-bg-primary theme-text-primary">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-6 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate("/supplier/service/tour")}
              className="p-2 rounded-lg transition theme-hover"
            >
              <ChevronLeft size={20} />
            </button>
            <div>
              <h1 className="text-2xl font-bold flex items-center gap-2">
                <Calendar className="icon-brand" size={28} />
                {t("tour_booking_list_title")}
              </h1>
              <p className="text-sm theme-text-secondary mt-1">
                {t("tour_booking_list_subtitle")}
              </p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="mb-6 border-b theme-border">
          <div className="flex gap-4">
            {[
              { id: 0, label: t("tour_booking_tab_pending"), count: getTabCount(0) },
              { id: 1, label: t("tour_booking_tab_confirmed"), count: getTabCount(1) },
              { id: 2, label: t("tour_booking_tab_cancelled"), count: getTabCount(2) },
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as 0 | 1 | 2)}
                className={`px-4 py-3 font-medium transition relative ${
                  activeTab === tab.id
                    ? "theme-text-brand"
                    : "theme-text-secondary hover:theme-text-primary"
                }`}
              >
                {tab.label}
                {tab.count > 0 && (
                  <span className={`ml-2 px-2 py-0.5 rounded-full text-xs font-semibold ${
                    activeTab === tab.id
                      ? "theme-bg-brand theme-text-brand-contrast"
                      : "theme-bg-secondary theme-text-secondary"
                  }`}>
                    {tab.count}
                  </span>
                )}
                {activeTab === tab.id && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 theme-bg-brand" />
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        {filteredBookings.length === 0 ? (
          <div className="text-center py-16 rounded-xl theme-bg-card">
            <Calendar className="w-16 h-16 mx-auto mb-4 theme-text-secondary opacity-30" />
            <p className="text-lg theme-text-secondary">{t("tour_booking_no_data")}</p>
          </div>
        ) : (
          <div className="rounded-xl overflow-hidden shadow-sm theme-bg-card">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="theme-bg-secondary">
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
                <tbody className="divide-y theme-divide">
                  {filteredBookings.map((booking) => (
                    <tr
                      key={booking.bookingId}
                      className="transition theme-hover"
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
        title={modalState.type === "confirm" ? t("tour_booking_confirm_title") : t("tour_booking_cancel_title")}
        message={
          modalState.type === "confirm"
            ? t("tour_booking_confirm_message")
            : t("tour_booking_cancel_message")
        }
        confirmText={modalState.type === "confirm" ? t("tour_booking_confirm") : t("tour_booking_cancel")}
        loading={actionLoading !== null}
      />
    </div>
  );
};

export default ListTourBookingPage;
