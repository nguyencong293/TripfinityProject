import React, { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import {
  BarChart3,
  Hotel,
  Calendar,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Star,
  AlertCircle,
  Bell,
  MessageSquare,
  CheckCircle,
  Ticket,
  TrendingDown as PriceDown,
  ChevronRight,
  Eye,
  Edit,
  MoreVertical,
  MapPin,
  Users,
  Plus,
  List,
  Settings,
  BarChart2,
  FileText,
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
import { useTheme } from "../../../hooks/useTheme";
import { useLanguage } from "../../../hooks/useLanguage";
import { useHotelDashboardStatistics } from "../../../hooks/useHotelDashboardStatistics";
import { getProviderByUserId } from "../../../services/providerService";
import { getHotelsByProvider } from "../../../services/hotelService";
import type {
  HotelDTO,
  HotelBookingDTO,
  HotelReviewDTO,
  HotelPriceAlertDTO,
  HotelRatingSummaryDTO,
} from "../../../types";
import api from "../../../services/api";
import ReviewCard from "../../../components/hotel/ReviewCard";
import PriceAlertCard from "../../../components/hotel/PriceAlertCard";
import RatingSummaryCard from "../../../components/hotel/RatingSummaryCard";

interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: string | number;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  badge?: {
    text: string;
    variant: "success" | "warning" | "danger" | "info";
  };
  action?: {
    text: string;
    onClick: () => void;
  };
}

const StatCard: React.FC<StatCardProps> = ({
  icon,
  label,
  value,
  trend,
  badge,
  action,
}) => {
  const { dark } = useTheme();

  const badgeColors = {
    success: dark
      ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
      : "bg-emerald-50 text-emerald-700 border-emerald-200",
    warning: dark
      ? "bg-amber-500/20 text-amber-400 border-amber-500/30"
      : "bg-amber-50 text-amber-700 border-amber-200",
    danger: dark
      ? "bg-red-500/20 text-red-400 border-red-500/30"
      : "bg-red-50 text-red-700 border-red-200",
    info: dark
      ? "bg-blue-500/20 text-blue-400 border-blue-500/30"
      : "bg-blue-50 text-blue-700 border-blue-200",
  };

  return (
    <div
      className={`relative overflow-hidden rounded-xl border p-6 transition-all hover:shadow-lg ${
        dark
          ? "bg-gray-800/50 border-gray-700 hover:border-emerald-500/50"
          : "bg-white border-gray-200 hover:border-emerald-500/50"
      }`}
    >
      <div className="flex items-start justify-between mb-4">
        <div
          className={`p-3 rounded-lg ${
            dark ? "bg-emerald-500/20" : "bg-emerald-50"
          }`}
        >
          {icon}
        </div>
        {badge && (
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium border ${
              badgeColors[badge.variant]
            }`}
          >
            {badge.text}
          </span>
        )}
      </div>

      <div className="space-y-1">
        <p
          className={`text-sm font-medium ${
            dark ? "text-gray-400" : "text-gray-600"
          }`}
        >
          {label}
        </p>
        <p
          className={`text-3xl font-bold ${
            dark ? "text-white" : "text-gray-900"
          }`}
        >
          {value}
        </p>
      </div>

      {trend && (
        <div className="mt-4 flex items-center gap-2">
          {trend.isPositive ? (
            <TrendingUp className="w-4 h-4 text-emerald-500" />
          ) : (
            <TrendingDown className="w-4 h-4 text-red-500" />
          )}
          <span
            className={`text-sm font-medium ${
              trend.isPositive ? "text-emerald-500" : "text-red-500"
            }`}
          >
            {trend.isPositive ? "+" : ""}
            {trend.value.toFixed(1)}%
          </span>
          <span
            className={`text-sm ${dark ? "text-gray-400" : "text-gray-500"}`}
          >
            so với tháng trước
          </span>
        </div>
      )}

      {action && (
        <button
          onClick={action.onClick}
          className={`mt-4 w-full py-2 px-4 rounded-lg text-sm font-medium transition-colors ${
            dark
              ? "bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20"
              : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"
          }`}
        >
          {action.text}
        </button>
      )}
    </div>
  );
};

// Notification types
type NotificationType =
  | "new_booking"
  | "new_review"
  | "payment_success"
  | "e_ticket_created"
  | "price_alert";

interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  time: string;
  isNew: boolean;
}

interface NotificationItemProps {
  notification: Notification;
  onClick: () => void;
}

const NotificationItem: React.FC<NotificationItemProps> = ({
  notification,
  onClick,
}) => {
  const { dark } = useTheme();

  const getIcon = (type: NotificationType) => {
    switch (type) {
      case "new_booking":
        return <Calendar className="w-5 h-5 text-blue-500" />;
      case "new_review":
        return <MessageSquare className="w-5 h-5 text-purple-500" />;
      case "payment_success":
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case "e_ticket_created":
        return <Ticket className="w-5 h-5 text-orange-500" />;
      case "price_alert":
        return <PriceDown className="w-5 h-5 text-red-500" />;
    }
  };

  const getBgColor = (type: NotificationType) => {
    switch (type) {
      case "new_booking":
        return dark ? "bg-blue-500/10" : "bg-blue-50";
      case "new_review":
        return dark ? "bg-purple-500/10" : "bg-purple-50";
      case "payment_success":
        return dark ? "bg-green-500/10" : "bg-green-50";
      case "e_ticket_created":
        return dark ? "bg-orange-500/10" : "bg-orange-50";
      case "price_alert":
        return dark ? "bg-red-500/10" : "bg-red-50";
    }
  };

  return (
    <button
      onClick={onClick}
      className={`flex-shrink-0 w-80 p-4 rounded-xl border transition-all hover:shadow-md ${
        dark
          ? "bg-gray-800/50 border-gray-700 hover:border-emerald-500/50"
          : "bg-white border-gray-200 hover:border-emerald-500/50"
      }`}
    >
      <div className="flex gap-3">
        <div
          className={`flex-shrink-0 p-2 rounded-lg ${getBgColor(
            notification.type
          )}`}
        >
          {getIcon(notification.type)}
        </div>
        <div className="flex-1 min-w-0 text-left">
          <div className="flex items-start justify-between gap-2">
            <p
              className={`text-sm font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              {notification.title}
            </p>
            {notification.isNew && (
              <span className="flex-shrink-0 w-2 h-2 bg-emerald-500 rounded-full" />
            )}
          </div>
          <p
            className={`text-xs mt-1 line-clamp-2 ${
              dark ? "text-gray-400" : "text-gray-600"
            }`}
          >
            {notification.message}
          </p>
          <p
            className={`text-xs mt-2 ${
              dark ? "text-gray-500" : "text-gray-500"
            }`}
          >
            {notification.time}
          </p>
        </div>
      </div>
    </button>
  );
};

// Hotel Card Component
interface HotelCardProps {
  hotel: HotelDTO;
  onView: () => void;
  onEdit: () => void;
}

const HotelCard: React.FC<HotelCardProps> = ({ hotel, onView, onEdit }) => {
  const { dark } = useTheme();

  const getStatusColor = (status: string) => {
    switch (status) {
      case "published":
        return dark
          ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
          : "bg-emerald-50 text-emerald-700 border-emerald-200";
      case "archived":
        return dark
          ? "bg-gray-500/20 text-gray-400 border-gray-500/30"
          : "bg-gray-50 text-gray-700 border-gray-200";
      case "disabled":
        return dark
          ? "bg-red-500/20 text-red-400 border-red-500/30"
          : "bg-red-50 text-red-700 border-red-200";
      default:
        return dark
          ? "bg-blue-500/20 text-blue-400 border-blue-500/30"
          : "bg-blue-50 text-blue-700 border-blue-200";
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case "published":
        return "Đang hoạt động";
      case "archived":
        return "Đã lưu trữ";
      case "disabled":
        return "Vô hiệu hóa";
      default:
        return status;
    }
  };

  return (
    <div
      className={`rounded-xl border overflow-hidden transition-all hover:shadow-lg ${
        dark
          ? "bg-gray-800/50 border-gray-700 hover:border-emerald-500/50"
          : "bg-white border-gray-200 hover:border-emerald-500/50"
      }`}
    >
      {/* Image */}
      <div className="relative h-48 bg-gradient-to-br from-emerald-500/20 to-blue-500/20">
        {hotel.thumbnailUrl ? (
          <img
            src={hotel.thumbnailUrl}
            alt={hotel.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <Hotel className="w-16 h-16 text-gray-400" />
          </div>
        )}
        {/* Status Badge */}
        <div className="absolute top-3 right-3">
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
              hotel.hotelStatus
            )}`}
          >
            {getStatusText(hotel.hotelStatus)}
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        <h3
          className={`text-lg font-semibold mb-2 line-clamp-1 ${
            dark ? "text-white" : "text-gray-900"
          }`}
        >
          {hotel.title}
        </h3>

        {/* Info Grid */}
        <div className="space-y-2 mb-4">
          {hotel.location && (
            <div className="flex items-center gap-2 text-sm">
              <MapPin
                className={`w-4 h-4 ${
                  dark ? "text-gray-400" : "text-gray-500"
                }`}
              />
              <span
                className={`line-clamp-1 ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                {hotel.location}
              </span>
            </div>
          )}

          <div className="flex items-center gap-4 text-sm">
            {hotel.starRating && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                <span
                  className={`font-medium ${
                    dark ? "text-gray-300" : "text-gray-700"
                  }`}
                >
                  {hotel.starRating} sao
                </span>
              </div>
            )}

            {hotel.ratingAverage !== undefined && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 text-orange-500" />
                <span
                  className={`font-medium ${
                    dark ? "text-gray-300" : "text-gray-700"
                  }`}
                >
                  {hotel.ratingAverage.toFixed(1)}
                </span>
              </div>
            )}
          </div>

          {hotel.capacity && (
            <div className="flex items-center gap-2 text-sm">
              <Users
                className={`w-4 h-4 ${
                  dark ? "text-gray-400" : "text-gray-500"
                }`}
              />
              <span className={dark ? "text-gray-400" : "text-gray-600"}>
                Sức chứa: {hotel.capacity} người
              </span>
            </div>
          )}

          <div className="flex items-center gap-2 text-sm">
            <DollarSign
              className={`w-4 h-4 ${dark ? "text-gray-400" : "text-gray-500"}`}
            />
            <span
              className={`font-semibold ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            >
              {hotel.price.toLocaleString("vi-VN")} {hotel.currencyCode}
            </span>
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          <button
            onClick={onView}
            className={`flex-1 py-2 px-3 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-2 ${
              dark
                ? "bg-blue-500/10 text-blue-400 hover:bg-blue-500/20"
                : "bg-blue-50 text-blue-700 hover:bg-blue-100"
            }`}
          >
            <Eye className="w-4 h-4" />
            Xem
          </button>
          <button
            onClick={onEdit}
            className={`flex-1 py-2 px-3 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-2 ${
              dark
                ? "bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20"
                : "bg-emerald-50 text-emerald-700 hover:bg-emerald-100"
            }`}
          >
            <Edit className="w-4 h-4" />
            Sửa
          </button>
          <button
            className={`p-2 rounded-lg text-sm font-medium transition-colors ${
              dark
                ? "bg-gray-700 text-gray-300 hover:bg-gray-600"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            <MoreVertical className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};

// Booking Row Component
const BookingRow = ({ booking }: { booking: HotelBookingDTO }) => {
  const { dark } = useTheme();

  const getStatusColor = (status: string) => {
    const colors = {
      pending:
        "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-500",
      confirmed:
        "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-500",
      completed:
        "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-500",
      cancelled: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-500",
      refunded:
        "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-500",
    };
    return (
      colors[status as keyof typeof colors] ||
      "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-500"
    );
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("vi-VN", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).format(date);
  };

  return (
    <div
      className={`p-4 rounded-lg border transition-colors ${
        !booking.providerSeen
          ? "bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800"
          : "bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h4
              className={`font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              #{booking.bookingId}
            </h4>
            {!booking.providerSeen && (
              <span className="px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900/50 dark:text-blue-400 rounded-full">
                Mới
              </span>
            )}
          </div>
          <p className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}>
            User ID: {booking.userId}
          </p>
        </div>
        <span
          className={`px-3 py-1 text-xs font-medium rounded-full ${getStatusColor(
            booking.bookingStatus || "pending"
          )}`}
        >
          {booking.bookingStatus || "pending"}
        </span>
      </div>
      <div className="grid grid-cols-2 gap-3 text-sm">
        <div>
          <p className={`mb-1 ${dark ? "text-gray-400" : "text-gray-500"}`}>
            Ngày nhận phòng
          </p>
          <p className={`font-medium ${dark ? "text-white" : "text-gray-900"}`}>
            {formatDate(booking.startDate)}
          </p>
        </div>
        <div>
          <p className={`mb-1 ${dark ? "text-gray-400" : "text-gray-500"}`}>
            Ngày trả phòng
          </p>
          <p className={`font-medium ${dark ? "text-white" : "text-gray-900"}`}>
            {formatDate(booking.endDate)}
          </p>
        </div>
        <div>
          <p className={`mb-1 ${dark ? "text-gray-400" : "text-gray-500"}`}>
            Số khách
          </p>
          <p className={`font-medium ${dark ? "text-white" : "text-gray-900"}`}>
            {booking.numAdults} người lớn
            {booking.numChildren ? `, ${booking.numChildren} trẻ em` : ""}
          </p>
        </div>
        <div>
          <p className={`mb-1 ${dark ? "text-gray-400" : "text-gray-500"}`}>
            Tổng tiền
          </p>
          <p
            className={`font-semibold ${
              dark ? "text-blue-400" : "text-blue-600"
            }`}
          >
            {booking.totalPrice?.toLocaleString("vi-VN") || "0"}{" "}
            {booking.currencyCode || "VND"}
          </p>
        </div>
      </div>
      {booking.providerNotes && (
        <div
          className={`mt-3 p-2 rounded ${
            dark ? "bg-gray-700/50" : "bg-gray-50"
          }`}
        >
          <p className={`text-xs ${dark ? "text-gray-400" : "text-gray-600"}`}>
            Ghi chú: {booking.providerNotes}
          </p>
        </div>
      )}
    </div>
  );
};

// Revenue Chart Data Type
interface RevenueChartData {
  day: number;
  revenue: number;
  label: string;
}

// Custom Tooltip Props
interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{
    value: number;
    payload: RevenueChartData;
  }>;
}

// ==================== SECTION 6: QUICK ACTION COMPONENT ====================
interface QuickActionProps {
  icon: React.ReactNode;
  label: string;
  description: string;
  color: "emerald" | "blue" | "purple" | "orange" | "pink" | "indigo";
  onClick: () => void;
}

const QuickAction: React.FC<QuickActionProps> = ({
  icon,
  label,
  description,
  color,
  onClick,
}) => {
  const { dark } = useTheme();

  const colorClasses = {
    emerald: {
      bg: dark ? "bg-emerald-500/10" : "bg-emerald-50",
      icon: "text-emerald-500",
      hover: dark
        ? "hover:bg-emerald-500/20 hover:border-emerald-500/50"
        : "hover:bg-emerald-100 hover:border-emerald-300",
    },
    blue: {
      bg: dark ? "bg-blue-500/10" : "bg-blue-50",
      icon: "text-blue-500",
      hover: dark
        ? "hover:bg-blue-500/20 hover:border-blue-500/50"
        : "hover:bg-blue-100 hover:border-blue-300",
    },
    purple: {
      bg: dark ? "bg-purple-500/10" : "bg-purple-50",
      icon: "text-purple-500",
      hover: dark
        ? "hover:bg-purple-500/20 hover:border-purple-500/50"
        : "hover:bg-purple-100 hover:border-purple-300",
    },
    orange: {
      bg: dark ? "bg-orange-500/10" : "bg-orange-50",
      icon: "text-orange-500",
      hover: dark
        ? "hover:bg-orange-500/20 hover:border-orange-500/50"
        : "hover:bg-orange-100 hover:border-orange-300",
    },
    pink: {
      bg: dark ? "bg-pink-500/10" : "bg-pink-50",
      icon: "text-pink-500",
      hover: dark
        ? "hover:bg-pink-500/20 hover:border-pink-500/50"
        : "hover:bg-pink-100 hover:border-pink-300",
    },
    indigo: {
      bg: dark ? "bg-indigo-500/10" : "bg-indigo-50",
      icon: "text-indigo-500",
      hover: dark
        ? "hover:bg-indigo-500/20 hover:border-indigo-500/50"
        : "hover:bg-indigo-100 hover:border-indigo-300",
    },
  };

  const colors = colorClasses[color];

  return (
    <button
      onClick={onClick}
      className={`group relative rounded-xl border p-6 transition-all ${
        dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
      } ${colors.hover}`}
    >
      <div className="flex items-start gap-4">
        <div className={`p-3 rounded-lg ${colors.bg}`}>
          <div className={colors.icon}>{icon}</div>
        </div>
        <div className="flex-1 text-left">
          <h3
            className={`text-base font-semibold mb-1 ${
              dark ? "text-white" : "text-gray-900"
            }`}
          >
            {label}
          </h3>
          <p className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}>
            {description}
          </p>
        </div>
        <ChevronRight
          className={`w-5 h-5 transition-transform group-hover:translate-x-1 ${
            dark ? "text-gray-500" : "text-gray-400"
          }`}
        />
      </div>
    </button>
  );
};

const DashboardHotelPage: React.FC = () => {
  const { dark } = useTheme();
  const { t } = useLanguage();
  const navigate = useNavigate();

  const [providerId, setProviderId] = useState<number | undefined>(undefined);
  const [loadingProvider, setLoadingProvider] = useState(true);
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [loadingHotels, setLoadingHotels] = useState(false);
  const [hotelsError, setHotelsError] = useState<string | null>(null);
  const [bookings, setBookings] = useState<HotelBookingDTO[]>([]);
  const [loadingBookings, setLoadingBookings] = useState(false);
  const [bookingsError, setBookingsError] = useState<string | null>(null);
  const [reviews, setReviews] = useState<HotelReviewDTO[]>([]);
  const [loadingReviews, setLoadingReviews] = useState(false);
  const [reviewsError, setReviewsError] = useState<string | null>(null);
  const [priceAlerts, setPriceAlerts] = useState<HotelPriceAlertDTO[]>([]);
  const [loadingAlerts, setLoadingAlerts] = useState(false);
  const [alertsError, setAlertsError] = useState<string | null>(null);
  const [ratingSummaries, setRatingSummaries] = useState<
    HotelRatingSummaryDTO[]
  >([]);
  const [loadingSummaries, setLoadingSummaries] = useState(false);
  const [summariesError, setSummariesError] = useState<string | null>(null);

  // Get provider ID from localStorage user
  useEffect(() => {
    const fetchProviderId = async () => {
      try {
        const userStr = localStorage.getItem("user");
        if (!userStr) {
          setLoadingProvider(false);
          return;
        }

        const user = JSON.parse(userStr);
        const provider = await getProviderByUserId(user.userId);

        if (provider?.providerId) {
          setProviderId(provider.providerId);
        }
      } catch (error) {
        console.error("Error fetching provider:", error);
      } finally {
        setLoadingProvider(false);
      }
    };

    fetchProviderId();
  }, []);

  // Fetch hotels
  useEffect(() => {
    const fetchHotels = async () => {
      if (!providerId) return;

      setLoadingHotels(true);
      setHotelsError(null);

      try {
        const data = await getHotelsByProvider(providerId);
        setHotels(data);
      } catch (error) {
        console.error("Error fetching hotels:", error);
        setHotelsError("Không thể tải danh sách khách sạn");
      } finally {
        setLoadingHotels(false);
      }
    };

    fetchHotels();
  }, [providerId]);

  // Fetch bookings
  useEffect(() => {
    const fetchBookings = async () => {
      if (!providerId) return;

      setLoadingBookings(true);
      setBookingsError(null);

      try {
        const response = await api.get<HotelBookingDTO[]>(
          `/hotel-bookings/provider/${providerId}`
        );
        // Sort by createdAt descending (newest first)
        const sortedBookings = response.data.sort((a, b) => {
          const dateA = new Date(a.createdAt || 0).getTime();
          const dateB = new Date(b.createdAt || 0).getTime();
          return dateB - dateA;
        });
        setBookings(sortedBookings);
      } catch (error) {
        console.error("Error fetching bookings:", error);
        setBookingsError("Không thể tải danh sách đặt phòng");
      } finally {
        setLoadingBookings(false);
      }
    };

    fetchBookings();
  }, [providerId]);

  useEffect(() => {
    const fetchReviews = async () => {
      if (!providerId || hotels.length === 0) return;

      setLoadingReviews(true);
      setReviewsError(null);

      try {
        // Fetch reviews for all hotels of this provider
        const allReviews: HotelReviewDTO[] = [];

        for (const hotel of hotels) {
          try {
            const response = await api.get<HotelReviewDTO[]>(
              `/hotel-reviews/hotel/${hotel.hotelId}`
            );
            allReviews.push(...response.data);
          } catch (hotelError: unknown) {
            // Bỏ qua lỗi 404 (endpoint chưa có hoặc hotel chưa có review)
            if (
              hotelError &&
              typeof hotelError === "object" &&
              "response" in hotelError
            ) {
              const axiosError = hotelError as {
                response?: { status?: number };
              };
              if (axiosError.response?.status === 404) {
                console.log(
                  `Hotel ${hotel.hotelId} chưa có review hoặc endpoint chưa tồn tại`
                );
                continue;
              }
            }
            throw hotelError; // Re-throw nếu là lỗi khác
          }
        }

        // Sort by createdAt descending (newest first)
        const sortedReviews = allReviews.sort((a, b) => {
          const dateA = new Date(a.createdAt || 0).getTime();
          const dateB = new Date(b.createdAt || 0).getTime();
          return dateB - dateA;
        });

        setReviews(sortedReviews);
      } catch (error) {
        console.error("Error fetching reviews:", error);
        // Chỉ set error nếu là lỗi thật sự (không phải 404)
        if (error && typeof error === "object" && "response" in error) {
          const axiosError = error as { response?: { status?: number } };
          if (axiosError.response?.status !== 404) {
            setReviewsError("Không thể tải danh sách đánh giá");
          }
        } else {
          setReviewsError("Không thể tải danh sách đánh giá");
        }
      } finally {
        setLoadingReviews(false);
      }
    };

    fetchReviews();
  }, [providerId, hotels]);

  // Fetch price alerts
  useEffect(() => {
    const fetchPriceAlerts = async () => {
      if (!providerId) return;

      setLoadingAlerts(true);
      setAlertsError(null);

      try {
        const response = await api.get<HotelPriceAlertDTO[]>(
          `/hotel-price-alerts/provider/${providerId}`
        );

        // Sort by createdAt descending (newest first)
        const sortedAlerts = response.data.sort((a, b) => {
          const dateA = new Date(a.createdAt || 0).getTime();
          const dateB = new Date(b.createdAt || 0).getTime();
          return dateB - dateA;
        });

        setPriceAlerts(sortedAlerts);
      } catch (error) {
        console.error("Error fetching price alerts:", error);
        // Xử lý 404 như Section 7
        if (error && typeof error === "object" && "response" in error) {
          const axiosError = error as { response?: { status?: number } };
          if (axiosError.response?.status !== 404) {
            setAlertsError("Không thể tải danh sách cảnh báo giá");
          }
        } else {
          setAlertsError("Không thể tải danh sách cảnh báo giá");
        }
      } finally {
        setLoadingAlerts(false);
      }
    };

    fetchPriceAlerts();
  }, [providerId]);

  // Fetch rating summaries
  useEffect(() => {
    const fetchRatingSummaries = async () => {
      if (!providerId) return;

      setLoadingSummaries(true);
      setSummariesError(null);

      try {
        const response = await api.get<HotelRatingSummaryDTO[]>(
          `/hotel-rating-summaries/provider/${providerId}`
        );

        // Sort by totalReviews descending (most reviewed first)
        const sortedSummaries = response.data.sort((a, b) => {
          return b.totalReviews - a.totalReviews;
        });

        setRatingSummaries(sortedSummaries);
      } catch (error) {
        console.error("Error fetching rating summaries:", error);
        // Xử lý 404 như các section khác
        if (error && typeof error === "object" && "response" in error) {
          const axiosError = error as { response?: { status?: number } };
          if (axiosError.response?.status !== 404) {
            setSummariesError("Không thể tải thống kê đánh giá");
          }
        } else {
          setSummariesError("Không thể tải thống kê đánh giá");
        }
      } finally {
        setLoadingSummaries(false);
      }
    };

    fetchRatingSummaries();
  }, [providerId]);

  const {
    statistics,
    loading: statsLoading,
    error: statsError,
    refetch,
  } = useHotelDashboardStatistics(providerId);

  const isLoading = loadingProvider || statsLoading;

  // Mock notifications - in real app, fetch from API
  const notifications: Notification[] = [
    {
      id: "1",
      type: "new_booking",
      title: "Đặt phòng mới",
      message: "Bạn có 3 đặt phòng mới tại Seaside Resort cần xác nhận",
      time: "5 phút trước",
      isNew: true,
    },
    {
      id: "2",
      type: "payment_success",
      title: "Thanh toán thành công",
      message:
        "Khách hàng Nguyễn Văn A đã thanh toán 2.500.000đ cho booking #12345",
      time: "15 phút trước",
      isNew: true,
    },
    {
      id: "3",
      type: "new_review",
      title: "Đánh giá mới",
      message: "Mountain View Hotel nhận được đánh giá 5 sao từ khách hàng",
      time: "30 phút trước",
      isNew: false,
    },
    {
      id: "4",
      type: "e_ticket_created",
      title: "E-Ticket đã được tạo",
      message: "E-Ticket cho booking #12346 đã được tạo và gửi cho khách",
      time: "1 giờ trước",
      isNew: false,
    },
    {
      id: "5",
      type: "price_alert",
      title: "Cảnh báo giá",
      message: "Giá phòng của City Center Hotel thấp hơn 15% so với đối thủ",
      time: "2 giờ trước",
      isNew: false,
    },
  ];

  // ==================== SECTION 5: REVENUE CHART DATA ====================
  const revenueChartData = useMemo((): RevenueChartData[] => {
    if (bookings.length === 0) return [];

    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();
    const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

    // Initialize data for all days in current month
    const dailyRevenue: { [key: number]: number } = {};
    for (let day = 1; day <= daysInMonth; day++) {
      dailyRevenue[day] = 0;
    }

    // Calculate revenue by day
    bookings.forEach((booking) => {
      if (
        booking.bookingDate &&
        (booking.bookingStatus === "confirmed" ||
          booking.bookingStatus === "completed")
      ) {
        const bookingDate = new Date(booking.bookingDate);
        if (
          bookingDate.getMonth() === currentMonth &&
          bookingDate.getFullYear() === currentYear
        ) {
          const day = bookingDate.getDate();
          dailyRevenue[day] += Number(booking.totalPrice) || 0;
        }
      }
    });

    // Convert to chart data format
    return Array.from({ length: daysInMonth }, (_, i) => ({
      day: i + 1,
      revenue: dailyRevenue[i + 1],
      label: `${i + 1}`,
    }));
  }, [bookings]);

  // Custom tooltip for revenue chart
  const CustomTooltip: React.FC<CustomTooltipProps> = ({ active, payload }) => {
    if (active && payload && payload.length) {
      return (
        <div
          className={`p-3 rounded-lg border shadow-lg ${
            dark ? "bg-gray-800 border-gray-700" : "bg-white border-gray-200"
          }`}
        >
          <p
            className={`text-sm font-medium ${
              dark ? "text-gray-300" : "text-gray-700"
            }`}
          >
            Ngày {payload[0].payload.day}
          </p>
          <p className="text-sm font-semibold text-emerald-500 mt-1">
            {Number(payload[0].value).toLocaleString("vi-VN")} đ
          </p>
        </div>
      );
    }
    return null;
  };

  useEffect(() => {
    document.title = `${t("hotel_dashboard")} - Tripfinity`;
  }, [t]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-500 mx-auto mb-4"></div>
          <p className={dark ? "text-gray-400" : "text-gray-600"}>
            Đang tải dữ liệu...
          </p>
        </div>
      </div>
    );
  }

  if (statsError) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <AlertCircle className="w-12 h-12 text-red-500 mx-auto mb-4" />
          <p className="text-red-500 mb-4">{statsError}</p>
          <button
            onClick={refetch}
            className="px-4 py-2 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors"
          >
            Thử lại
          </button>
        </div>
      </div>
    );
  }

  if (!providerId) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <AlertCircle className="w-12 h-12 text-amber-500 mx-auto mb-4" />
          <p className={dark ? "text-gray-400" : "text-gray-600"}>
            Không tìm thấy thông tin nhà cung cấp
          </p>
        </div>
      </div>
    );
  }

  const newNotificationsCount = notifications.filter((n) => n.isNew).length;

  // Get top 6 hotels for dashboard
  const displayedHotels = hotels.slice(0, 6);

  // Get recent 5 bookings
  const recentBookings = bookings.slice(0, 5);
  const unseenBookingsCount = bookings.filter((b) => !b.providerSeen).length;

  return (
    <div className="space-y-6 p-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1
            className={`text-2xl font-bold flex items-center gap-2 ${
              dark ? "text-white" : "text-gray-900"
            }`}
          >
            <BarChart3 className="w-7 h-7 text-emerald-500" />
            Dashboard Quản lý Khách sạn
          </h1>
          <p className={`mt-1 ${dark ? "text-gray-400" : "text-gray-600"}`}>
            Tổng quan về hoạt động kinh doanh khách sạn
          </p>
        </div>
      </div>

      {/* SECTION 1: THỐNG KÊ TỔNG QUAN */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          icon={<Hotel className="w-6 h-6 text-emerald-500" />}
          label="Tổng số khách sạn"
          value={statistics?.totalHotels || 0}
          trend={
            statistics?.totalHotelsChange !== undefined
              ? {
                  value: statistics.totalHotelsChange,
                  isPositive: statistics.totalHotelsChange >= 0,
                }
              : undefined
          }
          action={{
            text: "Xem danh sách",
            onClick: () => console.log("View hotels list"),
          }}
        />

        <StatCard
          icon={<Calendar className="w-6 h-6 text-blue-500" />}
          label="Tổng đặt phòng"
          value={statistics?.totalBookings || 0}
          badge={
            statistics?.unseenBookings
              ? {
                  text: `${statistics.unseenBookings} mới`,
                  variant: "warning",
                }
              : undefined
          }
          action={{
            text: "Xem đặt phòng",
            onClick: () => console.log("View bookings"),
          }}
        />

        <StatCard
          icon={<DollarSign className="w-6 h-6 text-green-500" />}
          label="Doanh thu tháng này"
          value={
            statistics?.monthlyRevenue
              ? `${statistics.monthlyRevenue.toLocaleString("vi-VN")}đ`
              : "0đ"
          }
          trend={
            statistics?.revenueChange !== undefined
              ? {
                  value: statistics.revenueChange,
                  isPositive: statistics.revenueChange >= 0,
                }
              : undefined
          }
          action={{
            text: "Xem chi tiết",
            onClick: () => console.log("View revenue details"),
          }}
        />

        <StatCard
          icon={<Star className="w-6 h-6 text-yellow-500" />}
          label="Đánh giá trung bình"
          value={
            statistics?.averageRating
              ? statistics.averageRating.toFixed(1)
              : "N/A"
          }
          badge={
            statistics?.totalReviews
              ? {
                  text: `${statistics.totalReviews} đánh giá`,
                  variant: "info",
                }
              : undefined
          }
          action={{
            text: "Xem đánh giá",
            onClick: () => console.log("View ratings"),
          }}
        />
      </div>

      {/* SECTION 2: THÔNG BÁO MỚI (Notification Bar) */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Bell
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Thông báo mới
            </h2>
            {newNotificationsCount > 0 && (
              <span className="px-2 py-0.5 text-xs font-medium bg-emerald-500 text-white rounded-full">
                {newNotificationsCount}
              </span>
            )}
          </div>
          <button
            className={`flex items-center gap-1 text-sm font-medium transition-colors ${
              dark
                ? "text-emerald-400 hover:text-emerald-300"
                : "text-emerald-600 hover:text-emerald-700"
            }`}
            onClick={() => console.log("View all notifications")}
          >
            Xem tất cả
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-thin scrollbar-thumb-emerald-500 scrollbar-track-gray-200 dark:scrollbar-track-gray-800">
          {notifications.map((notification) => (
            <NotificationItem
              key={notification.id}
              notification={notification}
              onClick={() =>
                console.log("Clicked notification:", notification.id)
              }
            />
          ))}
        </div>
      </div>

      {/* SECTION 6: HÀNH ĐỘNG NHANH (QUICK ACTIONS) */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center gap-2 mb-6">
          <Zap
            className={`w-5 h-5 ${
              dark ? "text-emerald-400" : "text-emerald-600"
            }`}
          />
          <h2
            className={`text-lg font-semibold ${
              dark ? "text-white" : "text-gray-900"
            }`}
          >
            Hành động nhanh
          </h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <QuickAction
            icon={<Plus className="w-6 h-6" />}
            label="Thêm khách sạn mới"
            description="Tạo khách sạn mới và đăng tải lên hệ thống"
            color="emerald"
            onClick={() => navigate("/supplier/service/hotel/create")}
          />

          <QuickAction
            icon={<List className="w-6 h-6" />}
            label="Quản lý đặt phòng"
            description="Xem và xử lý các đặt phòng hiện tại"
            color="blue"
            onClick={() => console.log("Navigate to bookings management")}
          />

          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label="Quản lý đánh giá"
            description="Xem và phản hồi đánh giá từ khách hàng"
            color="purple"
            onClick={() => console.log("Navigate to reviews management")}
          />

          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label="Báo cáo doanh thu"
            description="Xem chi tiết báo cáo doanh thu và thống kê"
            color="orange"
            onClick={() => console.log("Navigate to revenue reports")}
          />

          <QuickAction
            icon={<Settings className="w-6 h-6" />}
            label="Cài đặt giá"
            description="Quản lý giá phòng và các tùy chọn giá"
            color="pink"
            onClick={() => console.log("Navigate to price settings")}
          />

          <QuickAction
            icon={<FileText className="w-6 h-6" />}
            label="Quản lý hợp đồng"
            description="Xem và quản lý các hợp đồng với khách hàng"
            color="indigo"
            onClick={() => console.log("Navigate to contracts")}
          />
        </div>
      </div>

      {/* SECTION 3: DANH SÁCH KHÁCH SẠN */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Hotel
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Danh sách khách sạn
            </h2>
            <span
              className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}
            >
              ({hotels.length} khách sạn)
            </span>
          </div>
          <button
            className={`flex items-center gap-1 text-sm font-medium transition-colors ${
              dark
                ? "text-emerald-400 hover:text-emerald-300"
                : "text-emerald-600 hover:text-emerald-700"
            }`}
            onClick={() => console.log("View all hotels")}
          >
            Xem tất cả
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {loadingHotels ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đang tải khách sạn...
              </p>
            </div>
          </div>
        ) : hotelsError ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <AlertCircle className="w-8 h-8 text-red-500 mx-auto mb-2" />
              <p className="text-sm text-red-500">{hotelsError}</p>
            </div>
          </div>
        ) : displayedHotels.length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <Hotel
                className={`w-12 h-12 mx-auto mb-3 ${
                  dark ? "text-gray-600" : "text-gray-400"
                }`}
              />
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Chưa có khách sạn nào
              </p>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {displayedHotels.slice(0, 6).map((hotel) => (
              <HotelCard
                key={hotel.hotelId}
                hotel={hotel}
                onView={() =>
                  navigate(`/supplier/service/hotel/${hotel.hotelId}/view`)
                }
                onEdit={() =>
                  navigate(`/supplier/service/hotel/${hotel.hotelId}/edit`)
                }
              />
            ))}
          </div>
        )}
      </div>

      {/* SECTION 4: ĐẶT PHÒNG GẦN ĐÂY */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Calendar
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Đặt phòng gần đây
            </h2>
            {unseenBookingsCount > 0 && (
              <span className="px-2 py-0.5 text-xs font-medium bg-emerald-500 text-white rounded-full">
                {unseenBookingsCount} mới
              </span>
            )}
          </div>
          <button
            className={`flex items-center gap-1 text-sm font-medium transition-colors ${
              dark
                ? "text-emerald-400 hover:text-emerald-300"
                : "text-emerald-600 hover:text-emerald-700"
            }`}
            onClick={() => console.log("View all bookings")}
          >
            Xem tất cả
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {loadingBookings ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đang tải đặt phòng...
              </p>
            </div>
          </div>
        ) : bookingsError ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <AlertCircle className="w-8 h-8 text-red-500 mx-auto mb-2" />
              <p className="text-sm text-red-500">{bookingsError}</p>
            </div>
          </div>
        ) : recentBookings.length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <Calendar
                className={`w-12 h-12 mx-auto mb-3 ${
                  dark ? "text-gray-600" : "text-gray-400"
                }`}
              />
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Chưa có đặt phòng nào
              </p>
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            {recentBookings.map((booking) => (
              <BookingRow key={booking.bookingId} booking={booking} />
            ))}
          </div>
        )}
      </div>

      {/* SECTION 5: BIỂU ĐỒ DOANH THU */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-2">
            <BarChart3
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Doanh thu tháng này
            </h2>
          </div>
          <div className="flex items-center gap-2">
            <span
              className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}
            >
              Tổng:{" "}
              <span
                className={`font-semibold ${
                  dark ? "text-emerald-400" : "text-emerald-600"
                }`}
              >
                {(statistics?.monthlyRevenue || 0).toLocaleString("vi-VN")} đ
              </span>
            </span>
          </div>
        </div>

        {loadingBookings ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đang tải dữ liệu doanh thu...
              </p>
            </div>
          </div>
        ) : bookingsError ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <AlertCircle className="w-8 h-8 text-red-500 mx-auto mb-2" />
              <p className="text-sm text-red-500">{bookingsError}</p>
            </div>
          </div>
        ) : revenueChartData.length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <BarChart3
                className={`w-12 h-12 mx-auto mb-3 ${
                  dark ? "text-gray-600" : "text-gray-400"
                }`}
              />
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Chưa có dữ liệu doanh thu
              </p>
            </div>
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={revenueChartData}>
              <CartesianGrid
                strokeDasharray="3 3"
                stroke={dark ? "#374151" : "#e5e7eb"}
              />
              <XAxis
                dataKey="label"
                stroke={dark ? "#9ca3af" : "#6b7280"}
                style={{ fontSize: "12px" }}
              />
              <YAxis
                stroke={dark ? "#9ca3af" : "#6b7280"}
                style={{ fontSize: "12px" }}
                tickFormatter={(value: number) =>
                  `${(value / 1000000).toFixed(1)}M`
                }
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar
                dataKey="revenue"
                fill="#10b981"
                radius={[8, 8, 0, 0]}
                maxBarSize={40}
              />
            </BarChart>
          </ResponsiveContainer>
        )}

        <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <p
                className={`text-xs ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đặt phòng hôm nay
              </p>
              <p
                className={`text-lg font-semibold mt-1 ${
                  dark ? "text-white" : "text-gray-900"
                }`}
              >
                {statistics?.todayBookings || 0}
              </p>
            </div>
            <div>
              <p
                className={`text-xs ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Tổng doanh thu
              </p>
              <p
                className={`text-lg font-semibold mt-1 ${
                  dark ? "text-emerald-400" : "text-emerald-600"
                }`}
              >
                {(statistics?.totalRevenue || 0).toLocaleString("vi-VN")} đ
              </p>
            </div>
            <div>
              <p
                className={`text-xs ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Tăng trưởng
              </p>
              <div className="flex items-center justify-center gap-1 mt-1">
                {(statistics?.revenueChange || 0) >= 0 ? (
                  <TrendingUp className="w-4 h-4 text-emerald-500" />
                ) : (
                  <TrendingDown className="w-4 h-4 text-red-500" />
                )}
                <p
                  className={`text-lg font-semibold ${
                    (statistics?.revenueChange || 0) >= 0
                      ? "text-emerald-500"
                      : "text-red-500"
                  }`}
                >
                  {(statistics?.revenueChange || 0) >= 0 ? "+" : ""}
                  {(statistics?.revenueChange || 0).toFixed(1)}%
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* SECTION 7: ĐÁNH GIÁ GẦN ĐÂY */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <MessageSquare
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Đánh giá gần đây
            </h2>
            <span
              className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}
            >
              ({reviews.length} đánh giá)
            </span>
          </div>
          <button
            className={`flex items-center gap-1 text-sm font-medium transition-colors ${
              dark
                ? "text-emerald-400 hover:text-emerald-300"
                : "text-emerald-600 hover:text-emerald-700"
            }`}
            onClick={() => console.log("View all reviews")}
          >
            Xem tất cả
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {loadingReviews ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đang tải đánh giá...
              </p>
            </div>
          </div>
        ) : reviewsError ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <AlertCircle className="w-8 h-8 text-red-500 mx-auto mb-2" />
              <p className="text-sm text-red-500">{reviewsError}</p>
            </div>
          </div>
        ) : reviews.slice(0, 5).length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <MessageSquare
                className={`w-12 h-12 mx-auto mb-3 ${
                  dark ? "text-gray-600" : "text-gray-400"
                }`}
              />
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Chưa có đánh giá nào
              </p>
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            {reviews.slice(0, 5).map((review) => {
              const hotel = hotels.find((h) => h.hotelId === review.hotelId);
              return (
                <ReviewCard
                  key={review.reviewId}
                  review={review}
                  hotelName={hotel?.title || "Khách sạn"}
                />
              );
            })}
          </div>
        )}
      </div>
      {/* SECTION 8: CẢNH BÁO GIÁ (PRICE ALERTS) */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <AlertCircle
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Cảnh báo giá
            </h2>
            <span
              className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}
            >
              ({priceAlerts.length} cảnh báo)
            </span>
          </div>
          <button
            className={`flex items-center gap-1 text-sm font-medium transition-colors ${
              dark
                ? "text-emerald-400 hover:text-emerald-300"
                : "text-emerald-600 hover:text-emerald-700"
            }`}
            onClick={() => console.log("View all price alerts")}
          >
            Xem tất cả
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {loadingAlerts ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đang tải cảnh báo giá...
              </p>
            </div>
          </div>
        ) : alertsError ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <AlertCircle className="w-8 h-8 text-red-500 mx-auto mb-2" />
              <p className="text-sm text-red-500">{alertsError}</p>
            </div>
          </div>
        ) : priceAlerts.slice(0, 5).length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <TrendingDown
                className={`w-12 h-12 mx-auto mb-3 ${
                  dark ? "text-gray-600" : "text-gray-400"
                }`}
              />
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Chưa có cảnh báo giá nào
              </p>
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            {priceAlerts.slice(0, 5).map((alert) => {
              const hotel = hotels.find((h) => h.hotelId === alert.hotelId);
              return (
                <PriceAlertCard
                  key={alert.alertId}
                  alert={alert}
                  hotelName={hotel?.title || "Khách sạn"}
                  currentPrice={hotel?.price}
                />
              );
            })}
          </div>
        )}
      </div>
      {/* SECTION 9: THỐNG KÊ ĐÁNH GIÁ (RATING STATISTICS) */}
      <div
        className={`rounded-xl border p-6 ${
          dark ? "bg-gray-800/50 border-gray-700" : "bg-white border-gray-200"
        }`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <BarChart2
              className={`w-5 h-5 ${
                dark ? "text-emerald-400" : "text-emerald-600"
              }`}
            />
            <h2
              className={`text-lg font-semibold ${
                dark ? "text-white" : "text-gray-900"
              }`}
            >
              Thống kê đánh giá
            </h2>
            <span
              className={`text-sm ${dark ? "text-gray-400" : "text-gray-600"}`}
            >
              ({ratingSummaries.length} khách sạn)
            </span>
          </div>
          <button
            className={`flex items-center gap-1 text-sm font-medium transition-colors ${
              dark
                ? "text-emerald-400 hover:text-emerald-300"
                : "text-emerald-600 hover:text-emerald-700"
            }`}
            onClick={() => console.log("View detailed statistics")}
          >
            Xem chi tiết
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {loadingSummaries ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mx-auto mb-2"></div>
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Đang tải thống kê đánh giá...
              </p>
            </div>
          </div>
        ) : summariesError ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <AlertCircle className="w-8 h-8 text-red-500 mx-auto mb-2" />
              <p className="text-sm text-red-500">{summariesError}</p>
            </div>
          </div>
        ) : ratingSummaries.length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <BarChart2
                className={`w-12 h-12 mx-auto mb-3 ${
                  dark ? "text-gray-600" : "text-gray-400"
                }`}
              />
              <p
                className={`text-sm ${
                  dark ? "text-gray-400" : "text-gray-600"
                }`}
              >
                Chưa có thống kê đánh giá
              </p>
              <p
                className={`text-xs mt-1 ${
                  dark ? "text-gray-500" : "text-gray-500"
                }`}
              >
                Thống kê sẽ hiển thị khi khách sạn nhận được đánh giá
              </p>
            </div>
          </div>
        ) : (
          <div className="space-y-4">
            {ratingSummaries.map((summary) => {
              const hotel = hotels.find((h) => h.hotelId === summary.hotelId);
              return (
                <RatingSummaryCard
                  key={summary.hotelId}
                  summary={summary}
                  hotelName={hotel?.title || `Khách sạn #${summary.hotelId}`}
                />
              );
            })}
          </div>
        )}

        {/* Summary Statistics */}
        {ratingSummaries.length > 0 && (
          <div
            className={`mt-6 pt-6 border-t ${
              dark ? "border-gray-700" : "border-gray-200"
            }`}
          >
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="text-center">
                <p
                  className={`text-xs mb-1 ${
                    dark ? "text-gray-400" : "text-gray-600"
                  }`}
                >
                  Tổng đánh giá
                </p>
                <p
                  className={`text-2xl font-bold ${
                    dark ? "text-white" : "text-gray-900"
                  }`}
                >
                  {ratingSummaries.reduce((sum, s) => sum + s.totalReviews, 0)}
                </p>
              </div>

              <div className="text-center">
                <p
                  className={`text-xs mb-1 ${
                    dark ? "text-gray-400" : "text-gray-600"
                  }`}
                >
                  Điểm TB tất cả KS
                </p>
                <div className="flex items-center justify-center gap-1">
                  <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                  <p
                    className={`text-2xl font-bold ${
                      dark ? "text-emerald-400" : "text-emerald-600"
                    }`}
                  >
                    {(
                      ratingSummaries.reduce((sum, s) => sum + s.avgRating, 0) /
                      ratingSummaries.length
                    ).toFixed(1)}
                  </p>
                </div>
              </div>

              <div className="text-center">
                <p
                  className={`text-xs mb-1 ${
                    dark ? "text-gray-400" : "text-gray-600"
                  }`}
                >
                  Đánh giá 5 sao
                </p>
                <p
                  className={`text-2xl font-bold ${
                    dark ? "text-emerald-400" : "text-emerald-600"
                  }`}
                >
                  {ratingSummaries.reduce((sum, s) => sum + s.count5, 0)}
                </p>
              </div>

              <div className="text-center">
                <p
                  className={`text-xs mb-1 ${
                    dark ? "text-gray-400" : "text-gray-600"
                  }`}
                >
                  KS có đánh giá
                </p>
                <p
                  className={`text-2xl font-bold ${
                    dark ? "text-blue-400" : "text-blue-600"
                  }`}
                >
                  {ratingSummaries.filter((s) => s.totalReviews > 0).length}/
                  {hotels.length}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default DashboardHotelPage;
