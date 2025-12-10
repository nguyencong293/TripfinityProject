import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  BarChart3,
  MapPin,
  Calendar,
  Bell,
  ChevronRight,
  Plus,
  List,
  BarChart2,
  MessageSquare,
  Zap,
  Clock,
  Users,
  Eye,
  CheckCircle,
  XCircle,
  User,
  Phone,
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
  getAttractionsByProvider,
  getAttractionReviewsByAttraction,
  getAttractionReviewsCountByProvider,
  getAttractionBookingsByProvider,
} from "../../../services/attractionService";
import type {
  AttractionDTO,
  AttractionBookingDTO,
  AttractionReviewDTO,
  UserDTO,
} from "../../../types";
import api from "../../../services/api";
import {
  QuickAction,
  NotificationItem,
  StatCard,
} from "../../../components/shared";
import { useLanguage } from "../../../hooks/useLanguage";
import ConfirmModal from "../../../components/common/ConfirmModal";
import type { Notification, NotificationType } from "../../../components/shared";

interface BackendNotification {
  notification_id: number;
  title: string;
  content: string;
  sent_at: string;
  is_read: boolean;
  category: string;
}

// Main Dashboard
const DashboardAttractionPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [providerId, setProviderId] = useState<number | undefined>();
  const [attractions, setAttractions] = useState<AttractionDTO[]>([]);
  const [bookings, setBookings] = useState<AttractionBookingDTO[]>([]);
  const [recentReviews, setRecentReviews] = useState<AttractionReviewDTO[]>([]);
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
        await api.patch(`/attraction-bookings/${modalState.bookingId}/confirm`);
      } else {
        await api.patch(`/attraction-bookings/${modalState.bookingId}/cancel`);
      }

      // Refresh booking data
      const response = await api.get<AttractionBookingDTO>(
        `/attraction-bookings/${modalState.bookingId}`
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
          ? "Lỗi khi xác nhận đặt vé"
          : "Lỗi khi hủy đặt vé"
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

    if (lastMonthRevenue === 0 && currentMonthRevenue > 0) {
      return { value: 100, isPositive: true, isOver100: true };
    }
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

    if (lastMonthCount === 0 && currentMonthCount > 0) {
      return { value: 100, isPositive: true, isOver100: true };
    }
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

  // Load provider data
  useEffect(() => {
    const userStr = localStorage.getItem("user");
    if (!userStr) {
      navigate("/supplier/auth/login");
      return;
    }

    const user = JSON.parse(userStr);

    const fetchProvider = async () => {
      try {
        const provider = await getProviderByUserId(user.userId);
        if (provider && provider.providerId) {
          setProviderId(provider.providerId);
        }
      } catch (error) {
        console.error("❌ Error loading provider:", error);
      }
    };

    fetchProvider();
  }, [navigate]);

  // Load dashboard data
  useEffect(() => {
    if (!providerId) return;

    const load = async () => {
      try {
        // Fetch attractions
        const attrs = await getAttractionsByProvider(providerId);
        console.log("📊 Loaded attractions:", attrs.length);
        setAttractions(attrs);

        // Try to fetch bookings (API not implemented yet)
        try {
          const bks = await getAttractionBookingsByProvider(providerId);
          console.log("📅 Loaded bookings:", bks.length);
          setBookings(bks);

          // Fetch users for bookings
          const userIds = [...new Set(bks.map((b) => b.userId))];
          const cache = new Map<number, UserDTO>();
          await Promise.all(
            userIds.map(async (uid) => {
              try {
                const user = await getUserById(uid);
                cache.set(uid, user);
              } catch (e) {
                console.error(`Failed to load user ${uid}:`, e);
              }
            })
          );
          setUserCache(cache);
        } catch (bookingError) {
          console.warn("⚠️ Attraction booking API chưa implement, bỏ qua:", bookingError);
          setBookings([]);
        }

        // Fetch reviews for the first attraction (if available)
        const firstAttractionId = attrs[0]?.attractionId;
        if (firstAttractionId) {
          const revs = await getAttractionReviewsByAttraction(firstAttractionId);
          setRecentReviews(revs.slice(0, 2));
        } else {
          setRecentReviews([]);
        }

        // Fetch total reviews count for provider
        const reviewsCount = await getAttractionReviewsCountByProvider(providerId);
        setTotalReviews(reviewsCount);
      } catch (e) {
        console.error("❌ Error loading dashboard data:", e);
      }
    };

    load();

    // Reload data when window gains focus
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

      if (diffMins < 1) return "Vừa xong";
      if (diffMins < 60) return `${diffMins} phút trước`;
      if (diffHours < 24) return `${diffHours} giờ trước`;
      return `${diffDays} ngày trước`;
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

  // Calculate average visit duration
  const averageVisitDuration = useMemo(() => {
    const validDurations = attractions
      .filter((a) => a.averageVisitMinutes && a.averageVisitMinutes > 0)
      .map((a) => a.averageVisitMinutes!);
    
    if (validDurations.length === 0) return 0;
    
    const sum = validDurations.reduce((acc, val) => acc + val, 0);
    return Math.round(sum / validDurations.length);
  }, [attractions]);

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-6">
      {/* SECTION 1: Thống kê tổng quan */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={<BarChart3 className="w-5 h-5 icon-brand" />}
          label="Tổng doanh thu"
          value={`${formatCompactCurrency(
            bookings
              .filter((b) => b.providerConfirmed === 1)
              .reduce((sum, b) => sum + (b.totalPrice || 0), 0)
          )} VND`}
          trend={calculateMonthGrowth}
        />
        <StatCard
          icon={<MapPin className="w-5 h-5 icon-brand" />}
          label="Tổng số đặt vé"
          value={bookings.filter((b) => b.providerConfirmed === 1).length}
          trend={calculateBookingGrowth}
        />
        <StatCard
          icon={<Calendar className="w-5 h-5 icon-brand" />}
          label="Tổng đánh giá"
          value={totalReviews}
        />
        <StatCard
          icon={<MapPin className="w-5 h-5 icon-brand" />}
          label="Điểm tham quan"
          value={attractions.length}
        />
      </div>

      {/* SECTION 2: Thông báo */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Bell className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              Thông báo mới
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
            Xem tất cả <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {notifications.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <Bell className="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>Không có thông báo mới</p>
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
            Hành động nhanh
          </h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <QuickAction
            icon={<Plus className="w-6 h-6" />}
            label="Thêm điểm tham quan"
            description="Tạo mới một điểm tham quan"
            onClick={() => navigate("/supplier/service/attraction/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label="Quản lý đặt vé"
            description="Xem và xử lý các đơn đặt vé"
            onClick={() => navigate("/supplier/service/attraction/bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label="Quản lý đánh giá"
            description="Xem và trả lời đánh giá"
            onClick={() => navigate("/supplier/service/attraction/all-reviews")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label="Quản lý điểm tham quan"
            description="Chỉnh sửa thông tin điểm tham quan"
            onClick={() => navigate("/supplier/service/attraction/list")}
          />
        </div>
      </div>

      {/* SECTION 4: Biểu đồ doanh thu */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <BarChart3 className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              Biểu đồ doanh thu
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

      {/* SECTION 5: Danh sách điểm tham quan */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            Điểm tham quan của bạn
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/attraction/list")}
          >
            Xem tất cả <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {attractions.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <MapPin className="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>Chưa có điểm tham quan nào</p>
              <button
                onClick={() => navigate("/supplier/service/attraction/create")}
                className="mt-4 px-4 py-2 theme-bg-primary theme-text-button rounded-lg hover:opacity-90 transition-opacity"
              >
                Tạo điểm tham quan đầu tiên
              </button>
            </div>
          ) : (
            attractions.slice(0, 3).map((a) => (
              <div
                key={a.attractionId}
                className="rounded-lg border theme-border theme-bg-card p-4 hover:shadow-md transition-shadow"
              >
                <div className="flex items-start gap-3">
                  {a.thumbnailUrl ? (
                    <img
                      src={a.thumbnailUrl}
                      alt={a.title}
                      className="w-20 h-20 object-cover rounded-lg cursor-pointer"
                      onClick={() =>
                        navigate(`/supplier/service/attraction/${a.attractionId}/view`)
                      }
                    />
                  ) : (
                    <div 
                      className="w-20 h-20 rounded-lg theme-bg-secondary flex items-center justify-center cursor-pointer"
                      onClick={() =>
                        navigate(`/supplier/service/attraction/${a.attractionId}/view`)
                      }
                    >
                      <MapPin className="w-8 h-8 theme-text-secondary" />
                    </div>
                  )}
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold theme-text-primary truncate cursor-pointer hover:theme-text-brand"
                        onClick={() =>
                          navigate(`/supplier/service/attraction/${a.attractionId}/view`)
                        }>
                      {a.title}
                    </h3>
                    <p className="text-sm theme-text-secondary mt-1">
                      {a.location || "Chưa có địa điểm"}
                    </p>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="text-sm font-medium theme-text-brand">
                        {a.price.toLocaleString("vi-VN")} VND
                      </span>
                      {a.averageVisitMinutes && (
                        <span className="text-xs theme-text-secondary flex items-center gap-1">
                          <Clock className="w-3 h-3" />
                          {a.averageVisitMinutes} phút
                        </span>
                      )}
                    </div>
                    <div className="flex gap-2 mt-3">
                      <button
                        onClick={() =>
                          navigate(`/supplier/service/attraction/${a.attractionId}/edit`)
                        }
                        className="flex-1 px-3 py-1.5 text-sm border theme-border rounded-lg hover:theme-bg-secondary transition-colors theme-text-primary"
                      >
                        Chỉnh sửa
                      </button>
                      <button
                        onClick={() =>
                          navigate(`/supplier/service/attraction/${a.attractionId}/view`)
                        }
                        className="flex-1 px-3 py-1.5 text-sm theme-bg-primary theme-text-button rounded-lg hover:opacity-90 transition-opacity"
                      >
                        Xem chi tiết
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* SECTION 6: Đặt vé gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Calendar className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              Đặt vé gần đây
            </h2>
          </div>
          <button
            className="link-brand text-sm font-medium flex items-center gap-1"
            onClick={() => navigate("/supplier/service/attraction/bookings")}
          >
            Xem tất cả
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        {bookings.filter((b) => b.providerConfirmed === 0).length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>Chưa có đặt vé nào</p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {[...bookings]
              .filter((b) => b.providerConfirmed === 0)
              .sort((a, b) => {
                const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
                const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
                return dateB - dateA;
              })
              .slice(0, 1)
              .map((b) => {
                const attraction = attractions.find((a) => a.attractionId === b.attractionId);
                const user = userCache.get(b.userId);
                
                const formatDate = (s?: string) => s ? new Date(s).toLocaleDateString("vi-VN") : "N/A";
                const formatDateTime = (s?: string) => s ? new Date(s).toLocaleString("vi-VN", { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : "N/A";
                const formatCurrency = (v?: number) => new Intl.NumberFormat("vi-VN").format(v || 0);
                
                const getPaymentStatusLabel = (method?: string) => {
                  if (!method || method === "counter") {
                    return { label: "Thanh toán tại quầy", sublabel: "Chưa thanh toán", color: "bg-yellow-100 text-yellow-800 border-yellow-300", icon: "💵" };
                  }
                  return { label: "Thanh toán online", sublabel: method.toUpperCase() + " - Đã thanh toán", color: "bg-green-100 text-green-800 border-green-300", icon: "✅" };
                };
                
                const paymentInfo = getPaymentStatusLabel(b.paymentMethod);
                
                return (
                  <div
                    key={b.bookingId}
                    className={`p-5 rounded-xl border-2 transition-all hover:shadow-lg ${!b.providerSeen ? "bg-blue-50 border-blue-400 ring-2 ring-blue-200" : "theme-bg-card theme-border hover:border-gray-300"}`}
                  >
                    <div className="flex items-start justify-between mb-4 pb-4 border-b theme-border">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2 flex-wrap">
                          <h3 className="text-xl font-bold theme-text-primary">#{b.bookingId}</h3>
                          {!b.providerSeen && <span className="px-2.5 py-1 text-xs font-bold bg-red-500 text-white rounded-full animate-pulse shadow-sm">MỚI</span>}
                          <span className={`px-3 py-1 text-xs font-semibold rounded-full border-2 ${b.providerConfirmed === 0 ? "bg-orange-100 text-orange-700 border-orange-300" : b.providerConfirmed === 1 ? "bg-blue-100 text-blue-700 border-blue-300" : "bg-red-100 text-red-700 border-red-300"}`}>
                            {b.providerConfirmed === 0 ? "Chờ xác nhận" : b.providerConfirmed === 1 ? "Đã xác nhận" : "Đã hủy"}
                          </span>
                        </div>
                        <div className="flex items-center gap-2 text-sm theme-text-secondary">
                          <Clock className="w-4 h-4" />
                          <span className="font-medium">{formatDateTime(b.createdAt)}</span>
                        </div>
                      </div>
                    </div>

                    {attraction && (
                      <div className="mb-4 p-3 rounded-lg bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200">
                        <div className="flex items-center gap-2">
                          <MapPin className="w-5 h-5 text-blue-600" />
                          <div>
                            <p className="text-xs text-blue-600 font-medium mb-0.5">Điểm tham quan</p>
                            <p className="text-base font-bold text-blue-900">{attraction.title}</p>
                          </div>
                        </div>
                      </div>
                    )}

                    <div className="mb-4 p-3 rounded-lg bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200">
                      <p className="text-xs text-green-600 font-medium mb-2">Thông tin khách hàng</p>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 text-green-600 flex-shrink-0" />
                          <span className="text-sm font-semibold text-green-900">{user?.fullName || `User ID: ${b.userId}`}</span>
                        </div>
                        {user?.phoneNumber && (
                          <div className="flex items-center gap-2">
                            <Phone className="w-4 h-4 text-green-600 flex-shrink-0" />
                            <span className="text-sm font-semibold text-green-900">{user.phoneNumber}</span>
                          </div>
                        )}
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
                      <div className="flex items-start gap-2 p-3 rounded-lg theme-bg-secondary">
                        <Calendar className="w-5 h-5 mt-0.5 text-green-600 flex-shrink-0" />
                        <div className="min-w-0 flex-1">
                          <p className="text-xs theme-text-secondary font-medium mb-1">Ngày tham quan</p>
                          <p className="font-bold theme-text-primary text-base truncate">{formatDate(b.startDate || b.visitDate)}</p>
                        </div>
                      </div>
                      <div className="flex items-start gap-2 p-3 rounded-lg theme-bg-secondary">
                        <Users className="w-5 h-5 mt-0.5 text-blue-600 flex-shrink-0" />
                        <div className="min-w-0 flex-1">
                          <p className="text-xs theme-text-secondary font-medium mb-1">Số khách</p>
                          <p className="font-bold theme-text-primary text-base">{b.numAdults} người lớn{b.numChildren ? `, ${b.numChildren} trẻ em` : ""}</p>
                        </div>
                      </div>
                    </div>

                    <div className="mb-4 p-3 rounded-lg border-2 ${paymentInfo.color}">
                      <div className="flex items-start gap-2">
                        <span className="text-xl">{paymentInfo.icon}</span>
                        <div className="min-w-0 flex-1">
                          <p className="text-xs font-semibold mb-1 opacity-80">Thông tin thanh toán</p>
                          <p className="font-bold text-sm leading-tight">{paymentInfo.label}</p>
                          <p className="text-xs mt-0.5 opacity-75">{paymentInfo.sublabel}</p>
                        </div>
                      </div>
                    </div>

                    <div className="mb-4 p-4 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 shadow-lg">
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-semibold text-white opacity-90">Tổng tiền</span>
                        <div className="text-right">
                          <span className="text-2xl font-black text-white block">{formatCurrency(b.totalPrice)}</span>
                          <span className="text-sm font-medium text-white opacity-90">{b.currencyCode || "VND"}</span>
                        </div>
                      </div>
                    </div>

                    {b.providerNotes && (
                      <div className="mb-4 p-3 rounded-lg bg-amber-50 border-2 border-amber-300">
                        <p className="text-xs font-bold text-amber-800 mb-1.5 flex items-center gap-1">📝 Ghi chú / Yêu cầu đặc biệt</p>
                        <p className="text-sm text-amber-900 font-medium leading-relaxed">{b.providerNotes}</p>
                      </div>
                    )}

                    <div className="flex items-center gap-2 flex-wrap pt-3 border-t theme-border">
                      <button 
                        onClick={() => navigate(`/supplier/service/attraction/bookings/${b.bookingId}`)} 
                        className="flex items-center gap-2 px-4 py-2 text-sm font-semibold theme-text-primary hover:theme-text-brand bg-white hover:bg-blue-50 border-2 theme-border hover:border-blue-300 rounded-lg transition-all shadow-sm hover:shadow"
                      >
                        <Eye className="w-4 h-4" />Xem chi tiết
                      </button>
                      {b.providerConfirmed === 0 && (
                        <button 
                          onClick={() => setModalState({ isOpen: true, type: "confirm", bookingId: b.bookingId || null })} 
                          className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-green-600 hover:bg-green-700 rounded-lg transition-all shadow-sm hover:shadow-md"
                        >
                          <CheckCircle className="w-4 h-4" />Xác nhận đặt vé
                        </button>
                      )}
                      {(b.providerConfirmed === 0 || b.providerConfirmed === 1) && (
                        <button 
                          onClick={() => setModalState({ isOpen: true, type: "cancel", bookingId: b.bookingId || null })} 
                          className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-lg transition-all shadow-sm hover:shadow-md"
                        >
                          <XCircle className="w-4 h-4" />Hủy đặt vé
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
          </div>
        )}
      </div>

      {/* SECTION 7: Thống kê thời gian tham quan */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <Clock className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            Thống kê thời gian tham quan
          </h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="p-4 rounded-lg theme-bg-secondary">
            <p className="text-sm theme-text-secondary mb-1">
              Thời gian trung bình
            </p>
            <p className="text-2xl font-bold theme-text-primary">
              {averageVisitDuration > 0 ? `${averageVisitDuration} phút` : "N/A"}
            </p>
          </div>
          <div className="p-4 rounded-lg theme-bg-secondary">
            <p className="text-sm theme-text-secondary mb-1">
              Điểm ngắn nhất
            </p>
            <p className="text-2xl font-bold theme-text-primary">
              {attractions.length > 0
                ? `${Math.min(
                    ...attractions
                      .filter((a) => a.averageVisitMinutes && a.averageVisitMinutes > 0)
                      .map((a) => a.averageVisitMinutes!)
                  )} phút`
                : "N/A"}
            </p>
          </div>
          <div className="p-4 rounded-lg theme-bg-secondary">
            <p className="text-sm theme-text-secondary mb-1">
              Điểm dài nhất
            </p>
            <p className="text-2xl font-bold theme-text-primary">
              {attractions.length > 0
                ? `${Math.max(
                    ...attractions
                      .filter((a) => a.averageVisitMinutes && a.averageVisitMinutes > 0)
                      .map((a) => a.averageVisitMinutes!)
                  )} phút`
                : "N/A"}
            </p>
          </div>
        </div>
      </div>

      {/* SECTION 8: Nhận xét gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            Đánh giá gần đây
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/attraction/recent-reviews")}
          >
            Xem tất cả <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentReviews.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <MessageSquare className="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>Chưa có đánh giá nào</p>
            </div>
          ) : (
            recentReviews.map((r) => {
              const reviewAttraction = attractions.find(
                (a) => a.attractionId === r.attractionId
              );
              return (
                <div
                  key={r.reviewId}
                  className="rounded-lg border theme-border theme-bg-card p-4"
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-medium theme-text-primary">
                      {reviewAttraction?.title || "Điểm tham quan"}
                    </span>
                    <div className="flex items-center gap-1">
                      <span className="text-yellow-500">★</span>
                      <span className="font-medium theme-text-primary">
                        {r.rating.toFixed(1)}
                      </span>
                    </div>
                  </div>
                  {r.title && (
                    <h4 className="font-medium theme-text-primary mb-1">
                      {r.title}
                    </h4>
                  )}
                  <p className="text-sm theme-text-secondary line-clamp-2">
                    {r.content}
                  </p>
                  <p className="text-xs theme-text-tertiary mt-2">
                    {r.createdAt
                      ? new Date(r.createdAt).toLocaleDateString("vi-VN")
                      : ""}
                  </p>
                </div>
              );
            })
          )}
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
            ? "Xác nhận đặt vé"
            : "Hủy đặt vé"
        }
        message={
          modalState.type === "confirm"
            ? "Bạn có chắc chắn muốn xác nhận đặt vé này không?"
            : "Bạn có chắc chắn muốn hủy đặt vé này không?"
        }
        confirmText={
          modalState.type === "confirm" ? "Xác nhận" : "Hủy đặt vé"
        }
        cancelText="Quay lại"
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading === modalState.bookingId}
      />
    </div>
  );
};

export default DashboardAttractionPage;
