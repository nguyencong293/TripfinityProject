package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Attraction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AttractionRepository extends JpaRepository<Attraction, Integer> {
    List<Attraction> findByProvider_ProviderId(Integer providerId);
}
