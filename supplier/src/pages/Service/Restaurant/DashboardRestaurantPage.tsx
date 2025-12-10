import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  BarChart3,
  Utensils,
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
} from "../../../services/providerService";
import {
  getRestaurantsByProvider,
  getRestaurantReviewsByRestaurant,
  getRestaurantReviewsCountByProvider,
  getRestaurantRatingSummaryByRestaurant,
} from "../../../services/restaurantService";
import type {
  RestaurantDTO,
  RestaurantBookingDTO,
  RestaurantRatingSummaryDTO,
  RestaurantReviewDTO,
  UserDTO,
} from "../../../types";
import api from "../../../services/api";
import {
  QuickAction,
  NotificationItem,
  StatCard,
} from "../../../components/shared";
import { RestaurantCard } from "../../../components/restaurant";
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

// Restaurant Booking Row Component
interface RestaurantBookingRowProps {
  booking: RestaurantBookingDTO;
  restaurantName?: string;
  userName?: string;
  userPhone?: string;
  onView: () => void;
  onConfirm: () => void;
  onCancel: () => void;
}

const RestaurantBookingRow: React.FC<RestaurantBookingRowProps> = ({
  booking,
  restaurantName,
  userName,
  userPhone,
  onView,
  onConfirm,
  onCancel,
}) => {
  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleDateString("vi-VN");
  };

  const formatTime = (timeString?: string) => {
    if (!timeString) return "N/A";
    return timeString.substring(0, 5); // HH:mm:ss -> HH:mm
  };

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-6 hover:shadow-md transition-shadow">
      <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
        {/* Left Section: Restaurant & Customer Info */}
        <div className="md:col-span-5">
          <div className="mb-4">
            <h4 className="font-semibold theme-text-primary text-lg mb-2">
              {restaurantName || "Nhà hàng"}
            </h4>
            <div className="space-y-1.5">
              <div className="flex items-center gap-2 text-sm theme-text-secondary">
                <span className="font-medium">Khách hàng:</span>
                <span>{userName || "N/A"}</span>
              </div>
              <div className="flex items-center gap-2 text-sm theme-text-secondary">
                <span className="font-medium">Điện thoại:</span>
                <span>{userPhone || "N/A"}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Middle Section: Booking Details */}
        <div className="md:col-span-4">
          <div className="space-y-2.5">
            <div className="flex items-center gap-2 text-sm">
              <Calendar className="w-4 h-4 theme-text-secondary" />
              <span className="theme-text-secondary">Ngày đặt:</span>
              <span className="font-medium theme-text-primary">
                {formatDate(booking.reservationDate)}
              </span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <Clock className="w-4 h-4 theme-text-secondary" />
              <span className="theme-text-secondary">Giờ:</span>
              <span className="font-medium theme-text-primary">
                {formatTime(booking.reservationTime)}
              </span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <Users className="w-4 h-4 theme-text-secondary" />
              <span className="theme-text-secondary">Số khách:</span>
              <span className="font-medium theme-text-primary">
                {booking.numAdults} người
              </span>
            </div>
            {booking.specialRequests && (
              <div className="flex items-start gap-2 text-sm pt-1">
                <MessageSquare className="w-4 h-4 theme-text-secondary mt-0.5" />
                <div>
                  <span className="theme-text-secondary">Yêu cầu:</span>
                  <p className="theme-text-primary italic mt-0.5">
                    {booking.specialRequests}
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Section: Price & Actions */}
        <div className="md:col-span-3 flex flex-col justify-between">
          <div className="text-right mb-4">
            <p className="text-sm theme-text-secondary mb-1">Tổng tiền</p>
            <p className="text-2xl font-bold theme-text-primary">
              {(booking.totalPrice || 0).toLocaleString("vi-VN")}
            </p>
            <p className="text-sm theme-text-secondary">{booking.currencyCode || "VND"}</p>
          </div>
          <div className="flex flex-col gap-2">
            <button
              onClick={onView}
              className="w-full px-4 py-2 text-sm theme-bg-secondary theme-text-primary rounded-lg hover:theme-bg-tertiary transition-colors font-medium"
            >
              Xem chi tiết
            </button>
            <div className="flex gap-2">
              <button
                onClick={onConfirm}
                className="flex-1 px-4 py-2 text-sm bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium"
              >
                Xác nhận
              </button>
              <button
                onClick={onCancel}
                className="flex-1 px-4 py-2 text-sm bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium"
              >
                Từ chối
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// Restaurant Rating Summary Card Component
interface RestaurantRatingSummaryCardProps {
  summary: RestaurantRatingSummaryDTO;
  restaurantName: string;
}

const RestaurantRatingSummaryCard: React.FC<RestaurantRatingSummaryCardProps> = ({
  summary,
  restaurantName,
}) => {
  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4">
      <h4 className="font-semibold theme-text-primary mb-3">{restaurantName}</h4>
      <div className="flex items-center gap-3 mb-4">
        <div className="text-3xl font-bold theme-text-primary">
          {summary.avgRating?.toFixed(1) || "0.0"}
        </div>
        <div className="flex-1">
          <div className="text-yellow-500 mb-1">⭐⭐⭐⭐⭐</div>
          <p className="text-sm theme-text-secondary">
            {summary.totalReviews || 0} đánh giá
          </p>
        </div>
      </div>
      <div className="space-y-2">
        {summary.avgQuality !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-24">Chất lượng:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-orange-500"
                style={{ width: `${(summary.avgQuality / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgQuality?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgService !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-24">Dịch vụ:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-blue-500"
                style={{ width: `${(summary.avgService / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgService?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgPrice !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-24">Giá cả:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-green-500"
                style={{ width: `${(summary.avgPrice / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgPrice?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgLocation !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-24">Vị trí:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-purple-500"
                style={{ width: `${(summary.avgLocation / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgLocation?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgAmbience !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-24">Không khí:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-pink-500"
                style={{ width: `${(summary.avgAmbience / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgAmbience?.toFixed(1)}
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

// Restaurant Review Card Component
interface RestaurantReviewCardProps {
  review: RestaurantReviewDTO;
  restaurantName: string;
  readOnly?: boolean;
}

const RestaurantReviewCard: React.FC<RestaurantReviewCardProps> = ({
  review,
  restaurantName,
}) => {
  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h4 className="font-semibold theme-text-primary">{restaurantName}</h4>
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
            : "N/A"}
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
          {review.aspects.quality !== undefined && (
            <span className="px-2 py-1 bg-orange-100 text-orange-700 rounded">
              Chất lượng: {review.aspects.quality}/5
            </span>
          )}
          {review.aspects.service !== undefined && (
            <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded">
              Dịch vụ: {review.aspects.service}/5
            </span>
          )}
          {review.aspects.price !== undefined && (
            <span className="px-2 py-1 bg-green-100 text-green-700 rounded">
              Giá cả: {review.aspects.price}/5
            </span>
          )}
          {review.aspects.location !== undefined && (
            <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded">
              Vị trí: {review.aspects.location}/5
            </span>
          )}
          {review.aspects.ambience !== undefined && (
            <span className="px-2 py-1 bg-pink-100 text-pink-700 rounded">
              Không khí: {review.aspects.ambience}/5
            </span>
          )}
        </div>
      )}
    </div>
  );
};

// Main Dashboard
const DashboardRestaurantPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [providerId, setProviderId] = useState<number | undefined>();
  const [restaurants, setRestaurants] = useState<RestaurantDTO[]>([]);
  const [bookings, setBookings] = useState<RestaurantBookingDTO[]>([]);
  const [ratingSummaries, setRatingSummaries] = useState<
    RestaurantRatingSummaryDTO[]
  >([]);
  const [recentReviews, setRecentReviews] = useState<RestaurantReviewDTO[]>([]);
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
        await api.patch(`/restaurant-bookings/${modalState.bookingId}/status/confirmed`);
      } else {
        await api.patch(`/restaurant-bookings/${modalState.bookingId}/status/cancelled`);
      }

      // Refresh booking data
      const response = await api.get<RestaurantBookingDTO>(
        `/restaurant-bookings/${modalState.bookingId}`
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
          ? "Lỗi khi xác nhận đặt bàn"
          : "Lỗi khi hủy đặt bàn"
      );
    } finally {
      setActionLoading(null);
    }
  };

  // Helper function to format currency compactly
  const formatCompactCurrency = (value: number): string => {
    if (value >= 1000000000) {
      return `${(value / 1000000000).toFixed(1)}T`;
    } else if (value >= 1000000) {
      return `${(value / 1000000).toFixed(1)}Tr`;
    } else if (value >= 1000) {
      return `${(value / 1000).toFixed(1)}N`;
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

        const rs = await getRestaurantsByProvider(providerId);
        console.log("🍽️ Restaurants found:", rs.length, rs);
        setRestaurants(rs);

        // Fetch restaurant bookings
        const bRes = await api.get<RestaurantBookingDTO[]>(`/restaurant-bookings/provider/${providerId}`);
        const bookingsData = bRes.data || [];
        console.log("📅 Restaurant bookings found:", bookingsData.length);
        setBookings(bookingsData);

        // Fetch user info for all bookings
        const uniqueUserIds = Array.from(new Set(bookingsData.map((b) => b.userId)));
        const usersMap = new Map<number, UserDTO>();
        await Promise.all(
          uniqueUserIds.map(async (userId) => {
            try {
              const userResponse = await api.get<UserDTO>(`/users/${userId}`);
              usersMap.set(userId, userResponse.data);
            } catch (e) {
              console.error(`Failed to fetch user ${userId}:`, e);
            }
          })
        );
        setUserCache(usersMap);
        console.log("👥 Users loaded:", usersMap.size);

        // Fetch rating summaries for each restaurant
        console.log(`📊 Fetching rating summaries for ${rs.length} restaurants:`, rs.map(r => ({ id: r.restaurantId, title: r.title })));
        const summaryPromises = rs.map((r) => {
          return r.restaurantId
            ? getRestaurantRatingSummaryByRestaurant(r.restaurantId)
                .then((summary) => {
                  console.log(`✅ Restaurant ${r.restaurantId} (${r.title}) - Summary:`, {
                    summaryRestaurantId: summary.restaurantId,
                    avgRating: summary.avgRating,
                    totalReviews: summary.totalReviews
                  });
                  return summary;
                })
                .catch((e) => {
                  console.error(`❌ Failed to fetch rating for restaurant ${r.restaurantId} (${r.title}):`, e.message);
                  return null;
                })
            : Promise.resolve(null);
        });
        const summaries = (await Promise.all(summaryPromises)).filter(
          (s) => s !== null
        ) as RestaurantRatingSummaryDTO[];
        console.log(`✅ All summaries loaded (${summaries.length}):`, summaries.map(s => ({ id: s.restaurantId, rating: s.avgRating, reviews: s.totalReviews })));
        setRatingSummaries(summaries);

        // Fetch reviews from all restaurants
        const allReviews: RestaurantReviewDTO[] = [];
        for (const restaurant of rs) {
          if (restaurant.restaurantId) {
            try {
              const revs = await getRestaurantReviewsByRestaurant(restaurant.restaurantId);
              allReviews.push(...revs);
            } catch (e) {
              console.error(`Failed to load reviews for restaurant ${restaurant.restaurantId}:`, e);
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
        const reviewsCount = await getRestaurantReviewsCountByProvider(providerId);
        console.log("📊 Total reviews for provider:", reviewsCount, typeof reviewsCount);
        // Handle if backend returns object instead of number
        const count = typeof reviewsCount === 'object' && reviewsCount !== null && 'totalReviews' in reviewsCount
          ? (reviewsCount as { totalReviews: number }).totalReviews
          : reviewsCount;
        setTotalReviews(typeof count === 'number' ? count : 0);
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
          `http://localhost:8080/api/notifications/user/${user.userId}/recent?limit=3&categoryPrefix=service_restaurant`
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

  // Derived selections - get 2 most recent restaurants
  const recentRestaurants = useMemo(() => {
    return [...restaurants]
      .sort((a, b) => {
        const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
        const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
        return dateB - dateA;
      })
      .slice(0, 2);
  }, [restaurants]);

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
          icon={<Utensils className="w-5 h-5 icon-brand" />}
          label="Tổng đặt bàn"
          value={bookings.filter((b) => b.providerConfirmed === 1).length}
          trend={calculateBookingGrowth}
        />
        <StatCard
          icon={<Calendar className="w-5 h-5 icon-brand" />}
          label="Tổng đánh giá"
          value={typeof totalReviews === 'number' ? totalReviews : 0}
        />
        <StatCard
          icon={<Utensils className="w-5 h-5 icon-brand" />}
          label="Nhà hàng"
          value={restaurants.length}
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
            {t("view_all")} <ChevronRight className="w-4 h-4" />
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
            label="Thêm nhà hàng"
            description="Tạo nhà hàng mới"
            onClick={() => navigate("/supplier/service/restaurant/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label="Quản lý đặt bàn"
            description="Xem & xác nhận đặt bàn"
            onClick={() => navigate("/supplier/service/restaurant/bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label="Quản lý đánh giá"
            description="Phản hồi khách hàng"
            onClick={() => navigate("/supplier/service/restaurant/all-reviews")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label="Quản lý nhà hàng"
            description="Xem tất cả nhà hàng"
            onClick={() => navigate("/supplier/service/restaurant/list")}
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
              <Bar dataKey="revenue" fill="#f97316" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* SECTION 5: Danh sách nhà hàng */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            Danh sách nhà hàng
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/restaurant/list")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {restaurants.slice(0, 3).map((r) => (
            <RestaurantCard
              key={r.restaurantId}
              restaurant={r}
              onView={() =>
                navigate(`/supplier/service/restaurant/${r.restaurantId}/view`)
              }
              onEdit={() =>
                navigate(`/supplier/service/restaurant/${r.restaurantId}/edit`)
              }
            />
          ))}
        </div>
      </div>

      {/* SECTION 6: Đặt bàn gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Calendar className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              Đặt bàn gần đây
            </h2>
          </div>
          <button
            className="link-brand text-sm font-medium flex items-center gap-1"
            onClick={() => navigate("/supplier/service/restaurant/bookings")}
          >
            {t("view_all")}
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        {bookings.filter((b) => b.providerConfirmed === 0).length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>Chưa có đặt bàn nào</p>
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
                const restaurant = restaurants.find((r) => r.restaurantId === b.restaurantId);
                const user = userCache.get(b.userId);
                return (
                  <div key={b.bookingId} className="relative">
                    <div className="m-auto">
                      <RestaurantBookingRow
                        booking={b}
                        restaurantName={restaurant?.title}
                        userName={user?.fullName}
                        userPhone={user?.phoneNumber}
                        onView={() =>
                          navigate(
                            `/supplier/service/restaurant/bookings/${b.bookingId}`
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
            Tổng quan đánh giá
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/restaurant/all-reviews")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentRestaurants.length === 0 ? (
            <div className="theme-text-secondary text-sm">
              Chưa có dữ liệu đánh giá
            </div>
          ) : (
            recentRestaurants.map((restaurant) => {
              const summary = ratingSummaries.find(
                (s) => s.restaurantId === restaurant.restaurantId
              );
              console.log(`🔍 Restaurant ${restaurant.restaurantId} (${restaurant.title}):`, summary ? 'Has summary' : 'No summary');
              return summary ? (
                <RestaurantRatingSummaryCard
                  key={restaurant.restaurantId}
                  summary={summary}
                  restaurantName={restaurant.title || "Nhà hàng"}
                />
              ) : (
                <div key={restaurant.restaurantId} className="rounded-xl border theme-border theme-bg-card p-4">
                  <h4 className="font-semibold theme-text-primary mb-3">{restaurant.title || "Nhà hàng"}</h4>
                  <p className="text-sm theme-text-secondary">Chưa có đánh giá nào</p>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* SECTION 8: Nhận xét gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            Nhận xét gần đây
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/restaurant/recent-reviews")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentReviews.length === 0 && (
            <div className="theme-text-secondary text-sm">
              Chưa có đánh giá nào
            </div>
          )}
          {recentReviews.map((r) => {
            const reviewRestaurant = restaurants.find((rest) => rest.restaurantId === r.restaurantId);
            return (
              <RestaurantReviewCard
                key={r.reviewId}
                review={r}
                restaurantName={reviewRestaurant?.title || "Nhà hàng"}
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
            ? "Xác nhận đặt bàn"
            : "Hủy đặt bàn"
        }
        message={
          modalState.type === "confirm"
            ? "Bạn có chắc chắn muốn xác nhận đặt bàn này không?"
            : "Bạn có chắc chắn muốn hủy đặt bàn này không?"
        }
        confirmText={
          modalState.type === "confirm"
            ? "Xác nhận"
            : "Hủy đặt bàn"
        }
        cancelText="Quay lại"
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading === modalState.bookingId}
      />
    </div>
  );
};

export default DashboardRestaurantPage;
