package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.TourReviewAspects;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TourReviewAspectsRepository extends JpaRepository<TourReviewAspects, Integer> {
}
