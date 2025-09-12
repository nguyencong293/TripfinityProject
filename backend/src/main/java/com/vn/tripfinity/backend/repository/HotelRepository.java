package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Integer> {
    List<Hotel> findByProvider_ProviderId(Integer providerId);
}