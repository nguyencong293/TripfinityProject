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
@Table(name = "hotel_review_aspects")
public class HotelReviewAspects {

    @Id
    @Column(name = "review_id")
    private Integer reviewId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "review_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private HotelReview review;

    @Column(name = "cleanliness", nullable = false)
    private Integer cleanliness;

    @Column(name = "service", nullable = false)
    private Integer service;

    @Column(name = "value_for_money", nullable = false)
    private Integer valueForMoney;

    @Column(name = "location", nullable = false)
    private Integer location;

    @Column(name = "facilities", nullable = false)
    private Integer facilities;
}
