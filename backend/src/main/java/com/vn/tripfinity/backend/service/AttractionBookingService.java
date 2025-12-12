package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.AttractionBookingDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Attraction;
import com.vn.tripfinity.backend.model.AttractionBooking;
import com.vn.tripfinity.backend.model.AttractionPayment;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.AttractionBookingRepository;
import com.vn.tripfinity.backend.repository.AttractionPaymentRepository;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AttractionBookingService {

    private final AttractionBookingRepository bookingRepository;
    private final AttractionPaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final AttractionRepository attractionRepository;
    private final ProviderRepository providerRepository;
    private final NotificationService notificationService;
    private final EmailService emailService;
    private final FCMService fcmService;
    private final PointsService pointsService;

    public List<AttractionBookingDTO> getAllBookings() {
        log.debug("Lấy toàn bộ attraction bookings");
        return bookingRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AttractionBookingDTO getBookingById(Integer bookingId) {
        log.debug("Lấy attraction booking theo ID: {}", bookingId);
        AttractionBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));
        return convertToDTO(booking);
    }

    public List<AttractionBookingDTO> getBookingsByUser(Integer userId) {
        log.debug("Lấy danh sách bookings của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<AttractionBooking> bookings = bookingRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} bookings của User ID: {}", bookings.size(), userId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionBookingDTO> getBookingsByAttraction(Integer attractionId) {
        log.debug("Lấy danh sách bookings của Attraction ID: {}", attractionId);
        attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        List<AttractionBooking> bookings = bookingRepository.findByAttraction_AttractionId(attractionId);
        log.info("Tìm thấy {} bookings của Attraction ID: {}", bookings.size(), attractionId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionBookingDTO> getBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách bookings của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<AttractionBooking> bookings = bookingRepository.findByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} bookings của Provider ID: {}", bookings.size(), providerId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionBookingDTO> getBookingsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách bookings của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        AttractionBooking.BookingStatus bookingStatus = AttractionBooking.BookingStatus.valueOf(status);
        List<AttractionBooking> bookings = bookingRepository.findByUserAndStatus(userId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionBookingDTO> getBookingsByProviderAndStatus(Integer providerId, String status) {
        log.debug("Lấy danh sách bookings của Provider ID: {} với status: {}", providerId, status);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        AttractionBooking.BookingStatus bookingStatus = AttractionBooking.BookingStatus.valueOf(status);
        List<AttractionBooking> bookings = bookingRepository.findByProviderAndStatus(providerId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionBookingDTO> getUnseenBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách bookings chưa xem của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<AttractionBooking> bookings = bookingRepository.findByProviderAndSeen(providerId, false);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AttractionBookingDTO createBooking(AttractionBookingDTO dto) {
        log.debug("Tạo Booking: {}", dto);
        log.info("🔍 Booking request - userId: {}, attractionId: {}, numAdults: {}",
                dto.getUserId(), dto.getAttractionId(), dto.getNumAdults());

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Attraction attraction = attractionRepository.findById(dto.getAttractionId())
                .orElseThrow(
                        () -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + dto.getAttractionId()));

        log.info("🎯 Attraction info - attractionId: {}, title: {}, maxParticipants: {}",
                attraction.getAttractionId(), attraction.getTitle(), attraction.getMaxParticipants());

        // Validate số lượng khách còn lại
        if (attraction.getMaxParticipants() != null && attraction.getMaxParticipants() > 0) {
            validateAvailability(attraction, dto.getNumAdults());
        }

        // AUTO-FIX: Tự động lấy providerId từ attraction nếu không được cung cấp
        Provider provider = null;
        if (dto.getProviderId() != null) {
            provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        } else if (attraction.getProvider() != null) {
            // Lấy provider từ attraction
            provider = attraction.getProvider();
            log.info("✅ Tự động lấy Provider ID: {} từ Attraction ID: {}", provider.getProviderId(),
                    attraction.getAttractionId());
        }

        AttractionBooking.BookingStatus bookingStatus = dto.getBookingStatus() != null
                ? AttractionBooking.BookingStatus.valueOf(dto.getBookingStatus())
                : AttractionBooking.BookingStatus.pending;

        AttractionBooking booking = AttractionBooking.builder()
                .user(user)
                .attraction(attraction)
                .provider(provider)
                .bookingDate(dto.getBookingDate() != null ? dto.getBookingDate() : LocalDateTime.now())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .numAdults(dto.getNumAdults())
                .totalPrice(dto.getTotalPrice())
                .currencyCode(dto.getCurrencyCode())
                .bookingStatus(bookingStatus)
                .eTicketUrl(dto.getETicketUrl())
                .qrCodeData(dto.getQrCodeData())
                .channel(dto.getChannel())
                .holdUntil(dto.getHoldUntil())
                .providerSeen(false)
                .providerConfirmed(0)
                .providerNotes(dto.getProviderNotes())
                .build();

        AttractionBooking savedBooking = bookingRepository.save(booking);
        log.info("✅ Tạo Booking ID: {}", savedBooking.getBookingId());

        // Auto-create payment record
        createPaymentRecord(savedBooking, dto.getPaymentMethod());

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            String bookingCode = "ATB" + savedBooking.getBookingId();
            String customerName = user.getFullName() != null ? user.getFullName() : user.getEmail();
            String attractionTitle = attraction.getTitle();
            String startDate = dto.getStartDate() != null ? dto.getStartDate().toString() : "N/A";
            String totalPrice = String.format("%,.0f", dto.getTotalPrice());
            String paymentMethod = dto.getPaymentMethod() != null ? dto.getPaymentMethod() : "counter";

            // Thông báo in-app cho user
            notificationService.notifyUserAttractionBookingCreated(
                    user.getUserId(),
                    attractionTitle,
                    bookingCode);
            log.info("📬 User notification created for userId: {}", user.getUserId());

            // Gửi email cho user
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                emailService.sendAttractionBookingConfirmationEmail(
                        user.getEmail(),
                        customerName,
                        attractionTitle,
                        bookingCode,
                        startDate,
                        totalPrice,
                        paymentMethod);
                log.info("📧 Confirmation email sent to: {}", user.getEmail());
            }

            // Thông báo in-app cho supplier
            if (provider != null && provider.getUser() != null) {
                Integer supplierId = provider.getUser().getUserId();
                notificationService.notifySupplierNewAttractionBooking(
                        supplierId,
                        attractionTitle,
                        bookingCode,
                        customerName);
                log.info("📬 Supplier notification created for supplierId: {}", supplierId);

                // GỬI FCM PUSH NOTIFICATION ĐẾN SUPPLIER
                String supplierFcmToken = provider.getUser().getFcmToken();
                if (supplierFcmToken != null && !supplierFcmToken.isEmpty()) {
                    fcmService.sendNotificationToDevice(
                            supplierFcmToken,
                            "Đơn đặt điểm tham quan mới",
                            "Khách hàng " + customerName + " vừa đặt " + attractionTitle,
                            java.util.Map.of(
                                    "type", "new_attraction_booking",
                                    "bookingId", savedBooking.getBookingId().toString(),
                                    "attractionId", attraction.getAttractionId().toString()));
                    log.info("📱 FCM notification sent to supplier");
                }

                // Gửi email cho supplier
                String supplierEmail = provider.getUser().getEmail();
                String supplierName = provider.getUser().getFullName() != null
                        ? provider.getUser().getFullName()
                        : "Supplier";

                if (supplierEmail != null && !supplierEmail.isEmpty()) {
                    emailService.sendSupplierNewAttractionBookingEmail(
                            supplierEmail,
                            supplierName,
                            attractionTitle,
                            bookingCode,
                            customerName,
                            startDate,
                            totalPrice,
                            paymentMethod,
                            dto.getNumAdults());
                    log.info("📧 Supplier booking email sent to: {}", supplierEmail);
                }
            }

        } catch (Exception e) {
            log.error("❌ Failed to send notifications/email: {}", e.getMessage());
            // Không throw exception để không block booking creation
        }

        return convertToDTO(savedBooking);
    }

    /**
     * Validate số lượng khách còn lại trước khi tạo booking
     */
    private void validateAvailability(Attraction attraction, Integer requestedGuests) {
        Integer attractionId = attraction.getAttractionId();

        log.info("🔍 Starting validation for Attraction ID: {}, requested guests: {}",
                attractionId, requestedGuests);

        // Tính tổng số người đã book (tính TẤT CẢ booking active: pending, confirmed, completed)
        // KHÔNG tính: cancelled, refunded
        Integer bookedCapacity = bookingRepository.sumGuestsByAttractionActive(attractionId);
        if (bookedCapacity == null)
            bookedCapacity = 0;

        log.info("📊 Current booked capacity: {}", bookedCapacity);

        // Validate sức chứa
        if (attraction.getMaxParticipants() != null && attraction.getMaxParticipants() > 0) {
            Integer availableCapacity = attraction.getMaxParticipants() - bookedCapacity;
            log.info("👥 Total capacity: {}, Booked: {}, Available: {}, Requested: {}",
                    attraction.getMaxParticipants(), bookedCapacity, availableCapacity, requestedGuests);

            if (requestedGuests > availableCapacity) {
                String errorMsg = String.format(
                        "Điểm tham quan '%s' không đủ chỗ! Hiện còn chỗ cho %d người, bạn đang yêu cầu %d người.",
                        attraction.getTitle(), availableCapacity, requestedGuests);
                log.error("❌ Validation failed: {}", errorMsg);
                throw new IllegalArgumentException(errorMsg);
            }
        } else {
            log.warn("⚠️ Attraction maxParticipants is null or 0, skipping capacity validation");
        }

        log.info("✅ Validation passed: Attraction {}, guests {}/{}",
                attractionId, requestedGuests, attraction.getMaxParticipants());
    }

    /**
     * Create payment record for booking
     * 
     * @param booking          The attraction booking
     * @param paymentMethodStr Payment method (counter, zalopay, etc.)
     */
    private void createPaymentRecord(AttractionBooking booking, String paymentMethodStr) {
        try {
            AttractionPayment.PaymentMethod paymentMethod;
            AttractionPayment.PaymentStatus paymentStatus;

            // Parse payment method
            if (paymentMethodStr != null && !paymentMethodStr.isEmpty()) {
                paymentMethod = AttractionPayment.PaymentMethod.valueOf(paymentMethodStr.toLowerCase());
            } else {
                paymentMethod = AttractionPayment.PaymentMethod.counter; // Default
            }

            // Set payment status based on method
            if (paymentMethod == AttractionPayment.PaymentMethod.counter) {
                paymentStatus = AttractionPayment.PaymentStatus.pending; // Pay later at counter
            } else {
                paymentStatus = AttractionPayment.PaymentStatus.success; // Online payment already completed
            }

            // Generate transaction ID
            String transactionId = "ATTXN_" + booking.getBookingId() + "_" + System.currentTimeMillis();

            AttractionPayment payment = AttractionPayment.builder()
                    .booking(booking)
                    .user(booking.getUser())
                    .amount(booking.getTotalPrice())
                    .currencyCode(booking.getCurrencyCode())
                    .paymentMethod(paymentMethod)
                    .transactionId(transactionId)
                    .paymentStatus(paymentStatus)
                    .paymentDate(LocalDateTime.now())
                    .build();

            paymentRepository.save(payment);
            log.info("✅ Created payment record for booking #{} with method: {}, status: {}",
                    booking.getBookingId(), paymentMethod, paymentStatus);

        } catch (Exception e) {
            log.error("Failed to create payment record for booking #{}: {}", booking.getBookingId(), e.getMessage());
            // Don't fail the booking creation if payment record fails
        }
    }

    public AttractionBookingDTO updateBooking(Integer bookingId, AttractionBookingDTO dto) {
        log.debug("Cập nhật Booking ID: {}", bookingId);
        AttractionBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        if (dto.getUserId() != null && !dto.getUserId().equals(booking.getUser().getUserId())) {
            User user = userRepository.findById(dto.getUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));
            booking.setUser(user);
        }

        if (dto.getAttractionId() != null &&
                !dto.getAttractionId().equals(booking.getAttraction().getAttractionId())) {
            Attraction attraction = attractionRepository.findById(dto.getAttractionId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Không tìm thấy Attraction id: " + dto.getAttractionId()));
            booking.setAttraction(attraction);
        }

        if (dto.getProviderId() != null) {
            Provider provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
            booking.setProvider(provider);
        }

        if (dto.getStartDate() != null)
            booking.setStartDate(dto.getStartDate());
        if (dto.getEndDate() != null)
            booking.setEndDate(dto.getEndDate());
        if (dto.getNumAdults() != null)
            booking.setNumAdults(dto.getNumAdults());
        if (dto.getTotalPrice() != null)
            booking.setTotalPrice(dto.getTotalPrice());
        if (dto.getCurrencyCode() != null)
            booking.setCurrencyCode(dto.getCurrencyCode());
        if (dto.getBookingStatus() != null)
            booking.setBookingStatus(AttractionBooking.BookingStatus.valueOf(dto.getBookingStatus()));
        if (dto.getETicketUrl() != null)
            booking.setETicketUrl(dto.getETicketUrl());
        if (dto.getQrCodeData() != null)
            booking.setQrCodeData(dto.getQrCodeData());
        if (dto.getChannel() != null)
            booking.setChannel(dto.getChannel());
        if (dto.getHoldUntil() != null)
            booking.setHoldUntil(dto.getHoldUntil());
        if (dto.getProviderSeen() != null)
            booking.setProviderSeen(dto.getProviderSeen());
        if (dto.getProviderNotes() != null)
            booking.setProviderNotes(dto.getProviderNotes());

        AttractionBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã cập nhật Booking ID: {}", updatedBooking.getBookingId());

        return convertToDTO(updatedBooking);
    }

    public AttractionBookingDTO markAsSeenByProvider(Integer bookingId) {
        log.debug("Đánh dấu đã xem Booking ID: {}", bookingId);
        AttractionBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderSeen(true);
        AttractionBooking updated = bookingRepository.save(booking);
        log.info("Đã đánh dấu Booking ID: {} là đã xem", bookingId);

        return convertToDTO(updated);
    }

    public AttractionBookingDTO confirmBooking(Integer bookingId) {
        log.debug("Xác nhận Booking ID: {}", bookingId);
        AttractionBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderConfirmed(1);
        booking.setProviderConfirmedAt(LocalDateTime.now());
        booking.setBookingStatus(AttractionBooking.BookingStatus.confirmed);

        AttractionBooking updated = bookingRepository.save(booking);
        log.info("Đã xác nhận Booking ID: {} lúc {}", bookingId, updated.getProviderConfirmedAt());

        // 🎁 CỘNG ĐIỂM CHO USER
        try {
            pointsService.awardBookingPoints(booking.getUser().getUserId(), "Điểm tham quan", bookingId);
        } catch (Exception e) {
            log.error("Failed to award points for booking {}: {}", bookingId, e.getMessage());
        }

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            User user = booking.getUser();
            Attraction attraction = booking.getAttraction();
            String bookingCode = "ATB" + bookingId;
            String customerName = user.getFullName() != null ? user.getFullName() : user.getEmail();
            String attractionTitle = attraction.getTitle();
            String startDate = booking.getStartDate() != null ? booking.getStartDate().toString() : "N/A";

            // Thông báo in-app cho user
            notificationService.notifyUserAttractionBookingConfirmed(
                    user.getUserId(),
                    attractionTitle,
                    bookingCode);
            log.info("📬 Booking confirmed notification sent to userId: {}", user.getUserId());

            // 📱 GỬI FCM PUSH NOTIFICATION ĐẾN USER
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                String pushTitle = "Đặt điểm tham quan đã được xác nhận";
                String pushBody = String.format(
                        "Đơn đặt '%s' (Mã: %s) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!",
                        attractionTitle, bookingCode);
                fcmService.sendNotificationToDevice(user.getFcmToken(), pushTitle, pushBody, null);
                log.info("📱 FCM push notification sent to user {}, token: {}...", user.getUserId(),
                        user.getFcmToken().substring(0, 20));
            } else {
                log.warn("⚠️ User {} has no FCM token, skipping push notification", user.getUserId());
            }

            // Gửi email cho user
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                emailService.sendAttractionBookingApprovedEmail(
                        user.getEmail(),
                        customerName,
                        attractionTitle,
                        bookingCode,
                        startDate);
                log.info("📧 Booking approved email sent to: {}", user.getEmail());
            }

        } catch (Exception e) {
            log.error("❌ Failed to send confirm notifications/email: {}", e.getMessage());
        }

        return convertToDTO(updated);
    }

    public AttractionBookingDTO cancelBooking(Integer bookingId) {
        log.debug("Hủy Booking ID: {}", bookingId);
        AttractionBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderConfirmed(2);
        booking.setProviderConfirmedAt(LocalDateTime.now());
        booking.setBookingStatus(AttractionBooking.BookingStatus.cancelled);
        AttractionBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã hủy Booking ID: {} lúc {}", bookingId, updatedBooking.getProviderConfirmedAt());

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            User user = booking.getUser();
            Attraction attraction = booking.getAttraction();
            String bookingCode = "ATB" + bookingId;
            String customerName = user.getFullName() != null ? user.getFullName() : user.getEmail();
            String attractionTitle = attraction.getTitle();

            // Thông báo in-app cho user
            notificationService.notifyUserAttractionBookingCancelled(
                    user.getUserId(),
                    attractionTitle,
                    bookingCode);
            log.info("📬 Booking cancelled notification sent to userId: {}", user.getUserId());

            // 📱 GỬI FCM PUSH NOTIFICATION ĐẾN USER
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                String pushTitle = "Đặt điểm tham quan đã bị hủy";
                String pushBody = String.format(
                        "Rất tiếc, đơn đặt '%s' (Mã: %s) của bạn đã bị hủy bởi nhà cung cấp. Vui lòng liên hệ để biết thêm chi tiết.",
                        attractionTitle, bookingCode);
                fcmService.sendNotificationToDevice(user.getFcmToken(), pushTitle, pushBody, null);
                log.info("📱 FCM cancellation push notification sent to user {}, token: {}...", user.getUserId(),
                        user.getFcmToken().substring(0, 20));
            } else {
                log.warn("⚠️ User {} has no FCM token, skipping push notification", user.getUserId());
            }

            // Gửi email cho user
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                emailService.sendAttractionBookingCancelledEmail(
                        user.getEmail(),
                        customerName,
                        attractionTitle,
                        bookingCode);
                log.info("📧 Booking cancelled email sent to: {}", user.getEmail());
            }

        } catch (Exception e) {
            log.error("❌ Failed to send cancel notifications/email: {}", e.getMessage());
        }

        return convertToDTO(updatedBooking);
    }

    public void deleteBooking(Integer bookingId) {
        log.debug("Xóa Booking ID: {}", bookingId);
        AttractionBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        bookingRepository.delete(booking);
        log.info("Đã xóa Booking ID: {}", bookingId);
    }

    public void cancelExpiredPendingBookings() {
        log.debug("Hủy các booking pending đã hết hạn");
        LocalDateTime now = LocalDateTime.now();
        List<AttractionBooking> expiredBookings = bookingRepository.findExpiredPendingBookings(now);

        for (AttractionBooking booking : expiredBookings) {
            booking.setBookingStatus(AttractionBooking.BookingStatus.cancelled);
        }

        bookingRepository.saveAll(expiredBookings);
        log.info("Đã hủy {} booking pending hết hạn", expiredBookings.size());
    }

    private AttractionBookingDTO convertToDTO(AttractionBooking booking) {
        return AttractionBookingDTO.builder()
                .bookingId(booking.getBookingId())
                .userId(booking.getUser() != null ? booking.getUser().getUserId() : null)
                .attractionId(booking.getAttraction() != null ? booking.getAttraction().getAttractionId() : null)
                .bookingDate(booking.getBookingDate())
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .numAdults(booking.getNumAdults())
                .totalPrice(booking.getTotalPrice())
                .currencyCode(booking.getCurrencyCode())
                .bookingStatus(booking.getBookingStatus() != null ? booking.getBookingStatus().name() : null)
                .eTicketUrl(booking.getETicketUrl())
                .qrCodeData(booking.getQrCodeData())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .providerId(booking.getProvider() != null ? booking.getProvider().getProviderId() : null)
                .channel(booking.getChannel())
                .holdUntil(booking.getHoldUntil())
                .providerSeen(booking.isProviderSeen())
                .providerNotes(booking.getProviderNotes())
                .providerConfirmed(booking.getProviderConfirmed())
                .providerConfirmedAt(booking.getProviderConfirmedAt())
                .build();
    }

    /**
     * Fix missing providerId for existing bookings
     * Updates all bookings that don't have a provider set by getting it from their
     * attraction
     * 
     * @return Number of bookings updated
     */
    @Transactional
    public int fixMissingProviderIds() {
        log.info("🔧 Bắt đầu fix providerId cho các attraction bookings...");

        // Find all bookings without provider
        List<AttractionBooking> bookingsWithoutProvider = bookingRepository.findAll().stream()
                .filter(booking -> booking.getProvider() == null && booking.getAttraction() != null)
                .collect(Collectors.toList());

        log.info("📊 Tìm thấy {} bookings không có providerId", bookingsWithoutProvider.size());

        int updatedCount = 0;
        for (AttractionBooking booking : bookingsWithoutProvider) {
            Attraction attraction = booking.getAttraction();
            if (attraction.getProvider() != null) {
                booking.setProvider(attraction.getProvider());
                bookingRepository.save(booking);
                updatedCount++;
                log.info("✅ Updated Booking ID: {} với Provider ID: {}",
                        booking.getBookingId(),
                        attraction.getProvider().getProviderId());
            } else {
                log.warn("⚠️ Attraction ID: {} không có Provider!", attraction.getAttractionId());
            }
        }

        log.info("🎉 Đã cập nhật {} bookings với providerId", updatedCount);
        return updatedCount;
    }
}
