package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "conversations", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "provider_id"}))
public class Conversation {

    public enum ConversationStatus {
        active, closed, archived
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "conversation_id")
    private Integer conversationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Provider provider;

    @Column(name = "subject", length = 255)
    private String subject;

    @Enumerated(EnumType.STRING)
    @Column(name = "conversation_status", nullable = false, length = 20)
    @Builder.Default
    private ConversationStatus conversationStatus = ConversationStatus.active;

    @Column(name = "last_message_at")
    private LocalDateTime lastMessageAt;

    @Column(name = "last_message_preview", length = 255)
    private String lastMessagePreview;

    @Column(name = "user_unread_count", nullable = false)
    @Builder.Default
    private Integer userUnreadCount = 0;

    @Column(name = "provider_unread_count", nullable = false)
    @Builder.Default
    private Integer providerUnreadCount = 0;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (conversationStatus == null) {
            conversationStatus = ConversationStatus.active;
        }
        if (userUnreadCount == null) {
            userUnreadCount = 0;
        }
        if (providerUnreadCount == null) {
            providerUnreadCount = 0;
        }
    }
}
