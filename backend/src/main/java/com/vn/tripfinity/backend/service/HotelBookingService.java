package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.HotelBookingDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelBooking;
import com.vn.tripfinity.backend.model.HotelPayment;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.HotelBookingRepository;
import com.vn.tripfinity.backend.repository.HotelPaymentRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelBookingService {

    private final HotelBookingRepository bookingRepository;
    private final HotelPaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final ProviderRepository providerRepository;

    public List<HotelBookingDTO> getAllBookings() {
        log.debug("Lấy toàn bộ hotel bookings");
        return bookingRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelBookingDTO getBookingById(Integer bookingId) {
        log.debug("Lấy hotel booking theo ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));
        return convertToDTO(booking);
    }

    public List<HotelBookingDTO> getBookingsByUser(Integer userId) {
        log.debug("Lấy danh sách bookings của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<HotelBooking> bookings = bookingRepository.findByUser_UserId(userId);
        log.info("Tìm thấy {} bookings của User ID: {}", bookings.size(), userId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelBookingDTO> getBookingsByHotel(Integer hotelId) {
        log.debug("Lấy danh sách bookings của Hotel ID: {}", hotelId);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelBooking> bookings = bookingRepository.findByHotel_HotelId(hotelId);
        log.info("Tìm thấy {} bookings của Hotel ID: {}", bookings.size(), hotelId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelBookingDTO> getBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách bookings của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<HotelBooking> bookings = bookingRepository.findByProvider_ProviderId(providerId);
        log.info("Tìm thấy {} bookings của Provider ID: {}", bookings.size(), providerId);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelBookingDTO> getBookingsByUserAndStatus(Integer userId, String status) {
        log.debug("Lấy danh sách bookings của User ID: {} với status: {}", userId, status);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        HotelBooking.BookingStatus bookingStatus = HotelBooking.BookingStatus.valueOf(status);
        List<HotelBooking> bookings = bookingRepository.findByUserAndStatus(userId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelBookingDTO> getBookingsByProviderAndStatus(Integer providerId, String status) {
        log.debug("Lấy danh sách bookings của Provider ID: {} với status: {}", providerId, status);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        HotelBooking.BookingStatus bookingStatus = HotelBooking.BookingStatus.valueOf(status);
        List<HotelBooking> bookings = bookingRepository.findByProviderAndStatus(providerId, bookingStatus);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelBookingDTO> getUnseenBookingsByProvider(Integer providerId) {
        log.debug("Lấy danh sách bookings chưa xem của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<HotelBooking> bookings = bookingRepository.findByProviderAndSeen(providerId, false);

        return bookings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelBookingDTO createBooking(HotelBookingDTO dto) {
        log.debug("Tạo Booking: {}", dto);
        log.info("🔍 Booking request - userId: {}, hotelId: {}, rooms: {}, numAdults: {}", 
            dto.getUserId(), dto.getHotelId(), dto.getRooms(), dto.getNumAdults());

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        log.info("🏨 Hotel info - hotelId: {}, title: {}, totalRooms: {}, capacity: {}", 
            hotel.getHotelId(), hotel.getTitle(), hotel.getTotalRooms(), hotel.getCapacity());

        // Đặt giá trị mặc định cho rooms nếu null
        if (dto.getRooms() == null) {
            // Thử parse từ provider_notes nếu có (để tương thích với data cũ)
            Integer roomsFromNotes = parseRoomsFromNotes(dto.getProviderNotes());
            if (roomsFromNotes != null) {
                log.warn("⚠️ Field 'rooms' is null, parsed from provider_notes: {}", roomsFromNotes);
                dto.setRooms(roomsFromNotes);
            } else {
                log.warn("⚠️ Field 'rooms' is null, setting default to 1");
                dto.setRooms(1);
            }
        }

        // Validate số phòng và sức chứa còn lại
        validateAvailability(hotel, dto.getRooms(), dto.getNumAdults());

        // AUTO-FIX: Tự động lấy providerId từ hotel nếu không được cung cấp
        Provider provider = null;
        if (dto.getProviderId() != null) {
            provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
        } else if (hotel.getProvider() != null) {
            // Lấy provider từ hotel
            provider = hotel.getProvider();
            log.info("✅ Tự động lấy Provider ID: {} từ Hotel ID: {}", provider.getProviderId(), hotel.getHotelId());
        }

        HotelBooking.BookingStatus bookingStatus = dto.getBookingStatus() != null
                ? HotelBooking.BookingStatus.valueOf(dto.getBookingStatus())
                : HotelBooking.BookingStatus.pending;

        HotelBooking booking = HotelBooking.builder()
                .user(user)
                .hotel(hotel)
                .provider(provider)
                .bookingDate(dto.getBookingDate() != null ? dto.getBookingDate() : LocalDateTime.now())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .numAdults(dto.getNumAdults())
                .rooms(dto.getRooms() != null ? dto.getRooms() : 1)
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

        HotelBooking savedBooking = bookingRepository.save(booking);
        log.info("✅ Tạo Booking ID: {}", savedBooking.getBookingId());

        // Auto-create payment record
        createPaymentRecord(savedBooking, dto.getPaymentMethod());

        return convertToDTO(savedBooking);
    }

    /**
     * Validate số phòng và sức chứa còn lại trước khi tạo booking
     */
    private void validateAvailability(Hotel hotel, Integer requestedRooms, Integer requestedGuests) {
        Integer hotelId = hotel.getHotelId();
        
        log.info("🔍 Starting validation for Hotel ID: {}, requested rooms: {}, requested guests: {}", 
            hotelId, requestedRooms, requestedGuests);
        
        // Tính tổng số phòng đã book (tính TẤT CẢ booking active: pending, confirmed, completed)
        // KHÔNG tính: cancelled, refunded, checked_out
        Integer bookedRooms = bookingRepository.sumRoomsByHotelActive(hotelId);
        if (bookedRooms == null) bookedRooms = 0;
        
        log.info("📊 Current booked rooms: {}", bookedRooms);
        
        // Tính tổng số người đã book (tính TẤT CẢ booking active: pending, confirmed, completed)
        // KHÔNG tính: cancelled, refunded, checked_out
        Integer bookedCapacity = bookingRepository.sumGuestsByHotelActive(hotelId);
        if (bookedCapacity == null) bookedCapacity = 0;
        
        log.info("📊 Current booked capacity: {}", bookedCapacity);
        
        // Validate số phòng
        if (hotel.getTotalRooms() != null && hotel.getTotalRooms() > 0) {
            Integer availableRooms = hotel.getTotalRooms() - bookedRooms;
            log.info("🏨 Total rooms: {}, Booked: {}, Available: {}, Requested: {}", 
                hotel.getTotalRooms(), bookedRooms, availableRooms, requestedRooms);
            
            if (requestedRooms > availableRooms) {
                String errorMsg = String.format("Khách sạn '%s' không đủ phòng trống! Hiện còn %d phòng, bạn đang yêu cầu %d phòng.", 
                    hotel.getTitle(), availableRooms, requestedRooms);
                log.error("❌ Validation failed: {}", errorMsg);
                throw new IllegalArgumentException(errorMsg);
            }
        } else {
            log.warn("⚠️ Hotel totalRooms is null or 0, skipping room validation");
        }
        
        // Validate sức chứa
        if (hotel.getCapacity() != null && hotel.getCapacity() > 0) {
            Integer availableCapacity = hotel.getCapacity() - bookedCapacity;
            log.info("👥 Total capacity: {}, Booked: {}, Available: {}, Requested: {}", 
                hotel.getCapacity(), bookedCapacity, availableCapacity, requestedGuests);
            
            if (requestedGuests > availableCapacity) {
                String errorMsg = String.format("Khách sạn '%s' không đủ chỗ! Hiện còn chỗ cho %d người, bạn đang yêu cầu %d người.", 
                    hotel.getTitle(), availableCapacity, requestedGuests);
                log.error("❌ Validation failed: {}", errorMsg);
                throw new IllegalArgumentException(errorMsg);
            }
        } else {
            log.warn("⚠️ Hotel capacity is null or 0, skipping capacity validation");
        }
        
        log.info("✅ Validation passed: Hotel {}, rooms {}/{}, guests {}/{}", 
            hotelId, requestedRooms, hotel.getTotalRooms(), requestedGuests, hotel.getCapacity());
    }

    /**
     * Parse rooms từ provider_notes (format: "rooms=2; beds=1")
     * Để tương thích với Flutter app hiện tại
     */
    private Integer parseRoomsFromNotes(String providerNotes) {
        if (providerNotes == null || providerNotes.isEmpty()) {
            return null;
        }
        
        try {
            // Format: "rooms=2; beds=1" hoặc "rooms=39; beds=1"
            String[] parts = providerNotes.split(";");
            for (String part : parts) {
                part = part.trim();
                if (part.startsWith("rooms=")) {
                    String roomsStr = part.substring(6).trim();
                    return Integer.parseInt(roomsStr);
                }
            }
        } catch (Exception e) {
            log.warn("Failed to parse rooms from provider_notes: {}", providerNotes, e);
        }
        
        return null;
    }

    /**
     * Create payment record for booking
     * 
     * @param booking          The hotel booking
     * @param paymentMethodStr Payment method (counter, zalopay, etc.)
     */
    private void createPaymentRecord(HotelBooking booking, String paymentMethodStr) {
        try {
            HotelPayment.PaymentMethod paymentMethod;
            HotelPayment.PaymentStatus paymentStatus;

            // Parse payment method
            if (paymentMethodStr != null && !paymentMethodStr.isEmpty()) {
                paymentMethod = HotelPayment.PaymentMethod.valueOf(paymentMethodStr.toLowerCase());
            } else {
                paymentMethod = HotelPayment.PaymentMethod.counter; // Default
            }

            // Set payment status based on method
            if (paymentMethod == HotelPayment.PaymentMethod.counter) {
                paymentStatus = HotelPayment.PaymentStatus.pending; // Pay later at hotel
            } else {
                paymentStatus = HotelPayment.PaymentStatus.success; // Online payment already completed
            }

            // Generate transaction ID
            String transactionId = "TXN_" + booking.getBookingId() + "_" + System.currentTimeMillis();

            HotelPayment payment = HotelPayment.builder()
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

    public HotelBookingDTO updateBooking(Integer bookingId, HotelBookingDTO dto) {
        log.debug("Cập nhật Booking ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        if (dto.getUserId() != null && !dto.getUserId().equals(booking.getUser().getUserId())) {
            User user = userRepository.findById(dto.getUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));
            booking.setUser(user);
        }

        if (dto.getHotelId() != null && !dto.getHotelId().equals(booking.getHotel().getHotelId())) {
            Hotel hotel = hotelRepository.findById(dto.getHotelId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));
            booking.setHotel(hotel);
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
            booking.setBookingStatus(HotelBooking.BookingStatus.valueOf(dto.getBookingStatus()));
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

        HotelBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã cập nhật Booking ID: {}", updatedBooking.getBookingId());

        return convertToDTO(updatedBooking);
    }

    public HotelBookingDTO markAsSeenByProvider(Integer bookingId) {
        log.debug("Đánh dấu đã xem Booking ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderSeen(true);
        HotelBooking updated = bookingRepository.save(booking);
        log.info("Đã đánh dấu Booking ID: {} là đã xem", bookingId);

        return convertToDTO(updated);
    }

    public HotelBookingDTO confirmBooking(Integer bookingId) {
        log.debug("Xác nhận Booking ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderConfirmed(1);
        booking.setProviderConfirmedAt(LocalDateTime.now());
        booking.setBookingStatus(HotelBooking.BookingStatus.confirmed);
        
        HotelBooking updated = bookingRepository.save(booking);
        log.info("Đã xác nhận Booking ID: {} lúc {}", bookingId, updated.getProviderConfirmedAt());

        return convertToDTO(updated);
    }

    public HotelBookingDTO cancelBooking(Integer bookingId) {
        log.debug("Hủy Booking ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setProviderConfirmed(2);
        booking.setProviderConfirmedAt(LocalDateTime.now());
        booking.setBookingStatus(HotelBooking.BookingStatus.cancelled);
        HotelBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã hủy Booking ID: {} lúc {}", bookingId, updatedBooking.getProviderConfirmedAt());

        return convertToDTO(updatedBooking);
    }

    public void deleteBooking(Integer bookingId) {
        log.debug("Xóa Booking ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        bookingRepository.delete(booking);
        log.info("Đã xóa Booking ID: {}", bookingId);
    }

    public void cancelExpiredPendingBookings() {
        log.debug("Hủy các booking pending đã hết hạn");
        LocalDateTime now = LocalDateTime.now();
        List<HotelBooking> expiredBookings = bookingRepository.findExpiredPendingBookings(now);

        for (HotelBooking booking : expiredBookings) {
            booking.setBookingStatus(HotelBooking.BookingStatus.cancelled);
        }

        bookingRepository.saveAll(expiredBookings);
        log.info("Đã hủy {} booking pending hết hạn", expiredBookings.size());
    }

    private HotelBookingDTO convertToDTO(HotelBooking booking) {
        return HotelBookingDTO.builder()
                .bookingId(booking.getBookingId())
                .userId(booking.getUser() != null ? booking.getUser().getUserId() : null)
                .hotelId(booking.getHotel() != null ? booking.getHotel().getHotelId() : null)
                .bookingDate(booking.getBookingDate())
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .numAdults(booking.getNumAdults())
                .rooms(booking.getRooms())
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
     * Updates all bookings that don't have a provider set by getting it from their hotel
     * 
     * @return Number of bookings updated
     */
    @Transactional
    public int fixMissingProviderIds() {
        log.info("🔧 Bắt đầu fix providerId cho các bookings...");
        
        // Find all bookings without provider
        List<HotelBooking> bookingsWithoutProvider = bookingRepository.findAll().stream()
                .filter(booking -> booking.getProvider() == null && booking.getHotel() != null)
                .collect(Collectors.toList());
        
        log.info("📊 Tìm thấy {} bookings không có providerId", bookingsWithoutProvider.size());
        
        int updatedCount = 0;
        for (HotelBooking booking : bookingsWithoutProvider) {
            Hotel hotel = booking.getHotel();
            if (hotel.getProvider() != null) {
                booking.setProvider(hotel.getProvider());
                bookingRepository.save(booking);
                updatedCount++;
                log.info("✅ Updated Booking ID: {} với Provider ID: {}", 
                    booking.getBookingId(), 
                    hotel.getProvider().getProviderId());
            } else {
                log.warn("⚠️ Hotel ID: {} không có Provider!", hotel.getHotelId());
            }
        }
        
        log.info("🎉 Đã cập nhật {} bookings với providerId", updatedCount);
        return updatedCount;
    }
}