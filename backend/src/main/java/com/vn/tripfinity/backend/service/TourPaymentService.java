package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.TourPaymentDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.TourBooking;
import com.vn.tripfinity.backend.model.TourPayment;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.TourBookingRepository;
import com.vn.tripfinity.backend.repository.TourPaymentRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TourPaymentService {

    private final TourPaymentRepository paymentRepository;
    private final TourBookingRepository bookingRepository;
    private final UserRepository userRepository;

    public List<TourPaymentDTO> getAllPayments() {
        log.debug("Lấy toàn bộ tour payments");
        return paymentRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TourPaymentDTO getPaymentById(Integer paymentId) {
        log.debug("Lấy tour payment theo ID: {}", paymentId);
        TourPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));
        return convertToDTO(payment);
    }

    public TourPaymentDTO getPaymentByBookingId(Integer bookingId) {
        log.debug("Lấy tour payment theo Booking ID: {}", bookingId);
        TourPayment payment = paymentRepository.findByBooking_BookingId(bookingId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Payment cho Booking id: " + bookingId));
        return convertToDTO(payment);
    }

    public TourPaymentDTO getPaymentByTransactionId(String transactionId) {
        log.debug("Lấy tour payment theo Transaction ID: {}", transactionId);
        TourPayment payment = paymentRepository.findByTransactionId(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException(
                "Không tìm thấy Payment với transaction id: " + transactionId));
        return convertToDTO(payment);
    }

    public List<TourPaymentDTO> getPaymentsByUser(Integer userId) {
        log.debug("Lấy danh sách tour payments của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<TourPayment> payments = paymentRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} tour payments của User ID: {}", payments.size(), userId);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourPaymentDTO> getPaymentsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách tour payments của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        TourPayment.PaymentStatus paymentStatus = TourPayment.PaymentStatus.valueOf(status);
        List<TourPayment> payments = paymentRepository.findByUserAndStatus(userId, paymentStatus);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TourPaymentDTO createPayment(TourPaymentDTO dto) {
        log.debug("Tạo Tour Payment: {}", dto);

        TourBooking booking = bookingRepository.findById(dto.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + dto.getBookingId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        // Kiểm tra transaction ID trùng
        if (paymentRepository.existsByTransactionId(dto.getTransactionId())) {
            throw new IllegalStateException("Transaction ID đã tồn tại: " + dto.getTransactionId());
        }

        TourPayment.PaymentStatus paymentStatus = dto.getPaymentStatus() != null
                ? TourPayment.PaymentStatus.valueOf(dto.getPaymentStatus())
                : TourPayment.PaymentStatus.pending;

        TourPayment.PaymentMethod paymentMethod = TourPayment.PaymentMethod.valueOf(dto.getPaymentMethod());

        TourPayment payment = TourPayment.builder()
                .booking(booking)
                .user(user)
                .amount(dto.getAmount())
                .currencyCode(dto.getCurrencyCode())
                .paymentMethod(paymentMethod)
                .transactionId(dto.getTransactionId())
                .paymentStatus(paymentStatus)
                .paymentDate(dto.getPaymentDate() != null ? dto.getPaymentDate() : LocalDateTime.now())
                .build();

        TourPayment savedPayment = paymentRepository.save(payment);
        log.info("✅ Tạo Tour Payment ID: {} với transaction: {}", savedPayment.getPaymentId(),
                savedPayment.getTransactionId());

        // Tự động cập nhật booking status nếu payment thành công
        if (paymentStatus == TourPayment.PaymentStatus.success) {
            booking.setBookingStatus(TourBooking.BookingStatus.confirmed);
            bookingRepository.save(booking);
            log.info("✅ Đã cập nhật Tour Booking ID: {} sang status confirmed", booking.getBookingId());
        }

        return convertToDTO(savedPayment);
    }

    public TourPaymentDTO updatePayment(Integer paymentId, TourPaymentDTO dto) {
        log.debug("Cập nhật Tour Payment ID: {}", paymentId);
        TourPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        TourPayment.PaymentStatus oldStatus = payment.getPaymentStatus();

        if (dto.getAmount() != null) {
            payment.setAmount(dto.getAmount());
        }
        if (dto.getCurrencyCode() != null) {
            payment.setCurrencyCode(dto.getCurrencyCode());
        }
        if (dto.getPaymentMethod() != null) {
            payment.setPaymentMethod(TourPayment.PaymentMethod.valueOf(dto.getPaymentMethod()));
        }
        if (dto.getPaymentStatus() != null) {
            TourPayment.PaymentStatus newStatus = TourPayment.PaymentStatus.valueOf(dto.getPaymentStatus());
            payment.setPaymentStatus(newStatus);

            // Cập nhật booking status khi payment status thay đổi
            if (oldStatus != newStatus && newStatus == TourPayment.PaymentStatus.success) {
                TourBooking booking = payment.getBooking();
                booking.setBookingStatus(TourBooking.BookingStatus.confirmed);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Tour Booking ID: {} sang status confirmed", booking.getBookingId());
            } else if (oldStatus != newStatus && newStatus == TourPayment.PaymentStatus.refunded) {
                TourBooking booking = payment.getBooking();
                booking.setBookingStatus(TourBooking.BookingStatus.refunded);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Tour Booking ID: {} sang status refunded", booking.getBookingId());
            }
        }
        if (dto.getPaymentDate() != null) {
            payment.setPaymentDate(dto.getPaymentDate());
        }

        TourPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Tour Payment ID: {}", updatedPayment.getPaymentId());

        return convertToDTO(updatedPayment);
    }

    public TourPaymentDTO updatePaymentStatus(Integer paymentId, String status) {
        log.debug("Cập nhật Tour Payment Status ID: {} sang: {}", paymentId, status);
        TourPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        TourPayment.PaymentStatus oldStatus = payment.getPaymentStatus();
        TourPayment.PaymentStatus newStatus = TourPayment.PaymentStatus.valueOf(status);
        payment.setPaymentStatus(newStatus);

        // Cập nhật booking status
        if (oldStatus != newStatus) {
            TourBooking booking = payment.getBooking();

            TourBooking.BookingStatus updatedStatus = switch (newStatus) {
                case success ->
                    TourBooking.BookingStatus.confirmed;
                case refunded ->
                    TourBooking.BookingStatus.refunded;
                case failed ->
                    TourBooking.BookingStatus.cancelled;
                default ->
                    null; // không thay đổi
            };

            if (updatedStatus != null) {
                booking.setBookingStatus(updatedStatus);
                bookingRepository.save(booking);
            }
        }

        TourPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Tour Payment Status ID: {} sang: {}", updatedPayment.getPaymentId(), status);

        return convertToDTO(updatedPayment);
    }

    public void deletePayment(Integer paymentId) {
        log.debug("Xóa Tour Payment ID: {}", paymentId);
        TourPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        paymentRepository.delete(payment);
        log.info("Đã xóa Tour Payment ID: {}", paymentId);
    }

    private TourPaymentDTO convertToDTO(TourPayment payment) {
        return TourPaymentDTO.builder()
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
