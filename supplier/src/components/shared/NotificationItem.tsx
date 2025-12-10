import React from "react";
import {
  Calendar,
  MessageSquare,
  CheckCircle,
  Ticket,
  TrendingDown as PriceDown,
} from "lucide-react";

export type NotificationType =
  | "new_booking"
  | "new_review"
  | "payment_success"
  | "e_ticket_created"
  | "price_alert"
  | "service_hotel_new"
  | "service_hotel_update"
  | "service_hotel_booking"
  | "service_attraction_new"
  | "service_attraction_update"
  | "service_attraction_booking"
  | "service_restaurant_new"
  | "service_restaurant_update"
  | "service_restaurant_booking"
  | "service_tour_new"
  | "service_tour_update"
  | "service_tour_booking"
  | "payment_failed"
  | "payment_refund"
  | "system_alert"
  | "system_maintenance"
  | "promotion";

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  time: string;
  isNew: boolean;
}

export interface NotificationItemProps {
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
      className="w-full p-5 rounded-xl border theme-border theme-bg-card transition-all hover:shadow-md hover:border-blue-300 dark:hover:border-blue-600 min-h-[140px] flex flex-col"
    >
      <div className="flex gap-3 flex-1">
        <div
          className={`flex-shrink-0 p-2.5 rounded-lg ${getBg(notification.type)}`}
        >
          {getIcon(notification.type)}
        </div>
        <div className="flex-1 min-w-0 text-left flex flex-col">
          <div className="flex items-start justify-between gap-2 mb-2">
            <p className="text-sm font-semibold theme-text-primary line-clamp-1">
              {notification.title}
            </p>
            {notification.isNew && (
              <span className="flex-shrink-0 w-2 h-2 theme-bg-primary rounded-full" />
            )}
          </div>
          <p className="text-xs line-clamp-3 theme-text-secondary flex-1">
            {notification.message}
          </p>
          <p className="text-xs mt-3 theme-text-tertiary">
            {notification.time}
          </p>
        </div>
      </div>
    </button>
  );
};

export default NotificationItem;
