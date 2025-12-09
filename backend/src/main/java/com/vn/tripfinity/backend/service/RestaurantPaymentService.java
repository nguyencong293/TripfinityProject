package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.RestaurantPaymentDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.RestaurantBooking;
import com.vn.tripfinity.backend.model.RestaurantPayment;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.RestaurantBookingRepository;
import com.vn.tripfinity.backend.repository.RestaurantPaymentRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RestaurantPaymentService {

    private final RestaurantPaymentRepository paymentRepository;
    private final RestaurantBookingRepository bookingRepository;
    private final UserRepository userRepository;

    public List<RestaurantPaymentDTO> getAllPayments() {
        log.debug("Lấy toàn bộ restaurant payments");
        return paymentRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public RestaurantPaymentDTO getPaymentById(Integer paymentId) {
        log.debug("Lấy payment theo ID: {}", paymentId);
        RestaurantPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));
        return convertToDTO(payment);
    }

    public RestaurantPaymentDTO getPaymentByBookingId(Integer bookingId) {
        log.debug("Lấy payment theo Booking ID: {}", bookingId);
        RestaurantPayment payment = paymentRepository.findByBooking_BookingId(bookingId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Payment cho Booking id: " + bookingId));
        return convertToDTO(payment);
    }

    public RestaurantPaymentDTO getPaymentByTransactionId(String transactionId) {
        log.debug("Lấy payment theo Transaction ID: {}", transactionId);
        RestaurantPayment payment = paymentRepository.findByTransactionId(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException(
                "Không tìm thấy Payment với transaction id: " + transactionId));
        return convertToDTO(payment);
    }

    public List<RestaurantPaymentDTO> getPaymentsByUser(Integer userId) {
        log.debug("Lấy danh sách payments của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<RestaurantPayment> payments = paymentRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} payments của User ID: {}", payments.size(), userId);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantPaymentDTO> getPaymentsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách payments của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        RestaurantPayment.PaymentStatus paymentStatus = RestaurantPayment.PaymentStatus.valueOf(status);
        List<RestaurantPayment> payments = paymentRepository.findByUserAndStatus(userId, paymentStatus);

        return payments.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public RestaurantPaymentDTO createPayment(RestaurantPaymentDTO dto) {
        log.debug("Tạo Payment: {}", dto);

        RestaurantBooking booking = bookingRepository.findById(dto.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + dto.getBookingId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        // Kiểm tra transaction ID trùng
        if (paymentRepository.existsByTransactionId(dto.getTransactionId())) {
            throw new IllegalStateException("Transaction ID đã tồn tại: " + dto.getTransactionId());
        }

        RestaurantPayment.PaymentStatus paymentStatus = dto.getPaymentStatus() != null
                ? RestaurantPayment.PaymentStatus.valueOf(dto.getPaymentStatus())
                : RestaurantPayment.PaymentStatus.pending;

        RestaurantPayment.PaymentMethod paymentMethod = RestaurantPayment.PaymentMethod.valueOf(dto.getPaymentMethod());

        RestaurantPayment payment = RestaurantPayment.builder()
                .booking(booking)
                .user(user)
                .amount(dto.getAmount())
                .currencyCode(dto.getCurrencyCode())
                .paymentMethod(paymentMethod)
                .transactionId(dto.getTransactionId())
                .paymentStatus(paymentStatus)
                .paymentDate(dto.getPaymentDate() != null ? dto.getPaymentDate() : LocalDateTime.now())
                .build();

        RestaurantPayment savedPayment = paymentRepository.save(payment);
        log.info("✅ Tạo Payment ID: {} với transaction: {}", savedPayment.getPaymentId(),
                savedPayment.getTransactionId());

        // Tự động cập nhật booking status nếu payment thành công
        if (paymentStatus == RestaurantPayment.PaymentStatus.success) {
            booking.setBookingStatus(RestaurantBooking.BookingStatus.confirmed);
            bookingRepository.save(booking);
            log.info("✅ Đã cập nhật Booking ID: {} sang status confirmed", booking.getBookingId());
        }

        return convertToDTO(savedPayment);
    }

    public RestaurantPaymentDTO updatePayment(Integer paymentId, RestaurantPaymentDTO dto) {
        log.debug("Cập nhật Payment ID: {}", paymentId);
        RestaurantPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        RestaurantPayment.PaymentStatus oldStatus = payment.getPaymentStatus();

        if (dto.getAmount() != null) {
            payment.setAmount(dto.getAmount());
        }
        if (dto.getCurrencyCode() != null) {
            payment.setCurrencyCode(dto.getCurrencyCode());
        }
        if (dto.getPaymentMethod() != null) {
            payment.setPaymentMethod(RestaurantPayment.PaymentMethod.valueOf(dto.getPaymentMethod()));
        }
        if (dto.getPaymentStatus() != null) {
            RestaurantPayment.PaymentStatus newStatus = RestaurantPayment.PaymentStatus.valueOf(dto.getPaymentStatus());
            payment.setPaymentStatus(newStatus);

            // Cập nhật booking status khi payment status thay đổi
            if (oldStatus != newStatus && newStatus == RestaurantPayment.PaymentStatus.success) {
                RestaurantBooking booking = payment.getBooking();
                booking.setBookingStatus(RestaurantBooking.BookingStatus.confirmed);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Booking ID: {} sang status confirmed", booking.getBookingId());
            } else if (oldStatus != newStatus && newStatus == RestaurantPayment.PaymentStatus.refunded) {
                RestaurantBooking booking = payment.getBooking();
                booking.setBookingStatus(RestaurantBooking.BookingStatus.refunded);
                bookingRepository.save(booking);
                log.info("✅ Đã cập nhật Booking ID: {} sang status refunded", booking.getBookingId());
            }
        }
        if (dto.getPaymentDate() != null) {
            payment.setPaymentDate(dto.getPaymentDate());
        }

        RestaurantPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Payment ID: {}", updatedPayment.getPaymentId());

        return convertToDTO(updatedPayment);
    }

    public RestaurantPaymentDTO updatePaymentStatus(Integer paymentId, String status) {
        log.debug("Cập nhật Payment Status ID: {} sang: {}", paymentId, status);
        RestaurantPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        RestaurantPayment.PaymentStatus oldStatus = payment.getPaymentStatus();
        RestaurantPayment.PaymentStatus newStatus = RestaurantPayment.PaymentStatus.valueOf(status);
        payment.setPaymentStatus(newStatus);

        // Cập nhật booking status
        if (oldStatus != newStatus) {
            RestaurantBooking booking = payment.getBooking();

            RestaurantBooking.BookingStatus updatedStatus = switch (newStatus) {
                case success ->
                    RestaurantBooking.BookingStatus.confirmed;
                case refunded ->
                    RestaurantBooking.BookingStatus.refunded;
                case failed ->
                    RestaurantBooking.BookingStatus.cancelled;
                default ->
                    null; // không thay đổi
            };

            if (updatedStatus != null) {
                booking.setBookingStatus(updatedStatus);
                bookingRepository.save(booking);
            }
        }

        RestaurantPayment updatedPayment = paymentRepository.save(payment);
        log.info("Đã cập nhật Payment Status ID: {} sang: {}", updatedPayment.getPaymentId(), status);

        return convertToDTO(updatedPayment);
    }

    public void deletePayment(Integer paymentId) {
        log.debug("Xóa Payment ID: {}", paymentId);
        RestaurantPayment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Payment id: " + paymentId));

        paymentRepository.delete(payment);
        log.info("Đã xóa Payment ID: {}", paymentId);
    }

    private RestaurantPaymentDTO convertToDTO(RestaurantPayment payment) {
        return RestaurantPaymentDTO.builder()
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
