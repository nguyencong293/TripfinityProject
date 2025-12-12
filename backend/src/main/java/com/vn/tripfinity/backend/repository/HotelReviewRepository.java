package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.HotelReview;

@Repository
public interface HotelReviewRepository extends JpaRepository<HotelReview, Integer> {

    @Query("SELECT r FROM HotelReview r WHERE r.hotel.hotelId = :hotelId ORDER BY r.createdAt DESC")
    List<HotelReview> findByHotel_HotelId(@Param("hotelId") Integer hotelId);

    @Query("SELECT r FROM HotelReview r WHERE r.hotel.hotelId = :hotelId AND r.reviewStatus = :status ORDER BY r.createdAt DESC")
    List<HotelReview> findByHotelAndStatus(@Param("hotelId") Integer hotelId,
            @Param("status") HotelReview.ReviewStatus status);

    @Query("SELECT COUNT(r) FROM HotelReview r WHERE r.hotel.provider.providerId = :providerId")
    Long countByHotel_Provider_ProviderId(@Param("providerId") Integer providerId);

    /**
     * Tính trung bình rating của hotel (chỉ tính reviews đã approved)
     * Trả về null nếu chưa có review nào
     */
    @Query("SELECT AVG(r.rating) FROM HotelReview r WHERE r.hotel.hotelId = :hotelId AND r.reviewStatus = 'approved'")
    Double calculateAverageRating(@Param("hotelId") Integer hotelId);
}
