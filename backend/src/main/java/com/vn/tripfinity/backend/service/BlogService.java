package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.BlogDTO;
import com.vn.tripfinity.backend.model.Blog;
import com.vn.tripfinity.backend.model.Blog.BlogStatus;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.BlogRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class BlogService {

    private final BlogRepository blogRepository;
    private final UserRepository userRepository;

    // ==================== MAPPER ====================

    private BlogDTO toDTO(Blog blog) {
        return BlogDTO.builder()
                .blogId(blog.getBlogId())
                .bloggerId(blog.getBlogger().getUserId())
                .title(blog.getTitle())
                .slug(blog.getSlug())
                .content(blog.getContent())
                .coverImageUrl(blog.getCoverImageUrl())
                .tags(blog.getTags())
                .viewsCount(blog.getViewsCount())
                .likesCount(blog.getLikesCount())
                .blogStatus(blog.getBlogStatus().name())
                .publishedAt(blog.getPublishedAt())
                .createdAt(blog.getCreatedAt())
                .updatedAt(blog.getUpdatedAt())
                .bloggerName(blog.getBlogger().getFullName())
                .bloggerAvatar(blog.getBlogger().getAvatarUrl())
                .build();
    }

    private Blog toEntity(BlogDTO dto, User blogger) {
        Blog blog = new Blog();
        blog.setBlogger(blogger);
        blog.setTitle(dto.getTitle());
        blog.setSlug(dto.getSlug() != null && !dto.getSlug().isEmpty() ? dto.getSlug() : generateSlug(dto.getTitle()));
        blog.setContent(dto.getContent());
        blog.setCoverImageUrl(dto.getCoverImageUrl());
        blog.setTags(dto.getTags());
        blog.setViewsCount(0);
        blog.setLikesCount(0);
        blog.setBlogStatus(BlogStatus.published);
        blog.setPublishedAt(LocalDateTime.now());
        return blog;
    }

    // Tạo slug từ title
    private String generateSlug(String title) {
        if (title == null || title.isEmpty()) {
            return "blog-" + System.currentTimeMillis();
        }
        
        // Normalize và loại bỏ dấu tiếng Việt
        String normalized = Normalizer.normalize(title, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        String withoutDiacritics = pattern.matcher(normalized).replaceAll("");
        
        // Chuyển đổi thành slug
        String slug = withoutDiacritics
                .toLowerCase()
                .replaceAll("[đĐ]", "d")
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                .replaceAll("^-|-$", "");
        
        // Đảm bảo slug unique
        String baseSlug = slug;
        int counter = 1;
        while (blogRepository.existsBySlug(slug)) {
            slug = baseSlug + "-" + counter;
            counter++;
        }
        
        return slug;
    }

    // ==================== PUBLIC APIs (không cần auth) ====================

    /**
     * Lấy tất cả blogs đã publish (cho public)
     */
    public List<BlogDTO> getAllPublishedBlogs() {
        return blogRepository.findAllPublished(BlogStatus.published).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Lấy blog mới nhất (cho home page)
     */
    public BlogDTO getLatestBlog() {
        List<Blog> blogs = blogRepository.findLatestPublished(BlogStatus.published, PageRequest.of(0, 1));
        if (blogs.isEmpty()) {
            return null;
        }
        return toDTO(blogs.get(0));
    }

    /**
     * Lấy N blog mới nhất
     */
    public List<BlogDTO> getLatestBlogs(int limit) {
        return blogRepository.findLatestPublished(BlogStatus.published, PageRequest.of(0, limit)).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Lấy blog theo slug (tăng view count)
     */
    @Transactional
    public BlogDTO getBlogBySlug(String slug) {
        Blog blog = blogRepository.findBySlug(slug)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Blog không tồn tại"));
        
        // Tăng view count
        blogRepository.incrementViewCount(blog.getBlogId());
        blog.setViewsCount(blog.getViewsCount() + 1);
        
        return toDTO(blog);
    }

    /**
     * Lấy blog theo ID (tăng view count)
     */
    @Transactional
    public BlogDTO getBlogById(Integer blogId) {
        Blog blog = blogRepository.findById(blogId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Blog không tồn tại"));
        
        // Tăng view count
        blogRepository.incrementViewCount(blog.getBlogId());
        blog.setViewsCount(blog.getViewsCount() + 1);
        
        return toDTO(blog);
    }

    /**
     * Tìm kiếm blogs
     */
    public List<BlogDTO> searchBlogs(String keyword) {
        return blogRepository.searchPublishedBlogs(BlogStatus.published, keyword).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Lấy blogs theo tag
     */
    public List<BlogDTO> getBlogsByTag(String tag) {
        return blogRepository.findByTagAndStatus(BlogStatus.published, tag).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // ==================== SUPPLIER APIs (cần auth) ====================

    /**
     * Lấy tất cả blogs của supplier
     */
    public List<BlogDTO> getBlogsByBlogger(Integer userId) {
        return blogRepository.findByBlogger_UserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Tạo blog mới
     */
    @Transactional
    public BlogDTO createBlog(BlogDTO dto) {
        User blogger = userRepository.findById(dto.getBloggerId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User không tồn tại"));
        
        Blog blog = toEntity(dto, blogger);
        Blog saved = blogRepository.save(blog);
        log.info("Created new blog: {} by user {}", saved.getBlogId(), blogger.getUserId());
        return toDTO(saved);
    }

    /**
     * Cập nhật blog
     */
    @Transactional
    public BlogDTO updateBlog(Integer blogId, BlogDTO dto) {
        Blog blog = blogRepository.findById(blogId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Blog không tồn tại"));
        
        // Chỉ blogger mới được sửa
        if (!blog.getBlogger().getUserId().equals(dto.getBloggerId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Bạn không có quyền chỉnh sửa blog này");
        }
        
        blog.setTitle(dto.getTitle());
        blog.setContent(dto.getContent());
        blog.setCoverImageUrl(dto.getCoverImageUrl());
        blog.setTags(dto.getTags());
        
        // Cập nhật slug nếu title thay đổi
        if (dto.getSlug() != null && !dto.getSlug().isEmpty() && !dto.getSlug().equals(blog.getSlug())) {
            if (blogRepository.existsBySlug(dto.getSlug())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Slug đã tồn tại");
            }
            blog.setSlug(dto.getSlug());
        }
        
        // Cập nhật status
        if (dto.getBlogStatus() != null) {
            blog.setBlogStatus(BlogStatus.valueOf(dto.getBlogStatus()));
            if (dto.getBlogStatus().equals("published") && blog.getPublishedAt() == null) {
                blog.setPublishedAt(LocalDateTime.now());
            }
        }
        
        Blog updated = blogRepository.save(blog);
        log.info("Updated blog: {}", updated.getBlogId());
        return toDTO(updated);
    }

    /**
     * Xóa blog
     */
    @Transactional
    public void deleteBlog(Integer blogId, Integer userId) {
        Blog blog = blogRepository.findById(blogId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Blog không tồn tại"));
        
        // Chỉ blogger mới được xóa
        if (!blog.getBlogger().getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Bạn không có quyền xóa blog này");
        }
        
        blogRepository.delete(blog);
        log.info("Deleted blog: {} by user {}", blogId, userId);
    }

    /**
     * Archive/Unarchive blog
     */
    @Transactional
    public BlogDTO toggleArchive(Integer blogId, Integer userId) {
        Blog blog = blogRepository.findById(blogId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Blog không tồn tại"));
        
        if (!blog.getBlogger().getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Bạn không có quyền thực hiện thao tác này");
        }
        
        if (blog.getBlogStatus() == BlogStatus.published) {
            blog.setBlogStatus(BlogStatus.archived);
        } else {
            blog.setBlogStatus(BlogStatus.published);
            if (blog.getPublishedAt() == null) {
                blog.setPublishedAt(LocalDateTime.now());
            }
        }
        
        Blog updated = blogRepository.save(blog);
        log.info("Toggled archive for blog: {}, new status: {}", blogId, updated.getBlogStatus());
        return toDTO(updated);
    }

    /**
     * Đếm số blogs của blogger
     */
    public long countBlogsByBlogger(Integer userId) {
        return blogRepository.countByBlogger_UserId(userId);
    }
}
