package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Attraction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AttractionRepository extends JpaRepository<Attraction, Integer> {
    List<Attraction> findByProvider_ProviderId(Integer providerId);

    long countByArea_AreaId(Integer areaId);

    @Query("SELECT COALESCE(SUM(a.ratingAverage), 0) FROM Attraction a WHERE a.area.areaId = :areaId")
    Double sumRatingAverageByArea(@Param("areaId") Integer areaId);

    @Query("SELECT a FROM Attraction a WHERE (:q IS NULL OR :q = '' OR LOWER(a.title) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(a.location) LIKE LOWER(CONCAT('%', :q, '%'))) AND (:status IS NULL OR a.attractionStatus = :status) ORDER BY a.createdAt DESC")
    List<Attraction> searchByTitleOrLocation(@Param("q") String q,
            @Param("status") Attraction.AttractionStatus status);

    @Query("SELECT a FROM Attraction a WHERE a.area.areaId = :areaId AND (:status IS NULL OR a.attractionStatus = :status) ORDER BY a.createdAt DESC")
    List<Attraction> findByAreaWithStatus(@Param("areaId") Integer areaId,
            @Param("status") Attraction.AttractionStatus status);

}
