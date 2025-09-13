package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Tour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TourRepository extends JpaRepository<Tour, Integer> {
    List<Tour> findByProvider_ProviderId(Integer providerId);

    @Query("SELECT t FROM Tour t WHERE (:q IS NULL OR :q = '' OR LOWER(t.title) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(t.location) LIKE LOWER(CONCAT('%', :q, '%'))) AND (:status IS NULL OR t.tourStatus = :status) ORDER BY t.createdAt DESC")
    List<Tour> searchByTitleOrLocation(@Param("q") String q, @Param("status") Tour.TourStatus status);
}
