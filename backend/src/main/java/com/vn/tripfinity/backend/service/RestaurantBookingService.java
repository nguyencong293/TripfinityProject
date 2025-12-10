package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.RestaurantBookingDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.model.RestaurantBooking;
import com.vn.tripfinity.backend.model.RestaurantPayment;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.RestaurantBookingRepository;
import com.vn.tripfinity.backend.repository.RestaurantPaymentRepository;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RestaurantBookingService {

    private final RestaurantBookingRepository bookingRepository;
    private final RestaurantPaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final ProviderRepository providerRepository;
    private final NotificationService notificationService;
    private final EmailService emailService;
    private final FCMService fcmService;

    public List<RestaurantBookingDTO> getAllBookings() {
        log.debug("Lấy toàn bộ restaurant bookings");
        return bookingRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public RestaurantBookingDTO getBookingById(Integer bookingId) {
        log.debug("Lấy restaurant booking theo ID: {}", bookingId);
        RestaurantBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));
        return convertToDTO(booking);
    }

    public List<RestaurantBookingDTO> getBookingsByUser(Integer userId) {
        log.debug("Lấy danh sách bookings của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<RestaurantBooking> bookings = bookingRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} bookings của User ID: {}", bookings.size(), userId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantBookingDTO> getBookingsByRestaurant(Integer restaurantId) {
        log.debug("Lấy danh sách bookings của Restaurant ID: {}", restaurantId);
        restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + restaurantId));

        List<RestaurantBooking> bookings = bookingRepository.findByRestaurant_RestaurantId(restaurantId);
        log.info("Tìm thấy {} bookings của Restaurant ID: {}", bookings.size(), restaurantId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantBookingDTO> getBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách bookings của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<RestaurantBooking> bookings = bookingRepository.findByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} bookings của Provider ID: {}", bookings.size(), providerId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantBookingDTO> getBookingsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách bookings của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        RestaurantBooking.BookingStatus bookingStatus = RestaurantBooking.BookingStatus.valueOf(status);
        List<RestaurantBooking> bookings = bookingRepository.findByUserAndStatus(userId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantBookingDTO> getBookingsByProviderAndStatus(Integer providerId, String status) {
        log.debug("Lấy danh sách bookings của Provider ID: {} với status: {}", providerId, status);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        RestaurantBooking.BookingStatus bookingStatus = RestaurantBooking.BookingStatus.valueOf(status);
        List<RestaurantBooking> bookings = bookingRepository.findByProviderAndStatus(providerId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantBookingDTO> getUnseenBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách bookings chưa xem của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<RestaurantBooking> bookings = bookingRepository.findByProviderAndSeen(providerId, false);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public RestaurantBookingDTO createBooking(RestaurantBookingDTO dto) {
        log.debug("Tạo Booking: {}", dto);
        log.info("🔍 Booking request - userId: {}, restaurantId: {}, numAdults: {}", 
            dto.getUserId(), dto.getRestaurantId(), dto.getNumAdults());

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Restaurant restaurant = restaurantRepository.findById(dto.getRestaurantId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + dto.getRestaurantId()));

        log.info("🍴 Restaurant info - restaurantId: {}, title: {}", 
            restaurant.getRestaurantId(), restaurant.getTitle());

        // AUTO-FIX: Tự động lấy providerId từ restaurant nếu không được cung cấp
        Provider provider = null;
        if (dto.getProviderId() != null) {
            provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        } else if (restaurant.getProvider() != null) {
            // Lấy provider từ restaurant
            provider = restaurant.getProvider();
            log.info("✅ Tự động lấy Provider ID: {} từ Restaurant ID: {}", provider.getProviderId(), restaurant.getRestaurantId());
        }

        RestaurantBooking.BookingStatus bookingStatus = dto.getBookingStatus() != null
                ? RestaurantBooking.BookingStatus.valueOf(dto.getBookingStatus())
                : RestaurantBooking.BookingStatus.pending;

        RestaurantBooking booking = RestaurantBooking.builder()
                .user(user)
                .restaurant(restaurant)
                .provider(provider)
                .bookingDate(dto.getBookingDate() != null ? dto.getBookingDate() : LocalDateTime.now())
                .reservationDate(dto.getReservationDate())
                .reservationTime(dto.getReservationTime())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .numAdults(dto.getNumAdults())
                .specialRequests(dto.getSpecialRequests())
                .totalPrice(dto.getTotalPrice())
                .depositAmount(dto.getDepositAmount())
                .currencyCode(dto.getCurrencyCode())
                .bookingStatus(bookingStatus)
                .eTicketUrl(dto.getETicketUrl())
                .qrCodeData(dto.getQrCodeData())
                .channel(dto.getChannel())
                .holdUntil(dto.getHoldUntil())
                .providerSeen(false)
                .providerNotes(dto.getProviderNotes())
                .build();

        RestaurantBooking savedBooking = bookingRepository.save(booking);
        log.info("✅ Tạo Booking ID: {}", savedBooking.getBookingId());

        // Auto-create payment record
        createPaymentRecord(savedBooking, dto.getPaymentMethod());

        // 📧 GỬI THÔNG BÁO VÀ EMAIL CHO USER
        try {
            String bookingCode = "RBK" + savedBooking.getBookingId();
            String customerName = user.getFullName() != null ? user.getFullName() : user.getEmail();
            String restaurantTitle = restaurant.getTitle();
            String reservationDate = dto.getStartDate() != null ? dto.getStartDate().toString() : "N/A";
            String totalPrice = String.format("%,.0f", dto.getTotalPrice());
            String paymentMethod = dto.getPaymentMethod() != null ? dto.getPaymentMethod() : "counter";

            // Thông báo in-app cho user
            notificationService.notifyUserRestaurantBookingCreated(
                user.getUserId(), 
                restaurantTitle, 
                bookingCode
            );
            log.info("📬 User notification created for userId: {}", user.getUserId());

            // Gửi email cho user
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                emailService.sendRestaurantBookingConfirmationEmail(
                    user.getEmail(),
                    customerName,
                    restaurantTitle,
                    bookingCode,
                    reservationDate,
                    totalPrice,
                    paymentMethod,
                    dto.getNumAdults()
                );
                log.info("📧 Confirmation email sent to: {}", user.getEmail());
            }

            // Thông báo in-app cho supplier
            if (provider != null && provider.getUser() != null) {
                Integer supplierId = provider.getUser().getUserId();
                notificationService.notifySupplierNewRestaurantBooking(
                    supplierId,
                    restaurantTitle,
                    bookingCode,
                    customerName
                );
                log.info("📬 Supplier notification created for supplierId: {}", supplierId);
                
                // GỬI FCM PUSH NOTIFICATION ĐẾN SUPPLIER
                String supplierFcmToken = provider.getUser().getFcmToken();
                if (supplierFcmToken != null && !supplierFcmToken.isEmpty()) {
                    fcmService.sendNotificationToDevice(
                        supplierFcmToken,
                        "Đơn đặt bàn mới",
                        "Khách hàng " + customerName + " vừa đặt bàn tại " + restaurantTitle,
                        java.util.Map.of(
                            "type", "new_restaurant_booking",
                            "bookingId", savedBooking.getBookingId().toString(),
                            "restaurantId", restaurant.getRestaurantId().toString()
                        )
                    );
                    log.info("📱 FCM notification sent to supplier");
                }
                
                // Gửi email cho supplier
                String supplierEmail = provider.getUser().getEmail();
                String supplierName = provider.getUser().getFullName() != null 
                    ? provider.getUser().getFullName() 
                    : "Supplier";
                
                if (supplierEmail != null && !supplierEmail.isEmpty()) {
                    emailService.sendSupplierNewRestaurantBookingEmail(
                        supplierEmail,
                        supplierName,
                        restaurantTitle,
                        bookingCode,
                        customerName,
                        reservationDate,
                        totalPrice,
                        paymentMethod,
                        dto.getNumAdults()
                    );
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
     * Create payment record for booking
     * 
     * @param booking          The restaurant booking
     * @param paymentMethodStr Payment method (counter, zalopay, etc.)
     */
    private void createPaymentRecord(RestaurantBooking booking, String paymentMethodStr) {
        try {
            RestaurantPayment.PaymentMethod paymentMethod;
            RestaurantPayment.PaymentStatus paymentStatus;

            // Parse payment method
            if (paymentMethodStr != null && !paymentMethodStr.isEmpty()) {
                paymentMethod = RestaurantPayment.PaymentMethod.valueOf(paymentMethodStr.toLowerCase());
            } else {
                paymentMethod = RestaurantPayment.PaymentMethod.counter; // Default
            }

            // Set payment status based on method
            if (paymentMethod == RestaurantPayment.PaymentMethod.counter) {
                paymentStatus = RestaurantPayment.PaymentStatus.pending; // Counter: pending
            } else {
                paymentStatus = RestaurantPayment.PaymentStatus.success; // Online: success
            }

            // Generate unique transaction ID
            String transactionId = "REST-" + booking.getBookingId() + "-" + System.currentTimeMillis();

            RestaurantPayment payment = RestaurantPayment.builder()
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
            log.info("✅ Created payment record for booking {}: method={}, status={}", 
                booking.getBookingId(), paymentMethod, paymentStatus);

        } catch (Exception e) {
            log.error("❌ Failed to create payment record for booking {}: {}", 
                booking.getBookingId(), e.getMessage());
            // Don't throw - allow booking to be created even if payment record fails
        }
    }

    public RestaurantBookingDTO updateBooking(Integer bookingId, RestaurantBookingDTO dto) {
        log.debug("Cập nhật Booking ID: {}", bookingId);
        RestaurantBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        if (dto.getReservationDate() != null) {
            booking.setReservationDate(dto.getReservationDate());
        }
        if (dto.getReservationTime() != null) {
            booking.setReservationTime(dto.getReservationTime());
        }
        if (dto.getStartDate() != null) {
            booking.setStartDate(dto.getStartDate());
        }
        if (dto.getEndDate() != null) {
            booking.setEndDate(dto.getEndDate());
        }
        if (dto.getNumAdults() != null) {
            booking.setNumAdults(dto.getNumAdults());
        }
        if (dto.getSpecialRequests() != null) {
            booking.setSpecialRequests(dto.getSpecialRequests());
        }
        if (dto.getTotalPrice() != null) {
            booking.setTotalPrice(dto.getTotalPrice());
        }
        if (dto.getDepositAmount() != null) {
            booking.setDepositAmount(dto.getDepositAmount());
        }
        if (dto.getCurrencyCode() != null) {
            booking.setCurrencyCode(dto.getCurrencyCode());
        }
        if (dto.getBookingStatus() != null) {
            booking.setBookingStatus(RestaurantBooking.BookingStatus.valueOf(dto.getBookingStatus()));
        }
        if (dto.getETicketUrl() != null) {
            booking.setETicketUrl(dto.getETicketUrl());
        }
        if (dto.getQrCodeData() != null) {
            booking.setQrCodeData(dto.getQrCodeData());
        }
        if (dto.getChannel() != null) {
            booking.setChannel(dto.getChannel());
        }
        if (dto.getHoldUntil() != null) {
            booking.setHoldUntil(dto.getHoldUntil());
        }
        if (dto.getProviderSeen() != null) {
            booking.setProviderSeen(dto.getProviderSeen());
        }
        if (dto.getProviderNotes() != null) {
            booking.setProviderNotes(dto.getProviderNotes());
        }

        RestaurantBooking updated = bookingRepository.save(booking);
        log.info("✅ Cập nhật Booking ID: {}", updated.getBookingId());

        return convertToDTO(updated);
    }

    public RestaurantBookingDTO updateBookingStatus(Integer bookingId, String status) {
        log.debug("Cập nhật status của Booking ID: {} sang {}", bookingId, status);
        RestaurantBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        RestaurantBooking.BookingStatus newStatus = RestaurantBooking.BookingStatus.valueOf(status);
        booking.setBookingStatus(newStatus);

        // Update provider_confirmed based on status
        if (newStatus == RestaurantBooking.BookingStatus.confirmed) {
            booking.setProviderConfirmed(1);
            booking.setProviderConfirmedAt(LocalDateTime.now());
            log.debug("Provider đã xác nhận Booking ID: {}", bookingId);
        } else if (newStatus == RestaurantBooking.BookingStatus.cancelled) {
            booking.setProviderConfirmed(2);
            booking.setProviderConfirmedAt(LocalDateTime.now());
            log.debug("Provider đã hủy Booking ID: {}", bookingId);
        }

        RestaurantBooking updated = bookingRepository.save(booking);
        log.info("✅ Đã cập nhật status Booking ID: {} sang {}", updated.getBookingId(), newStatus);

        // 📧 GỬI THÔNG BÁO KHI STATUS THAY ĐỔI
        try {
            User user = booking.getUser();
            Restaurant restaurant = booking.getRestaurant();
            String bookingCode = "RBK" + booking.getBookingId();
            String restaurantTitle = restaurant.getTitle();

            if (newStatus == RestaurantBooking.BookingStatus.confirmed) {
                // Thông báo cho user khi booking được xác nhận
                notificationService.notifyUserRestaurantBookingConfirmed(
                    user.getUserId(), 
                    restaurantTitle, 
                    bookingCode
                );
                log.info("📬 Booking confirmed notification sent to userId: {}", user.getUserId());
                
                // 📱 GỬI FCM PUSH NOTIFICATION ĐẾN USER
                if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                    String pushTitle = "Đặt bàn đã được xác nhận";
                    String pushBody = "Đơn đặt bàn tại " + restaurantTitle + " đã được xác nhận";
                    fcmService.sendNotificationToDevice(user.getFcmToken(), pushTitle, pushBody, null);
                    log.info("📱 FCM push notification sent to user {}, token: {}...", user.getUserId(),
                            user.getFcmToken().substring(0, Math.min(20, user.getFcmToken().length())));
                } else {
                    log.warn("⚠️ User {} has no FCM token, skipping push notification", user.getUserId());
                }

            } else if (newStatus == RestaurantBooking.BookingStatus.cancelled) {
                // Thông báo cho user khi booking bị hủy
                notificationService.notifyUserRestaurantBookingCancelled(
                    user.getUserId(), 
                    restaurantTitle, 
                    bookingCode
                );
                log.info("📬 Booking cancelled notification sent to userId: {}", user.getUserId());
                
                // 📱 GỬI FCM PUSH NOTIFICATION ĐẾN USER
                if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                    String pushTitle = "Đặt bàn đã bị hủy";
                    String pushBody = "Đơn đặt bàn tại " + restaurantTitle + " đã bị hủy";
                    fcmService.sendNotificationToDevice(user.getFcmToken(), pushTitle, pushBody, null);
                    log.info("📱 FCM push notification sent to user {}, token: {}...", user.getUserId(),
                            user.getFcmToken().substring(0, Math.min(20, user.getFcmToken().length())));
                } else {
                    log.warn("⚠️ User {} has no FCM token, skipping push notification", user.getUserId());
                }
            }

        } catch (Exception e) {
            log.error("❌ Failed to send status change notifications: {}", e.getMessage());
            // Không throw exception để không block status update
        }

        return convertToDTO(updated);
    }

    public void deleteBooking(Integer bookingId) {
        log.debug("Xóa Booking ID: {}", bookingId);
        RestaurantBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        bookingRepository.delete(booking);
        log.info("✅ Đã xóa Booking ID: {}", bookingId);
    }

    public RestaurantBookingDTO markAsSeen(Integer bookingId) {
        log.debug("Đánh dấu đã xem Booking ID: {}", bookingId);
        RestaurantBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderSeen(true);
        RestaurantBooking updated = bookingRepository.save(booking);
        log.info("✅ Đã đánh dấu đã xem Booking ID: {}", bookingId);

        return convertToDTO(updated);
    }

    private RestaurantBookingDTO convertToDTO(RestaurantBooking booking) {
        return RestaurantBookingDTO.builder()
                .bookingId(booking.getBookingId())
                .userId(booking.getUser().getUserId())
                .restaurantId(booking.getRestaurant().getRestaurantId())
                .bookingDate(booking.getBookingDate())
                .reservationDate(booking.getReservationDate())
                .reservationTime(booking.getReservationTime())
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .numAdults(booking.getNumAdults())
                .specialRequests(booking.getSpecialRequests())
                .totalPrice(booking.getTotalPrice())
                .depositAmount(booking.getDepositAmount())
                .currencyCode(booking.getCurrencyCode())
                .bookingStatus(booking.getBookingStatus().name())
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
}
