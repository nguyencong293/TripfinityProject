package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelReviewAspects;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HotelReviewAspectsRepository extends JpaRepository<HotelReviewAspects, Integer> {
}
