import React from "react";
import { TrendingUp, TrendingDown } from "lucide-react";

export interface StatCardProps {
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

export default StatCard;
