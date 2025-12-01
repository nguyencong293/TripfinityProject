import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  BarChart3,
  Hotel,
  Calendar,
  Bell,
  ChevronRight,
  Plus,
  List,
  BarChart2,
  MessageSquare,
  Zap,
} from "lucide-react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import {
  getProviderByUserId,
  getUserById,
} from "../../../services/providerService";
import {
  getHotelsByProvider,
  getHotelRatingSummaryByHotel,
  getHotelReviewsByHotel,
  getHotelReviewsCountByProvider,
} from "../../../services/hotelService";
import type {
  HotelDTO,
  HotelBookingDTO,
  HotelRatingSummaryDTO,
  HotelReviewDTO,
  UserDTO,
} from "../../../types";
import api from "../../../services/api";
import {
  QuickAction,
  NotificationItem,
  StatCard,
  HotelCard,
  BookingRow,
  RatingSummaryCard,
  ReviewCard,
} from "../../../components/hotel";
import { useLanguage } from "../../../hooks/useLanguage";
import ConfirmModal from "../../../components/common/ConfirmModal";

// Notification types for this page context
import type { Notification, NotificationType } from "../../../components/hotel/NotificationItem";

interface BackendNotification {
  notification_id: number;
  title: string;
  content: string;
  sent_at: string;
  is_read: boolean;
  category: string;
}

// merged into hotelService

// Main Dashboard
const DashboardHotelPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [providerId, setProviderId] = useState<number | undefined>();
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [bookings, setBookings] = useState<HotelBookingDTO[]>([]);
  const [ratingSummaries, setRatingSummaries] = useState<
    HotelRatingSummaryDTO[]
  >([]);
  const [recentReviews, setRecentReviews] = useState<HotelReviewDTO[]>([]);
  const [totalReviews, setTotalReviews] = useState<number>(0);
  const [userCache, setUserCache] = useState<Map<number, UserDTO>>(new Map());
  const [actionLoading, setActionLoading] = useState<number | null>(null);
  const [modalState, setModalState] = useState<{
    isOpen: boolean;
    type: "confirm" | "cancel";
    bookingId: number | null;
  }>({ isOpen: false, type: "confirm", bookingId: null });
  const [revenueFilter, setRevenueFilter] = useState<
    "day" | "week" | "month" | "year"
  >("day");
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [newNotificationsCount, setNewNotificationsCount] = useState<number>(0);

  const executeAction = async () => {
    if (!modalState.bookingId) return;

    try {
      setActionLoading(modalState.bookingId);
      
      if (modalState.type === "confirm") {
        await api.patch(`/hotel-bookings/${modalState.bookingId}/confirm`);
      } else {
        await api.patch(`/hotel-bookings/${modalState.bookingId}/cancel`);
      }

      // Refresh booking data
      const response = await api.get<HotelBookingDTO>(
        `/hotel-bookings/${modalState.bookingId}`
      );
      setBookings((prev) =>
        prev.map((booking) =>
          booking.bookingId === modalState.bookingId ? response.data : booking
        )
      );

      setModalState({ isOpen: false, type: "confirm", bookingId: null });
    } catch (error) {
      console.error(`❌ Error ${modalState.type}ing booking:`, error);
      alert(
        modalState.type === "confirm"
          ? t("booking_confirmed_error") || "Lỗi khi xác nhận đặt phòng"
          : t("booking_cancelled_error") || "Lỗi khi hủy đặt phòng"
      );
    } finally {
      setActionLoading(null);
    }
  };

  // Helper function to format currency compactly
  const formatCompactCurrency = (value: number): string => {
    if (value >= 1000000000) {
      return `${(value / 1000000000).toFixed(1)}T`; // Tỷ
    } else if (value >= 1000000) {
      return `${(value / 1000000).toFixed(1)}Tr`; // Triệu
    } else if (value >= 1000) {
      return `${(value / 1000).toFixed(1)}N`; // Nghìn
    }
    return value.toString();
  };

  // Calculate month-over-month growth percentage
  const calculateMonthGrowth = useMemo(() => {
    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    const confirmedBookings = bookings.filter((b) => b.providerConfirmed === 1);

    const currentMonthRevenue = confirmedBookings
      .filter((b) => {
        if (!b.createdAt) return false;
        const date = new Date(b.createdAt);
        return (
          date.getMonth() === currentMonth && date.getFullYear() === currentYear
        );
      })
      .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

    const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear;

    const lastMonthRevenue = confirmedBookings
      .filter((b) => {
        if (!b.createdAt) return false;
        const date = new Date(b.createdAt);
        return (
          date.getMonth() === lastMonth && date.getFullYear() === lastMonthYear
        );
      })
      .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

    // Nếu tháng trước = 0 mà tháng nay > 0 thì tăng >100%
    if (lastMonthRevenue === 0 && currentMonthRevenue > 0) {
      return { value: 100, isPositive: true, isOver100: true };
    }
    // Nếu cả 2 tháng đều 0
    if (lastMonthRevenue === 0 && currentMonthRevenue === 0) {
      return { value: 0, isPositive: true, isOver100: false };
    }

    const growthPercent =
      ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
    return {
      value: Math.abs(growthPercent),
      isPositive: growthPercent >= 0,
      isOver100: false,
    };
  }, [bookings]);

  // Calculate month-over-month booking count growth
  const calculateBookingGrowth = useMemo(() => {
    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    const confirmedBookings = bookings.filter((b) => b.providerConfirmed === 1);

    const currentMonthCount = confirmedBookings.filter((b) => {
      if (!b.createdAt) return false;
      const date = new Date(b.createdAt);
      return (
        date.getMonth() === currentMonth && date.getFullYear() === currentYear
      );
    }).length;

    const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear;

    const lastMonthCount = confirmedBookings.filter((b) => {
      if (!b.createdAt) return false;
      const date = new Date(b.createdAt);
      return (
        date.getMonth() === lastMonth && date.getFullYear() === lastMonthYear
      );
    }).length;

    // Nếu tháng trước = 0 mà tháng nay > 0 thì tăng >100%
    if (lastMonthCount === 0 && currentMonthCount > 0) {
      return { value: 100, isPositive: true, isOver100: true };
    }
    // Nếu cả 2 tháng đều 0
    if (lastMonthCount === 0 && currentMonthCount === 0) {
      return { value: 0, isPositive: true, isOver100: false };
    }

    const growthPercent =
      ((currentMonthCount - lastMonthCount) / lastMonthCount) * 100;
    return {
      value: Math.abs(growthPercent),
      isPositive: growthPercent >= 0,
      isOver100: false,
    };
  }, [bookings]);

  useEffect(() => {
    const init = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) return;
        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);
        if (provider?.providerId) setProviderId(provider.providerId);
      } catch (e) {
        console.error(e);
      }
    };
    init();
  }, []);

  useEffect(() => {
    const load = async () => {
      if (!providerId) return;
      try {
        console.log("🔍 Loading data for providerId:", providerId);

        const hs = await getHotelsByProvider(providerId);
        console.log("🏨 Hotels found:", hs.length, hs);
        setHotels(hs);

        const bRes = await api.get<HotelBookingDTO[]>(
          `/hotel-bookings/provider/${providerId}`
        );
        console.log("📅 Bookings response:", bRes.data);
        console.log("📊 Total bookings:", bRes.data?.length || 0);
        setBookings(bRes.data || []);

        // Fetch user info for all bookings
        const uniqueUserIds = Array.from(
          new Set((bRes.data || []).map((b) => b.userId))
        );
        const usersMap = new Map<number, UserDTO>();
        await Promise.all(
          uniqueUserIds.map(async (userId) => {
            try {
              const user = await getUserById(userId);
              usersMap.set(userId, user);
            } catch (e) {
              console.error(`Failed to fetch user ${userId}:`, e);
            }
          })
        );
        setUserCache(usersMap);
        console.log("👥 Users loaded:", usersMap.size);

        // Fetch rating summaries for each hotel
        const summaryPromises = hs.map((h) =>
          h.hotelId
            ? getHotelRatingSummaryByHotel(h.hotelId).catch((e) => {
                console.error(
                  `Failed to fetch rating for hotel ${h.hotelId}:`,
                  e
                );
                return null;
              })
            : Promise.resolve(null)
        );
        const summaries = (await Promise.all(summaryPromises)).filter(
          (s) => s !== null
        ) as HotelRatingSummaryDTO[];
        setRatingSummaries(summaries);

        // Fetch reviews for the first hotel (if available)
        const firstHotelId = hs[0]?.hotelId;
        if (firstHotelId) {
          console.log(`📥 Dashboard loading reviews for hotel ${firstHotelId}`);
          const revs = await getHotelReviewsByHotel(firstHotelId);
          console.log(`📤 Dashboard received ${revs.length} reviews`);
          if (revs.length > 0) {
            console.log("🔍 Sample review:", {
              reviewId: revs[0].reviewId,
              likesCount: revs[0].likesCount,
              replyCount: revs[0].replyCount,
            });
          }
          setRecentReviews(revs.slice(0, 2));
        } else {
          setRecentReviews([]);
        }

        // Fetch total reviews count for provider
        const reviewsCount = await getHotelReviewsCountByProvider(providerId);
        console.log("📊 Total reviews for provider:", reviewsCount);
        setTotalReviews(reviewsCount);
      } catch (e) {
        console.error("❌ Error loading dashboard data:", e);
      }
    };

    load();

    // Reload data when window gains focus (user returns from detail page)
    const handleVisibilityChange = () => {
      if (!document.hidden) {
        load();
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () =>
      document.removeEventListener("visibilitychange", handleVisibilityChange);
  }, [providerId]);

  const revenueChartData = useMemo(() => {
    // Only count confirmed bookings (providerConfirmed === 1)
    const confirmedBookings = bookings.filter((b) => b.providerConfirmed === 1);

    if (revenueFilter === "day") {
      const map = new Map<number, number>();
      confirmedBookings.forEach((b) => {
        const d = b.createdAt ? new Date(b.createdAt).getDate() : 1;
        map.set(d, (map.get(d) || 0) + (b.totalPrice || 0));
      });
      return Array.from({ length: 30 }, (_, i) => {
        const day = i + 1;
        return { day, label: `${day}`, revenue: map.get(day) || 0 };
      });
    } else if (revenueFilter === "week") {
      const map = new Map<number, number>();
      confirmedBookings.forEach((b) => {
        if (b.createdAt) {
          const date = new Date(b.createdAt);
          const week = Math.ceil(date.getDate() / 7);
          map.set(week, (map.get(week) || 0) + (b.totalPrice || 0));
        }
      });
      return Array.from({ length: 4 }, (_, i) => {
        const week = i + 1;
        return {
          day: week,
          label: `Tuần ${week}`,
          revenue: map.get(week) || 0,
        };
      });
    } else if (revenueFilter === "month") {
      const map = new Map<number, number>();
      confirmedBookings.forEach((b) => {
        if (b.createdAt) {
          const month = new Date(b.createdAt).getMonth() + 1;
          map.set(month, (map.get(month) || 0) + (b.totalPrice || 0));
        }
      });
      return Array.from({ length: 12 }, (_, i) => {
        const month = i + 1;
        return { day: month, label: `T${month}`, revenue: map.get(month) || 0 };
      });
    } else {
      // year
      const map = new Map<number, number>();
      confirmedBookings.forEach((b) => {
        if (b.createdAt) {
          const year = new Date(b.createdAt).getFullYear();
          map.set(year, (map.get(year) || 0) + (b.totalPrice || 0));
        }
      });
      const currentYear = new Date().getFullYear();
      return Array.from({ length: 5 }, (_, i) => {
        const year = currentYear - 4 + i;
        return { day: year, label: `${year}`, revenue: map.get(year) || 0 };
      });
    }
  }, [bookings, revenueFilter]);

  // Fetch notifications from API
  useEffect(() => {
    const formatNotificationTime = (dateString: string): string => {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now.getTime() - date.getTime();
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMins / 60);
      const diffDays = Math.floor(diffHours / 24);

      if (diffMins < 1) return t("just_now") || "Vừa xong";
      if (diffMins < 60)
        return `${diffMins} ${t("minutes_ago_suffix") || "phút trước"}`;
      if (diffHours < 24)
        return `${diffHours} ${t("hours_ago_suffix") || "giờ trước"}`;
      return `${diffDays} ${t("days_ago_suffix") || "ngày trước"}`;
    };

    const fetchNotifications = async () => {
      const userStr = localStorage.getItem("user");
      if (!userStr) return;

      const user = JSON.parse(userStr);
      try {
        const response = await fetch(
          `http://localhost:8080/api/notifications/user/${user.userId}/recent?limit=3`
        );
        if (response.ok) {
          const data: BackendNotification[] = await response.json();
          // Map backend notification to frontend format
          const mapped: Notification[] = data.map((n: BackendNotification) => ({
            id: n.notification_id.toString(),
            type: n.category as NotificationType,
            title: n.title,
            message: n.content,
            time: formatNotificationTime(n.sent_at),
            isNew: !n.is_read,
          }));
          setNotifications(mapped);
          setNewNotificationsCount(
            data.filter((n: BackendNotification) => !n.is_read).length
          );
        }
      } catch (error) {
        console.error("Failed to fetch notifications:", error);
      }
    };

    fetchNotifications();
  }, [t]);

  // Derived selections - get 2 most recent hotels
  const recentHotels = useMemo(() => {
    return [...hotels]
      .sort((a, b) => {
        const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
        const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
        return dateB - dateA; // Newest first
      })
      .slice(0, 2);
  }, [hotels]);

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-6">
      {/* SECTION 1: Thống kê tổng quan */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={<BarChart3 className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_total_revenue")}
          value={`${formatCompactCurrency(
            bookings
              .filter((b) => b.providerConfirmed === 1)
              .reduce((sum, b) => sum + (b.totalPrice || 0), 0)
          )} VND`}
          trend={calculateMonthGrowth}
        />
        <StatCard
          icon={<Hotel className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_total_bookings")}
          value={bookings.filter((b) => b.providerConfirmed === 1).length}
          trend={calculateBookingGrowth}
        />
        <StatCard
          icon={<Calendar className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_total_reviews")}
          value={totalReviews}
          // badge={{ text: t("increase"), variant: "info" }}
        />
        <StatCard
          icon={<Hotel className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_hotels")}
          value={hotels.length}
        />
      </div>

      {/* SECTION 2: Thông báo */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Bell className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              {t("hotel_dashboard_new_notifications")}
            </h2>
            {newNotificationsCount > 0 && (
              <span className="px-2 py-0.5 text-xs font-medium theme-bg-primary theme-text-button rounded-full">
                {newNotificationsCount}
              </span>
            )}
          </div>
          <button
            className="link-brand text-sm font-medium flex items-center gap-1"
            onClick={() => navigate("/supplier/notifications")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {notifications.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <Bell className="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>{t("no_notifications") || "Không có thông báo mới"}</p>
            </div>
          ) : (
            notifications.map((n) => (
              <NotificationItem
                key={n.id}
                notification={n}
                onClick={() => console.log("Clicked", n.id)}
              />
            ))
          )}
        </div>
      </div>

      {/* SECTION 3: Hành động nhanh */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-6">
          <Zap className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("hotel_dashboard_quick_actions")}
          </h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <QuickAction
            icon={<Plus className="w-6 h-6" />}
            label={t("hotel_dashboard_action_add_hotel")}
            description={t("hotel_dashboard_action_add_hotel_desc")}
            onClick={() => navigate("/supplier/service/hotel/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label={t("hotel_dashboard_action_manage_bookings")}
            description={t("hotel_dashboard_action_manage_bookings_desc")}
            onClick={() => navigate("/supplier/service/hotel/bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label={t("hotel_dashboard_action_manage_reviews")}
            description={t("hotel_dashboard_action_manage_reviews_desc")}
            onClick={() => navigate("/supplier/service/hotel/all-reviews")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label={t("hotel_dashboard_action_manage_hotel")}
            description={t("hotel_dashboard_action_manage_hotel_desc")}
            onClick={() => navigate("/supplier/service/hotel/list")}
          />
        </div>
      </div>

      {/* SECTION 4: Biểu đồ doanh thu */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <BarChart3 className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              {t("hotel_dashboard_revenue_chart")}
            </h2>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setRevenueFilter("day")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "day"
                  ? "bg-blue-600 text-white"
                  : "theme-bg-secondary theme-text-secondary hover:theme-bg-tertiary"
              }`}
            >
              Ngày
            </button>
            <button
              onClick={() => setRevenueFilter("week")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "week"
                  ? "bg-blue-600 text-white"
                  : "theme-bg-secondary theme-text-secondary hover:theme-bg-tertiary"
              }`}
            >
              Tuần
            </button>
            <button
              onClick={() => setRevenueFilter("month")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "month"
                  ? "bg-blue-600 text-white"
                  : "theme-bg-secondary theme-text-secondary hover:theme-bg-tertiary"
              }`}
            >
              Tháng
            </button>
            <button
              onClick={() => setRevenueFilter("year")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "year"
                  ? "bg-blue-600 text-white"
                  : "theme-bg-secondary theme-text-secondary hover:theme-bg-tertiary"
              }`}
            >
              Năm
            </button>
          </div>
        </div>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={revenueChartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis tickFormatter={(value) => formatCompactCurrency(value)} />
              <Tooltip
                formatter={(value: number) => [
                  `${value.toLocaleString("vi-VN")} VND`,
                  "",
                ]}
                labelStyle={{ fontWeight: "bold" }}
              />
              <Bar dataKey="revenue" fill="#34A853" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* SECTION 5: Danh sách khách sạn */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("hotel_dashboard_hotel_list")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/hotel/list")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {hotels.slice(0, 3).map((h) => (
            <HotelCard
              key={h.hotelId}
              hotel={h}
              onView={() =>
                navigate(`/supplier/service/hotel/${h.hotelId}/view`)
              }
              onEdit={() =>
                navigate(`/supplier/service/hotel/${h.hotelId}/edit`)
              }
            />
          ))}
        </div>
      </div>

      {/* SECTION 6: Đặt phòng gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Calendar className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              {t("hotel_dashboard_recent_bookings")}
            </h2>
          </div>
          <button
            className="link-brand text-sm font-medium flex items-center gap-1"
            onClick={() => navigate("/supplier/service/hotel/bookings")}
          >
            {t("view_all")}
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        {bookings.filter((b) => b.providerConfirmed === 0).length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>{t("hotel_dashboard_no_bookings") || "Chưa có đặt phòng nào"}</p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {[...bookings]
              .filter((b) => b.providerConfirmed === 0)
              .sort((a, b) => {
                const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
                const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
                return dateB - dateA; // Mới nhất lên đầu
              })
              .slice(0, 1)
              .map((b) => {
                const hotel = hotels.find((h) => h.hotelId === b.hotelId);
                const user = userCache.get(b.userId);
                return (
                  <div key={b.bookingId} className="relative">
                    <div className="m-auto">
                      <BookingRow
                        booking={b}
                        hotelName={hotel?.title}
                        userName={user?.fullName}
                        userPhone={user?.phoneNumber}
                        onView={() =>
                          navigate(
                            `/supplier/service/hotel/bookings/${b.bookingId}`
                          )
                        }
                        onConfirm={() =>
                          setModalState({
                            isOpen: true,
                            type: "confirm",
                            bookingId: b.bookingId || null,
                          })
                        }
                        onCancel={() =>
                          setModalState({
                            isOpen: true,
                            type: "cancel",
                            bookingId: b.bookingId || null,
                          })
                        }
                      />
                    </div>
                  </div>
                );
              })}
          </div>
        )}
      </div>

      {/* SECTION 7: Thống kê & đánh giá */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary mb-4">
            {t("hotel_dashboard_rating_overview")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/hotel/all-reviews")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentHotels.length === 0 ? (
            <div className="theme-text-secondary text-sm">
              {t("hotel_dashboard_no_rating_data")}
            </div>
          ) : (
            recentHotels.map((hotel) => {
              const summary = ratingSummaries.find(
                (s) => s.hotelId === hotel.hotelId
              );
              return summary ? (
                <RatingSummaryCard
                  key={hotel.hotelId}
                  summary={summary}
                  hotelName={hotel.title || t("hotel")}
                />
              ) : null;
            })
          )}
        </div>
      </div>

      {/* SECTION 8: Nhận xét gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("hotel_dashboard_recent_reviews")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/hotel/recent-reviews")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentReviews.length === 0 && (
            <div className="theme-text-secondary text-sm">
              {t("hotel_dashboard_no_reviews")}
            </div>
          )}
          {recentReviews.map((r) => {
            const reviewHotel = hotels.find((h) => h.hotelId === r.hotelId);
            return (
              <ReviewCard
                key={r.reviewId}
                review={r}
                hotelName={reviewHotel?.title || t("hotel")}
                readOnly={true}
              />
            );
          })}
        </div>
      </div>

      {/* Confirm Modal */}
      <ConfirmModal
        isOpen={modalState.isOpen}
        onClose={() =>
          setModalState({ isOpen: false, type: "confirm", bookingId: null })
        }
        onConfirm={executeAction}
        title={
          modalState.type === "confirm"
            ? t("confirm_booking") || "Xác nhận đặt phòng"
            : t("cancel_booking") || "Hủy đặt phòng"
        }
        message={
          modalState.type === "confirm"
            ? t("confirm_booking_message") ||
              "Bạn có chắc chắn muốn xác nhận đặt phòng này không?"
            : t("confirm_cancel_booking") ||
              "Bạn có chắc chắn muốn hủy đặt phòng này không?"
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

export default DashboardHotelPage;
