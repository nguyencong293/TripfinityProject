package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelETicketDTO;
import com.vn.tripfinity.backend.service.HotelETicketService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hotel-e-tickets")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelETicketController {

    private final HotelETicketService eTicketService;

    @GetMapping
    public ResponseEntity<List<HotelETicketDTO>> getAllETickets() {
        log.info("GET /api/hotel-e-tickets - Lấy toàn bộ e-tickets");
        List<HotelETicketDTO> eTickets = eTicketService.getAllETickets();
        return ResponseEntity.ok(eTickets);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelETicketDTO> getETicketById(@PathVariable Integer id) {
        log.info("GET /api/hotel-e-tickets/{} - Lấy e-ticket theo ID", id);
        HotelETicketDTO eTicket = eTicketService.getETicketById(id);
        return ResponseEntity.ok(eTicket);
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<HotelETicketDTO> getETicketByBookingId(@PathVariable Integer bookingId) {
        log.info("GET /api/hotel-e-tickets/booking/{} - Lấy e-ticket theo booking ID", bookingId);
        HotelETicketDTO eTicket = eTicketService.getETicketByBookingId(bookingId);
        return ResponseEntity.ok(eTicket);
    }

    @GetMapping("/code/{ticketCode}")
    public ResponseEntity<HotelETicketDTO> getETicketByTicketCode(@PathVariable String ticketCode) {
        log.info("GET /api/hotel-e-tickets/code/{} - Lấy e-ticket theo ticket code", ticketCode);
        HotelETicketDTO eTicket = eTicketService.getETicketByTicketCode(ticketCode);
        return ResponseEntity.ok(eTicket);
    }

    @PostMapping
    public ResponseEntity<HotelETicketDTO> createETicket(@Valid @RequestBody HotelETicketDTO dto) {
        log.info("POST /api/hotel-e-tickets - Tạo e-ticket mới");
        HotelETicketDTO createdETicket = eTicketService.createETicket(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdETicket);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelETicketDTO> updateETicket(
            @PathVariable Integer id,
            @Valid @RequestBody HotelETicketDTO dto) {
        log.info("PUT /api/hotel-e-tickets/{} - Cập nhật e-ticket", id);
        HotelETicketDTO updatedETicket = eTicketService.updateETicket(id, dto);
        return ResponseEntity.ok(updatedETicket);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteETicket(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-e-tickets/{} - Xóa e-ticket", id);
        eTicketService.deleteETicket(id);
        return ResponseEntity.noContent().build();
    }
}