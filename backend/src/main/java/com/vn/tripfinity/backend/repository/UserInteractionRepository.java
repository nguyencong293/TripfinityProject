package com.vn.tripfinity.backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.UserInteraction;

@Repository
public interface UserInteractionRepository extends JpaRepository<UserInteraction, Long> {

    // Find all interactions by user
    List<UserInteraction> findByUser_UserId(Integer userId);

    // Find interactions by user and item type
    List<UserInteraction> findByUser_UserIdAndItemType(Integer userId, UserInteraction.ItemType itemType);

    // Find interactions by user and action type
    List<UserInteraction> findByUser_UserIdAndActionType(Integer userId, UserInteraction.ActionType actionType);

    // Find recent interactions by user
    @Query("SELECT ui FROM UserInteraction ui WHERE ui.user.userId = :userId " +
           "ORDER BY ui.interactionTimestamp DESC")
    List<UserInteraction> findRecentInteractionsByUserId(@Param("userId") Integer userId);

    // Find interactions within time range
    @Query("SELECT ui FROM UserInteraction ui WHERE ui.user.userId = :userId " +
           "AND ui.interactionTimestamp BETWEEN :startDate AND :endDate " +
           "ORDER BY ui.interactionTimestamp DESC")
    List<UserInteraction> findByUserIdAndTimestampBetween(
        @Param("userId") Integer userId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );

    // Count interactions by user
    Long countByUser_UserId(Integer userId);

    // Count interactions by action type
    Long countByActionType(UserInteraction.ActionType actionType);

    // Find all interactions for AI training export
    @Query("SELECT ui FROM UserInteraction ui WHERE ui.actionType IN :actionTypes " +
           "ORDER BY ui.interactionTimestamp DESC")
    List<UserInteraction> findForAITraining(@Param("actionTypes") List<UserInteraction.ActionType> actionTypes);
}
