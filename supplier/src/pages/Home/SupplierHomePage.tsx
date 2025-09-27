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

const SupplierHomePage: React.FC = () => {
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
      title: "Tạo dịch vụ mới",
      description:
        "Thêm sản phẩm du lịch hoặc dịch vụ mới cho khách hàng đặt bạn với ưu điểm nhanh booking",
      color: "bg-green-100 dark:bg-green-900/20",
      iconColor: "text-green-600 dark:text-green-400",
    },
    {
      icon: Star,
      title: "Xem và đánh giá",
      description:
        "Xem lại feedback và đánh giá về sản phẩm và dịch vụ bạn cung cấp",
      color: "bg-orange-100 dark:bg-orange-900/20",
      iconColor: "text-orange-600 dark:text-orange-400",
    },
    {
      icon: CreditCard,
      title: "Quản lý E-Ticket",
      description: "Theo dõi vé điện tử và các đơn đặt phòng hoàn thành",
      color: "bg-blue-100 dark:bg-blue-900/20",
      iconColor: "text-blue-600 dark:text-blue-400",
    },
  ];

  const StatCard = ({
    title,
    value,
    change,
    icon: Icon,
    color,
  }: {
    title: string;
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
      <p className="theme-text-secondary text-sm">{title}</p>
    </div>
  );

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Page Title */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold theme-text-primary">Trang chủ</h1>
          <p className="theme-text-secondary mt-1">
            Quản lý và theo dõi hoạt động kinh doanh của bạn
          </p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={selectedPeriod}
            onChange={(e) => setSelectedPeriod(e.target.value)}
            className="px-4 py-2 rounded-xl theme-bg-secondary theme-text-primary border theme-border"
          >
            <option value="today">Hôm nay</option>
            <option value="7days">7 ngày</option>
            <option value="30days">30 ngày gần đây</option>
            <option value="month">Tháng này</option>
          </select>
          <button className="btn-primary px-4 py-2">
            <Plus className="w-4 h-4 mr-2" />
            Thêm mới
          </button>
        </div>
      </div>
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <StatCard
          title="Dịch vụ đang hoạt động"
          value="24"
          change="7.9%"
          icon={Package}
          color="bg-green-100 dark:bg-green-900/20 text-green-600 dark:text-green-400"
        />
        <StatCard
          title="Booking mới hôm nay"
          value="24"
          change="18.2%"
          icon={Calendar}
          color="bg-blue-100 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400"
        />
        <StatCard
          title="Doanh thu tháng này"
          value="45.2M"
          change="12.5%"
          icon={DollarSign}
          color="bg-orange-100 dark:bg-orange-900/20 text-orange-600 dark:text-orange-400"
        />
      </div>
      {/* Revenue Chart */}
      <div className="theme-bg-card p-6 rounded-2xl border theme-border">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold theme-text-primary">
            Doanh thu 30 ngày gần đây
          </h2>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-2 text-sm theme-text-secondary">
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <span>Doanh thu</span>
            </div>
          </div>
        </div>
        <ResponsiveContainer width="100%" height={300}>
          <AreaChart data={revenueData}>
            <defs>
              <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#10B981" stopOpacity={0.3} />
                <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" className="opacity-30" />
            <XAxis
              dataKey="day"
              className="theme-text-secondary"
              axisLine={false}
              tickLine={false}
            />
            <YAxis
              className="theme-text-secondary"
              axisLine={false}
              tickLine={false}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: "var(--bg-card)",
                border: "1px solid var(--border)",
                borderRadius: "12px",
              }}
            />
            <Area
              type="monotone"
              dataKey="revenue"
              stroke="#10B981"
              strokeWidth={2}
              fill="url(#revenueGradient)"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
      {/* Quick Actions Section */}
      <div>
        <h2 className="text-xl font-semibold theme-text-primary mb-6">
          Thao tác nhanh
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {quickActions.map((action, index) => (
            <div
              key={index}
              className="theme-bg-card p-6 rounded-2xl border theme-border hover:shadow-lg transition-all duration-300 cursor-pointer"
            >
              <div className="flex items-start gap-4">
                <div className={`p-3 rounded-xl ${action.color}`}>
                  <action.icon className={`w-6 h-6 ${action.iconColor}`} />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold theme-text-primary mb-2">
                    {action.title}
                  </h3>
                  <p className="theme-text-secondary text-sm leading-relaxed">
                    {action.description}
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
