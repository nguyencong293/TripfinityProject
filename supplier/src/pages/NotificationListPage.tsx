import { useEffect, useState, useCallback } from "react";
import { Bell, Check, CheckCheck, Trash2, ArrowLeft, Search, Filter } from "lucide-react";
import { useNavigate } from "react-router-dom";

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
      service_hotel_new: { text: "Khách sạn mới", color: "bg-green-500" },
      service_hotel_update: { text: "Cập nhật", color: "bg-blue-500" },
      service_hotel_booking: { text: "Đặt phòng", color: "bg-purple-500" },
      service_tour_new: { text: "Tour mới", color: "bg-green-500" },
      service_tour_update: { text: "Cập nhật tour", color: "bg-blue-500" },
      service_tour_booking: { text: "Đặt tour", color: "bg-purple-500" },
      payment_success: { text: "Thanh toán", color: "bg-emerald-500" },
      payment_failed: { text: "Lỗi TT", color: "bg-red-500" },
      system_alert: { text: "Hệ thống", color: "bg-orange-500" },
      promotion: { text: "Khuyến mãi", color: "bg-pink-500" },
    };

    const badge = badges[category] || { text: "Thông báo", color: "bg-gray-500" };
    return (
      <span className={`${badge.color} text-white text-xs font-semibold px-2 py-1 rounded`}>
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

    if (diffMins < 1) return "Vừa xong";
    if (diffMins < 60) return `${diffMins} phút trước`;
    if (diffHours < 24) return `${diffHours} giờ trước`;
    if (diffDays < 7) return `${diffDays} ngày trước`;

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

  // Get unique categories for filter dropdown
  const categories = Array.from(new Set(notifications.map((n) => n.category)));

  return (
    <div className="container mx-auto px-6 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate(-1)}
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
            title="Quay lại"
          >
            <ArrowLeft className="w-6 h-6 text-gray-600 dark:text-gray-400" />
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-800 dark:text-gray-100 flex items-center gap-2">
              <Bell className="w-8 h-8" />
              Thông báo
            </h1>
            <p className="text-gray-600 dark:text-gray-400 mt-1">
              {unreadCount > 0 ? `Bạn có ${unreadCount} thông báo chưa đọc` : "Không có thông báo mới"}
            </p>
          </div>
        </div>
        <div className="flex gap-3">
          {unreadCount > 0 && (
            <button
              onClick={markAllAsRead}
              disabled={markAllLoading}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {markAllLoading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                  Đang xử lý...
                </>
              ) : (
                <>
                  <CheckCheck className="w-4 h-4" />
                  Đánh dấu tất cả đã đọc
                </>
              )}
            </button>
          )}
        </div>
      </div>

      {/* Filters & Search */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
        <div className="flex flex-wrap gap-4 items-center">
          {/* Search */}
          <div className="flex-1 min-w-[250px]">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Tìm kiếm thông báo..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          {/* Read Status Filter */}
          <div className="flex gap-2">
            <button
              onClick={() => setFilter("all")}
              className={`px-4 py-2 rounded-lg transition ${
                filter === "all"
                  ? "bg-blue-600 text-white"
                  : "bg-white border border-gray-300 hover:bg-gray-50"
              }`}
            >
              Tất cả ({notifications.length})
            </button>
            <button
              onClick={() => setFilter("unread")}
              className={`px-4 py-2 rounded-lg transition ${
                filter === "unread"
                  ? "bg-blue-600 text-white"
                  : "bg-white border border-gray-300 hover:bg-gray-50"
              }`}
            >
              Chưa đọc ({unreadCount})
            </button>
          </div>

          {/* Category Filter */}
          <div className="flex items-center gap-2">
            <Filter className="w-5 h-5 text-gray-600" />
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Tất cả danh mục</option>
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
          <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
            <span>Đang lọc:</span>
            {searchQuery && (
              <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded">
                "{searchQuery}"
              </span>
            )}
            {categoryFilter !== "all" && (
              <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded">
                {getCategoryText(categoryFilter)}
              </span>
            )}
            <button
              onClick={() => {
                setSearchQuery("");
                setCategoryFilter("all");
              }}
              className="ml-2 text-blue-600 hover:underline"
            >
              Xóa bộ lọc
            </button>
          </div>
        )}
      </div>

      {/* Notification List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="text-gray-600 mt-4">Đang tải...</p>
        </div>
      ) : filteredNotifications.length === 0 ? (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-12 text-center">
          <Bell className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <p className="text-gray-600 text-lg">
            {searchQuery || categoryFilter !== "all"
              ? "Không tìm thấy thông báo phù hợp"
              : filter === "unread"
              ? "Không có thông báo chưa đọc"
              : "Chưa có thông báo nào"}
          </p>
        </div>
      ) : (
        <>
          {/* Results summary */}
          <div className="mb-4 text-sm text-gray-600">
            Hiển thị {startIndex + 1}-{Math.min(startIndex + itemsPerPage, filteredNotifications.length)} trong tổng số {filteredNotifications.length} thông báo
          </div>

          <div className="space-y-3">
            {paginatedNotifications.map((notification) => (
              <div
                key={notification.notification_id}
                className={`relative bg-white rounded-lg shadow-sm border transition-all hover:shadow-md ${
                  notification.is_read
                    ? "border-gray-200"
                    : "border-blue-300 bg-blue-50/30"
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
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
                    </span>
                  </div>
                )}

                <div className="p-4 pt-10">
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    {notification.title}
                  </h3>
                  <p className="text-gray-700 mb-3">{notification.content}</p>

                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">
                      {formatDate(notification.sent_at)}
                    </span>

                    <div className="flex gap-2">
                      {!notification.is_read && (
                        <button
                          onClick={() => markAsRead(notification.notification_id)}
                          disabled={actionLoading === notification.notification_id}
                          className="px-3 py-1.5 bg-blue-100 text-blue-700 rounded hover:bg-blue-200 transition flex items-center gap-1 text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          {actionLoading === notification.notification_id ? (
                            <>
                              <div className="animate-spin rounded-full h-3 w-3 border-2 border-blue-700 border-t-transparent"></div>
                              Đang xử lý...
                            </>
                          ) : (
                            <>
                              <Check className="w-4 h-4" />
                              Đánh dấu đã đọc
                            </>
                          )}
                        </button>
                      )}
                      <button
                        onClick={() => deleteNotification(notification.notification_id)}
                        disabled={actionLoading === notification.notification_id}
                        className="px-3 py-1.5 bg-red-100 text-red-700 rounded hover:bg-red-200 transition flex items-center gap-1 text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {actionLoading === notification.notification_id ? (
                          <>
                            <div className="animate-spin rounded-full h-3 w-3 border-2 border-red-700 border-t-transparent"></div>
                            Đang xóa...
                          </>
                        ) : (
                          <>
                            <Trash2 className="w-4 h-4" />
                            Xóa
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
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Trước
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
                          ? "bg-blue-600 text-white"
                          : "border border-gray-300 hover:bg-gray-50"
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
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Sau
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

const getCategoryText = (category: string): string => {
  const map: Record<string, string> = {
    service_hotel_new: "Khách sạn mới",
    service_hotel_update: "Cập nhật khách sạn",
    service_hotel_booking: "Đặt phòng",
    service_tour_new: "Tour mới",
    service_tour_update: "Cập nhật tour",
    service_tour_booking: "Đặt tour",
    payment_success: "Thanh toán thành công",
    payment_failed: "Thanh toán thất bại",
    system_alert: "Cảnh báo hệ thống",
    promotion: "Khuyến mãi",
  };
  return map[category] || category;
};

export default NotificationListPage;