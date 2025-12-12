package com.vn.tripfinity.backend.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "badges")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Badge {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "badge_id")
    private Integer badgeId;
    
    @Column(name = "badge_name", nullable = false)
    private String badgeName;
    
    @Column(name = "badge_description", columnDefinition = "TEXT")
    private String badgeDescription;
    
    @Column(name = "icon_url", length = 512)
    private String iconUrl;
    
    @Column(name = "criteria_json", nullable = false, columnDefinition = "LONGTEXT")
    private String criteriaJson;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
