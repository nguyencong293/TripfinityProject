import React, { useState } from "react";
import {
  Calendar,
  Plus,
  DollarSign,
  Star,
  CreditCard,
  Package,
} from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { useTheme } from "../../hooks/useTheme";
import { useLanguage } from "../../hooks/useLanguage";

const SupplierHomePage: React.FC = () => {
  const { dark } = useTheme();
  const { t } = useLanguage();
  const [selectedPeriod, setSelectedPeriod] = useState("30days");

  // Sample data
  const revenueData = [
    { day: "1", revenue: 2500 },
    { day: "2", revenue: 1800 },
    { day: "3", revenue: 3200 },
    { day: "4", revenue: 2100 },
    { day: "5", revenue: 2800 },
    { day: "6", revenue: 3500 },
    { day: "7", revenue: 2200 },
    { day: "8", revenue: 4000 },
    { day: "9", revenue: 3100 },
    { day: "10", revenue: 2700 },
    { day: "11", revenue: 3800 },
    { day: "12", revenue: 2400 },
    { day: "13", revenue: 3600 },
    { day: "14", revenue: 4200 },
    { day: "15", revenue: 3900 },
    { day: "16", revenue: 2900 },
    { day: "17", revenue: 3400 },
    { day: "18", revenue: 4100 },
    { day: "19", revenue: 1900 },
    { day: "20", revenue: 2600 },
    { day: "21", revenue: 3700 },
    { day: "22", revenue: 4300 },
    { day: "23", revenue: 3200 },
    { day: "24", revenue: 2800 },
    { day: "25", revenue: 3500 },
    { day: "26", revenue: 4000 },
    { day: "27", revenue: 2300 },
    { day: "28", revenue: 3100 },
    { day: "29", revenue: 3800 },
    { day: "30", revenue: 4100 },
  ];

  const quickActions = [
    {
      icon: Plus,
      titleKey: "create_new_service",
      descriptionKey: "create_new_service_desc",
      color: "theme-bg-success",
      iconColor: "theme-text-success",
    },
    {
      icon: Star,
      titleKey: "view_reviews",
      descriptionKey: "view_reviews_desc",
      color: "theme-bg-warning",
      iconColor: "theme-text-warning",
    },
    {
      icon: CreditCard,
      titleKey: "manage_etickets",
      descriptionKey: "manage_etickets_desc",
      color: "theme-bg-info",
      iconColor: "theme-text-info",
    },
  ];

  const StatCard = ({
    titleKey,
    value,
    change,
    icon: Icon,
    color,
  }: {
    titleKey: string;
    value: string | number;
    change: string;
    icon: React.ElementType;
    color: string;
  }) => (
    <div className="theme-bg-card p-6 rounded-2xl border theme-border hover:shadow-lg transition-all duration-300">
      <div className="flex items-center justify-between mb-4">
        <div className={`p-3 rounded-xl ${color}`}>
          <Icon className="w-6 h-6" />
        </div>
        <div className="flex items-center text-sm font-medium theme-text-success">
          <span className="text-xs mr-1">↗</span>
          {change}
        </div>
      </div>
      <h3 className="theme-text-primary text-2xl font-bold mb-1">{value}</h3>
      <p className="theme-text-secondary text-sm">{t(titleKey)}</p>
    </div>
  );

  // Dynamic tooltip content based on theme
  const customTooltipStyle = {
    backgroundColor: dark ? "#1f2937" : "#ffffff",
    border: `1px solid ${dark ? "#374151" : "#e5e7eb"}`,
    borderRadius: "12px",
    color: dark ? "#f9fafb" : "#111827",
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Page Title */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold theme-text-primary">{t("home")}</h1>
          <p className="theme-text-secondary mt-1">{t("home_subtitle")}</p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={selectedPeriod}
            onChange={(e) => setSelectedPeriod(e.target.value)}
            className="px-4 py-2 rounded-xl theme-bg-card theme-text-primary border theme-border"
          >
            <option value="today">{t("today")}</option>
            <option value="7days">{t("7days")}</option>
            <option value="30days">{t("30days")}</option>
            <option value="month">{t("month")}</option>
          </select>
          <button className="btn-primary px-8 py-2 flex items-center gap-2">
            <Plus className="w-4 h-4" />
            {t("add_new")}
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <StatCard
          titleKey="active_services"
          value="24"
          change="7.9%"
          icon={Package}
          color="theme-bg-success"
        />
        <StatCard
          titleKey="new_bookings_today"
          value="24"
          change="18.2%"
          icon={Calendar}
          color="theme-bg-info"
        />
        <StatCard
          titleKey="monthly_revenue"
          value="45.2M"
          change="12.5%"
          icon={DollarSign}
          color="theme-bg-warning"
        />
      </div>

      {/* Revenue Chart */}
      <div className="theme-bg-card p-6 rounded-2xl border theme-border">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold theme-text-primary">
            {t("revenue_chart_title")}
          </h2>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-2 text-sm theme-text-secondary">
              <div className="w-3 h-3 rounded-full theme-bg-success"></div>
              <span>{t("revenue")}</span>
            </div>
          </div>
        </div>
        <ResponsiveContainer width="100%" height={300}>
          <AreaChart data={revenueData}>
            <defs>
              <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                <stop
                  offset="5%"
                  stopColor={dark ? "#10B981" : "#059669"}
                  stopOpacity={0.3}
                />
                <stop
                  offset="95%"
                  stopColor={dark ? "#10B981" : "#059669"}
                  stopOpacity={0}
                />
              </linearGradient>
            </defs>
            <CartesianGrid
              strokeDasharray="3 3"
              stroke={dark ? "#374151" : "#e5e7eb"}
              className="opacity-30"
            />
            <XAxis
              dataKey="day"
              className="theme-text-secondary"
              axisLine={false}
              tickLine={false}
              tick={{ fill: dark ? "#9ca3af" : "#6b7280" }}
            />
            <YAxis
              className="theme-text-secondary"
              axisLine={false}
              tickLine={false}
              tick={{ fill: dark ? "#9ca3af" : "#6b7280" }}
            />
            <Tooltip
              contentStyle={customTooltipStyle}
              labelStyle={{ color: dark ? "#f9fafb" : "#111827" }}
            />
            <Area
              type="monotone"
              dataKey="revenue"
              stroke={dark ? "#10B981" : "#059669"}
              strokeWidth={2}
              fill="url(#revenueGradient)"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      {/* Quick Actions Section */}
      <div>
        <h2 className="text-xl font-semibold theme-text-primary mb-6">
          {t("quick_actions")}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {quickActions.map((action, index) => (
            <div
              key={index}
              className="theme-bg-card p-6 rounded-2xl border theme-border hover:shadow-lg transition-all duration-300 cursor-pointer group"
            >
              <div className="flex items-start gap-4">
                <div
                  className={`p-3 rounded-xl ${action.color} group-hover:scale-110 transition-transform duration-200`}
                >
                  <action.icon className={`w-6 h-6 ${action.iconColor}`} />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold theme-text-primary mb-2">
                    {t(action.titleKey)}
                  </h3>
                  <p className="theme-text-secondary text-sm leading-relaxed">
                    {t(action.descriptionKey)}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default SupplierHomePage;
