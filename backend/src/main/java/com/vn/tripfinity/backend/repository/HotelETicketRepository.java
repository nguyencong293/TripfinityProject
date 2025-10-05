package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.HotelETicket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface HotelETicketRepository extends JpaRepository<HotelETicket, Integer> {

    Optional<HotelETicket> findByBooking_BookingId(Integer bookingId);

    Optional<HotelETicket> findByTicketCode(String ticketCode);

    boolean existsByTicketCode(String ticketCode);
}