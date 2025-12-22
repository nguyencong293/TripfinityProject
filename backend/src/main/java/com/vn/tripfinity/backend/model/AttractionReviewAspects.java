package com.vn.tripfinity.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
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
@Table(name = "attraction_review_aspects")
public class AttractionReviewAspects {

    @Id
    @Column(name = "review_id")
    private Integer reviewId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "review_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private AttractionReview review;

    @Column(name = "beauty", nullable = false)
    private Integer beauty; // 1..5

    @Column(name = "culture", nullable = false)
    private Integer culture; // 1..5

    @Column(name = "accessibility", nullable = false)
    private Integer accessibility; // 1..5

    @Column(name = "price", nullable = false)
    private Integer price; // 1..5

    @Column(name = "facilities", nullable = false)
    private Integer facilities; // 1..5
}
