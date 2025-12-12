package com.vn.tripfinity.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.UserBadge;

@Repository
public interface UserBadgeRepository extends JpaRepository<UserBadge, Integer> {
    List<UserBadge> findByUser_UserIdOrderByUnlockedAtDesc(Integer userId);
    
    Optional<UserBadge> findByUser_UserIdAndBadge_BadgeId(Integer userId, Integer badgeId);
    
    boolean existsByUser_UserIdAndBadge_BadgeId(Integer userId, Integer badgeId);
}
