import { useEffect, useState, useCallback } from "react";
import { Bell, Check, CheckCheck, Trash2, ArrowLeft, Search, Filter } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useLanguage } from "../hooks/useLanguage";

interface Notification {
  notification_id: number;
  user_id: number;
  notification_type: string;
  category: string;
  title: string;
  content: string;
  is_read: boolean;
  read_at: string | null;
  sent_at: string;
  created_at: string;
}

const NotificationListPage = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  
  // Helper function to get category text
  const getCategoryText = useCallback((category: string): string => {
    const map: Record<string, string> = {
      service_hotel_new: t("notification_cat_hotel_new"),
      service_hotel_update: t("notification_cat_hotel_update"),
      service_hotel_booking: t("notification_cat_hotel_booking"),
      service_attraction_new: t("notification_cat_attraction_new"),
      service_attraction_update: t("notification_cat_attraction_update"),
      service_attraction_booking: t("notification_cat_attraction_booking"),
      service_restaurant_new: t("notification_cat_restaurant_new"),
      service_restaurant_update: t("notification_cat_restaurant_update"),
      service_restaurant_booking: t("notification_cat_restaurant_booking"),
      service_tour_new: t("notification_cat_tour_new"),
      service_tour_update: t("notification_cat_tour_update"),
      service_tour_booking: t("notification_cat_tour_booking"),
      payment_success: t("notification_cat_payment_success"),
      payment_failed: t("notification_cat_payment_failed"),
      system_alert: t("notification_cat_system_alert"),
      promotion: t("notification_cat_promotion"),
    };
    return map[category] || category;
  }, [t]);
  
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<number | null>(null); // Track which notification is being actioned
  const [markAllLoading, setMarkAllLoading] = useState(false);
  const [filter, setFilter] = useState<"all" | "unread">("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState<string>("all");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Get user from localStorage
  const getUserId = (): number | null => {
    const userStr = localStorage.getItem("user");
    if (!userStr) return null;
    const user = JSON.parse(userStr);
    return user.userId;
  };

  const fetchNotifications = useCallback(async () => {
    const userId = getUserId();
    if (!userId) return;

    setLoading(true);
    try {
      const endpoint =
        filter === "unread"
          ? `http://localhost:8080/api/notifications/user/${userId}/unread`
          : `http://localhost:8080/api/notifications/user/${userId}`;

      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setNotifications(data);
      }
    } catch (error) {
      console.error("Failed to fetch notifications:", error);
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    fetchNotifications();
  }, [fetchNotifications]);

  const markAsRead = async (notificationId: number) => {
    setActionLoading(notificationId);
    try {
      const response = await fetch(
        `http://localhost:8080/api/notifications/${notificationId}/read`,
        {
          method: "PATCH",
        }
      );

      if (response.ok) {
        setNotifications((prev) =>
          prev.map((n) =>
            n.notification_id === notificationId
              ? { ...n, is_read: true, read_at: new Date().toISOString() }
              : n
          )
        );
      }
    } catch (error) {
      console.error("Failed to mark as read:", error);
    } finally {
      setActionLoading(null);
    }
  };

  const markAllAsRead = async () => {
    const userId = getUserId();
    if (!userId) return;

    setMarkAllLoading(true);
    try {
      const response = await fetch(
        `http://localhost:8080/api/notifications/user/${userId}/read-all`,
        {
          method: "PATCH",
        }
      );

      if (response.ok) {
        fetchNotifications();
      }
    } catch (error) {
      console.error("Failed to mark all as read:", error);
    } finally {
      setMarkAllLoading(false);
    }
  };

  const deleteNotification = async (notificationId: number) => {
    setActionLoading(notificationId);
    try {
      const response = await fetch(
        `http://localhost:8080/api/notifications/${notificationId}`,
        {
          method: "DELETE",
        }
      );

      if (response.ok) {
        setNotifications((prev) =>
          prev.filter((n) => n.notification_id !== notificationId)
        );
      }
    } catch (error) {
      console.error("Failed to delete notification:", error);
    } finally {
      setActionLoading(null);
    }
  };

  const getCategoryBadge = (category: string) => {
    const badges: Record<string, { text: string; color: string }> = {
      service_hotel_new: { text: t("notification_cat_hotel_new"), color: "theme-bg-success theme-text-success" },
      service_hotel_update: { text: t("notification_cat_hotel_update"), color: "theme-bg-info theme-text-info" },
      service_hotel_booking: { text: t("notification_cat_hotel_booking"), color: "bg-light-primary/20 dark:bg-dark-primary/20 theme-text-primary" },
      service_attraction_new: { text: t("notification_cat_attraction_new"), color: "theme-bg-success theme-text-success" },
      service_attraction_update: { text: t("notification_cat_attraction_update"), color: "theme-bg-info theme-text-info" },
      service_attraction_booking: { text: t("notification_cat_attraction_booking"), color: "bg-light-primary/20 dark:bg-dark-primary/20 theme-text-primary" },
      service_restaurant_new: { text: t("notification_cat_restaurant_new"), color: "theme-bg-success theme-text-success" },
      service_restaurant_update: { text: t("notification_cat_restaurant_update"), color: "theme-bg-info theme-text-info" },
      service_restaurant_booking: { text: t("notification_cat_restaurant_booking"), color: "bg-light-primary/20 dark:bg-dark-primary/20 theme-text-primary" },
      service_tour_new: { text: t("notification_cat_tour_new"), color: "theme-bg-success theme-text-success" },
      service_tour_update: { text: t("notification_cat_tour_update"), color: "theme-bg-info theme-text-info" },
      service_tour_booking: { text: t("notification_cat_tour_booking"), color: "bg-light-primary/20 dark:bg-dark-primary/20 theme-text-primary" },
      payment_success: { text: t("notification_cat_payment_success"), color: "bg-light-primary/30 dark:bg-dark-primary/30 theme-text-primary" },
      payment_failed: { text: t("notification_cat_payment_failed"), color: "theme-bg-error theme-text-error" },
      system_alert: { text: t("notification_cat_system_alert"), color: "theme-bg-warning theme-text-warning" },
      promotion: { text: t("notification_cat_promotion"), color: "bg-light-primary/20 dark:bg-dark-primary/20 theme-text-primary" },
    };

    const badge = badges[category] || { text: t("notification_cat_default"), color: "bg-light-textSecondary/20 dark:bg-dark-textSecondary/20 theme-text-secondary" };
    return (
      <span className={`${badge.color} text-caption-mobile font-semibold px-2 py-1 rounded`}>
        {badge.text}
      </span>
    );
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 1) return t("notification_just_now");
    if (diffMins < 60) return `${diffMins} ${t("minutes_ago_suffix")}`;
    if (diffHours < 24) return `${diffHours} ${t("hours_ago_suffix")}`;
    if (diffDays < 7) return `${diffDays} ${t("days_ago_suffix")}`;

    return date.toLocaleDateString("vi-VN", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  };

  const filteredNotifications = notifications
    .filter((n) => {
      // Filter by read status
      if (filter === "unread" && n.is_read) return false;

      // Filter by category
      if (categoryFilter !== "all" && n.category !== categoryFilter) return false;

      // Filter by search query
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        return (
          n.title.toLowerCase().includes(query) ||
          n.content.toLowerCase().includes(query)
        );
      }

      return true;
    });

  const unreadCount = notifications.filter((n) => !n.is_read).length;

  // Pagination
  const totalPages = Math.ceil(filteredNotifications.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedNotifications = filteredNotifications.slice(
    startIndex,
    startIndex + itemsPerPage
  );

  // Reset to page 1 when filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [filter, searchQuery, categoryFilter]);

  // All available categories (hardcoded to always show all options)
  const allCategories = [
    "service_hotel_new",
    "service_hotel_update",
    "service_hotel_booking",
    "service_attraction_new",
    "service_attraction_update",
    "service_attraction_booking",
    "service_restaurant_new",
    "service_restaurant_update",
    "service_restaurant_booking",
    "service_tour_new",
    "service_tour_update",
    "service_tour_booking",
    "payment_success",
    "payment_failed",
    "system_alert",
    "promotion",
  ];
  
  // Get unique categories from actual notifications
  const existingCategories = Array.from(new Set(notifications.map((n) => n.category)));
  
  // Use all categories for dropdown, but merge with existing ones to not miss any
  const categories = Array.from(new Set([...allCategories, ...existingCategories]));

  return (
    <div className="container mx-auto px-6 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate(-1)}
            className="p-2 rounded-lg hover:theme-bg-secondary transition-colors"
            title={t("back")}
          >
            <ArrowLeft className="w-6 h-6 theme-text-secondary" />
          </button>
          <div>
            <h1 className="text-h3-mobile sm:text-h2-tablet lg:text-h1-desktop font-bold theme-text-primary flex items-center gap-2">
              <Bell className="w-8 h-8" />
              {t("notifications_title")}
            </h1>
            <p className="theme-text-secondary mt-1 text-body2-mobile sm:text-body1-tablet">
              {unreadCount > 0 ? `${t("notifications_count_unread").replace("{count}", String(unreadCount))}` : t("no_new_notifications")}
            </p>
          </div>
        </div>
        <div className="flex gap-3">
          {unreadCount > 0 && (
            <button
              onClick={markAllAsRead}
              disabled={markAllLoading}
              className="btn-primary px-4 py-2 flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {markAllLoading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                  {t("processing")}
                </>
              ) : (
                <>
                  <CheckCheck className="w-4 h-4" />
                  {t("mark_all_as_read")}
                </>
              )}
            </button>
          )}
        </div>
      </div>

      {/* Filters & Search */}
      <div className="theme-bg-card rounded-lg shadow-sm border theme-border p-4 mb-6">
        <div className="flex flex-wrap gap-4 items-center">
          {/* Search */}
          <div className="flex-1 min-w-[250px]">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 theme-text-secondary" />
              <input
                type="text"
                placeholder={t("search_notifications")}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-light-focus dark:focus:ring-dark-focus focus:border-transparent theme-bg-background theme-text-primary"
              />
            </div>
          </div>

          {/* Read Status Filter */}
          <div className="flex gap-2">
            <button
              onClick={() => setFilter("all")}
              className={`px-4 py-2 rounded-lg transition ${
                filter === "all"
                  ? "btn-primary"
                  : "theme-bg-background border theme-border hover:theme-bg-secondary"
              }`}
            >
              {t("all_notifications")} ({notifications.length})
            </button>
            <button
              onClick={() => setFilter("unread")}
              className={`px-4 py-2 rounded-lg transition ${
                filter === "unread"
                  ? "btn-primary"
                  : "theme-bg-background border theme-border hover:theme-bg-secondary"
              }`}
            >
              {t("unread_notifications")} ({unreadCount})
            </button>
          </div>

          {/* Category Filter */}
          <div className="flex items-center gap-2">
            <Filter className="w-5 h-5 theme-text-secondary" />
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="px-4 py-2 border theme-border rounded-lg focus:ring-2 focus:ring-light-focus dark:focus:ring-dark-focus focus:border-transparent theme-bg-background theme-text-primary"
            >
              <option value="all">{t("all_categories")}</option>
              {categories.map((cat) => (
                <option key={cat} value={cat}>
                  {getCategoryText(cat)}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Active filters summary */}
        {(searchQuery || categoryFilter !== "all") && (
          <div className="mt-3 flex items-center gap-2 text-body2-mobile theme-text-secondary">
            <span>{t("filtering_by")}</span>
            {searchQuery && (
              <span className="px-2 py-1 bg-light-info/20 dark:bg-dark-info/20 theme-text-info rounded">
                "{searchQuery}"
              </span>
            )}
            {categoryFilter !== "all" && (
              <span className="px-2 py-1 bg-light-primary/20 dark:bg-dark-primary/20 theme-text-primary rounded">
                {getCategoryText(categoryFilter)}
              </span>
            )}
            <button
              onClick={() => {
                setSearchQuery("");
                setCategoryFilter("all");
              }}
              className="ml-2 link-brand"
            >
              {t("clear_filters")}
            </button>
          </div>
        )}
      </div>

      {/* Notification List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-light-primary dark:border-dark-primary mx-auto"></div>
          <p className="theme-text-secondary mt-4">{t("loading")}</p>
        </div>
      ) : filteredNotifications.length === 0 ? (
        <div className="theme-bg-card rounded-lg shadow-sm border theme-border p-12 text-center">
          <Bell className="w-16 h-16 icon-disabled mx-auto mb-4" />
          <p className="theme-text-secondary text-body1-mobile">
            {searchQuery || categoryFilter !== "all"
              ? t("no_notifications_found")
              : filter === "unread"
              ? t("no_unread_notifications")
              : t("no_notifications")}
          </p>
        </div>
      ) : (
        <>
          {/* Results summary */}
          <div className="mb-4 text-body2-mobile theme-text-secondary">
            {t("showing_results").replace("{start}", String(startIndex + 1)).replace("{end}", String(Math.min(startIndex + itemsPerPage, filteredNotifications.length))).replace("{total}", String(filteredNotifications.length))}
          </div>

          <div className="space-y-3">
            {paginatedNotifications.map((notification) => (
              <div
                key={notification.notification_id}
                className={`relative theme-bg-card rounded-lg shadow-sm border transition-all hover:shadow-md ${
                  notification.is_read
                    ? "theme-border"
                    : "border-light-info dark:border-dark-info bg-light-info/5 dark:bg-dark-info/5"
                }`}
              >
                {/* Category Badge (top-left) */}
                <div className="absolute top-3 left-3">
                  {getCategoryBadge(notification.category)}
                </div>

                {/* Unread Indicator (red dot) */}
                {!notification.is_read && (
                  <div className="absolute top-3 right-3">
                    <span className="flex h-3 w-3">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-light-error dark:bg-dark-error opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-3 w-3 bg-light-error dark:bg-dark-error"></span>
                    </span>
                  </div>
                )}

                <div className="p-4 pt-10">
                  <h3 className="text-subtitle1-mobile sm:text-subtitle1-tablet font-semibold theme-text-primary mb-2">
                    {notification.title}
                  </h3>
                  <p className="theme-text-secondary text-body2-mobile mb-3">{notification.content}</p>

                  <div className="flex items-center justify-between">
                    <span className="text-caption-mobile theme-text-disabled">
                      {formatDate(notification.sent_at)}
                    </span>

                    <div className="flex gap-2">
                      {!notification.is_read && (
                        <button
                          onClick={() => markAsRead(notification.notification_id)}
                          disabled={actionLoading === notification.notification_id}
                          className="px-3 py-1.5 bg-light-info/20 dark:bg-dark-info/20 theme-text-info rounded hover:bg-light-info/30 dark:hover:bg-dark-info/30 transition flex items-center gap-1 text-caption-mobile disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          {actionLoading === notification.notification_id ? (
                            <>
                              <div className="animate-spin rounded-full h-3 w-3 border-2 border-light-info dark:border-dark-info border-t-transparent"></div>
                              {t("processing")}
                            </>
                          ) : (
                            <>
                              <Check className="w-4 h-4" />
                              {t("mark_as_read")}
                            </>
                          )}
                        </button>
                      )}
                      <button
                        onClick={() => deleteNotification(notification.notification_id)}
                        disabled={actionLoading === notification.notification_id}
                        className="px-3 py-1.5 bg-light-error/20 dark:bg-dark-error/20 theme-text-error rounded hover:bg-light-error/30 dark:hover:bg-dark-error/30 transition flex items-center gap-1 text-caption-mobile disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {actionLoading === notification.notification_id ? (
                          <>
                            <div className="animate-spin rounded-full h-3 w-3 border-2 border-light-error dark:border-dark-error border-t-transparent"></div>
                            {t("processing")}
                          </>
                        ) : (
                          <>
                            <Trash2 className="w-4 h-4" />
                            {t("delete")}
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="mt-6 flex items-center justify-center gap-2">
              <button
                onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                disabled={currentPage === 1}
                className="px-4 py-2 border theme-border rounded-lg hover:theme-bg-secondary disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {t("pagination_prev")}
              </button>

              <div className="flex gap-1">
                {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                  let pageNum;
                  if (totalPages <= 5) {
                    pageNum = i + 1;
                  } else if (currentPage <= 3) {
                    pageNum = i + 1;
                  } else if (currentPage >= totalPages - 2) {
                    pageNum = totalPages - 4 + i;
                  } else {
                    pageNum = currentPage - 2 + i;
                  }

                  return (
                    <button
                      key={pageNum}
                      onClick={() => setCurrentPage(pageNum)}
                      className={`px-4 py-2 rounded-lg transition ${
                        currentPage === pageNum
                          ? "btn-primary"
                          : "border theme-border hover:theme-bg-secondary"
                      }`}
                    >
                      {pageNum}
                    </button>
                  );
                })}
              </div>

              <button
                onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                disabled={currentPage === totalPages}
                className="px-4 py-2 border theme-border rounded-lg hover:theme-bg-secondary disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {t("pagination_next")}
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default NotificationListPage;