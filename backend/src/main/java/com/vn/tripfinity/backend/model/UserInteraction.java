package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "user_item_interactions")
public class UserInteraction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "interaction_id")
    private Long interactionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @Column(name = "item_id", nullable = false)
    private Integer itemId;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_type", nullable = false, length = 20)
    private ItemType itemType;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false, length = 20)
    private ActionType actionType;

    @Column(name = "action_weight", nullable = false)
    private Integer actionWeight;

    @Column(name = "interaction_timestamp", nullable = false)
    private LocalDateTime interactionTimestamp;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // Enums
    public enum ItemType {
        tour, hotel, attraction, restaurant
    }

    public enum ActionType {
        search, view, click, favorite, book
    }

    @PrePersist
    public void prePersist() {
        if (interactionTimestamp == null) {
            interactionTimestamp = LocalDateTime.now();
        }
        // Set action weights if not provided
        if (actionWeight == null && actionType != null) {
            switch (actionType) {
                case search -> actionWeight = 1;
                case view -> actionWeight = 2;
                case click -> actionWeight = 3;
                case favorite -> actionWeight = 4;
                case book -> actionWeight = 5;
            }
        }
    }
}
