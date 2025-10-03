package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Integer> {

    // ==================== FIND BY PROVIDER ====================

    /**
     * Tìm tất cả hotels của một provider
     */
    List<Hotel> findByProvider_ProviderId(Integer providerId);

    /**
     * Tìm hotels của provider theo status
     */
    List<Hotel> findByProvider_ProviderIdAndHotelStatus(Integer providerId, Hotel.HotelStatus hotelStatus);

    /**
     * Tìm hotels của provider theo visibility
     */
    List<Hotel> findByProvider_ProviderIdAndVisibility(Integer providerId, Hotel.Visibility visibility);

    /**
     * Đếm số lượng hotels của provider
     */
    long countByProvider_ProviderId(Integer providerId);

    /**
     * Đếm số lượng hotels của provider theo status
     */
    long countByProvider_ProviderIdAndHotelStatus(Integer providerId, Hotel.HotelStatus hotelStatus);

    // ==================== FIND BY AREA ====================

    /**
     * Tìm tất cả hotels trong một khu vực
     */
    List<Hotel> findByArea_AreaId(Integer areaId);

    /**
     * Tìm hotels trong khu vực theo status
     */
    @Query("SELECT h FROM Hotel h WHERE h.area.areaId = :areaId " +
            "AND (:status IS NULL OR h.hotelStatus = :status) " +
            "ORDER BY h.createdAt DESC")
    List<Hotel> findByAreaWithStatus(@Param("areaId") Integer areaId,
            @Param("status") Hotel.HotelStatus status);

    /**
     * Đếm số lượng hotels trong khu vực
     */
    long countByArea_AreaId(Integer areaId);

    /**
     * Tính tổng rating average của hotels trong khu vực
     */
    @Query("SELECT COALESCE(SUM(h.ratingAverage), 0) FROM Hotel h WHERE h.area.areaId = :areaId")
    Double sumRatingAverageByArea(@Param("areaId") Integer areaId);

    // ==================== FIND BY SLUG ====================

    /**
     * Tìm hotel theo slug (SEO friendly URL)
     */
    Optional<Hotel> findBySlug(String slug);

    /**
     * Kiểm tra slug đã tồn tại chưa
     */
    boolean existsBySlug(String slug);

    // ==================== FIND BY STATUS ====================

    /**
     * Tìm hotels theo status
     */
    List<Hotel> findByHotelStatus(Hotel.HotelStatus hotelStatus);

    /**
     * Tìm hotels được published
     */
    @Query("SELECT h FROM Hotel h WHERE h.hotelStatus = 'published' " +
            "AND h.visibility = 'public_' " +
            "ORDER BY h.publishedAt DESC")
    List<Hotel> findAllPublished();

    /**
     * Tìm hotels featured (nổi bật)
     */
    @Query("SELECT h FROM Hotel h WHERE h.isFeatured = true " +
            "AND h.hotelStatus = 'published' " +
            "AND h.visibility = 'public_' " +
            "ORDER BY h.publishedAt DESC")
    List<Hotel> findAllFeatured();

    // ==================== SEARCH ====================

    /**
     * Tìm kiếm hotels theo title hoặc location
     */
    @Query("SELECT h FROM Hotel h WHERE " +
            "(:q IS NULL OR :q = '' OR " +
            "LOWER(h.title) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
            "LOWER(h.location) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
            "LOWER(h.address) LIKE LOWER(CONCAT('%', :q, '%'))) " +
            "AND (:status IS NULL OR h.hotelStatus = :status) " +
            "ORDER BY h.createdAt DESC")
    List<Hotel> searchByTitleOrLocation(@Param("q") String q,
            @Param("status") Hotel.HotelStatus status);

    /**
     * Tìm kiếm hotels của provider theo title hoặc location
     */
    @Query("SELECT h FROM Hotel h WHERE h.provider.providerId = :providerId " +
            "AND (:q IS NULL OR :q = '' OR " +
            "LOWER(h.title) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
            "LOWER(h.location) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
            "LOWER(h.address) LIKE LOWER(CONCAT('%', :q, '%'))) " +
            "AND (:status IS NULL OR h.hotelStatus = :status) " +
            "ORDER BY h.createdAt DESC")
    List<Hotel> searchByProviderAndQuery(@Param("providerId") Integer providerId,
            @Param("q") String q,
            @Param("status") Hotel.HotelStatus status);

    // ==================== FILTER BY PROPERTY TYPE ====================

    /**
     * Tìm hotels theo loại hình
     */
    List<Hotel> findByPropertyType(Hotel.PropertyType propertyType);

    /**
     * Tìm hotels theo loại hình và status
     */
    List<Hotel> findByPropertyTypeAndHotelStatus(Hotel.PropertyType propertyType,
            Hotel.HotelStatus hotelStatus);

    /**
     * Tìm hotels theo loại hình trong khu vực
     */
    @Query("SELECT h FROM Hotel h WHERE h.area.areaId = :areaId " +
            "AND h.propertyType = :propertyType " +
            "AND h.hotelStatus = 'published' " +
            "ORDER BY h.ratingAverage DESC")
    List<Hotel> findByAreaAndPropertyType(@Param("areaId") Integer areaId,
            @Param("propertyType") Hotel.PropertyType propertyType);

    // ==================== FILTER BY STAR RATING ====================

    /**
     * Tìm hotels theo số sao
     */
    List<Hotel> findByStarRating(Integer starRating);

    /**
     * Tìm hotels có số sao >= minStars
     */
    @Query("SELECT h FROM Hotel h WHERE h.starRating >= :minStars " +
            "AND h.hotelStatus = 'published' " +
            "ORDER BY h.starRating DESC, h.ratingAverage DESC")
    List<Hotel> findByMinStarRating(@Param("minStars") Integer minStars);

    // ==================== SORT BY RATING ====================

    /**
     * Tìm top hotels theo rating
     */
    @Query("SELECT h FROM Hotel h WHERE h.hotelStatus = 'published' " +
            "AND h.visibility = 'public_' " +
            "ORDER BY h.ratingAverage DESC, h.createdAt DESC")
    List<Hotel> findTopRatedHotels();

    /**
     * Tìm top hotels trong khu vực theo rating
     */
    @Query("SELECT h FROM Hotel h WHERE h.area.areaId = :areaId " +
            "AND h.hotelStatus = 'published' " +
            "AND h.visibility = 'public_' " +
            "ORDER BY h.ratingAverage DESC, h.createdAt DESC")
    List<Hotel> findTopRatedHotelsByArea(@Param("areaId") Integer areaId);

    // ==================== PRICE RANGE FILTER ====================

    /**
     * Tìm hotels trong khoảng giá
     */
    @Query("SELECT h FROM Hotel h WHERE h.price BETWEEN :minPrice AND :maxPrice " +
            "AND h.hotelStatus = 'published' " +
            "ORDER BY h.price ASC")
    List<Hotel> findByPriceRange(@Param("minPrice") Double minPrice,
            @Param("maxPrice") Double maxPrice);

    /**
     * Tìm hotels trong khu vực và khoảng giá
     */
    @Query("SELECT h FROM Hotel h WHERE h.area.areaId = :areaId " +
            "AND h.price BETWEEN :minPrice AND :maxPrice " +
            "AND h.hotelStatus = 'published' " +
            "ORDER BY h.price ASC")
    List<Hotel> findByAreaAndPriceRange(@Param("areaId") Integer areaId,
            @Param("minPrice") Double minPrice,
            @Param("maxPrice") Double maxPrice);

    // ==================== ADVANCED SEARCH ====================

    /**
     * Tìm kiếm nâng cao với nhiều điều kiện
     */
    @Query("SELECT h FROM Hotel h WHERE " +
            "(:areaId IS NULL OR h.area.areaId = :areaId) " +
            "AND (:propertyType IS NULL OR h.propertyType = :propertyType) " +
            "AND (:minStars IS NULL OR h.starRating >= :minStars) " +
            "AND (:minPrice IS NULL OR h.price >= :minPrice) " +
            "AND (:maxPrice IS NULL OR h.price <= :maxPrice) " +
            "AND h.hotelStatus = 'published' " +
            "AND h.visibility = 'public_' " +
            "ORDER BY h.ratingAverage DESC, h.createdAt DESC")
    List<Hotel> advancedSearch(@Param("areaId") Integer areaId,
            @Param("propertyType") Hotel.PropertyType propertyType,
            @Param("minStars") Integer minStars,
            @Param("minPrice") Double minPrice,
            @Param("maxPrice") Double maxPrice);

    // ==================== STATISTICS ====================

    /**
     * Tính tổng số hotels published
     */
    @Query("SELECT COUNT(h) FROM Hotel h WHERE h.hotelStatus = 'published'")
    long countPublishedHotels();

    /**
     * Tính trung bình rating của tất cả hotels
     */
    @Query("SELECT AVG(h.ratingAverage) FROM Hotel h WHERE h.hotelStatus = 'published'")
    Double calculateAverageRating();

    /**
     * Tính trung bình giá của hotels trong khu vực
     */
    @Query("SELECT AVG(h.price) FROM Hotel h WHERE h.area.areaId = :areaId " +
            "AND h.hotelStatus = 'published'")
    Double calculateAveragePriceByArea(@Param("areaId") Integer areaId);
}