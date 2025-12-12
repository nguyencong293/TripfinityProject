package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.Badge;

@Repository
public interface BadgeRepository extends JpaRepository<Badge, Integer> {
    List<Badge> findAllByOrderByBadgeIdAsc();
}
