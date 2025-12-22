import { useState, useEffect, useRef } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  ArrowLeft,
  Save,
  Image as ImageIcon,
  X,
  Eye,
  Upload,
  Loader2,
  RefreshCw,
} from "lucide-react";
import { useLanguage } from "../../hooks/useLanguage";
import type { BlogDTO } from "../../services/blogService";
import {
  getBlogById,
  updateBlog,
  uploadBlogImage,
} from "../../services/blogService";

const EditBlogPage = () => {
  const navigate = useNavigate();
  const { blogId } = useParams<{ blogId: string }>();
  const { t } = useLanguage();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const contentRef = useRef<HTMLTextAreaElement>(null);

  const [userId, setUserId] = useState<number | null>(null);
  const [blog, setBlog] = useState<BlogDTO | null>(null);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [coverImageUrl, setCoverImageUrl] = useState("");
  const [tags, setTags] = useState("");
  const [blogStatus, setBlogStatus] = useState<"published" | "archived">("published");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [showPreview, setShowPreview] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Load user
  useEffect(() => {
    const user = localStorage.getItem("user");
    if (user) {
      const userData = JSON.parse(user);
      setUserId(userData.userId);
    }
  }, []);

  // Fetch blog
  useEffect(() => {
    const fetchBlog = async () => {
      if (!blogId) return;
      setLoading(true);
      try {
        const data = await getBlogById(parseInt(blogId));
        setBlog(data);
        setTitle(data.title);
        setContent(data.content);
        setCoverImageUrl(data.coverImageUrl || "");
        setTags(data.tags || "");
        setBlogStatus(data.blogStatus || "published");
      } catch (err) {
        console.error("Error fetching blog:", err);
        alert(t("blog_not_found") || "Không tìm thấy bài viết");
        navigate("/supplier/blogs");
      } finally {
        setLoading(false);
      }
    };
    fetchBlog();
  }, [blogId]);

  // Validate
  const validate = () => {
    const newErrors: Record<string, string> = {};
    if (!title.trim()) newErrors.title = t("title_required") || "Tiêu đề là bắt buộc";
    if (!content.trim()) newErrors.content = t("content_required") || "Nội dung là bắt buộc";
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // Handle image upload
  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      alert(t("invalid_image") || "Vui lòng chọn file hình ảnh");
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      alert(t("image_too_large") || "Hình ảnh không được vượt quá 5MB");
      return;
    }

    setUploading(true);
    try {
      const imageUrl = await uploadBlogImage(file);
      setCoverImageUrl(imageUrl);
    } catch (err) {
      console.error("Error uploading image:", err);
      alert(t("upload_failed") || "Không thể upload hình ảnh");
    } finally {
      setUploading(false);
    }
  };

  // Handle submit
  const handleSubmit = async () => {
    if (!validate() || !userId || !blogId || !blog) return;

    setSaving(true);
    try {
      const updatedBlog: BlogDTO = {
        ...blog,
        bloggerId: userId,
        title: title.trim(),
        content: content.trim(),
        coverImageUrl: coverImageUrl || undefined,
        tags: tags.trim() || undefined,
        blogStatus: blogStatus,
      };

      await updateBlog(parseInt(blogId), updatedBlog);
      navigate("/supplier/blogs");
    } catch (err) {
      console.error("Error updating blog:", err);
      alert(t("update_failed") || "Không thể cập nhật bài viết");
    } finally {
      setSaving(false);
    }
  };

  // Insert text at cursor
  const insertAtCursor = (text: string) => {
    if (!contentRef.current) return;
    const start = contentRef.current.selectionStart;
    const end = contentRef.current.selectionEnd;
    const newContent = content.substring(0, start) + text + content.substring(end);
    setContent(newContent);
    setTimeout(() => {
      contentRef.current?.focus();
      contentRef.current?.setSelectionRange(start + text.length, start + text.length);
    }, 0);
  };

  if (loading) {
    return (
      <div className="min-h-screen theme-bg-base flex items-center justify-center">
        <RefreshCw className="w-8 h-8 animate-spin theme-text-secondary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen theme-bg-base">
      {/* Header */}
      <div className="sticky top-0 z-10 theme-bg-card border-b theme-border">
        <div className="max-w-5xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate("/supplier/blogs")}
              className="p-2 rounded-lg hover:theme-bg-secondary transition-colors"
            >
              <ArrowLeft className="w-5 h-5 theme-text-primary" />
            </button>
            <h1 className="text-xl font-bold theme-text-primary">
              {t("edit_blog") || "Chỉnh sửa bài viết"}
            </h1>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowPreview(!showPreview)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg border transition-colors ${
                showPreview
                  ? "bg-emerald-50 border-emerald-500 text-emerald-600 dark:bg-emerald-900/20"
                  : "theme-border theme-text-secondary hover:theme-bg-secondary"
              }`}
            >
              <Eye className="w-4 h-4" />
              {t("preview") || "Xem trước"}
            </button>
            <select
              value={blogStatus}
              onChange={(e) => setBlogStatus(e.target.value as typeof blogStatus)}
              className="px-4 py-2 rounded-lg border theme-border theme-bg-secondary theme-text-primary focus:outline-none focus:ring-2 focus:ring-emerald-500"
            >
              <option value="published">{t("published") || "Đã đăng"}</option>
              <option value="archived">{t("archived") || "Lưu trữ"}</option>
            </select>
            <button
              onClick={handleSubmit}
              disabled={saving}
              className="flex items-center gap-2 px-4 py-2 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors disabled:opacity-50"
            >
              {saving ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <Save className="w-4 h-4" />
              )}
              {t("save") || "Lưu"}
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 py-6">
        <div className={`grid gap-6 ${showPreview ? "grid-cols-2" : "grid-cols-1"}`}>
          {/* Editor */}
          <div className="space-y-6">
            {/* Cover Image */}
            <div className="theme-bg-card rounded-xl border theme-border p-4">
              <label className="block text-sm font-medium theme-text-primary mb-2">
                {t("cover_image") || "Ảnh bìa"}
              </label>
              <div className="relative">
                {coverImageUrl ? (
                  <div className="relative aspect-video rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-800">
                    <img
                      src={coverImageUrl}
                      alt="Cover"
                      className="w-full h-full object-cover"
                    />
                    <button
                      onClick={() => setCoverImageUrl("")}
                      className="absolute top-2 right-2 p-1 bg-red-500 text-white rounded-full hover:bg-red-600"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                ) : (
                  <div
                    onClick={() => fileInputRef.current?.click()}
                    className="aspect-video rounded-lg border-2 border-dashed theme-border hover:border-emerald-500 flex flex-col items-center justify-center cursor-pointer transition-colors"
                  >
                    {uploading ? (
                      <Loader2 className="w-8 h-8 animate-spin theme-text-secondary" />
                    ) : (
                      <>
                        <Upload className="w-8 h-8 theme-text-secondary mb-2" />
                        <p className="text-sm theme-text-secondary">
                          {t("click_to_upload") || "Click để upload ảnh bìa"}
                        </p>
                        <p className="text-xs theme-text-secondary mt-1">
                          PNG, JPG up to 5MB
                        </p>
                      </>
                    )}
                  </div>
                )}
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                />
              </div>
            </div>

            {/* Title */}
            <div className="theme-bg-card rounded-xl border theme-border p-4">
              <label className="block text-sm font-medium theme-text-primary mb-2">
                {t("title") || "Tiêu đề"} <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder={t("enter_title") || "Nhập tiêu đề bài viết..."}
                className={`w-full px-4 py-3 rounded-lg theme-bg-secondary theme-text-primary border ${
                  errors.title ? "border-red-500" : "theme-border"
                } focus:outline-none focus:ring-2 focus:ring-emerald-500 text-lg`}
              />
              {errors.title && (
                <p className="text-sm text-red-500 mt-1">{errors.title}</p>
              )}
            </div>

            {/* Content */}
            <div className="theme-bg-card rounded-xl border theme-border p-4">
              <label className="block text-sm font-medium theme-text-primary mb-2">
                {t("content") || "Nội dung"} <span className="text-red-500">*</span>
              </label>
              {/* Toolbar */}
              <div className="flex items-center gap-1 mb-2 pb-2 border-b theme-border">
                <button
                  onClick={() => insertAtCursor("**văn bản in đậm**")}
                  className="p-2 rounded hover:theme-bg-secondary theme-text-secondary font-bold"
                  title="Bold"
                >
                  B
                </button>
                <button
                  onClick={() => insertAtCursor("_văn bản in nghiêng_")}
                  className="p-2 rounded hover:theme-bg-secondary theme-text-secondary italic"
                  title="Italic"
                >
                  I
                </button>
                <button
                  onClick={() => insertAtCursor("\n## Tiêu đề\n")}
                  className="p-2 rounded hover:theme-bg-secondary theme-text-secondary"
                  title="Heading"
                >
                  H
                </button>
                <button
                  onClick={() => insertAtCursor("\n- Danh sách\n")}
                  className="p-2 rounded hover:theme-bg-secondary theme-text-secondary"
                  title="List"
                >
                  •
                </button>
                <button
                  onClick={() => insertAtCursor("[link text](url)")}
                  className="p-2 rounded hover:theme-bg-secondary theme-text-secondary"
                  title="Link"
                >
                  🔗
                </button>
                <button
                  onClick={() => insertAtCursor("![alt text](image_url)")}
                  className="p-2 rounded hover:theme-bg-secondary theme-text-secondary"
                  title="Image"
                >
                  <ImageIcon className="w-4 h-4" />
                </button>
              </div>
              <textarea
                ref={contentRef}
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder={t("enter_content") || "Viết nội dung bài viết của bạn..."}
                rows={15}
                className={`w-full px-4 py-3 rounded-lg theme-bg-secondary theme-text-primary border ${
                  errors.content ? "border-red-500" : "theme-border"
                } focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none`}
              />
              {errors.content && (
                <p className="text-sm text-red-500 mt-1">{errors.content}</p>
              )}
              <p className="text-xs theme-text-secondary mt-2">
                {t("markdown_supported") || "Hỗ trợ Markdown cơ bản"}
              </p>
            </div>

            {/* Tags */}
            <div className="theme-bg-card rounded-xl border theme-border p-4">
              <label className="block text-sm font-medium theme-text-primary mb-2">
                {t("tags") || "Tags"}
              </label>
              <input
                type="text"
                value={tags}
                onChange={(e) => setTags(e.target.value)}
                placeholder={t("enter_tags") || "du lịch, ẩm thực, khám phá (cách nhau bởi dấu phẩy)"}
                className="w-full px-4 py-3 rounded-lg theme-bg-secondary theme-text-primary border theme-border focus:outline-none focus:ring-2 focus:ring-emerald-500"
              />
              <p className="text-xs theme-text-secondary mt-2">
                {t("tags_hint") || "Các tags cách nhau bởi dấu phẩy"}
              </p>
            </div>
          </div>

          {/* Preview */}
          {showPreview && (
            <div className="theme-bg-card rounded-xl border theme-border p-6 sticky top-24 max-h-[calc(100vh-120px)] overflow-y-auto">
              <h2 className="text-lg font-semibold theme-text-primary mb-4 pb-2 border-b theme-border">
                {t("preview") || "Xem trước"}
              </h2>
              {coverImageUrl && (
                <img
                  src={coverImageUrl}
                  alt="Preview cover"
                  className="w-full aspect-video object-cover rounded-lg mb-4"
                />
              )}
              <h1 className="text-2xl font-bold theme-text-primary mb-4">
                {title || t("untitled") || "Chưa có tiêu đề"}
              </h1>
              {tags && (
                <div className="flex flex-wrap gap-2 mb-4">
                  {tags.split(",").map((tag, idx) => (
                    <span
                      key={idx}
                      className="px-2 py-1 text-xs bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300 rounded-full"
                    >
                      #{tag.trim()}
                    </span>
                  ))}
                </div>
              )}
              <div className="prose dark:prose-invert max-w-none theme-text-primary whitespace-pre-wrap">
                {content || t("no_content") || "Chưa có nội dung"}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default EditBlogPage;
