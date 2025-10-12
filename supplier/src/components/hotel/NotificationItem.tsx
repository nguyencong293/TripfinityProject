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
  | "price_alert";
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

export default NotificationItem;
