package com.vn.tripfinity.backend.scheduler;

import java.time.LocalDate;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.model.HotelBooking;
import com.vn.tripfinity.backend.repository.HotelBookingRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BookingScheduler {

    private static final Logger log = LoggerFactory.getLogger(BookingScheduler.class);

    private final HotelBookingRepository bookingRepository;

    /**
     * Tự động check-out các booking đã hết hạn
     * Chạy mỗi ngày lúc 12:00 trưa
     * Booking sẽ được check-out nếu: status = completed VÀ đã quá endDate
     */
    @Scheduled(cron = "0 0 12 * * ?") // Chạy lúc 12:00 trưa mỗi ngày
    @Transactional
    public void autoCheckOutExpiredBookings() {
        LocalDate today = LocalDate.now();
        
        log.info("🏨 [Auto Check-Out] Starting auto check-out process for date: {}", today);
        
        try {
            // Tìm tất cả booking completed có endDate < today (đã quá ngày checkout)
            List<HotelBooking> expiredBookings = bookingRepository.findBookingsToCheckOut(today);
            
            if (expiredBookings.isEmpty()) {
                log.info("✅ [Auto Check-Out] No bookings to check out");
                return;
            }
            
            log.info("📋 [Auto Check-Out] Found {} booking(s) to check out", expiredBookings.size());
            
            int checkedOutCount = 0;
            for (HotelBooking booking : expiredBookings) {
                try {
                    // Chuyển status từ completed → checked_out
                    booking.setBookingStatus(HotelBooking.BookingStatus.checked_out);
                    bookingRepository.save(booking);
                    
                    log.info("✅ [Auto Check-Out] Booking #{} checked out | Hotel: {} | EndDate: {} | Rooms: {}", 
                        booking.getBookingId(),
                        booking.getHotel().getTitle(),
                        booking.getEndDate(),
                        booking.getRooms());
                    
                    checkedOutCount++;
                } catch (Exception e) {
                    log.error("❌ [Auto Check-Out] Failed to check out booking #{}: {}", 
                        booking.getBookingId(), e.getMessage());
                }
            }
            
            log.info("✅ [Auto Check-Out] Successfully checked out {}/{} booking(s)", 
                checkedOutCount, expiredBookings.size());
            
        } catch (Exception e) {
            log.error("❌ [Auto Check-Out] Auto check-out process failed: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Chạy thử ngay khi khởi động server (để test)
     * Comment dòng này sau khi test xong
     */
    // @Scheduled(fixedDelay = Long.MAX_VALUE, initialDelay = 5000)
    // public void runOnStartup() {
    //     log.info("🚀 Running initial auto check-out on startup...");
    //     autoCheckOutExpiredBookings();
    // }
}
