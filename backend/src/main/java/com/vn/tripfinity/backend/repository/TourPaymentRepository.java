package com.vn.tripfinity.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.TourPayment;

@Repository
public interface TourPaymentRepository extends JpaRepository<TourPayment, Integer> {

    List<TourPayment> findByUser_UserId(Integer userId);

    Optional<TourPayment> findByBooking_BookingId(Integer bookingId);

    Optional<TourPayment> findByTransactionId(String transactionId);

    @Query("SELECT p FROM TourPayment p WHERE p.user.userId = :userId AND p.paymentStatus = :status ORDER BY p.paymentDate DESC")
    List<TourPayment> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") TourPayment.PaymentStatus status);

    boolean existsByTransactionId(String transactionId);
}
