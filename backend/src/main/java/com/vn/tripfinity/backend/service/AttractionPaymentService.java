package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.AttractionPaymentDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.AttractionBooking;
import com.vn.tripfinity.backend.model.AttractionPayment;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.AttractionBookingRepository;
import com.vn.tripfinity.backend.repository.AttractionPaymentRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AttractionPaymentService {

    private final AttractionPaymentRepository paymentRepository;
    private final AttractionBookingRepository bookingRepository;
    private final UserRepository userRepository;

    public List<AttractionPaymentDTO> getAllPayments() {
        log.debug("Lấy toàn bộ attraction payments");
        return paymentRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AttractionPaymentDTO getPaymentById(Integer paymentId) {
        log.debug("Lấy payment theo ID: {}", paymentId);
        AttractionPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));
        return convertToDTO(payment);
    }

    public AttractionPaymentDTO getPaymentByBookingId(Integer bookingId) {
        log.debug("Lấy payment theo Booking ID: {}", bookingId);
        AttractionPayment payment = paymentRepository.findByBooking_BookingId(bookingId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Payment cho Booking id: " + bookingId));
        return convertToDTO(payment);
    }

    public AttractionPaymentDTO getPaymentByTransactionId(String transactionId) {
        log.debug("Lấy payment theo Transaction ID: {}", transactionId);
        AttractionPayment payment = paymentRepository.findByTransactionId(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy Payment với transaction id: " + transactionId));
        return convertToDTO(payment);
    }

    public List<AttractionPaymentDTO> getPaymentsByUser(Integer userId) {
        log.debug("Lấy danh sách payments của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<AttractionPayment> payments = paymentRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} payments của User ID: {}", payments.size(), userId);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionPaymentDTO> getPaymentsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách payments của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        AttractionPayment.PaymentStatus paymentStatus = AttractionPayment.PaymentStatus.valueOf(status);
        List<AttractionPayment> payments = paymentRepository.findByUserAndStatus(userId, paymentStatus);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AttractionPaymentDTO createPayment(AttractionPaymentDTO dto) {
        log.debug("Tạo Payment: {}", dto);

        AttractionBooking booking = bookingRepository.findById(dto.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + dto.getBookingId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        // Kiểm tra transaction ID trùng
        if (paymentRepository.existsByTransactionId(dto.getTransactionId())) {
            throw new IllegalStateException("Transaction ID đã tồn tại: " + dto.getTransactionId());
        }

        AttractionPayment.PaymentStatus paymentStatus = dto.getPaymentStatus() != null
                ? AttractionPayment.PaymentStatus.valueOf(dto.getPaymentStatus())
                : AttractionPayment.PaymentStatus.pending;

        AttractionPayment.PaymentMethod paymentMethod = AttractionPayment.PaymentMethod.valueOf(
                dto.getPaymentMethod());

        AttractionPayment payment = AttractionPayment.builder()
                .booking(booking)
                .user(user)
                .amount(dto.getAmount())
                .currencyCode(dto.getCurrencyCode())
                .paymentMethod(paymentMethod)
                .transactionId(dto.getTransactionId())
                .paymentStatus(paymentStatus)
                .paymentDate(dto.getPaymentDate() != null ? dto.getPaymentDate() : LocalDateTime.now())
                .build();

        AttractionPayment savedPayment = paymentRepository.save(payment);
        log.info("✅ Tạo Payment ID: {} với transaction: {}", savedPayment.getPaymentId(),
                savedPayment.getTransactionId());

        // Tự động cập nhật booking status nếu payment thành công
        if (paymentStatus == AttractionPayment.PaymentStatus.success) {
            booking.setBookingStatus(AttractionBooking.BookingStatus.confirmed);
            bookingRepository.save(booking);
            log.info("✅ Đã cập nhật Booking ID: {} sang status confirmed", booking.getBookingId());
        }

        return convertToDTO(savedPayment);
    }

    public AttractionPaymentDTO updatePayment(Integer paymentId, AttractionPaymentDTO dto) {
        log.debug("Cập nhật Payment ID: {}", paymentId);
        AttractionPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        AttractionPayment.PaymentStatus oldStatus = payment.getPaymentStatus();

        if (dto.getAmount() != null) {
            payment.setAmount(dto.getAmount());
        }
        if (dto.getCurrencyCode() != null) {
            payment.setCurrencyCode(dto.getCurrencyCode());
        }
        if (dto.getPaymentMethod() != null) {
            payment.setPaymentMethod(AttractionPayment.PaymentMethod.valueOf(dto.getPaymentMethod()));
        }
        if (dto.getPaymentStatus() != null) {
            AttractionPayment.PaymentStatus newStatus = AttractionPayment.PaymentStatus.valueOf(
                    dto.getPaymentStatus());
            payment.setPaymentStatus(newStatus);

            // Cập nhật booking status khi payment status thay đổi
            if (oldStatus != newStatus && newStatus == AttractionPayment.PaymentStatus.success) {
                AttractionBooking booking = payment.getBooking();
                booking.setBookingStatus(AttractionBooking.BookingStatus.confirmed);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Booking ID: {} sang status confirmed", booking.getBookingId());
            } else if (oldStatus != newStatus && newStatus == AttractionPayment.PaymentStatus.refunded) {
                AttractionBooking booking = payment.getBooking();
                booking.setBookingStatus(AttractionBooking.BookingStatus.refunded);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Booking ID: {} sang status refunded", booking.getBookingId());
            }
        }
        if (dto.getPaymentDate() != null) {
            payment.setPaymentDate(dto.getPaymentDate());
        }

        AttractionPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Payment ID: {}", updatedPayment.getPaymentId());

        return convertToDTO(updatedPayment);
    }

    public AttractionPaymentDTO updatePaymentStatus(Integer paymentId, String status) {
        log.debug("Cập nhật Payment Status ID: {} sang: {}", paymentId, status);
        AttractionPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        AttractionPayment.PaymentStatus oldStatus = payment.getPaymentStatus();
        AttractionPayment.PaymentStatus newStatus = AttractionPayment.PaymentStatus.valueOf(status);
        payment.setPaymentStatus(newStatus);

        // Cập nhật booking status
        if (oldStatus != newStatus) {
            AttractionBooking booking = payment.getBooking();

            AttractionBooking.BookingStatus updatedStatus = switch (newStatus) {
                case success -> AttractionBooking.BookingStatus.confirmed;
                case refunded -> AttractionBooking.BookingStatus.refunded;
                case failed -> AttractionBooking.BookingStatus.cancelled;
                default -> null; // không thay đổi
            };

            if (updatedStatus != null) {
                booking.setBookingStatus(updatedStatus);
                bookingRepository.save(booking);
            }
        }

        AttractionPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Payment Status ID: {} sang: {}", updatedPayment.getPaymentId(), status);

        return convertToDTO(updatedPayment);
    }

    public void deletePayment(Integer paymentId) {
        log.debug("Xóa Payment ID: {}", paymentId);
        AttractionPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        paymentRepository.delete(payment);
        log.info("Đã xóa Payment ID: {}", paymentId);
    }

    private AttractionPaymentDTO convertToDTO(AttractionPayment payment) {
        return AttractionPaymentDTO.builder()
                .paymentId(payment.getPaymentId())
                .bookingId(payment.getBooking() != null ? payment.getBooking().getBookingId() : null)
                .userId(payment.getUser() != null ? payment.getUser().getUserId() : null)
                .amount(payment.getAmount())
                .currencyCode(payment.getCurrencyCode())
                .paymentMethod(payment.getPaymentMethod() != null ? payment.getPaymentMethod().name() : null)
                .transactionId(payment.getTransactionId())
                .paymentStatus(payment.getPaymentStatus() != null ? payment.getPaymentStatus().name() : null)
                .paymentDate(payment.getPaymentDate())
                .createdAt(payment.getCreatedAt())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }
}
