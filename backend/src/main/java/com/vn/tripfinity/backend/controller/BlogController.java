package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.BlogDTO;
import com.vn.tripfinity.backend.service.BlogService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/blogs")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class BlogController {

    private final BlogService blogService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    // ==================== PUBLIC APIs (không cần auth) ====================

    /**
     * Lấy tất cả blogs đã publish
     * GET /api/blogs/public
     */
    @GetMapping("/public")
    public ResponseEntity<List<BlogDTO>> getAllPublishedBlogs() {
        return ResponseEntity.ok(blogService.getAllPublishedBlogs());
    }

    /**
     * Lấy blog mới nhất (cho home page)
     * GET /api/blogs/public/latest
     */
    @GetMapping("/public/latest")
    public ResponseEntity<BlogDTO> getLatestBlog() {
        BlogDTO blog = blogService.getLatestBlog();
        if (blog == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(blog);
    }

    /**
     * Lấy N blog mới nhất
     * GET /api/blogs/public/latest?limit=5
     */
    @GetMapping("/public/latest/list")
    public ResponseEntity<List<BlogDTO>> getLatestBlogs(
            @RequestParam(defaultValue = "5") int limit) {
        return ResponseEntity.ok(blogService.getLatestBlogs(limit));
    }

    /**
     * Lấy blog theo slug (public view)
     * GET /api/blogs/public/slug/{slug}
     */
    @GetMapping("/public/slug/{slug}")
    public ResponseEntity<BlogDTO> getBlogBySlug(@PathVariable String slug) {
        return ResponseEntity.ok(blogService.getBlogBySlug(slug));
    }

    /**
     * Lấy blog theo ID (public view)
     * GET /api/blogs/public/{blogId}
     */
    @GetMapping("/public/{blogId}")
    public ResponseEntity<BlogDTO> getBlogById(@PathVariable Integer blogId) {
        return ResponseEntity.ok(blogService.getBlogById(blogId));
    }

    /**
     * Tìm kiếm blogs
     * GET /api/blogs/public/search?keyword=xxx
     */
    @GetMapping("/public/search")
    public ResponseEntity<List<BlogDTO>> searchBlogs(@RequestParam String keyword) {
        return ResponseEntity.ok(blogService.searchBlogs(keyword));
    }

    /**
     * Lấy blogs theo tag
     * GET /api/blogs/public/tag/{tag}
     */
    @GetMapping("/public/tag/{tag}")
    public ResponseEntity<List<BlogDTO>> getBlogsByTag(@PathVariable String tag) {
        return ResponseEntity.ok(blogService.getBlogsByTag(tag));
    }

    // ==================== SUPPLIER APIs (cần auth) ====================

    /**
     * Lấy tất cả blogs của blogger
     * GET /api/blogs/blogger/{userId}
     */
    @GetMapping("/blogger/{userId}")
    public ResponseEntity<List<BlogDTO>> getBlogsByBlogger(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer userId) {
        requireBearer(authorization);
        return ResponseEntity.ok(blogService.getBlogsByBlogger(userId));
    }

    /**
     * Tạo blog mới
     * POST /api/blogs
     */
    @PostMapping
    public ResponseEntity<BlogDTO> createBlog(
            @RequestHeader("Authorization") String authorization,
            @Valid @RequestBody BlogDTO dto) {
        requireBearer(authorization);
        BlogDTO created = blogService.createBlog(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * Cập nhật blog
     * PUT /api/blogs/{blogId}
     */
    @PutMapping("/{blogId}")
    public ResponseEntity<BlogDTO> updateBlog(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer blogId,
            @Valid @RequestBody BlogDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(blogService.updateBlog(blogId, dto));
    }

    /**
     * Xóa blog
     * DELETE /api/blogs/{blogId}?userId=xxx
     */
    @DeleteMapping("/{blogId}")
    public ResponseEntity<Void> deleteBlog(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer blogId,
            @RequestParam Integer userId) {
        requireBearer(authorization);
        blogService.deleteBlog(blogId, userId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Archive/Unarchive blog
     * PUT /api/blogs/{blogId}/toggle-archive?userId=xxx
     */
    @PutMapping("/{blogId}/toggle-archive")
    public ResponseEntity<BlogDTO> toggleArchive(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer blogId,
            @RequestParam Integer userId) {
        requireBearer(authorization);
        return ResponseEntity.ok(blogService.toggleArchive(blogId, userId));
    }

    /**
     * Đếm số blogs của blogger
     * GET /api/blogs/blogger/{userId}/count
     */
    @GetMapping("/blogger/{userId}/count")
    public ResponseEntity<Map<String, Long>> countBlogsByBlogger(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer userId) {
        requireBearer(authorization);
        long count = blogService.countBlogsByBlogger(userId);
        return ResponseEntity.ok(Map.of("count", count));
    }
}
