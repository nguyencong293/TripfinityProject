package com.vn.tripfinity.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.RestaurantPayment;

@Repository
public interface RestaurantPaymentRepository extends JpaRepository<RestaurantPayment, Integer> {

    List<RestaurantPayment> findByUser_UserId(Integer userId);

    Optional<RestaurantPayment> findByBooking_BookingId(Integer bookingId);

    Optional<RestaurantPayment> findByTransactionId(String transactionId);

    @Query("SELECT p FROM RestaurantPayment p WHERE p.user.userId = :userId AND p.paymentStatus = :status ORDER BY p.paymentDate DESC")
    List<RestaurantPayment> findByUserAndStatus(@Param("userId") Integer userId,
            @Param("status") RestaurantPayment.PaymentStatus status);

    boolean existsByTransactionId(String transactionId);
}
