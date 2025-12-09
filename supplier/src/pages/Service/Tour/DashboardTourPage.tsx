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
} from "lucide-react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from "recharts";
import type { PieLabelRenderProps } from "recharts";
import {
  getProviderByUserId,
  getUserById,
} from "../../../services/providerService";
import {
  getToursByProvider,
  getTourReviewsByTour,
  getTourReviewsCountByProvider,
  getTourBookingsByProvider,
  getTourRatingSummaryByTour,
} from "../../../services/tourService";
import type {
  TourDTO,
  TourBookingDTO,
  TourRatingSummaryDTO,
  TourReviewDTO,
  UserDTO,
} from "../../../types";
import api from "../../../services/api";
import {
  QuickAction,
  NotificationItem,
  StatCard,
} from "../../../components/shared";
import { TourCard } from "../../../components/tour";
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

// PieEntry interface for pie charts
interface PieEntry {
  name: string;
  value: number;
  color: string;
  [key: string]: string | number;
}

// Tour Booking Row Component
interface TourBookingRowProps {
  booking: TourBookingDTO;
  tourName?: string;
  userName?: string;
  userPhone?: string;
  onView: () => void;
  onConfirm: () => void;
  onCancel: () => void;
}

const TourBookingRow: React.FC<TourBookingRowProps> = ({
  booking,
  tourName,
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

  const getPaymentLabel = (method?: string) => {
    if (!method || method === "counter") {
      return { label: "Thanh toán tại quầy", color: "bg-yellow-100 text-yellow-800", icon: "💵" };
    }
    return { label: method.toUpperCase() + " - Đã thanh toán", color: "bg-green-100 text-green-800", icon: "✅" };
  };

  const paymentInfo = getPaymentLabel(booking.paymentMethod);

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4 hover:shadow-md transition-shadow">
      <div className="flex flex-col gap-3">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h4 className="font-semibold theme-text-primary mb-1">
              {tourName || "Tour"}
            </h4>
            <p className="text-sm theme-text-secondary">
              {userName || "Guest"} • {userPhone || "N/A"}
            </p>
          </div>
          <div className="text-right">
            <p className="font-semibold theme-text-primary">
              {booking.totalPrice?.toLocaleString("vi-VN")} {booking.currencyCode || "VND"}
            </p>
            <p className="text-sm theme-text-secondary">
              {booking.numAdults || 0} người
            </p>
          </div>
        </div>
        <div className="flex items-center gap-4 text-sm theme-text-secondary">
          <span>📅 {formatDate(booking.startDate)} - {formatDate(booking.endDate)}</span>
          <span>👥 {booking.numAdults || 0} người</span>
        </div>
        <div className={`flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-semibold ${paymentInfo.color}`}>
          <span>{paymentInfo.icon}</span>
          <span>{paymentInfo.label}</span>
        </div>
        {booking.specialRequests && (
          <p className="text-sm theme-text-secondary italic">
            💬 {booking.specialRequests}
          </p>
        )}
        <div className="flex gap-2 pt-2 border-t theme-border">
          <button
            onClick={onView}
            className="flex-1 px-3 py-2 text-sm theme-bg-secondary theme-text-primary rounded-lg hover:theme-bg-tertiary transition-colors"
          >
            Xem chi tiết
          </button>
          <button
            onClick={onConfirm}
            className="flex-1 px-3 py-2 text-sm bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            Xác nhận
          </button>
          <button
            onClick={onCancel}
            className="flex-1 px-3 py-2 text-sm bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            Từ chối
          </button>
        </div>
      </div>
    </div>
  );
};

// Tour Rating Summary Card Component
interface TourRatingSummaryCardProps {
  summary: TourRatingSummaryDTO;
  tourName: string;
}

const TourRatingSummaryCard: React.FC<TourRatingSummaryCardProps> = ({
  summary,
  tourName,
}) => {
  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4">
      <h4 className="font-semibold theme-text-primary mb-3">{tourName}</h4>
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
        {summary.avgGuideQuality !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-28">Hướng dẫn viên:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-blue-500"
                style={{ width: `${(summary.avgGuideQuality / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgGuideQuality?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgItineraryQuality !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-28">Lịch trình:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-green-500"
                style={{ width: `${(summary.avgItineraryQuality / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgItineraryQuality?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgValueForMoney !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-28">Giá trị:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-orange-500"
                style={{ width: `${(summary.avgValueForMoney / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgValueForMoney?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgOrganization !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-28">Tổ chức:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-purple-500"
                style={{ width: `${(summary.avgOrganization / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgOrganization?.toFixed(1)}
            </span>
          </div>
        )}
        {summary.avgSafety !== undefined && (
          <div className="flex items-center gap-2">
            <span className="text-sm theme-text-secondary w-28">An toàn:</span>
            <div className="flex-1 h-2 theme-bg-secondary rounded-full overflow-hidden">
              <div
                className="h-full bg-red-500"
                style={{ width: `${(summary.avgSafety / 5) * 100}%` }}
              />
            </div>
            <span className="text-sm font-medium theme-text-primary w-8">
              {summary.avgSafety?.toFixed(1)}
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

// Tour Review Card Component
interface TourReviewCardProps {
  review: TourReviewDTO;
  tourName: string;
  readOnly?: boolean;
}

const TourReviewCard: React.FC<TourReviewCardProps> = ({
  review,
  tourName,
}) => {
  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h4 className="font-semibold theme-text-primary">{tourName}</h4>
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
          {review.aspects.guideQuality !== undefined && (
            <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded">
              HDV: {review.aspects.guideQuality}/5
            </span>
          )}
          {review.aspects.itineraryQuality !== undefined && (
            <span className="px-2 py-1 bg-green-100 text-green-700 rounded">
              Lịch trình: {review.aspects.itineraryQuality}/5
            </span>
          )}
          {review.aspects.valueForMoney !== undefined && (
            <span className="px-2 py-1 bg-orange-100 text-orange-700 rounded">
              Giá trị: {review.aspects.valueForMoney}/5
            </span>
          )}
          {review.aspects.organization !== undefined && (
            <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded">
              Tổ chức: {review.aspects.organization}/5
            </span>
          )}
          {review.aspects.safety !== undefined && (
            <span className="px-2 py-1 bg-red-100 text-red-700 rounded">
              An toàn: {review.aspects.safety}/5
            </span>
          )}
        </div>
      )}
    </div>
  );
};

// Main Dashboard
const DashboardTourPage: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [providerId, setProviderId] = useState<number | undefined>();
  const [tours, setTours] = useState<TourDTO[]>([]);
  const [bookings, setBookings] = useState<TourBookingDTO[]>([]);
  const [ratingSummaries, setRatingSummaries] = useState<
    TourRatingSummaryDTO[]
  >([]);
  const [recentReviews, setRecentReviews] = useState<TourReviewDTO[]>([]);
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
        await api.patch(`/tour-bookings/${modalState.bookingId}/confirm`);
      } else {
        await api.patch(`/tour-bookings/${modalState.bookingId}/cancel`);
      }

      // Refresh booking data
      const response = await api.get<TourBookingDTO>(
        `/tour-bookings/${modalState.bookingId}`
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
          ? "Lỗi khi xác nhận đặt tour"
          : "Lỗi khi hủy đặt tour"
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

        const toursData = await getToursByProvider(providerId);
        console.log("🗺️ Tours found:", toursData.length, toursData);
        setTours(toursData);

        // Try to load bookings (API not implemented yet)
        try {
          const bRes = await getTourBookingsByProvider(providerId);
          console.log("📅 Bookings response:", bRes);
          console.log("📊 Total bookings:", bRes?.length || 0);
          setBookings(bRes || []);

          // Fetch user info for all bookings
          const uniqueUserIds = Array.from(
            new Set((bRes || []).map((b) => b.userId))
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
        } catch (bookingError) {
          console.warn("⚠️ Tour booking API chưa implement, bỏ qua:", bookingError);
          setBookings([]);
        }

        // TODO: Uncomment when tour review API is ready
        // Fetch rating summaries for each tour
        // const summaryPromises = toursData.map((t) =>
        //   t.tourId
        //     ? getTourRatingSummaryByTour(t.tourId).catch((e) => {
        //         console.error(
        //           `Failed to fetch rating for tour ${t.tourId}:`,
        //           e
        //         );
        //         return null;
        //       })
        //     : Promise.resolve(null)
        // );
        // const summaries = (await Promise.all(summaryPromises)).filter(
        //   (s) => s !== null
        // ) as TourRatingSummaryDTO[];
        // setRatingSummaries(summaries);
        setRatingSummaries([]);

        // Fetch reviews for the first tour (if available)
        // const firstTourId = toursData[0]?.tourId;
        // if (firstTourId) {
        //   console.log(`📥 Dashboard loading reviews for tour ${firstTourId}`);
        //   const revs = await getTourReviewsByTour(firstTourId);
        //   console.log(`📤 Dashboard received ${revs.length} reviews`);
        //   setRecentReviews(revs.slice(0, 2));
        // } else {
        //   setRecentReviews([]);
        // }
        setRecentReviews([]);

        // Fetch total reviews count for provider
        // const reviewsCount = await getTourReviewsCountByProvider(providerId);
        // console.log("📊 Total reviews for provider:", reviewsCount);
        // setTotalReviews(reviewsCount);
        setTotalReviews(0);
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

  // Difficulty Distribution Data
  const difficultyDistributionData = useMemo((): PieEntry[] => {
    const counts = { easy: 0, moderate: 0, hard: 0 };
    tours.forEach((tour) => {
      if (tour.difficultyLevel === "easy") counts.easy++;
      else if (tour.difficultyLevel === "moderate") counts.moderate++;
      else if (tour.difficultyLevel === "hard") counts.hard++;
    });

    return [
      { name: "Dễ", value: counts.easy, color: "#10b981" },
      { name: "Trung bình", value: counts.moderate, color: "#f59e0b" },
      { name: "Khó", value: counts.hard, color: "#ef4444" },
    ].filter((entry) => entry.value > 0);
  }, [tours]);

  // Tour Type Breakdown Data
  const tourTypeBreakdownData = useMemo((): PieEntry[] => {
    const counts = { group: 0, private: 0, custom: 0 };
    tours.forEach((tour) => {
      if (tour.tourType === "group") counts.group++;
      else if (tour.tourType === "private") counts.private++;
      else if (tour.tourType === "custom") counts.custom++;
    });

    return [
      { name: "Nhóm", value: counts.group, color: "#3b82f6" },
      { name: "Riêng tư", value: counts.private, color: "#8b5cf6" },
      { name: "Tùy chỉnh", value: counts.custom, color: "#ec4899" },
    ].filter((entry) => entry.value > 0);
  }, [tours]);

  // Categories Distribution Data
  const categoriesDistributionData = useMemo(() => {
    const categoryCounts = new Map<string, number>();
    
    tours.forEach((tour) => {
      if (tour.categoriesJson) {
        let categories: string[] = [];
        
        if (typeof tour.categoriesJson === "string") {
          try {
            categories = JSON.parse(tour.categoriesJson);
          } catch {
            categories = [tour.categoriesJson];
          }
        } else if (Array.isArray(tour.categoriesJson)) {
          categories = tour.categoriesJson;
        }
        
        categories.forEach((cat) => {
          categoryCounts.set(cat, (categoryCounts.get(cat) || 0) + 1);
        });
      }
    });

    const categoryLabels: Record<string, string> = {
      culture: "Văn hóa",
      nature: "Thiên nhiên",
      adventure: "Phiêu lưu",
      food: "Ẩm thực",
      beach: "Biển",
      mountain: "Núi",
      city: "Thành phố",
      historical: "Lịch sử",
    };

    return Array.from(categoryCounts.entries()).map(([category, count]) => ({
      category: categoryLabels[category] || category,
      count,
    }));
  }, [tours]);

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

  // Derived selections - get 2 most recent tours
  const recentTours = useMemo(() => {
    return [...tours]
      .sort((a, b) => {
        const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
        const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
        return dateB - dateA;
      })
      .slice(0, 2);
  }, [tours]);

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
          icon={<Calendar className="w-5 h-5 icon-brand" />}
          label="Tổng đặt tour"
          value={bookings.filter((b) => b.providerConfirmed === 1).length}
          trend={calculateBookingGrowth}
        />
        <StatCard
          icon={<MessageSquare className="w-5 h-5 icon-brand" />}
          label="Tổng đánh giá"
          value={totalReviews}
        />
        <StatCard
          icon={<MapPin className="w-5 h-5 icon-brand" />}
          label="Tours"
          value={tours.length}
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
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <QuickAction
            icon={<Plus className="w-6 h-6" />}
            label="Thêm tour"
            description="Tạo tour mới"
            onClick={() => navigate("/supplier/service/tour/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label="Quản lý đặt tour"
            description="Xem & xác nhận đặt tour"
            onClick={() => navigate("/supplier/service/tour/bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label="Quản lý đánh giá"
            description="Phản hồi khách hàng"
            onClick={() => navigate("/supplier/service/tour/all-reviews")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label="Quản lý tours"
            description="Xem tất cả tours"
            onClick={() => navigate("/supplier/service/tour/list")}
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
              <Bar dataKey="revenue" fill="#3b82f6" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* SECTION 5: Danh sách tours */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            Danh sách tours
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/tour/list")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {tours.slice(0, 3).map((tour) => (
            <TourCard
              key={tour.tourId}
              tour={tour}
              onView={() =>
                navigate(`/supplier/service/tour/${tour.tourId}/view`)
              }
              onEdit={() =>
                navigate(`/supplier/service/tour/${tour.tourId}/edit`)
              }
            />
          ))}
        </div>
      </div>

      {/* SECTION 6: Đặt tour gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Calendar className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              Đặt tour gần đây
            </h2>
          </div>
          <button
            className="link-brand text-sm font-medium flex items-center gap-1"
            onClick={() => navigate("/supplier/service/tour/bookings")}
          >
            {t("view_all")}
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        {bookings.filter((b) => b.providerConfirmed === 0).length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>Chưa có đặt tour nào</p>
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
                const tour = tours.find((t) => t.tourId === b.tourId);
                const user = userCache.get(b.userId);
                return (
                  <div key={b.bookingId} className="relative">
                    <div className="m-auto">
                      <TourBookingRow
                        booking={b}
                        tourName={tour?.title}
                        userName={user?.fullName}
                        userPhone={user?.phoneNumber}
                        onView={() =>
                          navigate(
                            `/supplier/service/tour/bookings/${b.bookingId}`
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
            onClick={() => navigate("/supplier/service/tour/all-reviews")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentTours.length === 0 ? (
            <div className="theme-text-secondary text-sm">
              Chưa có dữ liệu đánh giá
            </div>
          ) : (
            recentTours.map((tour) => {
              const summary = ratingSummaries.find(
                (s) => s.tourId === tour.tourId
              );
              return summary ? (
                <TourRatingSummaryCard
                  key={tour.tourId}
                  summary={summary}
                  tourName={tour.title || "Tour"}
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
            Nhận xét gần đây
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/tour/recent-reviews")}
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
            const reviewTour = tours.find((tour) => tour.tourId === r.tourId);
            return (
              <TourReviewCard
                key={r.reviewId}
                review={r}
                tourName={reviewTour?.title || "Tour"}
                readOnly={true}
              />
            );
          })}
        </div>
      </div>

      {/* SECTION 9: Difficulty Distribution (Tour-Specific) */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <BarChart2 className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            Phân bố độ khó
          </h2>
        </div>
        {difficultyDistributionData.length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <p>Chưa có dữ liệu</p>
          </div>
        ) : (
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={difficultyDistributionData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(props: PieLabelRenderProps) => {
                    const { name, percent } = props as PieLabelRenderProps & { name: string; percent: number };
                    return `${name}: ${(percent * 100).toFixed(0)}%`;
                  }}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {difficultyDistributionData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>

      {/* SECTION 10: Tour Type Breakdown (Tour-Specific) */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <BarChart2 className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            Phân loại tour
          </h2>
        </div>
        {tourTypeBreakdownData.length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <p>Chưa có dữ liệu</p>
          </div>
        ) : (
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={tourTypeBreakdownData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(props: PieLabelRenderProps) => {
                    const { name, percent } = props as PieLabelRenderProps & { name: string; percent: number };
                    return `${name}: ${(percent * 100).toFixed(0)}%`;
                  }}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {tourTypeBreakdownData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>

      {/* SECTION 11: Categories Distribution (Tour-Specific) */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <BarChart2 className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            Phân loại danh mục
          </h2>
        </div>
        {categoriesDistributionData.length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <p>Chưa có dữ liệu</p>
          </div>
        ) : (
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={categoriesDistributionData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="category" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="count" fill="#8b5cf6" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
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
            ? "Xác nhận đặt tour"
            : "Hủy đặt tour"
        }
        message={
          modalState.type === "confirm"
            ? "Bạn có chắc chắn muốn xác nhận đặt tour này không?"
            : "Bạn có chắc chắn muốn hủy đặt tour này không?"
        }
        confirmText={
          modalState.type === "confirm"
            ? "Xác nhận"
            : "Hủy đặt tour"
        }
        cancelText="Quay lại"
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading === modalState.bookingId}
      />
    </div>
  );
};

export default DashboardTourPage;
