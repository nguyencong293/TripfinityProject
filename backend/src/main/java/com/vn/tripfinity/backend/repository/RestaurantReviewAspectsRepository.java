package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.RestaurantReviewAspects;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RestaurantReviewAspectsRepository extends JpaRepository<RestaurantReviewAspects, Integer> {
}
