package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.TourBookingDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Tour;
import com.vn.tripfinity.backend.model.TourBooking;
import com.vn.tripfinity.backend.model.TourPayment;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.TourBookingRepository;
import com.vn.tripfinity.backend.repository.TourPaymentRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TourBookingService {

    private final TourBookingRepository bookingRepository;
    private final TourPaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final TourRepository tourRepository;
    private final ProviderRepository providerRepository;
    private final NotificationService notificationService;
    private final FCMService fcmService;

    public List<TourBookingDTO> getAllBookings() {
        log.debug("Lấy toàn bộ tour bookings");
        return bookingRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TourBookingDTO getBookingById(Integer bookingId) {
        log.debug("Lấy tour booking theo ID: {}", bookingId);
        TourBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));
        return convertToDTO(booking);
    }

    public List<TourBookingDTO> getBookingsByUser(Integer userId) {
        log.debug("Lấy danh sách tour bookings của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<TourBooking> bookings = bookingRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} tour bookings của User ID: {}", bookings.size(), userId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourBookingDTO> getBookingsByTour(Integer tourId) {
        log.debug("Lấy danh sách bookings của Tour ID: {}", tourId);
        tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        List<TourBooking> bookings = bookingRepository.findByTour_TourId(tourId);
        log.info("Tìm thấy {} bookings của Tour ID: {}", bookings.size(), tourId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourBookingDTO> getBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách tour bookings của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<TourBooking> bookings = bookingRepository.findByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} tour bookings của Provider ID: {}", bookings.size(), providerId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourBookingDTO> getBookingsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách tour bookings của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        TourBooking.BookingStatus bookingStatus = TourBooking.BookingStatus.valueOf(status);
        List<TourBooking> bookings = bookingRepository.findByUserAndStatus(userId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourBookingDTO> getBookingsByProviderAndStatus(Integer providerId, String status) {
        log.debug("Lấy danh sách tour bookings của Provider ID: {} với status: {}", providerId, status);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        TourBooking.BookingStatus bookingStatus = TourBooking.BookingStatus.valueOf(status);
        List<TourBooking> bookings = bookingRepository.findByProviderAndStatus(providerId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourBookingDTO> getUnseenBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách tour bookings chưa xem của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<TourBooking> bookings = bookingRepository.findByProviderAndSeen(providerId, false);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TourBookingDTO createBooking(TourBookingDTO dto) {
        log.debug("Tạo Tour Booking: {}", dto);
        log.info("🔍 Tour Booking request - userId: {}, tourId: {}, numAdults: {}", 
            dto.getUserId(), dto.getTourId(), dto.getNumAdults());

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Tour tour = tourRepository.findById(dto.getTourId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + dto.getTourId()));

        log.info("🎫 Tour info - tourId: {}, title: {}", tour.getTourId(), tour.getTitle());

        // AUTO-FIX: Tự động lấy providerId từ tour nếu không được cung cấp
        Provider provider = null;
        if (dto.getProviderId() != null) {
            provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        } else if (tour.getProvider() != null) {
            // Lấy provider từ tour
            provider = tour.getProvider();
            log.info("✅ Tự động lấy Provider ID: {} từ Tour ID: {}", provider.getProviderId(), tour.getTourId());
        }

        TourBooking.BookingStatus bookingStatus = dto.getBookingStatus() != null
                ? TourBooking.BookingStatus.valueOf(dto.getBookingStatus())
                : TourBooking.BookingStatus.pending;

        TourBooking booking = TourBooking.builder()
                .user(user)
                .tour(tour)
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
                .providerNotes(dto.getProviderNotes())
                .build();

        TourBooking savedBooking = bookingRepository.save(booking);
        log.info("✅ Tạo Tour Booking ID: {}", savedBooking.getBookingId());

        // Auto-create payment record
        createPaymentRecord(savedBooking, dto.getPaymentMethod());

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            String bookingCode = "TBK" + savedBooking.getBookingId();
            String customerName = user.getFullName() != null ? user.getFullName() : user.getEmail();
            String tourTitle = tour.getTitle();

            // Thông báo in-app cho user
            notificationService.notifyUserBookingCreated(
                user.getUserId(), 
                tourTitle, 
                bookingCode
            );
            log.info("📬 User notification created for userId: {}", user.getUserId());

            // Gửi email cho user (TODO: Implement in EmailService)
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                log.warn("⚠️ Tour confirmation email not sent - method not implemented yet");
            }

            // Thông báo in-app cho supplier
            if (provider != null && provider.getUser() != null) {
                Integer supplierId = provider.getUser().getUserId();
                // Use existing method for hotel, adapt for tour
                notificationService.notifySupplierNewBooking(
                    supplierId,
                    tourTitle,
                    bookingCode,
                    customerName
                );
                log.info("📬 Supplier notification created for supplierId: {}", supplierId);
                
                // GỬI FCM PUSH NOTIFICATION ĐẾN SUPPLIER
                String supplierFcmToken = provider.getUser().getFcmToken();
                if (supplierFcmToken != null && !supplierFcmToken.isEmpty()) {
                    fcmService.sendNotificationToDevice(
                        supplierFcmToken,
                        "Đơn đặt tour mới",
                        "Khách hàng " + customerName + " vừa đặt tour " + tourTitle,
                        java.util.Map.of(
                            "type", "new_tour_booking",
                            "bookingId", savedBooking.getBookingId().toString(),
                            "tourId", tour.getTourId().toString()
                        )
                    );
                    log.info("📱 FCM notification sent to supplier");
                }
                
                // Gửi email cho supplier (TODO: Implement in EmailService)
                String supplierEmail = provider.getUser().getEmail();
                if (supplierEmail != null && !supplierEmail.isEmpty()) {
                    log.warn("⚠️ Supplier tour booking email not sent - method not implemented yet");
                }
            }

        } catch (Exception e) {
            log.error("❌ Failed to send notifications/email: {}", e.getMessage());
            // Không throw exception để không block booking creation
        }

        return convertToDTO(savedBooking);
    }

    /**
     * Create payment record for tour booking
     * 
     * @param booking          The tour booking
     * @param paymentMethodStr Payment method (counter, zalopay, etc.)
     */
    private void createPaymentRecord(TourBooking booking, String paymentMethodStr) {
        try {
            TourPayment.PaymentMethod paymentMethod;
            TourPayment.PaymentStatus paymentStatus;

            // Parse payment method
            if (paymentMethodStr != null && !paymentMethodStr.isEmpty()) {
                paymentMethod = TourPayment.PaymentMethod.valueOf(paymentMethodStr.toLowerCase());
            } else {
                paymentMethod = TourPayment.PaymentMethod.counter; // Default
            }

            // Set payment status based on method
            if (paymentMethod == TourPayment.PaymentMethod.counter) {
                paymentStatus = TourPayment.PaymentStatus.pending; // Pay later
            } else {
                paymentStatus = TourPayment.PaymentStatus.success; // Online payment already completed
            }

            // Generate transaction ID
            String transactionId = "TOUR_TXN_" + booking.getBookingId() + "_" + System.currentTimeMillis();

            TourPayment payment = TourPayment.builder()
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
            log.info("✅ Created payment record for tour booking #{} with method: {}, status: {}",
                    booking.getBookingId(), paymentMethod, paymentStatus);

        } catch (Exception e) {
            log.error("Failed to create payment record for tour booking #{}: {}", booking.getBookingId(), e.getMessage());
            // Don't fail the booking creation if payment record fails
        }
    }

    public TourBookingDTO updateBooking(Integer bookingId, TourBookingDTO dto) {
        log.debug("Cập nhật Tour Booking ID: {}", bookingId);
        TourBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        if (dto.getUserId() != null && !dto.getUserId().equals(booking.getUser().getUserId())) {
            User user = userRepository.findById(dto.getUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));
            booking.setUser(user);
        }

        if (dto.getTourId() != null && !dto.getTourId().equals(booking.getTour().getTourId())) {
            Tour tour = tourRepository.findById(dto.getTourId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + dto.getTourId()));
            booking.setTour(tour);
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
            booking.setBookingStatus(TourBooking.BookingStatus.valueOf(dto.getBookingStatus()));
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

        TourBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã cập nhật Tour Booking ID: {}", updatedBooking.getBookingId());

        return convertToDTO(updatedBooking);
    }

    public TourBookingDTO markAsSeenByProvider(Integer bookingId) {
        log.debug("Đánh dấu đã xem Tour Booking ID: {}", bookingId);
        TourBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderSeen(true);
        TourBooking updated = bookingRepository.save(booking);
        log.info("Đã đánh dấu Tour Booking ID: {} là đã xem", bookingId);

        return convertToDTO(updated);
    }

    public TourBookingDTO confirmBooking(Integer bookingId) {
        log.debug("Xác nhận Tour Booking ID: {}", bookingId);
        TourBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setBookingStatus(TourBooking.BookingStatus.confirmed);
        booking.setProviderConfirmed(1); // 1 = confirmed by provider
        booking.setProviderConfirmedAt(java.time.LocalDateTime.now());
        
        TourBooking updated = bookingRepository.save(booking);
        log.info("Đã xác nhận Tour Booking ID: {} - providerConfirmed=1", bookingId);

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            User user = booking.getUser();
            Tour tour = booking.getTour();
            String bookingCode = "TBK" + bookingId;
            String tourTitle = tour.getTitle();

            // Thông báo in-app cho user
            notificationService.notifyUserBookingConfirmed(
                user.getUserId(),
                tourTitle,
                bookingCode
            );
            log.info("📬 Tour booking confirmed notification sent to userId: {}", user.getUserId());

            // 📱 GỬI FCM PUSH NOTIFICATION ĐẾN USER
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                String pushTitle = "Đặt tour đã được xác nhận";
                String pushBody = String.format("Đơn đặt tour '%s' (Mã: %s) của bạn đã được xác nhận. Chúng tôi rất mong được phục vụ bạn!", tourTitle, bookingCode);
                fcmService.sendNotificationToDevice(user.getFcmToken(), pushTitle, pushBody, null);
                log.info("📱 FCM push notification sent to user {}", user.getUserId());
            }

            // Gửi email cho user (TODO: Implement in EmailService)
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                log.warn("⚠️ Tour booking approved email not sent - method not implemented yet");
            }

        } catch (Exception e) {
            log.error("❌ Failed to send confirm notifications/email: {}", e.getMessage());
        }

        return convertToDTO(updated);
    }

    public TourBookingDTO cancelBooking(Integer bookingId) {
        log.debug("Hủy Tour Booking ID: {}", bookingId);
        TourBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setBookingStatus(TourBooking.BookingStatus.cancelled);
        booking.setProviderConfirmed(2); // 2 = cancelled by provider
        booking.setProviderConfirmedAt(java.time.LocalDateTime.now());
        TourBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã hủy Tour Booking ID: {} - providerConfirmed=2", bookingId);

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            User user = booking.getUser();
            Tour tour = booking.getTour();
            String bookingCode = "TBK" + bookingId;
            String tourTitle = tour.getTitle();

            // Thông báo in-app cho user
            notificationService.notifyUserBookingCancelled(
                user.getUserId(),
                tourTitle,
                bookingCode
            );
            log.info("📬 Tour booking cancelled notification sent to userId: {}", user.getUserId());

            // 📱 GỬI FCM PUSH NOTIFICATION ĐẾN USER
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                String pushTitle = "Đặt tour đã bị hủy";
                String pushBody = String.format("Rất tiếc, đơn đặt tour '%s' (Mã: %s) của bạn đã bị hủy bởi nhà cung cấp.", tourTitle, bookingCode);
                fcmService.sendNotificationToDevice(user.getFcmToken(), pushTitle, pushBody, null);
                log.info("📱 FCM cancellation push notification sent to user {}", user.getUserId());
            }

            // Gửi email cho user (TODO: Implement in EmailService)
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                log.warn("⚠️ Tour booking cancelled email not sent - method not implemented yet");
            }

        } catch (Exception e) {
            log.error("❌ Failed to send cancel notifications/email: {}", e.getMessage());
        }

        return convertToDTO(updatedBooking);
    }

    public void deleteBooking(Integer bookingId) {
        log.debug("Xóa Tour Booking ID: {}", bookingId);
        TourBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        bookingRepository.delete(booking);
        log.info("Đã xóa Tour Booking ID: {}", bookingId);
    }

    public void cancelExpiredPendingBookings() {
        log.debug("Hủy các tour booking pending đã hết hạn");
        LocalDateTime now = LocalDateTime.now();
        List<TourBooking> expiredBookings = bookingRepository.findExpiredPendingBookings(now);

        for (TourBooking booking : expiredBookings) {
            booking.setBookingStatus(TourBooking.BookingStatus.cancelled);
        }

        bookingRepository.saveAll(expiredBookings);
        log.info("Đã hủy {} tour booking pending hết hạn", expiredBookings.size());
    }

    private TourBookingDTO convertToDTO(TourBooking booking) {
        return TourBookingDTO.builder()
                .bookingId(booking.getBookingId())
                .userId(booking.getUser() != null ? booking.getUser().getUserId() : null)
                .tourId(booking.getTour() != null ? booking.getTour().getTourId() : null)
                .bookingDate(booking.getBookingDate())
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .numAdults(booking.getNumAdults())
                .specialRequests(booking.getSpecialRequests())
                .totalPrice(booking.getTotalPrice())
                .depositAmount(booking.getDepositAmount())
                .currencyCode(booking.getCurrencyCode())
                .paymentMethod(booking.getPaymentMethod())
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
     * Fix missing providerId for existing tour bookings
     * Updates all bookings that don't have a provider set by getting it from their tour
     * 
     * @return Number of bookings updated
     */
    @Transactional
    public int fixMissingProviderIds() {
        log.info("🔧 Bắt đầu fix providerId cho các tour bookings...");
        
        // Find all bookings without provider
        List<TourBooking> bookingsWithoutProvider = bookingRepository.findAll().stream()
                .filter(booking -> booking.getProvider() == null && booking.getTour() != null)
                .collect(Collectors.toList());
        
        log.info("📊 Tìm thấy {} tour bookings không có providerId", bookingsWithoutProvider.size());
        
        int updatedCount = 0;
        for (TourBooking booking : bookingsWithoutProvider) {
            Tour tour = booking.getTour();
            if (tour.getProvider() != null) {
                booking.setProvider(tour.getProvider());
                bookingRepository.save(booking);
                updatedCount++;
                log.info("✅ Updated Tour Booking ID: {} với Provider ID: {}", 
                    booking.getBookingId(), 
                    tour.getProvider().getProviderId());
            } else {
                log.warn("⚠️ Tour ID: {} không có Provider!", tour.getTourId());
            }
        }
        
        log.info("🎉 Đã cập nhật {} tour bookings với providerId", updatedCount);
        return updatedCount;
    }
}
