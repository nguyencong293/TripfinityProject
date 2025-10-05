package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.HotelETicketDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.HotelBooking;
import com.vn.tripfinity.backend.model.HotelETicket;
import com.vn.tripfinity.backend.repository.HotelBookingRepository;
import com.vn.tripfinity.backend.repository.HotelETicketRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelETicketService {

    private final HotelETicketRepository eTicketRepository;
    private final HotelBookingRepository bookingRepository;

    public List<HotelETicketDTO> getAllETickets() {
        log.debug("Lấy toàn bộ hotel e-tickets");
        return eTicketRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelETicketDTO getETicketById(Integer eTicketId) {
        log.debug("Lấy e-ticket theo ID: {}", eTicketId);
        HotelETicket eTicket = eTicketRepository.findById(eTicketId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy E-Ticket id: " + eTicketId));
        return convertToDTO(eTicket);
    }

    public HotelETicketDTO getETicketByBookingId(Integer bookingId) {
        log.debug("Lấy e-ticket theo Booking ID: {}", bookingId);
        HotelETicket eTicket = eTicketRepository.findByBooking_BookingId(bookingId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy E-Ticket cho Booking id: " + bookingId));
        return convertToDTO(eTicket);
    }

    public HotelETicketDTO getETicketByTicketCode(String ticketCode) {
        log.debug("Lấy e-ticket theo Ticket Code: {}", ticketCode);
        HotelETicket eTicket = eTicketRepository.findByTicketCode(ticketCode)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy E-Ticket với code: " + ticketCode));
        return convertToDTO(eTicket);
    }

    public HotelETicketDTO createETicket(HotelETicketDTO dto) {
        log.debug("Tạo E-Ticket: {}", dto);

        HotelBooking booking = bookingRepository.findById(dto.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + dto.getBookingId()));

        // Kiểm tra xem booking đã có e-ticket chưa
        if (eTicketRepository.findByBooking_BookingId(dto.getBookingId()).isPresent()) {
            throw new IllegalStateException("Booking này đã có E-Ticket");
        }

        // Generate ticket code nếu không có
        String ticketCode = dto.getTicketCode();
        if (ticketCode == null || ticketCode.isEmpty()) {
            ticketCode = generateUniqueTicketCode();
        } else {
            // Kiểm tra trùng ticket code
            if (eTicketRepository.existsByTicketCode(ticketCode)) {
                throw new IllegalStateException("Ticket code đã tồn tại: " + ticketCode);
            }
        }

        HotelETicket eTicket = HotelETicket.builder()
                .booking(booking)
                .ticketCode(ticketCode)
                .qrCodeData(dto.getQrCodeData())
                .pdfUrl(dto.getPdfUrl())
                .validFrom(dto.getValidFrom())
                .validUntil(dto.getValidUntil())
                .build();

        HotelETicket savedETicket = eTicketRepository.save(eTicket);
        log.info("✅ Tạo E-Ticket ID: {} với code: {}", savedETicket.getETicketId(), savedETicket.getTicketCode());

        return convertToDTO(savedETicket);
    }

    public HotelETicketDTO updateETicket(Integer eTicketId, HotelETicketDTO dto) {
        log.debug("Cập nhật E-Ticket ID: {}", eTicketId);
        HotelETicket eTicket = eTicketRepository.findById(eTicketId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy E-Ticket id: " + eTicketId));

        if (dto.getTicketCode() != null && !dto.getTicketCode().equals(eTicket.getTicketCode())) {
            if (eTicketRepository.existsByTicketCode(dto.getTicketCode())) {
                throw new IllegalStateException("Ticket code đã tồn tại: " + dto.getTicketCode());
            }
            eTicket.setTicketCode(dto.getTicketCode());
        }

        if (dto.getQrCodeData() != null)
            eTicket.setQrCodeData(dto.getQrCodeData());
        if (dto.getPdfUrl() != null)
            eTicket.setPdfUrl(dto.getPdfUrl());
        if (dto.getValidFrom() != null)
            eTicket.setValidFrom(dto.getValidFrom());
        if (dto.getValidUntil() != null)
            eTicket.setValidUntil(dto.getValidUntil());

        HotelETicket updatedETicket = eTicketRepository.save(eTicket);
        log.info("Đã cập nhật E-Ticket ID: {}", updatedETicket.getETicketId());

        return convertToDTO(updatedETicket);
    }

    public void deleteETicket(Integer eTicketId) {
        log.debug("Xóa E-Ticket ID: {}", eTicketId);
        HotelETicket eTicket = eTicketRepository.findById(eTicketId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy E-Ticket id: " + eTicketId));

        eTicketRepository.delete(eTicket);
        log.info("Đã xóa E-Ticket ID: {}", eTicketId);
    }

    private String generateUniqueTicketCode() {
        String code;
        do {
            code = "HT" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        } while (eTicketRepository.existsByTicketCode(code));
        return code;
    }

    private HotelETicketDTO convertToDTO(HotelETicket eTicket) {
        return HotelETicketDTO.builder()
                .eTicketId(eTicket.getETicketId())
                .bookingId(eTicket.getBooking() != null ? eTicket.getBooking().getBookingId() : null)
                .ticketCode(eTicket.getTicketCode())
                .qrCodeData(eTicket.getQrCodeData())
                .pdfUrl(eTicket.getPdfUrl())
                .validFrom(eTicket.getValidFrom())
                .validUntil(eTicket.getValidUntil())
                .createdAt(eTicket.getCreatedAt())
                .build();
    }
}