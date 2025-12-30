import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import {
  Plus,
  Search,
  Eye,
  Heart,
  Calendar,
  Edit,
  Trash2,
  Archive,
  ArchiveRestore,
  RefreshCw,
  FileText,
} from "lucide-react";
import { useLanguage } from "../../hooks/useLanguage";
import type { BlogDTO } from "../../services/blogService";
import {
  getBlogsByBlogger,
  deleteBlog,
  toggleArchive,
} from "../../services/blogService";

const BlogsPage = () => {
  const navigate = useNavigate();
  const { t } = useLanguage();
  
  const [blogs, setBlogs] = useState<BlogDTO[]>([]);
  const [filteredBlogs, setFilteredBlogs] = useState<BlogDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<"all" | "published" | "archived">("all");
  const [userId, setUserId] = useState<number | null>(null);

  // Load user từ localStorage
  useEffect(() => {
    const user = localStorage.getItem("user");
    if (user) {
      const userData = JSON.parse(user);
      setUserId(userData.userId);
    }
  }, []);

  // Fetch blogs
  const fetchBlogs = async () => {
    if (!userId) return;
    
    setLoading(true);
    setError(null);
    try {
      const data = await getBlogsByBlogger(userId);
      setBlogs(data);
      setFilteredBlogs(data);
    } catch (err) {
      console.error("Error fetching blogs:", err);
      setError("Không thể tải danh sách bài viết");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBlogs();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [userId]);

  // Filter blogs
  useEffect(() => {
    let filtered = blogs;

    // Filter by status
    if (statusFilter !== "all") {
      filtered = filtered.filter((blog) => blog.blogStatus === statusFilter);
    }

    // Filter by search
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        (blog) =>
          blog.title.toLowerCase().includes(query) ||
          blog.content.toLowerCase().includes(query) ||
          blog.tags?.toLowerCase().includes(query)
      );
    }

    setFilteredBlogs(filtered);
  }, [blogs, searchQuery, statusFilter]);

  // Handle delete
  const handleDelete = async (blogId: number) => {
    if (!userId) return;
    if (!confirm("Bạn có chắc chắn muốn xóa bài viết này?")) return;

    try {
      await deleteBlog(blogId, userId);
      setBlogs((prev) => prev.filter((b) => b.blogId !== blogId));
    } catch (err) {
      console.error("Error deleting blog:", err);
      alert("Không thể xóa bài viết");
    }
  };

  // Handle toggle archive
  const handleToggleArchive = async (blogId: number) => {
    if (!userId) return;

    try {
      const updated = await toggleArchive(blogId, userId);
      setBlogs((prev) =>
        prev.map((b) => (b.blogId === blogId ? updated : b))
      );
    } catch (err) {
      console.error("Error toggling archive:", err);
      alert("Không thể thay đổi trạng thái bài viết");
    }
  };

  // Format date
  const formatDate = (dateStr?: string) => {
    if (!dateStr) return "N/A";
    return new Date(dateStr).toLocaleDateString("vi-VN", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  // Stats
  const publishedCount = blogs.filter((b) => b.blogStatus === "published").length;
  const archivedCount = blogs.filter((b) => b.blogStatus === "archived").length;
  const totalViews = blogs.reduce((acc, b) => acc + (b.viewsCount || 0), 0);

  return (
    <div className="p-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold theme-text-primary">
            {t("blogs") || "Bài viết"}
          </h1>
          <p className="text-sm theme-text-secondary mt-1">
            {t("manage_blogs") || "Quản lý các bài viết của bạn"}
          </p>
        </div>
        <button
          onClick={() => navigate("/supplier/blogs/create")}
          className="mt-4 md:mt-0 flex items-center gap-2 px-4 py-2 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors"
        >
          <Plus className="w-5 h-5" />
          {t("create_blog") || "Tạo bài viết"}
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="theme-bg-card rounded-xl p-4 border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
              <FileText className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-sm theme-text-secondary">{t("total") || "Tổng"}</p>
              <p className="text-xl font-bold theme-text-primary">{blogs.length}</p>
            </div>
          </div>
        </div>
        <div className="theme-bg-card rounded-xl p-4 border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-emerald-100 dark:bg-emerald-900/30 rounded-lg">
              <FileText className="w-5 h-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-sm theme-text-secondary">{t("published") || "Đã đăng"}</p>
              <p className="text-xl font-bold theme-text-primary">{publishedCount}</p>
            </div>
          </div>
        </div>
        <div className="theme-bg-card rounded-xl p-4 border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
              <Archive className="w-5 h-5 text-yellow-600" />
            </div>
            <div>
              <p className="text-sm theme-text-secondary">{t("archived") || "Lưu trữ"}</p>
              <p className="text-xl font-bold theme-text-primary">{archivedCount}</p>
            </div>
          </div>
        </div>
        <div className="theme-bg-card rounded-xl p-4 border theme-border">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
              <Eye className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <p className="text-sm theme-text-secondary">{t("total_views") || "Lượt xem"}</p>
              <p className="text-xl font-bold theme-text-primary">{totalViews}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col md:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 theme-text-secondary" />
          <input
            type="text"
            placeholder={t("search_blogs") || "Tìm kiếm bài viết..."}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 rounded-lg theme-bg-secondary theme-text-primary border theme-border focus:outline-none focus:ring-2 focus:ring-emerald-500"
          />
        </div>
        <div className="flex gap-2">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as typeof statusFilter)}
            className="px-4 py-2 rounded-lg theme-bg-secondary theme-text-primary border theme-border focus:outline-none focus:ring-2 focus:ring-emerald-500"
          >
            <option value="all">{t("all_statuses") || "Tất cả"}</option>
            <option value="published">{t("published") || "Đã đăng"}</option>
            <option value="archived">{t("archived") || "Lưu trữ"}</option>
          </select>
          <button
            onClick={fetchBlogs}
            className="p-2 rounded-lg theme-bg-secondary theme-text-secondary hover:theme-text-primary transition-colors"
            title={t("refresh") || "Làm mới"}
          >
            <RefreshCw className={`w-5 h-5 ${loading ? "animate-spin" : ""}`} />
          </button>
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="flex items-center justify-center py-12">
          <RefreshCw className="w-8 h-8 animate-spin theme-text-secondary" />
        </div>
      ) : error ? (
        <div className="text-center py-12">
          <p className="text-red-500">{error}</p>
          <button
            onClick={fetchBlogs}
            className="mt-4 px-4 py-2 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600"
          >
            {t("retry") || "Thử lại"}
          </button>
        </div>
      ) : filteredBlogs.length === 0 ? (
        <div className="text-center py-12 theme-bg-card rounded-xl border theme-border">
          <FileText className="w-12 h-12 mx-auto theme-text-secondary mb-4" />
          <p className="theme-text-secondary">
            {searchQuery || statusFilter !== "all"
              ? t("no_blogs_found") || "Không tìm thấy bài viết nào"
              : t("no_blogs_yet") || "Chưa có bài viết nào"}
          </p>
          {!searchQuery && statusFilter === "all" && (
            <button
              onClick={() => navigate("/supplier/blogs/create")}
              className="mt-4 px-4 py-2 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600"
            >
              {t("create_first_blog") || "Tạo bài viết đầu tiên"}
            </button>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredBlogs.map((blog) => (
            <div
              key={blog.blogId}
              className="theme-bg-card rounded-xl border theme-border overflow-hidden hover:shadow-lg transition-shadow"
            >
              {/* Cover Image */}
              <div className="relative h-48 bg-gray-100 dark:bg-gray-800">
                {blog.coverImageUrl ? (
                  <img
                    src={blog.coverImageUrl}
                    alt={blog.title}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <FileText className="w-12 h-12 theme-text-secondary" />
                  </div>
                )}
                {/* Status Badge */}
                <div
                  className={`absolute top-3 right-3 px-2 py-1 rounded-full text-xs font-medium ${
                    blog.blogStatus === "published"
                      ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300"
                      : "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/50 dark:text-yellow-300"
                  }`}
                >
                  {blog.blogStatus === "published"
                    ? t("published") || "Đã đăng"
                    : t("archived") || "Lưu trữ"}
                </div>
              </div>

              {/* Content */}
              <div className="p-4">
                <h3 className="font-semibold theme-text-primary line-clamp-2 mb-2">
                  {blog.title}
                </h3>
                <p className="text-sm theme-text-secondary line-clamp-2 mb-3">
                  {blog.content.replace(/<[^>]*>/g, "").substring(0, 100)}...
                </p>

                {/* Tags */}
                {blog.tags && (
                  <div className="flex flex-wrap gap-1 mb-3">
                    {blog.tags.split(",").slice(0, 3).map((tag: string, idx: number) => (
                      <span
                        key={idx}
                        className="px-2 py-0.5 text-xs bg-gray-100 dark:bg-gray-700 theme-text-secondary rounded-full"
                      >
                        #{tag.trim()}
                      </span>
                    ))}
                  </div>
                )}

                {/* Stats */}
                <div className="flex items-center gap-4 text-sm theme-text-secondary mb-3">
                  <span className="flex items-center gap-1">
                    <Eye className="w-4 h-4" />
                    {blog.viewsCount || 0}
                  </span>
                  <span className="flex items-center gap-1">
                    <Heart className="w-4 h-4" />
                    {blog.likesCount || 0}
                  </span>
                  <span className="flex items-center gap-1">
                    <Calendar className="w-4 h-4" />
                    {formatDate(blog.publishedAt || blog.createdAt)}
                  </span>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-2 pt-3 border-t theme-border">
                  <button
                    onClick={() => navigate(`/supplier/blogs/edit/${blog.blogId}`)}
                    className="flex-1 flex items-center justify-center gap-1 px-3 py-2 text-sm theme-text-secondary hover:theme-text-primary hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
                  >
                    <Edit className="w-4 h-4" />
                    {t("edit") || "Sửa"}
                  </button>
                  <button
                    onClick={() => handleToggleArchive(blog.blogId!)}
                    className="flex-1 flex items-center justify-center gap-1 px-3 py-2 text-sm theme-text-secondary hover:theme-text-primary hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
                  >
                    {blog.blogStatus === "published" ? (
                      <>
                        <Archive className="w-4 h-4" />
                        {t("archive") || "Lưu trữ"}
                      </>
                    ) : (
                      <>
                        <ArchiveRestore className="w-4 h-4" />
                        {t("restore") || "Khôi phục"}
                      </>
                    )}
                  </button>
                  <button
                    onClick={() => handleDelete(blog.blogId!)}
                    className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default BlogsPage;
