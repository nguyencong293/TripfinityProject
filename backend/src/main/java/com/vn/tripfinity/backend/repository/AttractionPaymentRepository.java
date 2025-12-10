package com.vn.tripfinity.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.AttractionPayment;

@Repository
public interface AttractionPaymentRepository extends JpaRepository<AttractionPayment, Integer> {

    List<AttractionPayment> findByUser_UserId(Integer userId);

    Optional<AttractionPayment> findByBooking_BookingId(Integer bookingId);

    Optional<AttractionPayment> findByTransactionId(String transactionId);

    @Query("SELECT p FROM AttractionPayment p WHERE p.user.userId = :userId AND p.paymentStatus = :status ORDER BY p.paymentDate DESC")
    List<AttractionPayment> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") AttractionPayment.PaymentStatus status);

    boolean existsByTransactionId(String transactionId);
}
