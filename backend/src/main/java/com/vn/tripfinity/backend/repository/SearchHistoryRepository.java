package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.SearchHistory;

@Repository
public interface SearchHistoryRepository extends JpaRepository<SearchHistory, Integer> {

    /**
     * Find recent search history for a user, ordered by timestamp descending
     */
    @Query("SELECT sh FROM SearchHistory sh WHERE sh.user.userId = :userId " +
           "ORDER BY sh.searchTimestamp DESC")
    List<SearchHistory> findByUserIdOrderBySearchTimestampDesc(@Param("userId") Integer userId);

    /**
     * Find recent clicked items (viewed history) for a user
     */
    @Query("SELECT sh FROM SearchHistory sh WHERE sh.user.userId = :userId " +
           "AND sh.clicked = true " +
           "ORDER BY sh.clickTimestamp DESC")
    List<SearchHistory> findClickedByUserIdOrderByClickTimestampDesc(@Param("userId") Integer userId);

    /**
     * Find unique search queries for a user (for search suggestions)
     */
    @Query("SELECT DISTINCT sh.searchQuery FROM SearchHistory sh " +
           "WHERE sh.user.userId = :userId " +
           "ORDER BY MAX(sh.searchTimestamp) DESC")
    List<String> findDistinctSearchQueriesByUserId(@Param("userId") Integer userId);

    /**
     * Count search history entries for a user
     */
    @Query("SELECT COUNT(sh) FROM SearchHistory sh WHERE sh.user.userId = :userId")
    Long countByUserId(@Param("userId") Integer userId);

    /**
     * Delete all search history for a user
     */
    void deleteByUser_UserId(Integer userId);
}
