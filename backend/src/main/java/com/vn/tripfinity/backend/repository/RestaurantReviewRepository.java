package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.RestaurantReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RestaurantReviewRepository extends JpaRepository<RestaurantReview, Integer> {

    List<RestaurantReview> findByRestaurant_RestaurantId(Integer restaurantId);

    @Query("SELECT r FROM RestaurantReview r WHERE r.restaurant.restaurantId = :restaurantId AND r.reviewStatus = :status ORDER BY r.createdAt DESC")
    List<RestaurantReview> findByRestaurantAndStatus(@Param("restaurantId") Integer restaurantId,
            @Param("status") RestaurantReview.ReviewStatus status);
}
