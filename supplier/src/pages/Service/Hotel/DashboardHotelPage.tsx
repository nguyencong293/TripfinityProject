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
import { getProviderByUserId, getUserById } from "../../../services/providerService";
import {
  getHotelsByProvider,
  getActiveHotelPriceAlertsByProvider,
  getHotelRatingSummariesByProvider,
  getHotelReviewsByHotel,
} from "../../../services/hotelService";
import type {
  HotelDTO,
  HotelBookingDTO,
  HotelPriceAlertDTO,
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
  PriceAlertCard,
  RatingSummaryCard,
  ReviewCard,
} from "../../../components/hotel";
import { useLanguage } from "../../../hooks/useLanguage";

// Notification types for this page context
import type { Notification } from "../../../components/hotel/NotificationItem";
// merged into hotelService

// Main Dashboard
const DashboardHotelPage: React.FC = () => {
  const navigate = useNavigate();
  const { statistics } = useHotelDashboardStatistics(undefined);
  const { t } = useLanguage();
  const [providerId, setProviderId] = useState<number | undefined>();
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [bookings, setBookings] = useState<HotelBookingDTO[]>([]);
  const [priceAlerts, setPriceAlerts] = useState<HotelPriceAlertDTO[]>([]);
  const [ratingSummaries, setRatingSummaries] = useState<
    HotelRatingSummaryDTO[]
  >([]);
  const [recentReviews, setRecentReviews] = useState<HotelReviewDTO[]>([]);
  const [userCache, setUserCache] = useState<Map<number, UserDTO>>(new Map());

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
        const uniqueUserIds = Array.from(new Set((bRes.data || []).map(b => b.userId)));
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

        // Fetch provider-level data
        const [alerts, summaries] = await Promise.all([
          getActiveHotelPriceAlertsByProvider(providerId),
          getHotelRatingSummariesByProvider(providerId),
        ]);
        setPriceAlerts(alerts);
        setRatingSummaries(summaries);

        // Fetch reviews for the first hotel (if available)
        const firstHotelId = hs[0]?.hotelId;
        if (firstHotelId) {
          const revs = await getHotelReviewsByHotel(firstHotelId);
          setRecentReviews(revs.slice(0, 2));
        } else {
          setRecentReviews([]);
        }
      } catch (e) {
        console.error("❌ Error loading dashboard data:", e);
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
      title: t("hotel_dashboard_notif_new_booking_title"),
      message: t("hotel_dashboard_notif_new_booking_message"),
      time: `5 ${t("minutes_ago_suffix")}`,
      isNew: true,
    },
    {
      id: "2",
      type: "payment_success",
      title: t("hotel_dashboard_notif_payment_success_title"),
      message: t("hotel_dashboard_notif_payment_success_message"),
      time: `15 ${t("minutes_ago_suffix")}`,
      isNew: true,
    },
  ];

  // Derived selections
  const firstHotel = hotels[0];
  const activeAlert =
    priceAlerts.find((a) => a.hotelId === firstHotel?.hotelId) ||
    priceAlerts[0];
  const ratingSummary =
    ratingSummaries.find((s) => s.hotelId === firstHotel?.hotelId) ||
    ratingSummaries[0];

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 flex flex-col gap-6">
      {/* SECTION 1: Thống kê tổng quan */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={<BarChart3 className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_total_revenue")}
          value={`${(statistics?.totalRevenue || 0).toLocaleString(
            "vi-VN"
          )} VND`}
          trend={{ value: 12.4, isPositive: true }}
        />
        <StatCard
          icon={<Hotel className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_total_bookings")}
          value={statistics?.totalBookings || 0}
          trend={{ value: 3.2, isPositive: true }}
        />
        <StatCard
          icon={<Calendar className="w-5 h-5 icon-brand" />}
          label={t("hotel_dashboard_total_reviews")}
          value={statistics?.totalReviews || 0}
          badge={{ text: t("increase"), variant: "info" }}
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
            onClick={() => console.log("View all notifications")}
          >
            {t("view_all")} <ChevronRight className="w-4 h-4" />
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
            onClick={() => console.log("Bookings")}
          />
          <QuickAction
            icon={<MessageSquare className="w-6 h-6" />}
            label={t("hotel_dashboard_action_manage_reviews")}
            description={t("hotel_dashboard_action_manage_reviews_desc")}
            onClick={() => console.log("Reviews")}
          />
          <QuickAction
            icon={<BarChart2 className="w-6 h-6" />}
            label={t("hotel_dashboard_action_revenue_report")}
            description={t("hotel_dashboard_action_revenue_report_desc")}
            onClick={() => console.log("Revenue")}
          />
          <QuickAction
            icon={<Settings className="w-6 h-6" />}
            label={t("hotel_dashboard_action_price_settings")}
            description={t("hotel_dashboard_action_price_settings_desc")}
            onClick={() => console.log("Prices")}
          />
          <QuickAction
            icon={<FileText className="w-6 h-6" />}
            label={t("hotel_dashboard_action_contracts")}
            description={t("hotel_dashboard_action_contracts_desc")}
            onClick={() => console.log("Contracts")}
          />
        </div>
      </div>

      {/* SECTION 4: Biểu đồ doanh thu */}
      <div className="rounded-xl border theme-border theme-bg-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <BarChart3 className="w-5 h-5 icon-brand" />
          <h2 className="text-lg font-semibold theme-text-primary">
            {t("hotel_dashboard_revenue_chart")}
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
          {hotels.map((h) => (
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
        {bookings.length === 0 ? (
          <div className="text-center py-8 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>{t("hotel_dashboard_no_bookings") || "Chưa có đặt phòng nào"}</p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {[...bookings]
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
                        onView={() => console.log("View booking", b.bookingId)}
                        onConfirm={async () => {
                          try {
                            await api.patch(`/hotel-bookings/${b.bookingId}/confirm`);
                            // Refresh booking data
                            const response = await api.get<HotelBookingDTO>(`/hotel-bookings/${b.bookingId}`);
                            setBookings(prev => prev.map(booking => 
                              booking.bookingId === b.bookingId ? response.data : booking
                            ));
                            console.log("✅ Booking confirmed:", b.bookingId);
                          } catch (error) {
                            console.error("❌ Error confirming booking:", error);
                          }
                        }}
                        onCancel={() => {
                          console.log("Cancel booking", b.bookingId);
                          // TODO: Call API to cancel booking
                        }}
                      />
                    </div>
                  </div>
                );
              })}
          </div>
        )}
      </div>

      {/* SECTION 7: Thống kê & đánh giá */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="rounded-xl border theme-border theme-bg-card p-6">
          <h2 className="text-lg font-semibold theme-text-primary mb-4">
            {t("hotel_dashboard_price_alerts")}
          </h2>
          {activeAlert ? (
            <PriceAlertCard
              alert={activeAlert}
              hotelName={firstHotel?.title || t("hotel")}
              currentPrice={
                bookings.find((b) => b.hotelId === firstHotel?.hotelId)
                  ?.totalPrice
              }
            />
          ) : (
            <div className="theme-text-secondary text-sm">
              {t("hotel_dashboard_no_price_alerts")}
            </div>
          )}
        </div>

        <div className="rounded-xl border theme-border theme-bg-card p-6 lg:col-span-2">
          <h2 className="text-lg font-semibold theme-text-primary mb-4">
            {t("hotel_dashboard_rating_overview")}
          </h2>
          {ratingSummary ? (
            <RatingSummaryCard
              summary={ratingSummary}
              hotelName={firstHotel?.title || t("hotel")}
            />
          ) : (
            <div className="theme-text-secondary text-sm">
              {t("hotel_dashboard_no_rating_data")}
            </div>
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
            onClick={() => console.log("View all reviews")}
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
          {recentReviews.map((r) => (
            <ReviewCard
              key={r.reviewId}
              review={r}
              hotelName={firstHotel?.title || t("hotel")}
            />
          ))}
        </div>
      </div>
    </div>
  );
};

export default DashboardHotelPage;
