package com.vn.tripfinity.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.Conversation;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Integer> {

    // Tìm conversation giữa user và provider
    Optional<Conversation> findByUser_UserIdAndProvider_ProviderId(Integer userId, Integer providerId);

    // Lấy danh sách conversations của user (sorted by last message)
    @Query("SELECT c FROM Conversation c WHERE c.user.userId = :userId ORDER BY c.lastMessageAt DESC NULLS LAST")
    List<Conversation> findByUserIdOrderByLastMessageDesc(@Param("userId") Integer userId);

    // Lấy danh sách conversations của provider (sorted by last message)
    @Query("SELECT c FROM Conversation c WHERE c.provider.providerId = :providerId ORDER BY c.lastMessageAt DESC NULLS LAST")
    List<Conversation> findByProviderIdOrderByLastMessageDesc(@Param("providerId") Integer providerId);

    // Lấy conversations có tin nhắn chưa đọc của user
    @Query("SELECT c FROM Conversation c WHERE c.user.userId = :userId AND c.userUnreadCount > 0 ORDER BY c.lastMessageAt DESC")
    List<Conversation> findUnreadConversationsByUser(@Param("userId") Integer userId);

    // Lấy conversations có tin nhắn chưa đọc của provider
    @Query("SELECT c FROM Conversation c WHERE c.provider.providerId = :providerId AND c.providerUnreadCount > 0 ORDER BY c.lastMessageAt DESC")
    List<Conversation> findUnreadConversationsByProvider(@Param("providerId") Integer providerId);

    // Đếm số conversations có tin nhắn chưa đọc của user
    @Query("SELECT COUNT(c) FROM Conversation c WHERE c.user.userId = :userId AND c.userUnreadCount > 0")
    Long countUnreadConversationsByUser(@Param("userId") Integer userId);

    // Đếm số conversations có tin nhắn chưa đọc của provider
    @Query("SELECT COUNT(c) FROM Conversation c WHERE c.provider.providerId = :providerId AND c.providerUnreadCount > 0")
    Long countUnreadConversationsByProvider(@Param("providerId") Integer providerId);

    // Tổng số tin nhắn chưa đọc của user
    @Query("SELECT COALESCE(SUM(c.userUnreadCount), 0) FROM Conversation c WHERE c.user.userId = :userId")
    Long sumUnreadMessagesByUser(@Param("userId") Integer userId);

    // Tổng số tin nhắn chưa đọc của provider
    @Query("SELECT COALESCE(SUM(c.providerUnreadCount), 0) FROM Conversation c WHERE c.provider.providerId = :providerId")
    Long sumUnreadMessagesByProvider(@Param("providerId") Integer providerId);

    // Reset unread count cho user
    @Modifying
    @Query("UPDATE Conversation c SET c.userUnreadCount = 0 WHERE c.conversationId = :conversationId")
    void resetUserUnreadCount(@Param("conversationId") Integer conversationId);

    // Reset unread count cho provider
    @Modifying
    @Query("UPDATE Conversation c SET c.providerUnreadCount = 0 WHERE c.conversationId = :conversationId")
    void resetProviderUnreadCount(@Param("conversationId") Integer conversationId);

    // Pageable queries
    Page<Conversation> findByUser_UserIdOrderByLastMessageAtDesc(Integer userId, Pageable pageable);
    Page<Conversation> findByProvider_ProviderIdOrderByLastMessageAtDesc(Integer providerId, Pageable pageable);

    // Search conversations by subject or user/provider name
    @Query("SELECT c FROM Conversation c WHERE c.provider.providerId = :providerId " +
           "AND (LOWER(c.subject) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(c.user.fullName) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY c.lastMessageAt DESC NULLS LAST")
    List<Conversation> searchByProviderAndKeyword(@Param("providerId") Integer providerId, @Param("keyword") String keyword);

    @Query("SELECT c FROM Conversation c WHERE c.user.userId = :userId " +
           "AND (LOWER(c.subject) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(c.provider.companyName) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY c.lastMessageAt DESC NULLS LAST")
    List<Conversation> searchByUserAndKeyword(@Param("userId") Integer userId, @Param("keyword") String keyword);
}
