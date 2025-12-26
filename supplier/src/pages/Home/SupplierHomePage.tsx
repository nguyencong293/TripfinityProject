import React, { useEffect, useState, useMemo } from "react";
import { useNavigate, Link } from "react-router-dom";
import {
  Calendar,
  DollarSign,
  Star,
  TrendingUp,
  TrendingDown,
  Clock,
  Eye,
  CheckCircle2,
  XCircle,
  Package,
  Route,
  Building2,
  Utensils,
  MapPin,
  ChevronRight,
  Users,
  BarChart3,
  RefreshCw,
} from "lucide-react";
import {
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  Legend,
} from "recharts";
import { useTheme } from "../../hooks/useTheme";
import { useLanguage } from "../../hooks/useLanguage";
import { getProviderByUserId } from "../../services/providerService";
import { getToursByProvider, getTourBookingsByProvider } from "../../services/tourService";
import { getHotelsByProvider } from "../../services/hotelService";
import { getRestaurantsByProvider, getRestaurantBookingsByProvider } from "../../services/restaurantService";
import { getAttractionsByProvider, getAttractionBookingsByProvider } from "../../services/attractionService";
import api from "../../services/api";
import type {
  TourDTO,
  TourBookingDTO,
  HotelDTO,
  HotelBookingDTO,
  RestaurantDTO,
  RestaurantBookingDTO,
  AttractionDTO,
  AttractionBookingDTO,
  ProviderDTO,
} from "../../types";

// Interfaces
interface ServiceSummary {
  type: "tour" | "hotel" | "restaurant" | "attraction";
  icon: React.ComponentType<{ className?: string }>;
  color: string;
  bgColor: string;
  totalItems: number;
  publishedItems: number;
  totalBookings: number;
  pendingBookings: number;
  totalRevenue: number;
  avgRating: number;
  link: string;
}

interface RecentBooking {
  id: number;
  type: "tour" | "hotel" | "restaurant" | "attraction";
  serviceName: string;
  customerName: string;
  date: string;
  amount: number;
  status: string;
  providerConfirmed: number;
}

interface RevenueDataPoint {
  date: string;
  tour: number;
  hotel: number;
  restaurant: number;
  attraction: number;
}

const SupplierHomePage: React.FC = () => {
  const navigate = useNavigate();
  const { dark } = useTheme();
  const { t } = useLanguage();

  // State
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [providerId, setProviderId] = useState<number | undefined>();
  const [provider, setProvider] = useState<ProviderDTO | null>(null);

  // Service data
  const [tours, setTours] = useState<TourDTO[]>([]);
  const [tourBookings, setTourBookings] = useState<TourBookingDTO[]>([]);
  const [hotels, setHotels] = useState<HotelDTO[]>([]);
  const [hotelBookings, setHotelBookings] = useState<HotelBookingDTO[]>([]);
  const [restaurants, setRestaurants] = useState<RestaurantDTO[]>([]);
  const [restaurantBookings, setRestaurantBookings] = useState<RestaurantBookingDTO[]>([]);
  const [attractions, setAttractions] = useState<AttractionDTO[]>([]);
  const [attractionBookings, setAttractionBookings] = useState<AttractionBookingDTO[]>([]);

  // User cache for booking names
  const [userCache, setUserCache] = useState<Map<number, string>>(new Map());

  // Fetch provider and all data
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const userStr = localStorage.getItem("user");
        if (!userStr) return;

        const user = JSON.parse(userStr);
        const providerData = await getProviderByUserId(user.userId);
        if (!providerData?.providerId) return;

        setProviderId(providerData.providerId);
        setProvider(providerData);

        // Fetch all service data in parallel
        const [
          toursRes,
          tourBookingsRes,
          hotelsRes,
          hotelBookingsRes,
          restaurantsRes,
          restaurantBookingsRes,
          attractionsRes,
          attractionBookingsRes,
        ] = await Promise.all([
          getToursByProvider(providerData.providerId),
          getTourBookingsByProvider(providerData.providerId),
          getHotelsByProvider(providerData.providerId),
          api.get<HotelBookingDTO[]>(`/hotel-bookings/provider/${providerData.providerId}`),
          getRestaurantsByProvider(providerData.providerId),
          getRestaurantBookingsByProvider(providerData.providerId),
          getAttractionsByProvider(providerData.providerId),
          getAttractionBookingsByProvider(providerData.providerId),
        ]);

        setTours(toursRes || []);
        setTourBookings(tourBookingsRes || []);
        setHotels(hotelsRes || []);
        setHotelBookings(hotelBookingsRes.data || []);
        setRestaurants(restaurantsRes || []);
        setRestaurantBookings(restaurantBookingsRes || []);
        setAttractions(attractionsRes || []);
        setAttractionBookings(attractionBookingsRes || []);

        // Fetch user names for bookings
        const allBookings = [
          ...tourBookingsRes,
          ...hotelBookingsRes.data,
          ...restaurantBookingsRes,
          ...attractionBookingsRes,
        ];
        const userIds = [...new Set(allBookings.map((b) => b.userId))];
        const newUserCache = new Map<number, string>();

        for (const userId of userIds.slice(0, 20)) {
          try {
            const userRes = await api.get(`/users/${userId}`);
            newUserCache.set(userId, userRes.data.fullName || `${t("customer_id_prefix")}${userId}`);
          } catch {
            newUserCache.set(userId, `${t("customer_id_prefix")}${userId}`);
          }
        }
        setUserCache(newUserCache);
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [t]); // Added 't' dependency

  // Refresh data
  const handleRefresh = async () => {
    if (!providerId) return;
    setRefreshing(true);
    try {
      const [
        toursRes,
        tourBookingsRes,
        hotelsRes,
        hotelBookingsRes,
        restaurantsRes,
        restaurantBookingsRes,
        attractionsRes,
        attractionBookingsRes,
      ] = await Promise.all([
        getToursByProvider(providerId),
        getTourBookingsByProvider(providerId),
        getHotelsByProvider(providerId),
        api.get<HotelBookingDTO[]>(`/hotel-bookings/provider/${providerId}`),
        getRestaurantsByProvider(providerId),
        getRestaurantBookingsByProvider(providerId),
        getAttractionsByProvider(providerId),
        getAttractionBookingsByProvider(providerId),
      ]);

      setTours(toursRes || []);
      setTourBookings(tourBookingsRes || []);
      setHotels(hotelsRes || []);
      setHotelBookings(hotelBookingsRes.data || []);
      setRestaurants(restaurantsRes || []);
      setRestaurantBookings(restaurantBookingsRes || []);
      setAttractions(attractionsRes || []);
      setAttractionBookings(attractionBookingsRes || []);
    } catch (error) {
      console.error("Error refreshing data:", error);
    } finally {
      setRefreshing(false);
    }
  };

  // Calculate service summaries
  const serviceSummaries: ServiceSummary[] = useMemo(() => {
    const calculateRevenue = (bookings: Array<{ providerConfirmed?: number; totalPrice?: number }>, confirmedOnly = true) => {
      return bookings
        .filter((b) => !confirmedOnly || b.providerConfirmed === 1)
        .reduce((sum, b) => sum + (b.totalPrice || 0), 0);
    };

    const calculateAvgRating = (items: Array<{ ratingAverage?: number | null }>) => {
      const rated = items.filter((i) => i.ratingAverage);
      if (rated.length === 0) return 0;
      return rated.reduce((sum, i) => sum + (i.ratingAverage || 0), 0) / rated.length;
    };

    return [
      {
        type: "tour",
        icon: Route,
        color: "text-emerald-600",
        bgColor: "bg-emerald-100 dark:bg-emerald-900/30",
        totalItems: tours.length,
        publishedItems: tours.filter((t) => t.tourStatus === "published").length,
        totalBookings: tourBookings.length,
        pendingBookings: tourBookings.filter((b) => b.providerConfirmed === 0).length,
        totalRevenue: calculateRevenue(tourBookings),
        avgRating: calculateAvgRating(tours),
        link: "/supplier/service/tour",
      },
      {
        type: "hotel",
        icon: Building2,
        color: "text-blue-600",
        bgColor: "bg-blue-100 dark:bg-blue-900/30",
        totalItems: hotels.length,
        publishedItems: hotels.filter((h) => h.hotelStatus === "published").length,
        totalBookings: hotelBookings.length,
        pendingBookings: hotelBookings.filter((b) => b.providerConfirmed === 0).length,
        totalRevenue: calculateRevenue(hotelBookings),
        avgRating: calculateAvgRating(hotels),
        link: "/supplier/service/hotel",
      },
      {
        type: "restaurant",
        icon: Utensils,
        color: "text-amber-600",
        bgColor: "bg-amber-100 dark:bg-amber-900/30",
        totalItems: restaurants.length,
        publishedItems: restaurants.filter((r) => r.restaurantStatus === "published").length,
        totalBookings: restaurantBookings.length,
        pendingBookings: restaurantBookings.filter((b) => b.providerConfirmed === 0).length,
        totalRevenue: calculateRevenue(restaurantBookings),
        avgRating: calculateAvgRating(restaurants),
        link: "/supplier/service/restaurant",
      },
      {
        type: "attraction",
        icon: MapPin,
        color: "text-red-600",
        bgColor: "bg-red-100 dark:bg-red-900/30",
        totalItems: attractions.length,
        publishedItems: attractions.filter((a) => a.attractionStatus === "published").length,
        totalBookings: attractionBookings.length,
        pendingBookings: attractionBookings.filter((b) => b.providerConfirmed === 0).length,
        totalRevenue: calculateRevenue(attractionBookings),
        avgRating: calculateAvgRating(attractions),
        link: "/supplier/service/attraction",
      },
    ];
  }, [tours, tourBookings, hotels, hotelBookings, restaurants, restaurantBookings, attractions, attractionBookings]);

  // Total stats
  const totalStats = useMemo(() => {
    const allBookings = [...tourBookings, ...hotelBookings, ...restaurantBookings, ...attractionBookings];
    const confirmedBookings = allBookings.filter((b) => b.providerConfirmed === 1);
    const pendingBookings = allBookings.filter((b) => b.providerConfirmed === 0);

    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();
    const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear;

    const currentMonthRevenue = confirmedBookings
      .filter((b) => {
        if (!b.createdAt) return false;
        const date = new Date(b.createdAt);
        return date.getMonth() === currentMonth && date.getFullYear() === currentYear;
      })
      .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

    const lastMonthRevenue = confirmedBookings
      .filter((b) => {
        if (!b.createdAt) return false;
        const date = new Date(b.createdAt);
        return date.getMonth() === lastMonth && date.getFullYear() === lastMonthYear;
      })
      .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

    const revenueGrowth =
      lastMonthRevenue > 0
        ? ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100
        : currentMonthRevenue > 0
        ? 100
        : 0;

    const today = new Date().toISOString().split("T")[0];
    const todayBookings = allBookings.filter((b) => {
      const bookingDate = b.createdAt?.split("T")[0];
      return bookingDate === today;
    }).length;

    return {
      totalServices: tours.length + hotels.length + restaurants.length + attractions.length,
      publishedServices:
        tours.filter((t) => t.tourStatus === "published").length +
        hotels.filter((h) => h.hotelStatus === "published").length +
        restaurants.filter((r) => r.restaurantStatus === "published").length +
        attractions.filter((a) => a.attractionStatus === "published").length,
      totalBookings: allBookings.length,
      pendingBookings: pendingBookings.length,
      confirmedBookings: confirmedBookings.length,
      todayBookings,
      totalRevenue: confirmedBookings.reduce((sum, b) => sum + (b.totalPrice || 0), 0),
      currentMonthRevenue,
      revenueGrowth,
    };
  }, [tours, hotels, restaurants, attractions, tourBookings, hotelBookings, restaurantBookings, attractionBookings]);

  // Recent bookings
  const recentBookings: RecentBooking[] = useMemo(() => {
    const getServiceName = (type: string, serviceId: number): string => {
      switch (type) {
        case "tour":
          return tours.find((t) => t.tourId === serviceId)?.title || `${t("tour_id_prefix")}${serviceId}`;
        case "hotel":
          return hotels.find((h) => h.hotelId === serviceId)?.title || `${t("hotel_id_prefix")}${serviceId}`;
        case "restaurant":
          return restaurants.find((r) => r.restaurantId === serviceId)?.title || `${t("restaurant_id_prefix")}${serviceId}`;
        case "attraction":
          return attractions.find((a) => a.attractionId === serviceId)?.title || `${t("attraction_id_prefix")}${serviceId}`;
        default:
          return `${t("service_id_prefix")}${serviceId}`;
      }
    };

    const allBookings: RecentBooking[] = [
      ...tourBookings.map((b) => ({
        id: b.bookingId!,
        type: "tour" as const,
        serviceName: getServiceName("tour", b.tourId),
        customerName: userCache.get(b.userId) || `${t("customer_id_prefix")}${b.userId}`,
        date: b.createdAt || "",
        amount: b.totalPrice || 0,
        status: b.bookingStatus || "pending",
        providerConfirmed: b.providerConfirmed || 0,
      })),
      ...hotelBookings.map((b) => ({
        id: b.bookingId!,
        type: "hotel" as const,
        serviceName: getServiceName("hotel", b.hotelId),
        customerName: userCache.get(b.userId) || `${t("customer_id_prefix")}${b.userId}`,
        date: b.createdAt || "",
        amount: b.totalPrice || 0,
        status: b.bookingStatus || "pending",
        providerConfirmed: b.providerConfirmed || 0,
      })),
      ...restaurantBookings.map((b) => ({
        id: b.bookingId!,
        type: "restaurant" as const,
        serviceName: getServiceName("restaurant", b.restaurantId),
        customerName: userCache.get(b.userId) || `${t("customer_id_prefix")}${b.userId}`,
        date: b.createdAt || "",
        amount: b.totalPrice || 0,
        status: b.bookingStatus || "pending",
        providerConfirmed: b.providerConfirmed || 0,
      })),
      ...attractionBookings.map((b) => ({
        id: b.bookingId!,
        type: "attraction" as const,
        serviceName: getServiceName("attraction", b.attractionId),
        customerName: userCache.get(b.userId) || `${t("customer_id_prefix")}${b.userId}`,
        date: b.createdAt || "",
        amount: b.totalPrice || 0,
        status: b.bookingStatus || "pending",
        providerConfirmed: b.providerConfirmed || 0,
      })),
    ];

    return allBookings
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .slice(0, 10);
  }, [tours, hotels, restaurants, attractions, tourBookings, hotelBookings, restaurantBookings, attractionBookings, userCache, t]); // Added 't' dependency

  // Revenue chart data (last 7 days)
  const revenueChartData: RevenueDataPoint[] = useMemo(() => {
    const data: RevenueDataPoint[] = [];
    const now = new Date();

    for (let i = 6; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split("T")[0];
      const dayLabel = date.toLocaleDateString("vi-VN", { weekday: "short", day: "numeric" });

      const tourRev = tourBookings
        .filter((b) => b.providerConfirmed === 1 && b.createdAt?.split("T")[0] === dateStr)
        .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

      const hotelRev = hotelBookings
        .filter((b) => b.providerConfirmed === 1 && b.createdAt?.split("T")[0] === dateStr)
        .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

      const restaurantRev = restaurantBookings
        .filter((b) => b.providerConfirmed === 1 && b.createdAt?.split("T")[0] === dateStr)
        .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

      const attractionRev = attractionBookings
        .filter((b) => b.providerConfirmed === 1 && b.createdAt?.split("T")[0] === dateStr)
        .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

      data.push({
        date: dayLabel,
        tour: tourRev,
        hotel: hotelRev,
        restaurant: restaurantRev,
        attraction: attractionRev,
      });
    }

    return data;
  }, [tourBookings, hotelBookings, restaurantBookings, attractionBookings]);

  // Booking distribution for pie chart
  const bookingDistribution = useMemo(() => {
    return [
      { name: t("tour"), value: tourBookings.length, color: "#10B981" },
      { name: t("hotel"), value: hotelBookings.length, color: "#3B82F6" },
      { name: t("restaurant"), value: restaurantBookings.length, color: "#F59E0B" },
      { name: t("attraction"), value: attractionBookings.length, color: "#EF4444" },
    ].filter((item) => item.value > 0);
  }, [tourBookings, hotelBookings, restaurantBookings, attractionBookings, t]);

  // Format currency
  const formatCurrency = (amount: number): string => {
    if (amount >= 1000000000) {
      return `${(amount / 1000000000).toFixed(1)}T đ`;
    } else if (amount >= 1000000) {
      return `${(amount / 1000000).toFixed(1)}Tr đ`;
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(0)}K đ`;
    }
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const formatFullCurrency = (amount: number): string => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
    }).format(amount);
  };

  // Format date
  const formatDate = (dateStr: string): string => {
    if (!dateStr) return "N/A";
    return new Date(dateStr).toLocaleDateString("vi-VN", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  // Get status badge
  const getStatusBadge = (providerConfirmed: number) => {
    switch (providerConfirmed) {
      case 1:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">
            <CheckCircle2 className="w-3 h-3" />
            {t("confirmed")}
          </span>
        );
      case 2:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400">
            <XCircle className="w-3 h-3" />
            {t("cancelled")}
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400">
            <Clock className="w-3 h-3" />
            {t("pending")}
          </span>
        );
    }
  };

  // Get type icon
  const getTypeIcon = (type: string) => {
    switch (type) {
      case "tour":
        return <Route className="w-4 h-4 text-emerald-600" />;
      case "hotel":
        return <Building2 className="w-4 h-4 text-blue-600" />;
      case "restaurant":
        return <Utensils className="w-4 h-4 text-amber-600" />;
      case "attraction":
        return <MapPin className="w-4 h-4 text-red-600" />;
      default:
        return <Package className="w-4 h-4" />;
    }
  };

  // Custom Tooltip
  interface TooltipPayloadEntry {
    color: string;
    name: string;
    value: number;
  }

  interface CustomTooltipProps {
    active?: boolean;
    payload?: TooltipPayloadEntry[];
    label?: string;
  }

  const CustomTooltip: React.FC<CustomTooltipProps> = ({ active, payload, label }) => {
    if (active && payload && payload.length) {
      return (
        <div
          className="theme-bg-card p-3 rounded-lg border theme-border shadow-lg"
          style={{
            backgroundColor: dark ? "#1f2937" : "#ffffff",
            border: `1px solid ${dark ? "#374151" : "#e5e7eb"}`,
          }}
        >
          <p className="theme-text-primary font-medium mb-2">{label}</p>
          {payload.map((entry: TooltipPayloadEntry, index: number) => (
            <p key={index} className="text-sm" style={{ color: entry.color }}>
              {entry.name}: {formatFullCurrency(entry.value)}
            </p>
          ))}
        </div>
      );
    }
    return null;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-t-transparent theme-border rounded-full animate-spin mx-auto mb-4 border-t-emerald-500"></div>
          <p className="theme-text-secondary">{t("loading")}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold theme-text-primary">
            {t("dashboard")}
          </h1>
          <p className="theme-text-secondary mt-1">
            {t("welcome_back")}, {provider?.companyName || t("provider_profile")}
          </p>
        </div>
        <button
          onClick={handleRefresh}
          disabled={refreshing}
          className="flex items-center gap-2 px-4 py-2 rounded-lg theme-bg-secondary hover:theme-bg-tertiary transition-colors"
        >
          <RefreshCw className={`w-4 h-4 ${refreshing ? "animate-spin" : ""}`} />
          <span className="hidden sm:inline">{t("refresh")}</span>
        </button>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="theme-bg-card p-4 rounded-xl border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-emerald-100 dark:bg-emerald-900/30">
              <Package className="w-5 h-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-2xl font-bold theme-text-primary">{totalStats.publishedServices}</p>
              <p className="text-sm theme-text-secondary">{t("published_services")}</p>
            </div>
          </div>
        </div>

        <div className="theme-bg-card p-4 rounded-xl border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-blue-100 dark:bg-blue-900/30">
              <Calendar className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold theme-text-primary">{totalStats.pendingBookings}</p>
              <p className="text-sm theme-text-secondary">{t("pending_bookings_all")}</p>
            </div>
          </div>
        </div>

        <div className="theme-bg-card p-4 rounded-xl border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-amber-100 dark:bg-amber-900/30">
              <DollarSign className="w-5 h-5 text-amber-600" />
            </div>
            <div>
              <p className="text-2xl font-bold theme-text-primary">{formatCurrency(totalStats.currentMonthRevenue)}</p>
              <p className="text-sm theme-text-secondary">{t("current_month_revenue")}</p>
            </div>
          </div>
          {totalStats.revenueGrowth !== 0 && (
            <div className={`flex items-center gap-1 mt-2 text-sm ${totalStats.revenueGrowth > 0 ? "text-emerald-600" : "text-red-600"}`}>
              {totalStats.revenueGrowth > 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
              <span>{totalStats.revenueGrowth > 0 ? "+" : ""}{totalStats.revenueGrowth.toFixed(1)}%</span>
              <span className="theme-text-secondary">{t("vs_last_month")}</span>
            </div>
          )}
        </div>

        <div className="theme-bg-card p-4 rounded-xl border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-purple-100 dark:bg-purple-900/30">
              <Users className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <p className="text-2xl font-bold theme-text-primary">{totalStats.todayBookings}</p>
              <p className="text-sm theme-text-secondary">{t("today_bookings")}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Service Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {serviceSummaries.map((service) => (
          <Link
            key={service.type}
            to={service.link}
            className="theme-bg-card p-5 rounded-xl border theme-border hover:shadow-lg transition-all duration-300 group"
          >
            <div className="flex items-center justify-between mb-4">
              <div className={`p-3 rounded-xl ${service.bgColor}`}>
                <service.icon className={`w-6 h-6 ${service.color}`} />
              </div>
              <ChevronRight className="w-5 h-5 theme-text-secondary group-hover:theme-text-primary transition-colors" />
            </div>

            <h3 className="text-lg font-semibold theme-text-primary mb-3 capitalize">
              {t(service.type)}
            </h3>

            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="theme-text-secondary">{t("total_items")}:</span>
                <span className="font-medium theme-text-primary">{service.totalItems}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="theme-text-secondary">{t("published")}:</span>
                <span className="font-medium text-emerald-600">{service.publishedItems}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="theme-text-secondary">{t("bookings")}:</span>
                <span className="font-medium theme-text-primary">{service.totalBookings}</span>
              </div>
              {service.pendingBookings > 0 && (
                <div className="flex justify-between text-sm">
                  <span className="theme-text-secondary">{t("pending")}:</span>
                  <span className="font-medium text-amber-600">{service.pendingBookings}</span>
                </div>
              )}
              <div className="flex justify-between text-sm pt-2 border-t theme-border">
                <span className="theme-text-secondary">{t("revenue")}:</span>
                <span className="font-semibold text-emerald-600">{formatCurrency(service.totalRevenue)}</span>
              </div>
              {service.avgRating > 0 && (
                <div className="flex justify-between text-sm">
                  <span className="theme-text-secondary">{t("rating")}:</span>
                  <span className="flex items-center gap-1 font-medium theme-text-primary">
                    <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                    {service.avgRating.toFixed(1)}
                  </span>
                </div>
              )}
            </div>
          </Link>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue Chart */}
        <div className="lg:col-span-2 theme-bg-card p-6 rounded-xl border theme-border">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold theme-text-primary flex items-center gap-2">
              <BarChart3 className="w-5 h-5" />
              {t("revenue_chart")}
            </h2>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={revenueChartData}>
              <CartesianGrid strokeDasharray="3 3" stroke={dark ? "#374151" : "#e5e7eb"} />
              <XAxis dataKey="date" tick={{ fill: dark ? "#9ca3af" : "#6b7280", fontSize: 12 }} />
              <YAxis
                tick={{ fill: dark ? "#9ca3af" : "#6b7280", fontSize: 12 }}
                tickFormatter={(value) => formatCurrency(value)}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Bar dataKey="tour" name={t("tour")} fill="#10B981" radius={[4, 4, 0, 0]} />
              <Bar dataKey="hotel" name={t("hotel")} fill="#3B82F6" radius={[4, 4, 0, 0]} />
              <Bar dataKey="restaurant" name={t("restaurant")} fill="#F59E0B" radius={[4, 4, 0, 0]} />
              <Bar dataKey="attraction" name={t("attraction")} fill="#EF4444" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Booking Distribution */}
        <div className="theme-bg-card p-6 rounded-xl border theme-border">
          <h2 className="text-lg font-semibold theme-text-primary mb-6">
            {t("booking_distribution")}
          </h2>
          {bookingDistribution.length > 0 ? (
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={bookingDistribution}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  dataKey="value"
                  label={({ name, percent }) => `${name}: ${(Number(percent || 0) * 100).toFixed(0)}%`}
                  labelLine={false}
                >
                  {bookingDistribution.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip formatter={(value: number) => [`${value} ${t("bookings")}`, ""]} />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-[250px] theme-text-secondary">
              {t("no_bookings")}
            </div>
          )}
          <div className="grid grid-cols-2 gap-2 mt-4">
            {bookingDistribution.map((item) => (
              <div key={item.name} className="flex items-center gap-2 text-sm">
                <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }}></div>
                <span className="theme-text-secondary">{item.name}:</span>
                <span className="font-medium theme-text-primary">{item.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent Bookings */}
      <div className="theme-bg-card p-6 rounded-xl border theme-border">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-lg font-semibold theme-text-primary flex items-center gap-2">
            <Calendar className="w-5 h-5" />
            {t("recent_bookings")}
          </h2>
          <span className="text-sm theme-text-secondary">
            {t("total")}: {totalStats.totalBookings} {t("bookings")}
          </span>
        </div>

        {recentBookings.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b theme-border">
                  <th className="text-left py-3 px-4 text-sm font-medium theme-text-secondary">{t("type")}</th>
                  <th className="text-left py-3 px-4 text-sm font-medium theme-text-secondary">{t("service")}</th>
                  <th className="text-left py-3 px-4 text-sm font-medium theme-text-secondary">{t("customer")}</th>
                  <th className="text-left py-3 px-4 text-sm font-medium theme-text-secondary">{t("date")}</th>
                  <th className="text-right py-3 px-4 text-sm font-medium theme-text-secondary">{t("amount")}</th>
                  <th className="text-center py-3 px-4 text-sm font-medium theme-text-secondary">{t("status")}</th>
                  <th className="text-center py-3 px-4 text-sm font-medium theme-text-secondary">{t("action")}</th>
                </tr>
              </thead>
              <tbody>
                {recentBookings.map((booking) => (
                  <tr key={`${booking.type}-${booking.id}`} className="border-b theme-border hover:theme-bg-secondary/50 transition-colors">
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-2">
                        {getTypeIcon(booking.type)}
                        <span className="text-sm capitalize theme-text-secondary">{booking.type}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <span className="text-sm font-medium theme-text-primary line-clamp-1">{booking.serviceName}</span>
                    </td>
                    <td className="py-3 px-4">
                      <span className="text-sm theme-text-secondary">{booking.customerName}</span>
                    </td>
                    <td className="py-3 px-4">
                      <span className="text-sm theme-text-secondary">{formatDate(booking.date)}</span>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <span className="text-sm font-medium theme-text-primary">{formatFullCurrency(booking.amount)}</span>
                    </td>
                    <td className="py-3 px-4 text-center">
                      {getStatusBadge(booking.providerConfirmed)}
                    </td>
                    <td className="py-3 px-4 text-center">
                      <button
                        onClick={() => navigate(`/supplier/service/${booking.type}/bookings/${booking.id}`)}
                        className="inline-flex items-center gap-1 px-3 py-1 text-sm rounded-lg theme-bg-secondary hover:theme-bg-tertiary transition-colors"
                      >
                        <Eye className="w-4 h-4" />
                        {t("view")}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-12 theme-text-secondary">
            <Calendar className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>{t("no_bookings_yet")}</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default SupplierHomePage;
