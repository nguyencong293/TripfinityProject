package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.HotelPaymentDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.HotelBooking;
import com.vn.tripfinity.backend.model.HotelPayment;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.HotelBookingRepository;
import com.vn.tripfinity.backend.repository.HotelPaymentRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelPaymentService {

    private final HotelPaymentRepository paymentRepository;
    private final HotelBookingRepository bookingRepository;
    private final UserRepository userRepository;

    public List<HotelPaymentDTO> getAllPayments() {
        log.debug("Lấy toàn bộ hotel payments");
        return paymentRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPaymentDTO getPaymentById(Integer paymentId) {
        log.debug("Lấy payment theo ID: {}", paymentId);
        HotelPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));
        return convertToDTO(payment);
    }

    public HotelPaymentDTO getPaymentByBookingId(Integer bookingId) {
        log.debug("Lấy payment theo Booking ID: {}", bookingId);
        HotelPayment payment = paymentRepository.findByBooking_BookingId(bookingId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Payment cho Booking id: " + bookingId));
        return convertToDTO(payment);
    }

    public HotelPaymentDTO getPaymentByTransactionId(String transactionId) {
        log.debug("Lấy payment theo Transaction ID: {}", transactionId);
        HotelPayment payment = paymentRepository.findByTransactionId(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException(
                "Không tìm thấy Payment với transaction id: " + transactionId));
        return convertToDTO(payment);
    }

    public List<HotelPaymentDTO> getPaymentsByUser(Integer userId) {
        log.debug("Lấy danh sách payments của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<HotelPayment> payments = paymentRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} payments của User ID: {}", payments.size(), userId);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelPaymentDTO> getPaymentsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách payments của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        HotelPayment.PaymentStatus paymentStatus = HotelPayment.PaymentStatus.valueOf(status);
        List<HotelPayment> payments = paymentRepository.findByUserAndStatus(userId, paymentStatus);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelPaymentDTO createPayment(HotelPaymentDTO dto) {
        log.debug("Tạo Payment: {}", dto);

        HotelBooking booking = bookingRepository.findById(dto.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + dto.getBookingId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        // Kiểm tra transaction ID trùng
        if (paymentRepository.existsByTransactionId(dto.getTransactionId())) {
            throw new IllegalStateException("Transaction ID đã tồn tại: " + dto.getTransactionId());
        }

        HotelPayment.PaymentStatus paymentStatus = dto.getPaymentStatus() != null
                ? HotelPayment.PaymentStatus.valueOf(dto.getPaymentStatus())
                : HotelPayment.PaymentStatus.pending;

        HotelPayment.PaymentMethod paymentMethod = HotelPayment.PaymentMethod.valueOf(dto.getPaymentMethod());

        HotelPayment payment = HotelPayment.builder()
                .booking(booking)
                .user(user)
                .amount(dto.getAmount())
                .currencyCode(dto.getCurrencyCode())
                .paymentMethod(paymentMethod)
                .transactionId(dto.getTransactionId())
                .paymentStatus(paymentStatus)
                .paymentDate(dto.getPaymentDate() != null ? dto.getPaymentDate() : LocalDateTime.now())
                .build();

        HotelPayment savedPayment = paymentRepository.save(payment);
        log.info("✅ Tạo Payment ID: {} với transaction: {}", savedPayment.getPaymentId(),
                savedPayment.getTransactionId());

        // Tự động cập nhật booking status nếu payment thành công
        if (paymentStatus == HotelPayment.PaymentStatus.success) {
            booking.setBookingStatus(HotelBooking.BookingStatus.confirmed);
            bookingRepository.save(booking);
            log.info("✅ Đã cập nhật Booking ID: {} sang status confirmed", booking.getBookingId());
        }

        return convertToDTO(savedPayment);
    }

    public HotelPaymentDTO updatePayment(Integer paymentId, HotelPaymentDTO dto) {
        log.debug("Cập nhật Payment ID: {}", paymentId);
        HotelPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        HotelPayment.PaymentStatus oldStatus = payment.getPaymentStatus();

        if (dto.getAmount() != null) {
            payment.setAmount(dto.getAmount());
        }
        if (dto.getCurrencyCode() != null) {
            payment.setCurrencyCode(dto.getCurrencyCode());
        }
        if (dto.getPaymentMethod() != null) {
            payment.setPaymentMethod(HotelPayment.PaymentMethod.valueOf(dto.getPaymentMethod()));
        }
        if (dto.getPaymentStatus() != null) {
            HotelPayment.PaymentStatus newStatus = HotelPayment.PaymentStatus.valueOf(dto.getPaymentStatus());
            payment.setPaymentStatus(newStatus);

            // Cập nhật booking status khi payment status thay đổi
            if (oldStatus != newStatus && newStatus == HotelPayment.PaymentStatus.success) {
                HotelBooking booking = payment.getBooking();
                booking.setBookingStatus(HotelBooking.BookingStatus.confirmed);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Booking ID: {} sang status confirmed", booking.getBookingId());
            } else if (oldStatus != newStatus && newStatus == HotelPayment.PaymentStatus.refunded) {
                HotelBooking booking = payment.getBooking();
                booking.setBookingStatus(HotelBooking.BookingStatus.refunded);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Booking ID: {} sang status refunded", booking.getBookingId());
            }
        }
        if (dto.getPaymentDate() != null) {
            payment.setPaymentDate(dto.getPaymentDate());
        }

        HotelPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Payment ID: {}", updatedPayment.getPaymentId());

        return convertToDTO(updatedPayment);
    }

    public HotelPaymentDTO updatePaymentStatus(Integer paymentId, String status) {
        log.debug("Cập nhật Payment Status ID: {} sang: {}", paymentId, status);
        HotelPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        HotelPayment.PaymentStatus oldStatus = payment.getPaymentStatus();
        HotelPayment.PaymentStatus newStatus = HotelPayment.PaymentStatus.valueOf(status);
        payment.setPaymentStatus(newStatus);

        // Cập nhật booking status
        if (oldStatus != newStatus) {
            HotelBooking booking = payment.getBooking();

            HotelBooking.BookingStatus updatedStatus = switch (newStatus) {
                case success ->
                    HotelBooking.BookingStatus.confirmed;
                case refunded ->
                    HotelBooking.BookingStatus.refunded;
                case failed ->
                    HotelBooking.BookingStatus.cancelled;
                default ->
                    null; // không thay đổi
            };

            if (updatedStatus != null) {
                booking.setBookingStatus(updatedStatus);
                bookingRepository.save(booking);
            }
        }

        HotelPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Payment Status ID: {} sang: {}", updatedPayment.getPaymentId(), status);

        return convertToDTO(updatedPayment);
    }

    public void deletePayment(Integer paymentId) {
        log.debug("Xóa Payment ID: {}", paymentId);
        HotelPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        paymentRepository.delete(payment);
        log.info("Đã xóa Payment ID: {}", paymentId);
    }

    private HotelPaymentDTO convertToDTO(HotelPayment payment) {
        return HotelPaymentDTO.builder()
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
