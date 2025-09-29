import React, { useState } from "react";
import {
  Calendar,
  Plus,
  DollarSign,
  Star,
  CreditCard,
  Package,
  Bell,
  MessageSquare,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  Clock,
  FileText,
  ChevronDown,
  X,
  ExternalLink,
} from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
} from "recharts";
import { useTheme } from "../../hooks/useTheme";
import { useLanguage } from "../../hooks/useLanguage";

// TypeScript interfaces
interface SparklineDataPoint {
  value: number;
  index: number;
}

interface KPIDataItem {
  key: string;
  value: number;
  change: number;
  trend: "up" | "down" | "stable";
  sparklineData: number[];
  icon: React.ComponentType<{ className?: string }>;
  color: string;
}

interface RevenueDataPoint {
  day: string;
  tour: number;
  hotel: number;
  restaurant: number;
  attraction: number;
}

interface BookingTypeData {
  name: string;
  value: number;
  color: string;
}

interface Activity {
  id: string;
  type: string;
  title: string;
  description: string;
  timestamp: string;
  link: string;
  icon: React.ComponentType<{ className?: string }>;
  color: string;
}

interface Alert {
  id: string;
  type: string;
  title: string;
  description: string;
  priority: "urgent" | "high" | "medium";
  link: string;
  icon: React.ComponentType<{ className?: string }>;
}

interface ProviderInfo {
  logo: string;
  name: string;
  currentBalance: number;
  currency: string;
}

interface QuickLink {
  key: string;
  icon: React.ComponentType<{ className?: string }>;
  link: string;
}

const SupplierHomePage: React.FC = () => {
  const { dark } = useTheme();
  const { t } = useLanguage();
  const [selectedPeriod, setSelectedPeriod] = useState<string>("30days");
  const [showQuickActions, setShowQuickActions] = useState<boolean>(false);
  const [dismissedAlerts, setDismissedAlerts] = useState<string[]>([]);
  const [accountStatus] = useState<"approved" | "pending" | "rejected">(
    "pending"
  );

  // Mock data - Provider info
  const providerInfo: ProviderInfo = {
    logo: "/logo.png",
    name: "TripFinity Travel Co.",
    currentBalance: 45250000, // VND
    currency: "VND",
  };

  // Sample KPI data with sparklines
  const kpiData: KPIDataItem[] = [
    {
      key: "today_bookings",
      value: 8,
      change: 12.5,
      trend: "up",
      sparklineData: [3, 5, 4, 6, 7, 5, 8],
      icon: Calendar,
      color: "theme-bg-info",
    },
    {
      key: "upcoming_bookings",
      value: 24,
      change: 8.3,
      trend: "up",
      sparklineData: [18, 20, 19, 22, 21, 23, 24],
      icon: Clock,
      color: "theme-bg-warning",
    },
    {
      key: "monthly_revenue",
      value: 125500000, // VND
      change: 15.7,
      trend: "up",
      sparklineData: [95, 105, 110, 115, 118, 122, 125],
      icon: DollarSign,
      color: "theme-bg-success",
    },
    {
      key: "pending_payouts",
      value: 12300000, // VND
      change: -2.1,
      trend: "down",
      sparklineData: [15, 14, 13, 12, 13, 12, 12],
      icon: CreditCard,
      color: "theme-bg-secondary",
    },
    {
      key: "open_tickets",
      value: 3,
      change: 0,
      trend: "stable",
      sparklineData: [4, 3, 4, 3, 3, 3, 3],
      icon: Bell,
      color: "theme-bg-error",
    },
    {
      key: "new_messages",
      value: 7,
      change: 16.7,
      trend: "up",
      sparklineData: [4, 5, 6, 5, 6, 6, 7],
      icon: MessageSquare,
      color: "theme-bg-info",
    },
  ];

  // Revenue chart data (last 30 days)
  const revenueData: RevenueDataPoint[] = [
    {
      day: "1",
      tour: 2500000,
      hotel: 1800000,
      restaurant: 800000,
      attraction: 400000,
    },
    {
      day: "2",
      tour: 1800000,
      hotel: 2200000,
      restaurant: 600000,
      attraction: 300000,
    },
    {
      day: "3",
      tour: 3200000,
      hotel: 1500000,
      restaurant: 900000,
      attraction: 500000,
    },
    {
      day: "4",
      tour: 2100000,
      hotel: 1900000,
      restaurant: 700000,
      attraction: 350000,
    },
    {
      day: "5",
      tour: 2800000,
      hotel: 2100000,
      restaurant: 800000,
      attraction: 450000,
    },
    {
      day: "6",
      tour: 3100000,
      hotel: 1700000,
      restaurant: 850000,
      attraction: 420000,
    },
    {
      day: "7",
      tour: 2700000,
      hotel: 2000000,
      restaurant: 750000,
      attraction: 380000,
    },
    {
      day: "8",
      tour: 3300000,
      hotel: 1600000,
      restaurant: 900000,
      attraction: 500000,
    },
    {
      day: "9",
      tour: 2400000,
      hotel: 2300000,
      restaurant: 650000,
      attraction: 320000,
    },
    {
      day: "10",
      tour: 2900000,
      hotel: 1800000,
      restaurant: 800000,
      attraction: 450000,
    },
  ];

  // Bookings by type pie chart
  const bookingsTypeData: BookingTypeData[] = [
    { name: "tour", value: 35, color: "#10B981" },
    { name: "hotel", value: 28, color: "#3B82F6" },
    { name: "restaurant", value: 22, color: "#F59E0B" },
    { name: "attraction", value: 15, color: "#EF4444" },
  ];

  // Recent activities
  const recentActivities: Activity[] = [
    {
      id: "1",
      type: "new_booking",
      title: "Đặt tour Hạ Long Bay",
      description: "Nguyễn Văn A - 2 người - 15/10/2025",
      timestamp: "2 hours ago",
      link: "/bookings/1",
      icon: Calendar,
      color: "theme-text-success",
    },
    {
      id: "2",
      type: "refund_processed",
      title: "Hoàn tiền thành công",
      description: "Booking #2024 - 1,500,000 VND",
      timestamp: "4 hours ago",
      link: "/transactions/2024",
      icon: CreditCard,
      color: "theme-text-info",
    },
    {
      id: "3",
      type: "document_approved",
      title: "Tài liệu KYC đã được duyệt",
      description: "Giấy phép kinh doanh mới",
      timestamp: "1 day ago",
      link: "/documents",
      icon: FileText,
      color: "theme-text-success",
    },
    {
      id: "4",
      type: "webhook_failed",
      title: "Webhook delivery failed",
      description: "Payment confirmation endpoint",
      timestamp: "2 days ago",
      link: "/webhooks",
      icon: AlertTriangle,
      color: "theme-text-error",
    },
  ];

  // Alerts and tasks
  const alerts: Alert[] = [
    {
      id: "low_inventory_1",
      type: "low_inventory",
      title: "Hạ Long Bay Day Tour",
      description: "Chỉ còn 2 chỗ cho ngày 20/10/2025",
      priority: "high",
      link: "/listings/123",
      icon: Package,
    },
    {
      id: "hold_expiring_1",
      type: "hold_expiring",
      title: "Giữ chỗ #5678 sắp hết hạn",
      description: "Hết hạn trong 2 giờ nữa",
      priority: "urgent",
      link: "/bookings/5678",
      icon: Clock,
    },
    {
      id: "pending_kyc_1",
      type: "pending_kyc",
      title: "Tài liệu KYC chờ bổ sung",
      description: "Thiếu ảnh CCCD mặt sau",
      priority: "medium",
      link: "/documents/kyc",
      icon: FileText,
    },
  ];

  // Quick links data
  const quickLinks: QuickLink[] = [
    { key: "go_to_listings", icon: Package, link: "/listings" },
    { key: "bookings_inbox", icon: Calendar, link: "/bookings" },
    { key: "calendar", icon: Calendar, link: "/calendar" },
    { key: "messages", icon: MessageSquare, link: "/messages" },
    { key: "payouts", icon: CreditCard, link: "/payouts" },
  ];

  // Format currency
  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
    }).format(amount);
  };

  // Format number with units
  const formatValue = (key: string, value: number): string => {
    if (key === "monthly_revenue" || key === "pending_payouts") {
      return formatCurrency(value);
    }
    return value.toString();
  };

  // KPI Card Component
  const KPICard: React.FC<{ item: KPIDataItem }> = ({ item }) => (
    <div className="theme-bg-card p-6 rounded-2xl border theme-border hover:shadow-lg transition-all duration-300">
      <div className="flex items-center justify-between mb-4">
        <div className={`p-3 rounded-xl ${item.color}`}>
          <item.icon className="w-6 h-6" />
        </div>
        <div className="flex items-center text-sm font-medium">
          {item.trend === "up" && (
            <>
              <TrendingUp className="w-4 h-4 theme-text-success mr-1" />
              <span className="theme-text-success">+{item.change}%</span>
            </>
          )}
          {item.trend === "down" && (
            <>
              <TrendingDown className="w-4 h-4 theme-text-error mr-1" />
              <span className="theme-text-error">{item.change}%</span>
            </>
          )}
          {item.trend === "stable" && (
            <span className="theme-text-secondary">0%</span>
          )}
        </div>
      </div>
      <h3 className="theme-text-primary text-2xl font-bold mb-1">
        {formatValue(item.key, item.value)}
      </h3>
      <p className="theme-text-secondary text-sm mb-3">{t(item.key)}</p>

      {/* Mini Sparkline */}
      <div className="h-8">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart
            data={item.sparklineData.map(
              (value: number, index: number): SparklineDataPoint => ({
                value,
                index,
              })
            )}
          >
            <Line
              type="monotone"
              dataKey="value"
              stroke={
                item.trend === "up"
                  ? "#10B981"
                  : item.trend === "down"
                  ? "#EF4444"
                  : "#6B7280"
              }
              strokeWidth={2}
              dot={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );

  // Activity Item Component
  const ActivityItem: React.FC<{ activity: Activity }> = ({ activity }) => (
    <div className="flex items-start gap-4 p-4 theme-bg-card rounded-lg border theme-border hover:shadow-md transition-all duration-200">
      <div className="p-2 theme-bg-secondary rounded-lg">
        <activity.icon className={`w-4 h-4 ${activity.color}`} />
      </div>
      <div className="flex-1">
        <h4 className="font-medium theme-text-primary">{activity.title}</h4>
        <p className="text-sm theme-text-secondary">{activity.description}</p>
        <p className="text-xs theme-text-secondary mt-1">
          {activity.timestamp}
        </p>
      </div>
      <button className="p-1 hover:theme-bg-secondary rounded transition-colors">
        <ExternalLink className="w-4 h-4 theme-text-secondary" />
      </button>
    </div>
  );

  // Alert Item Component
  const AlertItem: React.FC<{ alert: Alert }> = ({ alert }) => {
    if (dismissedAlerts.includes(alert.id)) return null;

    const priorityColors: Record<Alert["priority"], string> = {
      urgent: "border-l-red-500 theme-bg-error",
      high: "border-l-orange-500 theme-bg-warning",
      medium: "border-l-yellow-500 bg-yellow-50 dark:bg-yellow-900/20",
    };

    return (
      <div
        className={`p-4 rounded-lg border-l-4 ${
          priorityColors[alert.priority]
        } theme-border`}
      >
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-3">
            <alert.icon className="w-5 h-5 theme-text-error mt-0.5" />
            <div>
              <h4 className="font-medium theme-text-primary">{alert.title}</h4>
              <p className="text-sm theme-text-secondary">
                {alert.description}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button className="text-xs theme-text-brand hover:underline">
              {t("view_details")}
            </button>
            <button
              onClick={() => setDismissedAlerts([...dismissedAlerts, alert.id])}
              className="p-1 hover:theme-bg-secondary rounded transition-colors"
            >
              <X className="w-4 h-4 theme-text-secondary" />
            </button>
          </div>
        </div>
      </div>
    );
  };

  // Custom Tooltip Component for Charts
  const CustomTooltip: React.FC<any> = ({ active, payload, label }) => {
    if (active && payload && payload.length) {
      return (
        <div
          className="theme-bg-card p-3 rounded-lg border theme-border shadow-lg"
          style={{
            backgroundColor: dark ? "#1f2937" : "#ffffff",
            border: `1px solid ${dark ? "#374151" : "#e5e7eb"}`,
          }}
        >
          <p className="theme-text-primary font-medium">{`Ngày ${label}`}</p>
          {payload.map((entry: any, index: number) => (
            <p key={index} className="text-sm" style={{ color: entry.color }}>
              {`${t(entry.dataKey)}: ${formatCurrency(entry.value)}`}
            </p>
          ))}
        </div>
      );
    }
    return null;
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Account Status Banner */}
      {accountStatus !== "approved" && (
        <div className="theme-bg-warning p-4 rounded-2xl border-l-4 border-l-orange-500">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <AlertTriangle className="w-6 h-6 theme-text-warning" />
              <div>
                <h3 className="font-semibold theme-text-primary">
                  {t("account_inactive")}
                </h3>
                <p className="text-sm theme-text-secondary">
                  {t("account_inactive_desc")}
                </p>
              </div>
            </div>
            <button className="btn-primary px-4 py-2">
              {t("view_details")}
            </button>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center shadow-sm border border-gray-100 p-2">
            <img
              src={providerInfo.logo}
              alt={providerInfo.name}
              className="w-8 h-8 object-contain"
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.style.display = "none";
                const nextElement = target.nextElementSibling as HTMLElement;
                if (nextElement) {
                  nextElement.classList.remove("hidden");
                }
              }}
            />
            <Package className="w-6 h-6 theme-text-secondary hidden" />
          </div>
          <div>
            <h1 className="text-2xl font-bold theme-text-primary">
              {providerInfo.name}
            </h1>
            <p className="theme-text-secondary">
              {t("current_balance")}:
              <span className="font-semibold theme-text-success ml-2">
                {formatCurrency(providerInfo.currentBalance)}
              </span>
            </p>
          </div>
        </div>

        <div className="relative">
          <button
            onClick={() => setShowQuickActions(!showQuickActions)}
            className="btn-primary px-6 py-3 flex items-center gap-2"
          >
            <Plus className="w-5 h-5" />
            {t("quick_actions")}
            <ChevronDown className="w-4 h-4" />
          </button>

          {showQuickActions && (
            <div className="absolute right-0 top-full mt-2 w-64 theme-bg-card border theme-border rounded-2xl shadow-lg py-2 z-50">
              <button className="w-full flex items-center gap-3 px-4 py-3 hover:theme-bg-secondary transition-colors text-left">
                <Plus className="w-5 h-5 theme-text-primary" />
                <span className="theme-text-primary">
                  {t("create_listing")}
                </span>
              </button>
              <button className="w-full flex items-center gap-3 px-4 py-3 hover:theme-bg-secondary transition-colors text-left">
                <Star className="w-5 h-5 theme-text-primary" />
                <span className="theme-text-primary">{t("new_promo")}</span>
              </button>
              <button className="w-full flex items-center gap-3 px-4 py-3 hover:theme-bg-secondary transition-colors text-left">
                <CreditCard className="w-5 h-5 theme-text-primary" />
                <span className="theme-text-primary">
                  {t("request_payout")}
                </span>
              </button>
            </div>
          )}
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {kpiData.map((item: KPIDataItem) => (
          <KPICard key={item.key} item={item} />
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue Chart */}
        <div className="theme-bg-card p-6 rounded-2xl border theme-border">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold theme-text-primary">
              {t("revenue_chart_title")}
            </h2>
            <select
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
              className="px-3 py-1 rounded-lg theme-bg-secondary theme-text-primary border theme-border text-sm focus-ring-primary"
            >
              <option value="7days">{t("7days")}</option>
              <option value="30days">{t("30days")}</option>
              <option value="month">{t("month")}</option>
            </select>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={revenueData}>
              <defs>
                <linearGradient
                  id="revenueGradient"
                  x1="0"
                  y1="0"
                  x2="0"
                  y2="1"
                >
                  <stop offset="5%" stopColor="#10B981" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid
                strokeDasharray="3 3"
                stroke={dark ? "#374151" : "#e5e7eb"}
              />
              <XAxis
                dataKey="day"
                tick={{ fill: dark ? "#9ca3af" : "#6b7280" }}
              />
              <YAxis tick={{ fill: dark ? "#9ca3af" : "#6b7280" }} />
              <Tooltip content={<CustomTooltip />} />
              <Area
                type="monotone"
                dataKey="tour"
                stackId="1"
                stroke="#10B981"
                fill="url(#revenueGradient)"
              />
              <Area
                type="monotone"
                dataKey="hotel"
                stackId="1"
                stroke="#3B82F6"
                fill="#3B82F6"
                fillOpacity={0.2}
              />
              <Area
                type="monotone"
                dataKey="restaurant"
                stackId="1"
                stroke="#F59E0B"
                fill="#F59E0B"
                fillOpacity={0.2}
              />
              <Area
                type="monotone"
                dataKey="attraction"
                stackId="1"
                stroke="#EF4444"
                fill="#EF4444"
                fillOpacity={0.2}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Bookings by Type Pie Chart */}
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={bookingsTypeData}
              cx="50%"
              cy="50%"
              outerRadius={80}
              dataKey="value"
              label={({ name, value }) => `${t(name)}: ${value}%`}
            >
              {bookingsTypeData.map((entry: BookingTypeData, index: number) => (
                <Cell key={`cell-${index}`} fill={entry.color} />
              ))}
            </Pie>
            <Tooltip
              formatter={(value: number, name: string) => [
                `${value}%`,
                t(name),
              ]}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      {/* Bottom Row - Activities and Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Activity */}
        <div className="theme-bg-card p-6 rounded-2xl border theme-border">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold theme-text-primary">
              {t("recent_activity")}
            </h2>
            <button className="text-sm theme-text-brand hover:underline">
              View all
            </button>
          </div>
          <div className="space-y-4">
            {recentActivities.map((activity: Activity) => (
              <ActivityItem key={activity.id} activity={activity} />
            ))}
          </div>
        </div>

        {/* Alerts & Tasks */}
        <div className="theme-bg-card p-6 rounded-2xl border theme-border">
          <h2 className="text-xl font-semibold theme-text-primary mb-6">
            {t("alerts_tasks")}
          </h2>
          <div className="space-y-4">
            {alerts
              .filter((alert: Alert) => !dismissedAlerts.includes(alert.id))
              .map((alert: Alert) => (
                <AlertItem key={alert.id} alert={alert} />
              ))}
            {alerts.filter(
              (alert: Alert) => !dismissedAlerts.includes(alert.id)
            ).length === 0 && (
              <p className="text-center theme-text-secondary py-8">
                Không có cảnh báo nào
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Quick Links */}
      <div className="theme-bg-card p-6 rounded-2xl border theme-border">
        <h2 className="text-xl font-semibold theme-text-primary mb-6">
          {t("quick_links")}
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
          {quickLinks.map((item: QuickLink) => (
            <button
              key={item.key}
              className="flex flex-col items-center gap-3 p-4 rounded-xl hover:theme-bg-secondary transition-all duration-200 group"
            >
              <div className="p-3 theme-bg-primary rounded-xl group-hover:scale-110 transition-transform duration-200">
                <item.icon className="w-6 h-6 theme-text-button" />
              </div>
              <span className="text-sm font-medium theme-text-primary text-center">
                {t(item.key)}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Click outside to close dropdown */}
      {showQuickActions && (
        <div
          className="fixed inset-0 z-40"
          onClick={() => setShowQuickActions(false)}
        />
      )}
    </div>
  );
};

export default SupplierHomePage;
