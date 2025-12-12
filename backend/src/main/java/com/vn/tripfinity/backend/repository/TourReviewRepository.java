package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.TourReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TourReviewRepository extends JpaRepository<TourReview, Integer> {

    List<TourReview> findByTour_TourId(Integer tourId);

    @Query("SELECT r FROM TourReview r WHERE r.tour.tourId = :tourId AND r.reviewStatus = :status ORDER BY r.createdAt DESC")
    List<TourReview> findByTourAndStatus(@Param("tourId") Integer tourId,
            @Param("status") TourReview.ReviewStatus status);

    /**
     * Tính trung bình rating của tour (chỉ tính reviews đã approved)
     * Trả về null nếu chưa có review nào
     */
    @Query("SELECT AVG(r.rating) FROM TourReview r WHERE r.tour.tourId = :tourId AND r.reviewStatus = 'approved'")
    Double calculateAverageRating(@Param("tourId") Integer tourId);
}
