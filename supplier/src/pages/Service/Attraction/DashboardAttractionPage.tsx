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
  Star,
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
  getAttractionRatingSummaryByAttraction,
} from "../../../services/attractionService";
import type {
  AttractionDTO,
  AttractionBookingDTO,
  AttractionReviewDTO,
  AttractionRatingSummaryDTO,
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

// Attraction Rating Summary Card Component
interface AttractionRatingSummaryCardProps {
  summary: AttractionRatingSummaryDTO;
  attractionName: string;
}

const AttractionRatingSummaryCard: React.FC<AttractionRatingSummaryCardProps> = ({
  summary,
  attractionName,
}) => {
  const getPercentage = (count: number) => {
    if (summary.totalReviews === 0) return 0;
    return ((count / summary.totalReviews) * 100).toFixed(1);
  };

  const getBarColor = (rating: number) => {
    if (rating === 5) return "bg-green-500";
    if (rating === 4) return "bg-blue-500";
    if (rating === 3) return "bg-yellow-500";
    if (rating === 2) return "bg-orange-500";
    return "bg-red-500";
  };

  const ratingDistribution = [
    { stars: 5, count: summary.count5 },
    { stars: 4, count: summary.count4 },
    { stars: 3, count: summary.count3 },
    { stars: 2, count: summary.count2 },
    { stars: 1, count: summary.count1 },
  ];

  const aspects = [
    { label: "Trải nghiệm", value: summary.avgExperience },
    { label: "Giá trị", value: summary.avgValueForMoney },
    { label: "Tiếp cận", value: summary.avgAccessibility },
    { label: "Tiện nghi", value: summary.avgFacilities },
    { label: "Nhân viên", value: summary.avgStaff },
  ];

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-5">
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h4 className="font-semibold text-base mb-1 theme-text-primary">
            {attractionName}
          </h4>
          <p className="text-sm theme-text-secondary">
            {summary.totalReviews} đánh giá
          </p>
        </div>

        <div className="flex flex-col items-center justify-center p-3 rounded-lg bg-green-100">
          <div className="flex items-center gap-1 mb-1">
            <Star className="w-5 h-5 text-green-600" />
            <span className="text-2xl font-bold text-green-600">
              {summary.avgRating.toFixed(1)}
            </span>
          </div>
          <p className="text-xs text-green-600">Trung bình</p>
        </div>
      </div>

      <div className="mb-4">
        <h5 className="text-sm font-semibold mb-3 theme-text-primary">
          Phân bố đánh giá
        </h5>
        <div className="space-y-2">
          {ratingDistribution.map((item) => (
            <div key={item.stars} className="flex items-center gap-3">
              <div className="flex items-center gap-1 w-16">
                <span className="text-sm font-medium theme-text-primary">
                  {item.stars}
                </span>
                <Star className="w-3.5 h-3.5 icon-primary" />
              </div>

              <div className="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                <div
                  className={`h-full ${getBarColor(item.stars)} transition-all`}
                  style={{ width: `${getPercentage(item.count)}%` }}
                />
              </div>

              <div className="w-16 text-right">
                <span className="text-sm font-medium theme-text-secondary">
                  {item.count} ({getPercentage(item.count)}%)
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {(summary.avgExperience ||
        summary.avgValueForMoney ||
        summary.avgAccessibility ||
        summary.avgFacilities ||
        summary.avgStaff) && (
        <div>
          <h5 className="text-sm font-semibold mb-3 theme-text-primary">
            Điểm chi tiết
          </h5>
          <div className="grid grid-cols-5 gap-3">
            {aspects.map((aspect) => (
              <div key={aspect.label} className="text-center">
                <p className="text-xs mb-1 theme-text-secondary">
                  {aspect.label}
                </p>
                <p className="text-lg font-bold theme-text-primary">
                  {aspect.value ? aspect.value.toFixed(1) : "N/A"}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

// Attraction Review Card Component
interface AttractionReviewCardProps {
  review: AttractionReviewDTO;
  attractionName: string;
  readOnly?: boolean;
}

const AttractionReviewCard: React.FC<AttractionReviewCardProps> = ({
  review,
  attractionName,
}) => {
  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h4 className="font-semibold theme-text-primary">{attractionName}</h4>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-yellow-500">
              {"⭐".repeat(Math.round(review.rating || 0))}
            </span>
            <span className="text-sm theme-text-secondary">
              {review.rating?.toFixed(1)}
            </span>
          </div>
        </div>
        <span className="text-sm theme-text-secondary">
          {review.createdAt
            ? new Date(review.createdAt).toLocaleDateString("vi-VN")
            : t("attraction_na")}
        </span>
      </div>
      {review.title && (
        <h5 className="font-medium theme-text-primary mb-2">{review.title}</h5>
      )}
      <p className="text-sm theme-text-secondary mb-3 line-clamp-3">
        {review.content}
      </p>
      {review.aspects && (
        <div className="flex flex-wrap gap-2 text-xs">
          {review.aspects.experience !== undefined && (
            <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded">
              {t("attraction_aspect_experience")}: {review.aspects.experience}/5
            </span>
          )}
          {review.aspects.valueForMoney !== undefined && (
            <span className="px-2 py-1 bg-green-100 text-green-700 rounded">
              {t("attraction_aspect_value")}: {review.aspects.valueForMoney}/5
            </span>
          )}
          {review.aspects.accessibility !== undefined && (
            <span className="px-2 py-1 bg-orange-100 text-orange-700 rounded">
              {t("attraction_aspect_accessibility")}: {review.aspects.accessibility}/5
            </span>
          )}
          {review.aspects.facilities !== undefined && (
            <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded">
              {t("attraction_aspect_facilities")}: {review.aspects.facilities}/5
            </span>
          )}
          {review.aspects.staff !== undefined && (
            <span className="px-2 py-1 bg-pink-100 text-pink-700 rounded">
              {t("attraction_aspect_staff")}: {review.aspects.staff}/5
            </span>
          )}
        </div>
      )}
    </div>
  );
};

// Main Dashboard
const DashboardAttractionPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [providerId, setProviderId] = useState<number | undefined>();
  const [attractions, setAttractions] = useState<AttractionDTO[]>([]);
  const [bookings, setBookings] = useState<AttractionBookingDTO[]>([]);
  const [ratingSummaries, setRatingSummaries] = useState<
    AttractionRatingSummaryDTO[]
  >([]);
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

        // Fetch rating summaries for all attractions
        const summaryPromises = attrs.map(async (attraction) => {
          try {
            if (!attraction.attractionId) return null;
            return await getAttractionRatingSummaryByAttraction(attraction.attractionId);
          } catch (e) {
            console.error(
              `Failed to load rating summary for attraction ${attraction.attractionId}:`,
              e
            );
            return null;
          }
        });
        const summaries = (await Promise.all(summaryPromises)).filter(
          (s) => s !== null
        ) as AttractionRatingSummaryDTO[];
        setRatingSummaries(summaries);

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

        // Fetch reviews from all attractions
        const allReviews: AttractionReviewDTO[] = [];
        for (const attraction of attrs) {
          if (attraction.attractionId) {
            try {
              const revs = await getAttractionReviewsByAttraction(attraction.attractionId);
              allReviews.push(...revs);
            } catch (e) {
              console.error(`Failed to load reviews for attraction ${attraction.attractionId}:`, e);
            }
          }
        }
        
        // Sort by newest and take 2 most recent
        allReviews.sort((a, b) => {
          const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
          const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
          return dateB - dateA;
        });
        setRecentReviews(allReviews.slice(0, 2));

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
          `http://localhost:8080/api/notifications/user/${user.userId}/recent?limit=3&categoryPrefix=service_attraction`
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

  // Derived selections - get 2 most recent attractions (sorted by creation date)
  const recentAttractions = useMemo(() => {
    return [...attractions]
      .sort((a, b) => {
        const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
        const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
        return dateB - dateA; // Newest first
      })
      .slice(0, 2);
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
          label={t("attraction_dashboard_total_reviews")}
          value={totalReviews}
        />
        <StatCard
          icon={<MapPin className="w-5 h-5 icon-brand" />}
          label={t("attraction_dashboard_attractions")}
          value={attractions.length}
        />
      </div>

      {/* SECTION 2: Thông báo */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Bell className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              {t("attraction_dashboard_new_notifications")}
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
              <p>{t("no_notifications")}</p>
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
            {t("attraction_dashboard_quick_actions")}
          </h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <QuickAction
            icon={<Plus className="w-6 h-6" />}
            label={t("attraction_dashboard_add_attraction")}
            description={t("attraction_dashboard_add_attraction_desc")}
            onClick={() => navigate("/supplier/service/attraction/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label={t("attraction_dashboard_manage_bookings")}
            description={t("attraction_dashboard_manage_bookings_desc")}
            onClick={() => navigate("/supplier/service/attraction/bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label={t("attraction_dashboard_manage_reviews")}
            description={t("attraction_dashboard_manage_reviews_desc")}
            onClick={() => navigate("/supplier/services/attraction/reviews/all")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label={t("attraction_dashboard_manage_attraction")}
            description={t("attraction_dashboard_manage_attraction_desc")}
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
              {t("attraction_dashboard_revenue_chart")}
            </h2>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setRevenueFilter("day")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "day"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("attraction_chart_day")}
            </button>
            <button
              onClick={() => setRevenueFilter("week")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "week"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("attraction_chart_week")}
            </button>
            <button
              onClick={() => setRevenueFilter("month")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "month"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("attraction_chart_month")}
            </button>
            <button
              onClick={() => setRevenueFilter("year")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "year"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("attraction_chart_year")}
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
            {t("attraction_dashboard_attraction_list")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/attraction/list")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {attractions.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <MapPin className="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>{t("attraction_dashboard_no_attractions")}</p>
              <button
                onClick={() => navigate("/supplier/service/attraction/create")}
                className="mt-4 px-4 py-2 theme-bg-primary theme-text-button rounded-lg hover:opacity-90 transition-opacity"
              >
                {t("attraction_dashboard_create_first")}
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
                      {a.location || t("attraction_dashboard_no_location")}
                    </p>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="text-sm font-medium theme-text-brand">
                        {a.price.toLocaleString("vi-VN")} {t("attraction_unit_vnd")}
                      </span>
                      {a.averageVisitMinutes && (
                        <span className="text-xs theme-text-secondary flex items-center gap-1">
                          <Clock className="w-3 h-3" />
                          {a.averageVisitMinutes} {t("attraction_unit_minutes")}
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
                        {t("attraction_dashboard_edit")}
                      </button>
                      <button
                        onClick={() =>
                          navigate(`/supplier/service/attraction/${a.attractionId}/view`)
                        }
                        className="flex-1 px-3 py-1.5 text-sm theme-bg-primary theme-text-button rounded-lg hover:opacity-90 transition-opacity"
                      >
                        {t("attraction_dashboard_view_detail")}
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
              {t("attraction_dashboard_recent_bookings_title")}
            </h2>
          </div>
          <button
            className="link-brand text-sm font-medium flex items-center gap-1"
            onClick={() => navigate("/supplier/service/attraction/bookings")}
          >
            {t("view_all")}
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        {bookings.filter((b) => b.providerConfirmed === 0).length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>{t("attraction_dashboard_no_bookings")}</p>
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
                
                const formatDate = (s?: string) => s ? new Date(s).toLocaleDateString("vi-VN") : t("attraction_na");
                const formatDateTime = (s?: string) => s ? new Date(s).toLocaleString("vi-VN", { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : t("attraction_na");
                const formatCurrency = (v?: number) => new Intl.NumberFormat("vi-VN").format(v || 0);
                
                const getPaymentStatusLabel = (method?: string) => {
                  if (!method || method === "counter") {
                    return { label: t("payment_counter"), sublabel: t("payment_counter_desc"), color: "bg-yellow-100 text-yellow-800 border-yellow-300", icon: "💵" };
                  }
                  return { label: t("payment_online"), sublabel: method.toUpperCase() + " - " + t("payment_completed"), color: "bg-green-100 text-green-800 border-green-300", icon: "✅" };
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
                          {!b.providerSeen && <span className="px-2.5 py-1 text-xs font-bold bg-red-500 text-white rounded-full animate-pulse shadow-sm">{t("attraction_booking_new_badge")}</span>}
                          <span className={`px-3 py-1 text-xs font-semibold rounded-full border-2 ${b.providerConfirmed === 0 ? "bg-orange-100 text-orange-700 border-orange-300" : b.providerConfirmed === 1 ? "bg-blue-100 text-blue-700 border-blue-300" : "bg-red-100 text-red-700 border-red-300"}`}>
                            {b.providerConfirmed === 0 ? t("attraction_status_pending") : b.providerConfirmed === 1 ? t("attraction_status_confirmed") : t("attraction_status_cancelled")}
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
                            <p className="text-xs text-blue-600 font-medium mb-0.5">{t("attraction")}</p>
                            <p className="text-base font-bold text-blue-900">{attraction.title}</p>
                          </div>
                        </div>
                      </div>
                    )}

                    <div className="mb-4 p-3 rounded-lg bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200">
                      <p className="text-xs text-green-600 font-medium mb-2">{t("customer_information")}</p>
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
                          <p className="text-xs theme-text-secondary font-medium mb-1">{t("checkin_date")}</p>
                          <p className="font-bold theme-text-primary text-base truncate">{formatDate(b.startDate || b.visitDate)}</p>
                        </div>
                      </div>
                      <div className="flex items-start gap-2 p-3 rounded-lg theme-bg-secondary">
                        <Users className="w-5 h-5 mt-0.5 text-blue-600 flex-shrink-0" />
                        <div className="min-w-0 flex-1">
                          <p className="text-xs theme-text-secondary font-medium mb-1">{t("guests")}</p>
                          <p className="font-bold theme-text-primary text-base">{b.numAdults} {t("adults_suffix")}{b.numChildren ? `, ${b.numChildren} ${t("children_suffix")}` : ""}</p>
                        </div>
                      </div>
                    </div>

                    <div className="mb-4 p-3 rounded-lg border-2 ${paymentInfo.color}">
                      <div className="flex items-start gap-2">
                        <span className="text-xl">{paymentInfo.icon}</span>
                        <div className="min-w-0 flex-1">
                          <p className="text-xs font-semibold mb-1 opacity-80">{t("payment_summary")}</p>
                          <p className="font-bold text-sm leading-tight">{paymentInfo.label}</p>
                          <p className="text-xs mt-0.5 opacity-75">{paymentInfo.sublabel}</p>
                        </div>
                      </div>
                    </div>

                    <div className="mb-4 p-4 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 shadow-lg">
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-semibold text-white opacity-90">{t("total_amount")}</span>
                        <div className="text-right">
                          <span className="text-2xl font-black text-white block">{formatCurrency(b.totalPrice)}</span>
                          <span className="text-sm font-medium text-white opacity-90">{b.currencyCode || t("attraction_unit_vnd")}</span>
                        </div>
                      </div>
                    </div>

                    {b.providerNotes && (
                      <div className="mb-4 p-3 rounded-lg bg-amber-50 border-2 border-amber-300">
                        <p className="text-xs font-bold text-amber-800 mb-1.5 flex items-center gap-1">📝 {t("provider_notes")}</p>
                        <p className="text-sm text-amber-900 font-medium leading-relaxed">{b.providerNotes}</p>
                      </div>
                    )}

                    <div className="flex items-center gap-2 flex-wrap pt-3 border-t theme-border">
                      <button 
                        onClick={() => navigate(`/supplier/service/attraction/bookings/${b.bookingId}`)} 
                        className="flex items-center gap-2 px-4 py-2 text-sm font-semibold theme-text-primary hover:theme-text-brand bg-white hover:bg-blue-50 border-2 theme-border hover:border-blue-300 rounded-lg transition-all shadow-sm hover:shadow"
                      >
                        <Eye className="w-4 h-4" />{t("view_detail")}
                      </button>
                      {b.providerConfirmed === 0 && (
                        <button 
                          onClick={() => setModalState({ isOpen: true, type: "confirm", bookingId: b.bookingId || null })} 
                          className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-green-600 hover:bg-green-700 rounded-lg transition-all shadow-sm hover:shadow-md"
                        >
                          <CheckCircle className="w-4 h-4" />{t("confirm_booking")}
                        </button>
                      )}
                      {(b.providerConfirmed === 0 || b.providerConfirmed === 1) && (
                        <button 
                          onClick={() => setModalState({ isOpen: true, type: "cancel", bookingId: b.bookingId || null })} 
                          className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-lg transition-all shadow-sm hover:shadow-md"
                        >
                          <XCircle className="w-4 h-4" />{t("cancel_booking")}
                        </button>
                      )}
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
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("attraction_dashboard_rating_overview")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/services/attraction/reviews/all")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentAttractions.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <p>{t("attraction_dashboard_no_rating_data")}</p>
            </div>
          ) : (
            recentAttractions.map((attraction) => {
              const summary = ratingSummaries.find(
                (s) => s.attractionId === attraction.attractionId
              );
              return summary ? (
                <AttractionRatingSummaryCard
                  key={attraction.attractionId}
                  summary={summary}
                  attractionName={attraction.title || t("attraction")}
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
            {t("attraction_dashboard_recent_reviews")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/attraction/recent-reviews")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentReviews.length === 0 ? (
            <div className="col-span-full text-center py-8 theme-text-secondary">
              <MessageSquare className="w-12 h-12 mx-auto mb-3 opacity-50" />
              <p>{t("attraction_dashboard_no_reviews")}</p>
            </div>
          ) : (
            recentReviews.map((r) => {
              const reviewAttraction = attractions.find(
                (a) => a.attractionId === r.attractionId
              );
              return (
                <AttractionReviewCard
                  key={r.reviewId}
                  review={r}
                  attractionName={reviewAttraction?.title || t("attraction")}
                  readOnly={true}
                />
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
            ? t("confirm_booking")
            : t("cancel_booking")
        }
        message={
          modalState.type === "confirm"
            ? t("confirm_booking_message")
            : t("confirm_cancel_booking")
        }
        confirmText={
          modalState.type === "confirm" ? t("confirm_booking") : t("cancel_booking")
        }
        cancelText={t("back")}
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading === modalState.bookingId}
      />
    </div>
  );
};

export default DashboardAttractionPage;
