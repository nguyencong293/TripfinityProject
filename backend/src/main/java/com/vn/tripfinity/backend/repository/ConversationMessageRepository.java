package com.vn.tripfinity.backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.ConversationMessage;

@Repository
public interface ConversationMessageRepository extends JpaRepository<ConversationMessage, Integer> {

    // Lấy tất cả tin nhắn của conversation (sorted by created_at ASC - cũ nhất trước)
    List<ConversationMessage> findByConversation_ConversationIdOrderByCreatedAtAsc(Integer conversationId);

    // Lấy tin nhắn mới nhất của conversation
    @Query("SELECT m FROM ConversationMessage m WHERE m.conversation.conversationId = :conversationId ORDER BY m.createdAt DESC")
    List<ConversationMessage> findLatestMessages(@Param("conversationId") Integer conversationId, Pageable pageable);

    // Lấy tin nhắn với phân trang (mới nhất trước)
    Page<ConversationMessage> findByConversation_ConversationIdOrderByCreatedAtDesc(Integer conversationId, Pageable pageable);

    // Lấy tin nhắn chưa đọc của conversation
    @Query("SELECT m FROM ConversationMessage m WHERE m.conversation.conversationId = :conversationId AND m.isRead = false AND m.senderType != :readerType ORDER BY m.createdAt ASC")
    List<ConversationMessage> findUnreadMessages(
            @Param("conversationId") Integer conversationId,
            @Param("readerType") ConversationMessage.SenderType readerType);

    // Đếm tin nhắn chưa đọc
    @Query("SELECT COUNT(m) FROM ConversationMessage m WHERE m.conversation.conversationId = :conversationId AND m.isRead = false AND m.senderType != :readerType")
    Long countUnreadMessages(
            @Param("conversationId") Integer conversationId,
            @Param("readerType") ConversationMessage.SenderType readerType);

    // Đánh dấu đã đọc tất cả tin nhắn từ đối phương
    @Modifying
    @Query("UPDATE ConversationMessage m SET m.isRead = true, m.readAt = :readAt WHERE m.conversation.conversationId = :conversationId AND m.senderType != :readerType AND m.isRead = false")
    int markAllAsRead(
            @Param("conversationId") Integer conversationId,
            @Param("readerType") ConversationMessage.SenderType readerType,
            @Param("readAt") LocalDateTime readAt);

    // Lấy tin nhắn sau một thời điểm (cho real-time polling)
    @Query("SELECT m FROM ConversationMessage m WHERE m.conversation.conversationId = :conversationId AND m.createdAt > :afterTime ORDER BY m.createdAt ASC")
    List<ConversationMessage> findMessagesAfter(
            @Param("conversationId") Integer conversationId,
            @Param("afterTime") LocalDateTime afterTime);

    // Lấy tin nhắn hình ảnh của conversation
    @Query("SELECT m FROM ConversationMessage m WHERE m.conversation.conversationId = :conversationId AND m.messageType = 'image' ORDER BY m.createdAt DESC")
    List<ConversationMessage> findImageMessages(@Param("conversationId") Integer conversationId);

    // Xóa tất cả tin nhắn của conversation (khi archive)
    @Modifying
    @Query("DELETE FROM ConversationMessage m WHERE m.conversation.conversationId = :conversationId")
    void deleteByConversationId(@Param("conversationId") Integer conversationId);
}
