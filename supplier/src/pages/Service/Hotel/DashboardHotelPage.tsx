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
  Settings,
  BarChart2,
  FileText,
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
import { useHotelDashboardStatistics } from "../../../hooks/useHotelDashboardStatistics";
import { getProviderByUserId } from "../../../services/providerService";
import { getHotelsByProvider } from "../../../services/hotelService";
import type {
  HotelDTO,
  HotelBookingDTO,
  HotelPriceAlertDTO,
  HotelRatingSummaryDTO,
  HotelReviewDTO,
} from "../../../types";
import api from "../../../services/api";
import {
  QuickAction,
  NotificationItem,
  StatCard,
  HotelCard,
  BookingRow,
  PriceAlertCard,
  RatingSummaryCard,
  ReviewCard,
} from "../../../components/hotel";

// Notification types for this page context
import type { Notification } from "../../../components/hotel/NotificationItem";

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

  // Demo data for new cards (can be wired to real APIs later)
  const demoPriceAlert: HotelPriceAlertDTO = {
    alertId: 1,
    hotelId: hotels[0]?.hotelId || 0,
    userId: 1001,
    targetPrice: 800000,
    currencyCode: "VND",
    isActive: true,
    createdAt: new Date().toISOString(),
    lastNotifiedAt: undefined,
  };

  const demoRatingSummary: HotelRatingSummaryDTO = {
    hotelId: hotels[0]?.hotelId || 0,
    avgRating: 4.3,
    totalReviews: 128,
    count5: 70,
    count4: 35,
    count3: 15,
    count2: 5,
    count1: 3,
    avgCleanliness: 4.2,
    avgService: 4.4,
    avgValueForMoney: 4.0,
    avgLocation: 4.1,
    avgFacilities: 4.2,
  };

  const demoReview: HotelReviewDTO = {
    reviewId: 1,
    hotelId: hotels[0]?.hotelId || 0,
    userId: 1001,
    rating: 5,
    title: "Tuyệt vời!",
    content:
      "Khách sạn sạch sẽ, nhân viên thân thiện và vị trí rất thuận tiện. Sẽ quay lại!",
    createdAt: new Date().toISOString(),
    likesCount: 12,
    replyCount: 3,
    aspects: {
      cleanliness: 4.5,
      service: 4.8,
      valueForMoney: 4.2,
      location: 4.6,
      facilities: 4.4,
    },
  };

  const demoReview2: HotelReviewDTO = {
    ...demoReview,
    reviewId: 2,
    rating: 4,
    title: "Hài lòng",
    likesCount: 5,
  };

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
          icon={<Hotel className="w-5 h-5 icon-brand" />}
          label="Đơn đặt phòng"
          value={statistics?.totalBookings || 0}
          trend={{ value: 3.2, isPositive: true }}
        />
        <StatCard
          icon={<Calendar className="w-5 h-5 icon-brand" />}
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

      {/* SECTION 7: Thống kê & đánh giá */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="rounded-xl border theme-border theme-bg-card p-6">
          <h2 className="text-lg font-semibold theme-text-primary mb-4">
            Cảnh báo giá
          </h2>
          <PriceAlertCard
            alert={demoPriceAlert}
            hotelName={hotels[0]?.title || "Khách sạn"}
            currentPrice={bookings[0]?.totalPrice || 950000}
          />
        </div>

        <div className="rounded-xl border theme-border theme-bg-card p-6 lg:col-span-2">
          <h2 className="text-lg font-semibold theme-text-primary mb-4">
            Tổng quan đánh giá
          </h2>
          <RatingSummaryCard
            summary={demoRatingSummary}
            hotelName={hotels[0]?.title || "Khách sạn"}
          />
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
            onClick={() => console.log("View all reviews")}
          >
            Xem tất cả <ChevronRight className="w-4 h-4" />
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ReviewCard
            review={demoReview}
            hotelName={hotels[0]?.title || "Khách sạn"}
          />
          <ReviewCard
            review={demoReview2}
            hotelName={hotels[0]?.title || "Khách sạn"}
          />
        </div>
      </div>
    </div>
  );
};

export default DashboardHotelPage;
