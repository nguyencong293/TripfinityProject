package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.Area;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AreaRepository extends JpaRepository<Area, Integer> {
    Optional<Area> findBySlug(String slug);

    @Query("SELECT a FROM Area a " +
            "WHERE LOWER(a.name) LIKE LOWER(CONCAT('%', :q, '%')) " +
            "   OR LOWER(a.slug) LIKE LOWER(CONCAT('%', :q, '%')) " +
            "ORDER BY CASE WHEN LOWER(a.name) = LOWER(:q) OR LOWER(a.slug) = LOWER(:q) THEN 0 ELSE 1 END, a.name ASC")
    List<Area> searchByNameOrSlug(@Param("q") String q);
}
