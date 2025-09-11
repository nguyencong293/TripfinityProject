package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "providers")
public class Provider {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "provider_id")
    private Integer providerId;

    // FK tới users.user_id (theo schema ảnh chụp)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    // Các cột khác (tùy bạn cần, không bắt buộc để mapping hoạt động)
    @Column(name = "company_name")
    private String companyName;

    @Column(name = "provider_status")
    private String providerStatus;
}