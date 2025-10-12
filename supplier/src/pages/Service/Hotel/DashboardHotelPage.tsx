import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  BarChart3,
  Hotel,
  Calendar,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Star,
  Bell,
  MessageSquare,
  CheckCircle,
  Ticket,
  TrendingDown as PriceDown,
  ChevronRight,
  Eye,
  Edit,
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
import { useHotelDashboardStatistics } from "../../../hooks/useHotelDashboardStatistics";
import { getProviderByUserId } from "../../../services/providerService";
import { getHotelsByProvider } from "../../../services/hotelService";
import type { HotelDTO, HotelBookingDTO } from "../../../types";
import api from "../../../services/api";

// QuickAction (theme-based)
interface QuickActionProps {
  icon: React.ReactNode;
  label: string;
  description: string;
  onClick: () => void;
}
const QuickAction: React.FC<QuickActionProps> = ({
  icon,
  label,
  description,
  onClick,
}) => (
  <button
    onClick={onClick}
    className="group relative rounded-xl border theme-border theme-bg-card p-6 transition-all hover:shadow-lg text-left w-full"
  >
    <div className="flex items-start gap-4">
      <div className="p-3 rounded-lg theme-bg-secondary">{icon}</div>
      <div className="flex-1">
        <h4 className="text-base font-semibold mb-1 theme-text-primary">
          {label}
        </h4>
        <p className="text-sm theme-text-secondary">{description}</p>
      </div>
      <ChevronRight className="w-5 h-5 icon-disabled transition-transform group-hover:translate-x-1" />
    </div>
  </button>
);

// Notification item (theme-based)
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
  const getIcon = (type: NotificationType) => {
    switch (type) {
      case "new_booking":
        return <Calendar className="w-5 h-5 theme-text-info" />;
      case "new_review":
        return <MessageSquare className="w-5 h-5 theme-text-info" />;
      case "payment_success":
        return <CheckCircle className="w-5 h-5 theme-text-success" />;
      case "e_ticket_created":
        return <Ticket className="w-5 h-5 theme-text-warning" />;
      case "price_alert":
        return <PriceDown className="w-5 h-5 theme-text-error" />;
    }
  };
  const getBg = (type: NotificationType) => {
    switch (type) {
      case "new_booking":
      case "new_review":
        return "theme-bg-info";
      case "payment_success":
        return "theme-bg-success";
      case "e_ticket_created":
        return "theme-bg-warning";
      case "price_alert":
        return "theme-bg-error";
    }
  };
  return (
    <button
      onClick={onClick}
      className="flex-shrink-0 w-80 p-4 rounded-xl border theme-border theme-bg-card transition-all hover:shadow-md"
    >
      <div className="flex gap-3">
        <div
          className={`flex-shrink-0 p-2 rounded-lg ${getBg(notification.type)}`}
        >
          {getIcon(notification.type)}
        </div>
        <div className="flex-1 min-w-0 text-left">
          <div className="flex items-start justify-between gap-2">
            <p className="text-sm font-semibold theme-text-primary">
              {notification.title}
            </p>
            {notification.isNew && (
              <span className="flex-shrink-0 w-2 h-2 theme-bg-primary rounded-full" />
            )}
          </div>
          <p className="text-xs mt-1 line-clamp-2 theme-text-secondary">
            {notification.message}
          </p>
          <p className="text-xs mt-2 theme-text-secondary">
            {notification.time}
          </p>
        </div>
      </div>
    </button>
  );
};

// Stat card (theme-based)
interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: string | number;
  trend?: { value: number; isPositive: boolean };
  badge?: { text: string; variant: "success" | "warning" | "danger" | "info" };
}
const StatCard: React.FC<StatCardProps> = ({
  icon,
  label,
  value,
  trend,
  badge,
}) => {
  const badgeColors: Record<
    NonNullable<StatCardProps["badge"]>["variant"],
    string
  > = {
    success: "theme-bg-success theme-text-success border-success",
    warning: "theme-bg-warning theme-text-warning border-warning",
    danger: "theme-bg-error theme-text-error border-error",
    info: "theme-bg-info theme-text-info border-info",
  } as const;
  return (
    <div className="relative overflow-hidden rounded-xl border theme-border theme-bg-card p-6 transition-all hover:shadow-lg">
      <div className="flex items-start justify-between mb-4">
        <div className="p-3 rounded-lg theme-bg-secondary">{icon}</div>
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
        <p className="text-sm font-medium theme-text-secondary">{label}</p>
        <p className="text-3xl font-bold theme-text-primary">{value}</p>
      </div>
      {trend && (
        <div className="mt-4 flex items-center gap-2">
          {trend.isPositive ? (
            <TrendingUp className="w-4 h-4 theme-text-success" />
          ) : (
            <TrendingDown className="w-4 h-4 theme-text-error" />
          )}
          <span
            className={`text-sm font-medium ${
              trend.isPositive ? "theme-text-success" : "theme-text-error"
            }`}
          >
            {trend.isPositive ? "+" : ""}
            {trend.value.toFixed(1)}%
          </span>
          <span className="text-sm theme-text-secondary">
            so với tháng trước
          </span>
        </div>
      )}
    </div>
  );
};

// Hotel card (theme-based)
interface HotelCardProps {
  hotel: HotelDTO;
  onView: () => void;
  onEdit: () => void;
}
const HotelCard: React.FC<HotelCardProps> = ({ hotel, onView, onEdit }) => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case "published":
        return "theme-bg-success theme-text-success border-success";
      case "archived":
        return "theme-bg-warning theme-text-warning border-warning";
      case "disabled":
        return "theme-bg-error theme-text-error border-error";
      default:
        return "theme-bg-info theme-text-info border-info";
    }
  };
  const formatCurrency = (v: number) =>
    new Intl.NumberFormat("vi-VN").format(v);
  return (
    <div className="rounded-xl border theme-border theme-bg-card overflow-hidden transition-all hover:shadow-lg">
      <div className="relative h-48 theme-bg-secondary">
        {hotel.thumbnailUrl ? (
          <img
            src={hotel.thumbnailUrl}
            alt={hotel.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <Hotel className="w-16 h-16 icon-disabled" />
          </div>
        )}
        <div className="absolute top-3 right-3">
          <span
            className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
              hotel.hotelStatus
            )}`}
          >
            {hotel.hotelStatus}
          </span>
        </div>
      </div>
      <div className="p-4">
        <h3 className="text-lg font-semibold mb-2 line-clamp-1 theme-text-primary">
          {hotel.title}
        </h3>
        <div className="space-y-2 mb-4">
          {hotel.location && (
            <div className="flex items-center gap-2 text-sm">
              <MapPin className="w-4 h-4 icon-disabled" />
              <span className="line-clamp-1 theme-text-secondary">
                {hotel.location}
              </span>
            </div>
          )}
          <div className="flex items-center gap-4 text-sm">
            {hotel.starRating && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 theme-text-warning" />
                <span className="font-medium theme-text-secondary">
                  {hotel.starRating} sao
                </span>
              </div>
            )}
            {hotel.ratingAverage !== undefined && (
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 theme-text-warning" />
                <span className="font-medium theme-text-secondary">
                  {hotel.ratingAverage.toFixed(1)}
                </span>
              </div>
            )}
          </div>
          {hotel.capacity && (
            <div className="flex items-center gap-2 text-sm">
              <Users className="w-4 h-4 icon-disabled" />
              <span className="theme-text-secondary">
                Sức chứa: {hotel.capacity} người
              </span>
            </div>
          )}
          <div className="flex items-center gap-2 text-sm">
            <DollarSign className="w-4 h-4 icon-disabled" />
            <span className="font-semibold theme-text-brand">
              {formatCurrency(hotel.price)} {hotel.currencyCode}
            </span>
          </div>
        </div>
        <div className="flex gap-2">
          <button
            onClick={onView}
            className="flex-1 btn-secondary btn-text-responsive flex items-center justify-center gap-2"
          >
            <Eye className="w-4 h-4" /> Xem
          </button>
          <button
            onClick={onEdit}
            className="flex-1 btn-primary btn-text-responsive flex items-center justify-center gap-2"
          >
            <Edit className="w-4 h-4" /> Sửa
          </button>
        </div>
      </div>
    </div>
  );
};

// Booking row (theme-based)
const BookingRow = ({ booking }: { booking: HotelBookingDTO }) => {
  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: "theme-bg-warning theme-text-warning border-warning",
      confirmed: "theme-bg-info theme-text-info border-info",
      completed: "theme-bg-success theme-text-success border-success",
      cancelled: "theme-bg-error theme-text-error border-error",
      refunded: "theme-bg-info theme-text-info border-info",
    };
    return (
      colors[status] || "theme-bg-secondary theme-text-secondary theme-border"
    );
  };
  const formatDate = (s?: string) =>
    s ? new Date(s).toLocaleDateString("vi-VN") : "N/A";
  const formatCurrency = (v?: number) =>
    new Intl.NumberFormat("vi-VN").format(v || 0);
  return (
    <div
      className={`p-4 rounded-lg border transition-colors ${
        !booking.providerSeen
          ? "theme-bg-info border-info"
          : "theme-bg-card theme-border"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-semibold theme-text-primary">
              #{booking.bookingId}
            </h4>
            {!booking.providerSeen && (
              <span className="px-2 py-0.5 text-xs font-medium theme-bg-info theme-text-info rounded-full">
                Mới
              </span>
            )}
          </div>
          <p className="text-sm theme-text-secondary">
            User ID: {booking.userId}
          </p>
        </div>
        <span
          className={`px-3 py-1 text-xs font-medium rounded-full border ${getStatusColor(
            booking.bookingStatus || "pending"
          )}`}
        >
          {booking.bookingStatus || "pending"}
        </span>
      </div>
      <div className="grid grid-cols-2 gap-3 text-sm">
        <div>
          <p className="mb-1 theme-text-secondary">Ngày nhận phòng</p>
          <p className="font-medium theme-text-primary">
            {formatDate(booking.startDate)}
          </p>
        </div>
        <div>
          <p className="mb-1 theme-text-secondary">Ngày trả phòng</p>
          <p className="font-medium theme-text-primary">
            {formatDate(booking.endDate)}
          </p>
        </div>
        <div>
          <p className="mb-1 theme-text-secondary">Số khách</p>
          <p className="font-medium theme-text-primary">
            {booking.numAdults} người lớn
            {booking.numChildren ? `, ${booking.numChildren} trẻ em` : ""}
          </p>
        </div>
        <div>
          <p className="mb-1 theme-text-secondary">Tổng tiền</p>
          <p className="font-semibold theme-text-brand">
            {formatCurrency(booking.totalPrice)} {booking.currencyCode || "VND"}
          </p>
        </div>
      </div>
      {booking.providerNotes && (
        <div className="mt-3 p-2 rounded theme-bg-secondary">
          <p className="text-xs theme-text-secondary">
            Ghi chú: {booking.providerNotes}
          </p>
        </div>
      )}
    </div>
  );
};

// Main Dashboard
const DashboardHotelPage: React.FC = () => {
  const navigate = useNavigate();
  const { statistics } = useHotelDashboardStatistics(undefined);
  const [providerId, setProviderId] = useState<number | undefined>();
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [bookings, setBookings] = useState<HotelBookingDTO[]>([]);

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
        const hs = await getHotelsByProvider(providerId);
        setHotels(hs);
        const bRes = await api.get<HotelBookingDTO[]>(
          `/hotel-bookings/provider/${providerId}`
        );
        setBookings(bRes.data);
      } catch (e) {
        console.error(e);
      }
    };
    load();
  }, [providerId]);

  const revenueChartData = useMemo(() => {
    const map = new Map<number, number>();
    bookings.forEach((b) => {
      const d = b.createdAt ? new Date(b.createdAt).getDate() : 1;
      map.set(d, (map.get(d) || 0) + (b.totalPrice || 0));
    });
    return Array.from({ length: 30 }, (_, i) => {
      const day = i + 1;
      return { day, label: `Ngày ${day}`, revenue: map.get(day) || 0 };
    });
  }, [bookings]);

  const newNotificationsCount = 2;
  const notifications: Notification[] = [
    {
      id: "1",
      type: "new_booking",
      title: "Đặt phòng mới",
      message: "Bạn có đặt phòng mới",
      time: "5 phút trước",
      isNew: true,
    },
    {
      id: "2",
      type: "payment_success",
      title: "Thanh toán thành công",
      message: "Thanh toán #12345",
      time: "15 phút trước",
      isNew: true,
    },
  ];

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-6">
      {/* SECTION 1: Thống kê tổng quan */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={<BarChart3 className="w-5 h-5 icon-brand" />}
          label="Tổng doanh thu"
          value={`${(statistics?.totalRevenue || 0).toLocaleString(
            "vi-VN"
          )} VND`}
          trend={{ value: 12.4, isPositive: true }}
        />
        <StatCard
          icon={<Users className="w-5 h-5 icon-brand" />}
          label="Đơn đặt phòng"
          value={statistics?.totalBookings || 0}
          trend={{ value: 3.2, isPositive: true }}
        />
        <StatCard
          icon={<Star className="w-5 h-5 icon-brand" />}
          label="Đánh giá"
          value={statistics?.totalReviews || 0}
          badge={{ text: "Tăng", variant: "info" }}
        />
        <StatCard
          icon={<Hotel className="w-5 h-5 icon-brand" />}
          label="Khách sạn"
          value={hotels.length}
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
            onClick={() => console.log("View all notifications")}
          >
            Xem tất cả <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="flex gap-4 overflow-x-auto pb-2">
          {notifications.map((n) => (
            <NotificationItem
              key={n.id}
              notification={n}
              onClick={() => console.log("Clicked", n.id)}
            />
          ))}
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
            label="Thêm khách sạn mới"
            description="Tạo khách sạn và đăng tải"
            onClick={() => navigate("/supplier/service/hotel/create")}
          />
          <QuickAction
            icon={<List className="w-6 h-6" />}
            label="Quản lý đặt phòng"
            description="Xem và xử lý đặt phòng"
            onClick={() => console.log("Bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label="Quản lý đánh giá"
            description="Xem và phản hồi đánh giá"
            onClick={() => console.log("Reviews")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label="Báo cáo doanh thu"
            description="Xem báo cáo chi tiết"
            onClick={() => console.log("Revenue")}
          />
          <QuickAction
            icon={<Settings className="w-6 h-6" />}
            label="Cài đặt giá"
            description="Quản lý giá phòng"
            onClick={() => console.log("Prices")}
          />
          <QuickAction
            icon={<FileText className="w-6 h-6" />}
            label="Quản lý hợp đồng"
            description="Xem hợp đồng"
            onClick={() => console.log("Contracts")}
          />
        </div>
      </div>

      {/* SECTION 4: Biểu đồ doanh thu */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <BarChart3 className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            Biểu đồ doanh thu
          </h2>
        </div>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={revenueChartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="day" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="revenue" fill="#34A853" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* SECTION 5: Danh sách khách sạn */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold theme-text-primary">
            Danh sách khách sạn
          </h2>
          <button
            className="link-brand flex items-center gap-1"
            onClick={() => navigate("/supplier/service/hotel/list")}
          >
            Xem tất cả <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {hotels.map((h) => (
            <HotelCard
              key={h.hotelId}
              hotel={h}
              onView={() => navigate(`/supplier/service/hotel/${h.hotelId}`)}
              onEdit={() =>
                navigate(`/supplier/service/hotel/${h.hotelId}/edit`)
              }
            />
          ))}
        </div>
      </div>

      {/* SECTION 6: Đặt phòng gần đây */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <Calendar className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            Đặt phòng gần đây
          </h2>
        </div>
        <div className="flex flex-col gap-3">
          {bookings.slice(0, 5).map((b) => (
            <BookingRow key={b.bookingId} booking={b} />
          ))}
        </div>
      </div>
    </div>
  );
};

export default DashboardHotelPage;
