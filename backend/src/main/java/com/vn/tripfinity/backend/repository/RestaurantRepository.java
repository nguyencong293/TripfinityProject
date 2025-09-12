package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, Integer> {
    List<Restaurant> findByProvider_ProviderId(Integer providerId);
}
