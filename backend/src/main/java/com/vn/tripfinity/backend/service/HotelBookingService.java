package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.HotelBookingDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelBooking;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.HotelBookingRepository;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelBookingService {

    private final HotelBookingRepository bookingRepository;
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

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        Provider provider = null;
        if (dto.getProviderId() != null) {
            provider = providerRepository.findById(dto.getProviderId())
                    .orElseThrow(
                            () -> new ResourceNotFoundException("Không tìm thấy Provider id: " + dto.getProviderId()));
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
                .numChildren(dto.getNumChildren() != null ? dto.getNumChildren() : 0)
                .totalPrice(dto.getTotalPrice())
                .currencyCode(dto.getCurrencyCode())
                .bookingStatus(bookingStatus)
                .eTicketUrl(dto.getETicketUrl())
                .qrCodeData(dto.getQrCodeData())
                .channel(dto.getChannel())
                .holdUntil(dto.getHoldUntil())
                .providerSeen(dto.getProviderSeen() != null ? dto.getProviderSeen() : false)
                .providerNotes(dto.getProviderNotes())
                .build();

        HotelBooking savedBooking = bookingRepository.save(booking);
        log.info("✅ Tạo Booking ID: {}", savedBooking.getBookingId());

        return convertToDTO(savedBooking);
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
        if (dto.getNumChildren() != null)
            booking.setNumChildren(dto.getNumChildren());
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
        HotelBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã đánh dấu đã xem Booking ID: {}", updatedBooking.getBookingId());

        return convertToDTO(updatedBooking);
    }

    public HotelBookingDTO cancelBooking(Integer bookingId) {
        log.debug("Hủy Booking ID: {}", bookingId);
        HotelBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Booking id: " + bookingId));

        booking.setBookingStatus(HotelBooking.BookingStatus.cancelled);
        HotelBooking updatedBooking = bookingRepository.save(booking);
        log.info("Đã hủy Booking ID: {}", updatedBooking.getBookingId());

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
                .numChildren(booking.getNumChildren())
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
                .providerSeen(booking.getProviderSeen())
                .providerNotes(booking.getProviderNotes())
                .build();
    }
}