package com.vn.tripfinity.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.AttractionReviewAspects;

@Repository
public interface AttractionReviewAspectsRepository extends JpaRepository<AttractionReviewAspects, Integer> {
}
