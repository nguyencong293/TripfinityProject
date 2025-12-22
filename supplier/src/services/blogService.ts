import api from "./api";

// Types
export interface BlogDTO {
  blogId?: number;
  bloggerId: number;
  title: string;
  slug?: string;
  content: string;
  coverImageUrl?: string;
  tags?: string;
  viewsCount?: number;
  likesCount?: number;
  blogStatus?: "published" | "archived";
  publishedAt?: string;
  createdAt?: string;
  updatedAt?: string;
  bloggerName?: string;
  bloggerAvatar?: string;
}

// ==================== PUBLIC APIs ====================

/**
 * Lấy tất cả blogs đã publish
 */
export const getAllPublishedBlogs = async (): Promise<BlogDTO[]> => {
  const response = await api.get<BlogDTO[]>("/blogs/public");
  return response.data;
};

/**
 * Lấy blog mới nhất
 */
export const getLatestBlog = async (): Promise<BlogDTO | null> => {
  const response = await api.get<BlogDTO>("/blogs/public/latest");
  return response.data || null;
};

/**
 * Lấy N blog mới nhất
 */
export const getLatestBlogs = async (limit: number = 5): Promise<BlogDTO[]> => {
  const response = await api.get<BlogDTO[]>(`/blogs/public/latest/list?limit=${limit}`);
  return response.data;
};

/**
 * Lấy blog theo slug
 */
export const getBlogBySlug = async (slug: string): Promise<BlogDTO> => {
  const response = await api.get<BlogDTO>(`/blogs/public/slug/${slug}`);
  return response.data;
};

/**
 * Lấy blog theo ID
 */
export const getBlogById = async (blogId: number): Promise<BlogDTO> => {
  const response = await api.get<BlogDTO>(`/blogs/public/${blogId}`);
  return response.data;
};

/**
 * Tìm kiếm blogs
 */
export const searchBlogs = async (keyword: string): Promise<BlogDTO[]> => {
  const response = await api.get<BlogDTO[]>(`/blogs/public/search?keyword=${encodeURIComponent(keyword)}`);
  return response.data;
};

// ==================== SUPPLIER APIs ====================

/**
 * Lấy tất cả blogs của blogger
 */
export const getBlogsByBlogger = async (userId: number): Promise<BlogDTO[]> => {
  const response = await api.get<BlogDTO[]>(`/blogs/blogger/${userId}`);
  return response.data;
};

/**
 * Tạo blog mới
 */
export const createBlog = async (blog: BlogDTO): Promise<BlogDTO> => {
  const response = await api.post<BlogDTO>("/blogs", blog);
  return response.data;
};

/**
 * Cập nhật blog
 */
export const updateBlog = async (blogId: number, blog: BlogDTO): Promise<BlogDTO> => {
  const response = await api.put<BlogDTO>(`/blogs/${blogId}`, blog);
  return response.data;
};

/**
 * Xóa blog
 */
export const deleteBlog = async (blogId: number, userId: number): Promise<void> => {
  await api.delete(`/blogs/${blogId}?userId=${userId}`);
};

/**
 * Archive/Unarchive blog
 */
export const toggleArchive = async (blogId: number, userId: number): Promise<BlogDTO> => {
  const response = await api.put<BlogDTO>(`/blogs/${blogId}/toggle-archive?userId=${userId}`);
  return response.data;
};

/**
 * Đếm số blogs của blogger
 */
export const countBlogsByBlogger = async (userId: number): Promise<number> => {
  const response = await api.get<{ count: number }>(`/blogs/blogger/${userId}/count`);
  return response.data.count;
};

/**
 * Upload image cho blog
 */
export const uploadBlogImage = async (file: File): Promise<string> => {
  const formData = new FormData();
  formData.append("file", file);
  const response = await api.post<{ imageUrl: string }>("/chat/upload-image", formData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
  return response.data.imageUrl;
};
