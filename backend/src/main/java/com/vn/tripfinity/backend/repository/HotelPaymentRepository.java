package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HotelPaymentRepository extends JpaRepository<HotelPayment, Integer> {

    List<HotelPayment> findByUser_UserId(Integer userId);

    Optional<HotelPayment> findByBooking_BookingId(Integer bookingId);

    Optional<HotelPayment> findByTransactionId(String transactionId);

    @Query("SELECT p FROM HotelPayment p WHERE p.user.userId = :userId AND p.paymentStatus = :status ORDER BY p.paymentDate DESC")
    List<HotelPayment> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") HotelPayment.PaymentStatus status);

    boolean existsByTransactionId(String transactionId);
}