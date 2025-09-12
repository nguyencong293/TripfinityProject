package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;

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
