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
} from "recharts";
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
  const { t } = useLanguage();
  
  const formatDate = (dateString?: string) => {
    if (!dateString) return t("tour_na");
    return new Date(dateString).toLocaleDateString("vi-VN");
  };

  const getPaymentLabel = (method?: string) => {
    if (!method || method === "counter") {
      return { 
        label: t("tour_payment_counter"), 
        colorClass: "theme-bg-warning theme-text-warning",
        icon: "💵" 
      };
    }
    return { 
      label: method.toUpperCase() + " - " + t("tour_payment_paid"), 
      colorClass: "theme-bg-success theme-text-success",
      icon: "✅" 
    };
  };

  const paymentInfo = getPaymentLabel(booking.paymentMethod);

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4 hover:shadow-md transition-shadow">
      <div className="flex flex-col gap-3">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h4 className="font-semibold theme-text-primary mb-1">
              {tourName || t("tour")}
            </h4>
            <p className="text-sm theme-text-secondary">
              {userName || t("tour_guest")} • {userPhone || t("tour_na")}
            </p>
          </div>
          <div className="text-right">
            <p className="font-semibold theme-text-primary">
              {booking.totalPrice?.toLocaleString("vi-VN")} {booking.currencyCode || t("tour_unit_vnd")}
            </p>
            <p className="text-sm theme-text-secondary">
              {booking.numAdults || 0} {t("tour_unit_people")}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-4 text-sm theme-text-secondary">
          <span>📅 {formatDate(booking.startDate)} - {formatDate(booking.endDate)}</span>
          <span>👥 {booking.numAdults || 0} {t("tour_unit_people")}</span>
        </div>
        <div className={`flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-semibold ${paymentInfo.colorClass}`}>
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
            className="flex-1 px-3 py-2 text-sm theme-bg-secondary theme-text-primary rounded-lg hover:opacity-80 transition-colors"
          >
            {t("tour_view_detail")}
          </button>
          <button
            onClick={onConfirm}
            className="flex-1 px-3 py-2 text-sm theme-bg-success theme-text-button rounded-lg hover:opacity-90 transition-colors"
          >
            {t("tour_confirm")}
          </button>
          <button
            onClick={onCancel}
            className="flex-1 px-3 py-2 text-sm theme-bg-error theme-text-button rounded-lg hover:opacity-90 transition-colors"
          >
            {t("tour_cancel")}
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
  const { t } = useLanguage();
  
  const getPercentage = (count: number) => {
    if (summary.totalReviews === 0) return 0;
    return ((count / summary.totalReviews) * 100).toFixed(1);
  };

  const getBarColorClass = (rating: number) => {
    if (rating === 5) return "theme-bg-success";
    if (rating === 4) return "theme-bg-info";
    if (rating === 3) return "theme-bg-warning";
    if (rating === 2) return "bg-light-warning dark:bg-dark-warning";
    return "theme-bg-error";
  };

  const ratingDistribution = [
    { stars: 5, count: summary.count5 },
    { stars: 4, count: summary.count4 },
    { stars: 3, count: summary.count3 },
    { stars: 2, count: summary.count2 },
    { stars: 1, count: summary.count1 },
  ];

  const aspects = [
    { label: t("tour_aspect_guide"), value: summary.avgGuideQuality },
    { label: t("tour_aspect_schedule"), value: summary.avgItineraryQuality },
    { label: t("tour_aspect_value"), value: summary.avgValueForMoney },
    { label: t("tour_aspect_organization"), value: summary.avgOrganization },
    { label: t("tour_aspect_safety"), value: summary.avgSafety },
  ];

  return (
    <div className="rounded-xl border theme-border theme-bg-card p-5">
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h4 className="font-semibold text-base mb-1 theme-text-primary">
            {tourName}
          </h4>
          <p className="text-sm theme-text-secondary">
            {summary.totalReviews || 0} {t("tour_rating_reviews")}
          </p>
        </div>

        <div className="flex flex-col items-center justify-center p-3 rounded-lg theme-bg-success">
          <div className="flex items-center gap-1 mb-1">
            <span className="text-light-warning dark:text-dark-warning">★</span>
            <span className="text-2xl font-bold theme-text-success">
              {summary.avgRating?.toFixed(1) || "0.0"}
            </span>
          </div>
          <p className="text-xs theme-text-success">{t("tour_rating_average")}</p>
        </div>
      </div>

      <div className="mb-4">
        <h5 className="text-sm font-semibold mb-3 theme-text-primary">
          {t("tour_rating_distribution")}
        </h5>
        <div className="space-y-2">
          {ratingDistribution.map((item) => (
            <div key={item.stars} className="flex items-center gap-3">
              <div className="flex items-center gap-1 w-16">
                <span className="text-sm font-medium theme-text-primary">
                  {item.stars}
                </span>
                <span className="text-light-warning dark:text-dark-warning text-sm">★</span>
              </div>

              <div className="flex-1 h-2 theme-bg-skeleton rounded-full overflow-hidden">
                <div
                  className={`h-full ${getBarColorClass(item.stars)} transition-all`}
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

      {(summary.avgGuideQuality ||
        summary.avgItineraryQuality ||
        summary.avgValueForMoney ||
        summary.avgOrganization ||
        summary.avgSafety) && (
        <div>
          <h5 className="text-sm font-semibold mb-3 theme-text-primary">
            {t("tour_rating_details")}
          </h5>
          <div className="grid grid-cols-5 gap-3">
            {aspects.map((aspect) => (
              <div key={aspect.label} className="text-center">
                <p className="text-xs mb-1 theme-text-secondary">
                  {aspect.label}
                </p>
                <p className="text-lg font-bold theme-text-primary">
                  {aspect.value ? aspect.value.toFixed(1) : t("tour_na")}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
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
  const { t } = useLanguage();
  
  return (
    <div className="rounded-xl border theme-border theme-bg-card p-4">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h4 className="font-semibold theme-text-primary">{tourName}</h4>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-light-warning dark:text-dark-warning">
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
            : t("tour_na")}
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
            <span className="px-2 py-1 theme-bg-info theme-text-info rounded">
              {t("tour_aspect_guide")}: {review.aspects.guideQuality}/5
            </span>
          )}
          {review.aspects.itineraryQuality !== undefined && (
            <span className="px-2 py-1 theme-bg-success theme-text-success rounded">
              {t("tour_aspect_schedule")}: {review.aspects.itineraryQuality}/5
            </span>
          )}
          {review.aspects.valueForMoney !== undefined && (
            <span className="px-2 py-1 theme-bg-warning theme-text-warning rounded">
              {t("tour_aspect_value")}: {review.aspects.valueForMoney}/5
            </span>
          )}
          {review.aspects.organization !== undefined && (
            <span className="px-2 py-1 bg-light-secondary dark:bg-dark-secondary theme-text-primary rounded">
              {t("tour_aspect_organization")}: {review.aspects.organization}/5
            </span>
          )}
          {review.aspects.safety !== undefined && (
            <span className="px-2 py-1 theme-bg-error theme-text-error rounded">
              {t("tour_aspect_safety")}: {review.aspects.safety}/5
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
          ? t("tour_error_confirm")
          : t("tour_error_cancel")
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

        // Fetch rating summaries for each tour
        const summaryPromises = toursData.map((t) =>
          t.tourId
            ? getTourRatingSummaryByTour(t.tourId).catch((e) => {
                console.error(
                  `Failed to fetch rating for tour ${t.tourId}:`,
                  e
                );
                return null;
              })
            : Promise.resolve(null)
        );
        const summaries = (await Promise.all(summaryPromises)).filter(
          (s) => s !== null
        ) as TourRatingSummaryDTO[];
        setRatingSummaries(summaries);

        // Fetch reviews from all tours
        const allReviews: TourReviewDTO[] = [];
        for (const tour of toursData) {
          if (tour.tourId) {
            try {
              const revs = await getTourReviewsByTour(tour.tourId);
              allReviews.push(...revs);
            } catch (e) {
              console.error(`Failed to load reviews for tour ${tour.tourId}:`, e);
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
        const reviewsCount = await getTourReviewsCountByProvider(providerId);
        console.log("📊 Total reviews for provider:", reviewsCount);
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
          label: `${t("tour_chart_week")} ${week}`,
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
  }, [bookings, revenueFilter, t]);

  // Fetch notifications from API
  useEffect(() => {
    const formatNotificationTime = (dateString: string): string => {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now.getTime() - date.getTime();
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMins / 60);
      const diffDays = Math.floor(diffHours / 24);

      if (diffMins < 1) return t("tour_just_now");
      if (diffMins < 60) return `${diffMins} ${t("tour_minutes_ago")}`;
      if (diffHours < 24) return `${diffHours} ${t("tour_hours_ago")}`;
      return `${diffDays} ${t("tour_days_ago")}`;
    };

    const fetchNotifications = async () => {
      const userStr = localStorage.getItem("user");
      if (!userStr) return;

      const user = JSON.parse(userStr);
      try {
        const response = await fetch(
          `http://localhost:8080/api/notifications/user/${user.userId}/recent?limit=3&categoryPrefix=service_tour`
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
          label={t("tour_total_revenue_title")}
          value={`${formatCompactCurrency(
            bookings
              .filter((b) => b.providerConfirmed === 1)
              .reduce((sum, b) => sum + (b.totalPrice || 0), 0)
          )} ${t("tour_unit_vnd")}`}
          trend={calculateMonthGrowth}
        />
        <StatCard
          icon={<Calendar className="w-5 h-5 icon-brand" />}
          label={t("tour_total_bookings_title")}
          value={bookings.filter((b) => b.providerConfirmed === 1).length}
          trend={calculateBookingGrowth}
        />
        <StatCard
          icon={<MessageSquare className="w-5 h-5 icon-brand" />}
          label={t("tour_total_reviews_title")}
          value={totalReviews}
        />
        <StatCard
          icon={<MapPin className="w-5 h-5 icon-brand" />}
          label={t("tour_total_tours_title")}
          value={tours.length}
        />
      </div>

      {/* SECTION 2: Thông báo */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Bell className="w-5 h-5 icon-brand" />
            <h2 className="text-lg font-semibold theme-text-primary">
              {t("tour_notifications_new")}
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
              <p>{t("tour_notifications_none")}</p>
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
            {t("tour_quick_actions")}
          </h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <QuickAction
            icon={<Plus className="w-6 h-6" />}
            label={t("tour_action_add")}
            description={t("tour_action_add_desc")}
            onClick={() => navigate("/supplier/service/tour/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label={t("tour_action_manage_bookings")}
            description={t("tour_action_manage_bookings_desc")}
            onClick={() => navigate("/supplier/service/tour/bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label={t("tour_action_manage_reviews")}
            description={t("tour_action_manage_reviews_desc")}
            onClick={() => navigate("/supplier/services/tour/reviews/all")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label={t("tour_action_manage_all")}
            description={t("tour_action_manage_all_desc")}
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
              {t("tour_revenue_chart")}
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
              {t("tour_chart_day")}
            </button>
            <button
              onClick={() => setRevenueFilter("week")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "week"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("tour_chart_week")}
            </button>
            <button
              onClick={() => setRevenueFilter("month")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "month"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("tour_chart_month")}
            </button>
            <button
              onClick={() => setRevenueFilter("year")}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                revenueFilter === "year"
                  ? "theme-bg-primary theme-text-button"
                  : "theme-bg-secondary theme-text-secondary hover:opacity-80"
              }`}
            >
              {t("tour_chart_year")}
            </button>
          </div>
        </div>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={revenueChartData}>
              <CartesianGrid strokeDasharray="3 3" className="theme-border" />
              <XAxis dataKey="label" className="theme-text-secondary" />
              <YAxis tickFormatter={(value) => formatCompactCurrency(value)} className="theme-text-secondary" />
              <Tooltip
                formatter={(value: number) => [
                  `${value.toLocaleString("vi-VN")} ${t("tour_unit_vnd")}`,
                  "",
                ]}
                labelStyle={{ fontWeight: "bold" }}
                contentStyle={{ 
                  backgroundColor: "var(--color-bg-card)", 
                  border: "1px solid var(--color-border)",
                  borderRadius: "8px"
                }}
              />
              <Bar dataKey="revenue" fill="var(--color-primary)" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* SECTION 5: Danh sách tours */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("tour_list_title")}
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
              {t("tour_recent_bookings")}
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
            <p>{t("tour_no_bookings")}</p>
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
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("tour_rating_average")}
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/services/tour/reviews/all")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {recentTours.length === 0 ? (
            <div className="theme-text-secondary text-sm">
              {t("tour_no_bookings")}
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
                  tourName={tour.title || t("tour")}
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
            {t("tour_reviews_recent_title")}
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
              {t("tour_reviews_no_reviews_msg")}
            </div>
          )}
          {recentReviews.map((r) => {
            const reviewTour = tours.find((tour) => tour.tourId === r.tourId);
            return (
              <TourReviewCard
                key={r.reviewId}
                review={r}
                tourName={reviewTour?.title || t("tour")}
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
            ? t("tour_booking_confirm_title")
            : t("tour_booking_cancel_title")
        }
        message={
          modalState.type === "confirm"
            ? t("tour_booking_confirm_message")
            : t("tour_booking_cancel_message")
        }
        confirmText={
          modalState.type === "confirm"
            ? t("tour_confirm")
            : t("tour_cancel")
        }
        cancelText={t("tour_back")}
        type={modalState.type === "cancel" ? "danger" : "confirm"}
        loading={actionLoading === modalState.bookingId}
      />
    </div>
  );
};

export default DashboardTourPage;
