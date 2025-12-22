package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.AttractionReview;

@Repository
public interface AttractionReviewRepository extends JpaRepository<AttractionReview, Integer> {

    @Query("SELECT r FROM AttractionReview r WHERE r.attraction.attractionId = :attractionId ORDER BY r.createdAt DESC")
    List<AttractionReview> findByAttraction_AttractionId(@Param("attractionId") Integer attractionId);

    @Query("SELECT r FROM AttractionReview r WHERE r.attraction.attractionId = :attractionId AND r.reviewStatus = :status ORDER BY r.createdAt DESC")
    List<AttractionReview> findByAttractionAndStatus(@Param("attractionId") Integer attractionId,
            @Param("status") AttractionReview.ReviewStatus status);

    @Query("SELECT COUNT(r) FROM AttractionReview r WHERE r.attraction.provider.providerId = :providerId")
    Long countByAttraction_Provider_ProviderId(@Param("providerId") Integer providerId);

    /**
     * Tính trung bình rating của attraction (chỉ tính reviews đã approved)
     * Trả về null nếu chưa có review nào
     */
    @Query("SELECT AVG(r.rating) FROM AttractionReview r WHERE r.attraction.attractionId = :attractionId AND r.reviewStatus = 'approved'")
    Double calculateAverageRating(@Param("attractionId") Integer attractionId);
}
