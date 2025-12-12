package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.Point;

@Repository
public interface PointRepository extends JpaRepository<Point, Integer> {
    List<Point> findByUser_UserIdOrderByCreatedAtDesc(Integer userId);
    
    @Query("SELECT COALESCE(SUM(p.points), 0) FROM Point p WHERE p.user.userId = :userId")
    Integer getTotalPointsByUserId(@Param("userId") Integer userId);
}
