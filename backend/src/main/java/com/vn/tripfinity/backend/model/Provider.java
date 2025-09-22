package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "providers")
public class Provider {

    public enum ProviderStatus {
        pending, approved, rejected, suspended
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "provider_id")
    private Integer providerId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @Column(name = "company_name", nullable = false, length = 255)
    private String companyName;

    @Column(name = "tax_code", length = 100)
    private String taxCode;

    @Column(name = "address", length = 512)
    private String address;

    @Column(name = "contact_email", length = 255)
    private String contactEmail;

    @Column(name = "contact_phone", length = 20)
    private String contactPhone;

    @Column(name = "bank_account_number", length = 100)
    private String bankAccountNumber;

    @Column(name = "bank_name", length = 255)
    private String bankName;

    @Column(name = "logo_url", length = 512)
    private String logoUrl;

    @Column(name = "provider_description", columnDefinition = "TEXT")
    private String providerDescription;

    @Column(name = "rating_overall", precision = 3, scale = 2, nullable = false)
    private BigDecimal ratingOverall;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider_status", nullable = false, length = 32)
    private ProviderStatus providerStatus;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false, columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false, columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (ratingOverall == null)
            ratingOverall = new BigDecimal("0.00");
        if (providerStatus == null)
            providerStatus = ProviderStatus.pending;
    }
}