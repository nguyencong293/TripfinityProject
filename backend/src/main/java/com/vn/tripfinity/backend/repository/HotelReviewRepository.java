package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HotelReviewRepository extends JpaRepository<HotelReview, Integer> {

    List<HotelReview> findByHotel_HotelId(Integer hotelId);

    @Query("SELECT r FROM HotelReview r WHERE r.hotel.hotelId = :hotelId AND r.reviewStatus = :status ORDER BY r.createdAt DESC")
    List<HotelReview> findByHotelAndStatus(@Param("hotelId") Integer hotelId,
            @Param("status") HotelReview.ReviewStatus status);
}
