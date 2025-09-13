package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Area;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AreaRepository extends JpaRepository<Area, Integer> {
    Optional<Area> findBySlug(String slug);
}
