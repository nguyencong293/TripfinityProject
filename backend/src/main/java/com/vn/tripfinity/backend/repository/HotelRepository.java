package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Integer> {
    List<Hotel> findByProvider_ProviderId(Integer providerId);

    @Query("SELECT h FROM Hotel h WHERE (:q IS NULL OR :q = '' OR LOWER(h.title) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(h.location) LIKE LOWER(CONCAT('%', :q, '%'))) AND (:status IS NULL OR h.hotelStatus = :status) ORDER BY h.createdAt DESC")
    List<Hotel> searchByTitleOrLocation(@Param("q") String q, @Param("status") Hotel.HotelStatus status);
}