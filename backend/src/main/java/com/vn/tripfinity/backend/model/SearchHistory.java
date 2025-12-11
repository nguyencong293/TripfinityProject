package com.vn.tripfinity.backend.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "search_history")
public class SearchHistory {

    public enum SearchType {
        hotel, restaurant, tour, attraction, general
    }

    public enum ItemType {
        hotel, restaurant, tour, attraction, area
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "search_history_id")
    private Integer searchHistoryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @Column(name = "search_query", nullable = false, length = 255)
    private String searchQuery;

    @Enumerated(EnumType.STRING)
    @Column(name = "search_type", nullable = false)
    private SearchType searchType = SearchType.general;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_type")
    private ItemType itemType;

    @Column(name = "item_id")
    private Integer itemId;

    @Column(name = "item_title", length = 255)
    private String itemTitle;

    @Column(name = "item_location", length = 255)
    private String itemLocation;

    @Column(name = "item_thumbnail_url", length = 512)
    private String itemThumbnailUrl;

    @CreationTimestamp
    @Column(name = "search_timestamp", nullable = false, updatable = false)
    private LocalDateTime searchTimestamp;

    @Column(name = "clicked", nullable = false)
    private Boolean clicked = false;

    @Column(name = "click_timestamp")
    private LocalDateTime clickTimestamp;
}
