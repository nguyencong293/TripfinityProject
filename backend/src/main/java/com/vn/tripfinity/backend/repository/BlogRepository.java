package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Blog;
import com.vn.tripfinity.backend.model.Blog.BlogStatus;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BlogRepository extends JpaRepository<Blog, Integer> {

    // Tìm blog theo slug
    Optional<Blog> findBySlug(String slug);

    // Kiểm tra slug đã tồn tại chưa
    boolean existsBySlug(String slug);

    // Lấy tất cả blogs theo blogger
    List<Blog> findByBlogger_UserIdOrderByCreatedAtDesc(Integer userId);

    // Lấy blogs đã publish theo blogger
    List<Blog> findByBlogger_UserIdAndBlogStatusOrderByCreatedAtDesc(Integer userId, BlogStatus status);

    // Lấy tất cả blogs đã publish (cho public view)
    @Query("SELECT b FROM Blog b WHERE b.blogStatus = :status ORDER BY b.publishedAt DESC")
    List<Blog> findAllPublished(@Param("status") BlogStatus status);

    // Lấy blogs đã publish với pagination
    @Query("SELECT b FROM Blog b WHERE b.blogStatus = :status ORDER BY b.publishedAt DESC")
    Page<Blog> findAllPublishedPaged(@Param("status") BlogStatus status, Pageable pageable);

    // Lấy blog mới nhất
    @Query("SELECT b FROM Blog b WHERE b.blogStatus = :status ORDER BY b.publishedAt DESC")
    List<Blog> findLatestPublished(@Param("status") BlogStatus status, Pageable pageable);

    // Tìm kiếm blogs theo title hoặc content
    @Query("SELECT b FROM Blog b WHERE b.blogStatus = :status AND (LOWER(b.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(b.content) LIKE LOWER(CONCAT('%', :keyword, '%'))) ORDER BY b.publishedAt DESC")
    List<Blog> searchPublishedBlogs(@Param("status") BlogStatus status, @Param("keyword") String keyword);

    // Tìm blogs theo tag
    @Query("SELECT b FROM Blog b WHERE b.blogStatus = :status AND b.tags LIKE CONCAT('%', :tag, '%') ORDER BY b.publishedAt DESC")
    List<Blog> findByTagAndStatus(@Param("status") BlogStatus status, @Param("tag") String tag);

    // Tăng view count
    @Modifying
    @Query("UPDATE Blog b SET b.viewsCount = b.viewsCount + 1 WHERE b.blogId = :blogId")
    void incrementViewCount(@Param("blogId") Integer blogId);

    // Tăng like count
    @Modifying
    @Query("UPDATE Blog b SET b.likesCount = b.likesCount + 1 WHERE b.blogId = :blogId")
    void incrementLikeCount(@Param("blogId") Integer blogId);

    // Đếm số blogs của blogger
    long countByBlogger_UserId(Integer userId);

    // Đếm số blogs published của blogger
    long countByBlogger_UserIdAndBlogStatus(Integer userId, BlogStatus status);
}
