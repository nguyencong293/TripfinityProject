package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, Integer> {
    List<Restaurant> findByProvider_ProviderId(Integer providerId);

    long countByArea_AreaId(Integer areaId);

    @Query("SELECT r FROM Restaurant r WHERE (:q IS NULL OR :q = '' OR LOWER(r.title) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(r.location) LIKE LOWER(CONCAT('%', :q, '%'))) AND (:status IS NULL OR r.restaurantStatus = :status) ORDER BY r.createdAt DESC")
    List<Restaurant> searchByTitleOrLocation(@Param("q") String q,
            @Param("status") Restaurant.RestaurantStatus status);

    @Query("SELECT r FROM Restaurant r WHERE r.area.areaId = :areaId AND (:status IS NULL OR r.restaurantStatus = :status) ORDER BY r.createdAt DESC")
    List<Restaurant> findByAreaWithStatus(@Param("areaId") Integer areaId,
            @Param("status") Restaurant.RestaurantStatus status);

}
