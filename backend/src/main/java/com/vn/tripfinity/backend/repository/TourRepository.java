package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Tour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TourRepository extends JpaRepository<Tour, Integer> {
    List<Tour> findByProvider_ProviderId(Integer providerId);
}
