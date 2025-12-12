package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.RestaurantReview;

@Repository
public interface RestaurantReviewRepository extends JpaRepository<RestaurantReview, Integer> {

    List<RestaurantReview> findByRestaurant_RestaurantId(Integer restaurantId);

    @Query("SELECT r FROM RestaurantReview r WHERE r.restaurant.restaurantId = :restaurantId AND r.reviewStatus = :status ORDER BY r.createdAt DESC")
    List<RestaurantReview> findByRestaurantAndStatus(@Param("restaurantId") Integer restaurantId,
            @Param("status") RestaurantReview.ReviewStatus status);

    @Query("SELECT COUNT(r) FROM RestaurantReview r WHERE r.restaurant.provider.providerId = :providerId")
    Long countByRestaurant_Provider_ProviderId(@Param("providerId") Integer providerId);

    /**
     * Tính trung bình rating của restaurant (chỉ tính reviews đã approved)
     * Trả về null nếu chưa có review nào
     */
    @Query("SELECT AVG(r.rating) FROM RestaurantReview r WHERE r.restaurant.restaurantId = :restaurantId AND r.reviewStatus = 'approved'")
    Double calculateAverageRating(@Param("restaurantId") Integer restaurantId);
}
