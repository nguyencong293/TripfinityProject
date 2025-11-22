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
}
