package com.vn.tripfinity.backend.service;

import java.io.UnsupportedEncodingException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);
    private final JavaMailSender mailSender;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendEmail(String to,
            String subject,
            String body) throws MessagingException, UnsupportedEncodingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom("tripfinity2025@gmail.com", "TripFinity");
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(body, true);

        mailSender.send(message);
    }

    /**
     * Email xác nhận đặt phòng cho user (async)
     */
    @Async
    public void sendBookingConfirmationEmail(String to, String customerName, String hotelTitle, 
            String bookingCode, String checkIn, String checkOut, String totalPrice, String paymentMethod) {
        try {
            String subject = "Xác nhận đặt phòng - " + hotelTitle;
            String htmlContent = buildBookingConfirmationHtml(customerName, hotelTitle, bookingCode, 
                checkIn, checkOut, totalPrice, paymentMethod);
            sendEmail(to, subject, htmlContent);
            log.info("✅ Booking confirmation email sent to {}", to);
        } catch (Exception e) {
            log.error("❌ Failed to send booking confirmation email to {}: {}", to, e.getMessage());
        }
    }

    /**
     * Email thông báo supplier có booking mới (async)
     */
    @Async
    public void sendSupplierNewBookingEmail(String to, String supplierName, String hotelTitle,
            String bookingCode, String customerName, String checkIn, String checkOut, 
            String totalPrice, String paymentMethod, int rooms, int adults) {
        try {
            String subject = "[Tripfinity] Đơn đặt phòng mới - " + hotelTitle;
            String htmlContent = buildSupplierNewBookingHtml(supplierName, hotelTitle, bookingCode,
                customerName, checkIn, checkOut, totalPrice, paymentMethod, rooms, adults);
            sendEmail(to, subject, htmlContent);
            log.info("✅ Supplier new booking email sent to {}", to);
        } catch (Exception e) {
            log.error("❌ Failed to send supplier new booking email to {}: {}", to, e.getMessage());
        }
    }

    /**
     * Email thông báo booking được xác nhận (async)
     */
    @Async
    public void sendBookingApprovedEmail(String to, String customerName, String hotelTitle, 
            String bookingCode, String checkIn, String checkOut) {
        try {
            String subject = "Đặt phòng đã được xác nhận - " + hotelTitle;
            String htmlContent = buildBookingApprovedHtml(customerName, hotelTitle, bookingCode, 
                checkIn, checkOut);
            sendEmail(to, subject, htmlContent);
            log.info("✅ Booking approved email sent to {}", to);
        } catch (Exception e) {
            log.error("❌ Failed to send booking approved email to {}: {}", to, e.getMessage());
        }
    }

    /**
     * Email thông báo booking bị hủy (async)
     */
    @Async
    public void sendBookingCancelledEmail(String to, String customerName, String hotelTitle, 
            String bookingCode) {
        try {
            String subject = "Đặt phòng đã bị hủy - " + hotelTitle;
            String htmlContent = buildBookingCancelledHtml(customerName, hotelTitle, bookingCode);
            sendEmail(to, subject, htmlContent);
            log.info("✅ Booking cancelled email sent to {}", to);
        } catch (Exception e) {
            log.error("❌ Failed to send booking cancelled email to {}: {}", to, e.getMessage());
        }
    }

    private String buildBookingConfirmationHtml(String customerName, String hotelTitle, 
            String bookingCode, String checkIn, String checkOut, String totalPrice, String paymentMethod) {
        String paymentText = paymentMethod.equalsIgnoreCase("counter") 
            ? "Thanh toán tại quầy" 
            : "Thanh toán qua " + paymentMethod.toUpperCase();
        
        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #4CAF50; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
                    .booking-details { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #4CAF50; }
                    .detail-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }
                    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🎉 Đặt phòng thành công!</h1>
                    </div>
                    <div class="content">
                        <p>Xin chào <strong>%s</strong>,</p>
                        <p>Cảm ơn bạn đã đặt phòng tại <strong>%s</strong>!</p>
                        <p>Đơn đặt phòng của bạn đã được ghi nhận. Vui lòng đợi 1-2 tiếng để đội ngũ của chúng tôi xác nhận đơn hàng.</p>
                        
                        <div class="booking-details">
                            <h3>Chi tiết đặt phòng</h3>
                            <div class="detail-row">
                                <span>Mã đặt phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Khách sạn:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Ngày nhận phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Ngày trả phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Tổng tiền:</span>
                                <strong style="color: #4CAF50;">%s VND</strong>
                            </div>
                            <div class="detail-row">
                                <span>Phương thức thanh toán:</span>
                                <strong style="color: #2196F3;">%s</strong>
                            </div>
                        </div>
                        
                        <p><strong>Lưu ý:</strong> Vui lòng giữ mã đặt phòng để thuận tiện cho việc check-in.</p>
                        
                        <p>Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi qua hotline hoặc email hỗ trợ.</p>
                    </div>
                    <div class="footer">
                        <p>Tripfinity - Nền tảng du lịch hàng đầu Việt Nam</p>
                        <p>Email: support@tripfinity.com | Hotline: 1900-xxxx</p>
                    </div>
                </div>
            </body>
            </html>
            """, customerName, hotelTitle, bookingCode, hotelTitle, checkIn, checkOut, totalPrice, paymentText);
    }

    private String buildSupplierNewBookingHtml(String supplierName, String hotelTitle, String bookingCode,
            String customerName, String checkIn, String checkOut, String totalPrice, 
            String paymentMethod, int rooms, int adults) {
        String paymentText = paymentMethod.equalsIgnoreCase("counter") 
            ? "Thanh toán tại quầy" 
            : "Đã thanh toán qua " + paymentMethod.toUpperCase();
        String paymentColor = paymentMethod.equalsIgnoreCase("counter") ? "#FF9800" : "#4CAF50";
        
        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #2196F3; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
                    .alert-box { background: #FFF3E0; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #FF9800; }
                    .booking-details { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #2196F3; }
                    .detail-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }
                    .action-btn { display: inline-block; padding: 12px 24px; background: #4CAF50; color: white; text-decoration: none; border-radius: 6px; margin: 10px 5px; }
                    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🔔 Đơn đặt phòng mới!</h1>
                    </div>
                    <div class="content">
                        <p>Xin chào <strong>%s</strong>,</p>
                        
                        <div class="alert-box">
                            <h3 style="margin-top: 0;">⏰ Yêu cầu xác nhận đặt phòng</h3>
                            <p>Khách sạn <strong>%s</strong> của bạn vừa nhận được một đơn đặt phòng mới. Vui lòng xác nhận trong vòng 1-2 tiếng.</p>
                        </div>
                        
                        <div class="booking-details">
                            <h3>Thông tin đặt phòng</h3>
                            <div class="detail-row">
                                <span>Mã đặt phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Khách hàng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Khách sạn:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Số phòng:</span>
                                <strong>%d phòng</strong>
                            </div>
                            <div class="detail-row">
                                <span>Số người:</span>
                                <strong>%d người lớn</strong>
                            </div>
                            <div class="detail-row">
                                <span>Ngày nhận phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Ngày trả phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Tổng tiền:</span>
                                <strong style="color: #4CAF50;">%s VND</strong>
                            </div>
                            <div class="detail-row">
                                <span>Phương thức thanh toán:</span>
                                <strong style="color: %s;">%s</strong>
                            </div>
                        </div>
                        
                        <div style="text-align: center; margin: 30px 0;">
                            <p><strong>Vui lòng đăng nhập vào hệ thống để xác nhận hoặc hủy đơn đặt phòng này.</strong></p>
                            <a href="http://localhost:5174/supplier/login" class="action-btn">Đăng nhập hệ thống</a>
                        </div>
                        
                        <p style="color: #FF5722;"><strong>⚠️ Lưu ý:</strong> Nếu không xác nhận trong vòng 2 tiếng, đơn đặt phòng có thể bị hủy tự động.</p>
                    </div>
                    <div class="footer">
                        <p>Tripfinity Supplier Dashboard</p>
                        <p>Email: supplier@tripfinity.com | Hotline: 1900-xxxx</p>
                    </div>
                </div>
            </body>
            </html>
            """, supplierName, hotelTitle, bookingCode, customerName, hotelTitle, rooms, adults, 
                checkIn, checkOut, totalPrice, paymentColor, paymentText);
    }

    private String buildBookingApprovedHtml(String customerName, String hotelTitle, 
            String bookingCode, String checkIn, String checkOut) {
        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #2196F3; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
                    .success-box { background: #E8F5E9; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #4CAF50; text-align: center; }
                    .detail-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }
                    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>✅ Đặt phòng đã được xác nhận!</h1>
                    </div>
                    <div class="content">
                        <p>Xin chào <strong>%s</strong>,</p>
                        
                        <div class="success-box">
                            <h2 style="color: #4CAF50; margin: 0;">🎊 Chúc mừng!</h2>
                            <p style="margin: 10px 0 0 0;">Đơn đặt phòng của bạn đã được xác nhận thành công!</p>
                        </div>
                        
                        <p>Đơn đặt phòng <strong>%s</strong> tại <strong>%s</strong> đã được xác nhận.</p>
                        
                        <div style="background: white; padding: 20px; margin: 20px 0; border-radius: 8px;">
                            <h3>Thông tin check-in</h3>
                            <div class="detail-row">
                                <span>Ngày nhận phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Ngày trả phòng:</span>
                                <strong>%s</strong>
                            </div>
                            <div class="detail-row">
                                <span>Mã đặt phòng:</span>
                                <strong>%s</strong>
                            </div>
                        </div>
                        
                        <p><strong>Lưu ý quan trọng:</strong></p>
                        <ul>
                            <li>Vui lòng mang theo CMND/CCCD khi check-in</li>
                            <li>Xuất trình mã đặt phòng tại quầy lễ tân</li>
                            <li>Thời gian check-in: 14:00 | Check-out: 12:00</li>
                        </ul>
                        
                        <p>Chúng tôi rất mong được phục vụ bạn! Chúc bạn có một chuyến đi vui vẻ! 🌟</p>
                    </div>
                    <div class="footer">
                        <p>Tripfinity - Nền tảng du lịch hàng đầu Việt Nam</p>
                        <p>Email: support@tripfinity.com | Hotline: 1900-xxxx</p>
                    </div>
                </div>
            </body>
            </html>
            """, customerName, bookingCode, hotelTitle, checkIn, checkOut, bookingCode);
    }

    private String buildBookingCancelledHtml(String customerName, String hotelTitle, String bookingCode) {
        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #f44336; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
                    .warning-box { background: #FFF3E0; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #FF9800; }
                    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>❌ Đặt phòng đã bị hủy</h1>
                    </div>
                    <div class="content">
                        <p>Xin chào <strong>%s</strong>,</p>
                        
                        <div class="warning-box">
                            <h3 style="margin-top: 0;">Thông báo hủy đặt phòng</h3>
                            <p>Rất tiếc, đơn đặt phòng <strong>%s</strong> tại <strong>%s</strong> của bạn đã bị hủy.</p>
                        </div>
                        
                        <p><strong>Lý do có thể:</strong></p>
                        <ul>
                            <li>Khách sạn hết phòng trống</li>
                            <li>Thông tin đặt phòng không chính xác</li>
                            <li>Yêu cầu hủy từ khách hàng</li>
                            <li>Lý do khác từ nhà cung cấp</li>
                        </ul>
                        
                        <p>Nếu bạn đã thanh toán, chúng tôi sẽ hoàn tiền trong vòng 3-5 ngày làm việc.</p>
                        
                        <p>Để biết thêm chi tiết hoặc đặt phòng khác, vui lòng liên hệ:</p>
                        <ul>
                            <li>📧 Email: support@tripfinity.com</li>
                            <li>📞 Hotline: 1900-xxxx</li>
                        </ul>
                        
                        <p>Chúng tôi rất xin lỗi vì sự bất tiện này và hy vọng được phục vụ bạn trong tương lai!</p>
                    </div>
                    <div class="footer">
                        <p>Tripfinity - Nền tảng du lịch hàng đầu Việt Nam</p>
                        <p>Email: support@tripfinity.com | Hotline: 1900-xxxx</p>
                    </div>
                </div>
            </body>
            </html>
            """, customerName, bookingCode, hotelTitle);
    }

    /**
     * Email xác nhận đặt bàn restaurant cho user (async)
     */
    @Async
    public void sendRestaurantBookingConfirmationEmail(String to, String customerName, String restaurantTitle, 
            String bookingCode, String reservationDate, String totalPrice, String paymentMethod, int guests) {
        try {
            String subject = "Xác nhận đặt bàn - " + restaurantTitle;
            String htmlContent = buildRestaurantBookingConfirmationHtml(customerName, restaurantTitle, bookingCode, 
                reservationDate, totalPrice, paymentMethod, guests);
            sendEmail(to, subject, htmlContent);
            log.info("✅ Restaurant booking confirmation email sent to {}", to);
        } catch (Exception e) {
            log.error("❌ Failed to send restaurant booking confirmation email to {}: {}", to, e.getMessage());
        }
    }

    /**
     * Email thông báo supplier có booking restaurant mới (async)
     */
    @Async
    public void sendSupplierNewRestaurantBookingEmail(String to, String supplierName, String restaurantTitle,
            String bookingCode, String customerName, String reservationDate, 
            String totalPrice, String paymentMethod, int guests) {
        try {
            String subject = "[Tripfinity] Đơn đặt bàn mới - " + restaurantTitle;
            String htmlContent = buildSupplierNewRestaurantBookingHtml(supplierName, restaurantTitle, bookingCode,
                customerName, reservationDate, totalPrice, paymentMethod, guests);
            sendEmail(to, subject, htmlContent);
            log.info("✅ Supplier new restaurant booking email sent to {}", to);
        } catch (Exception e) {
            log.error("❌ Failed to send supplier new restaurant booking email to {}: {}", to, e.getMessage());
        }
    }

    private String buildRestaurantBookingConfirmationHtml(String customerName, String restaurantTitle, 
            String bookingCode, String reservationDate, String totalPrice, String paymentMethod, int guests) {
        
        String paymentMethodText = switch (paymentMethod.toLowerCase()) {
            case "zalopay" -> "ZaloPay (đã thanh toán)";
            case "vnpay" -> "VNPay (đã thanh toán)";
            case "momo" -> "MoMo (đã thanh toán)";
            case "counter" -> "Thanh toán trực tiếp tại nhà hàng";
            default -> paymentMethod;
        };

        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background-color: #23A455; color: white; padding: 20px; text-align: center; }
                    .content { padding: 20px; background-color: #f9f9f9; }
                    .info-box { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #23A455; }
                    .footer { text-align: center; padding: 20px; font-size: 12px; color: #777; }
                    .button { display: inline-block; padding: 10px 20px; background-color: #23A455; color: white; text-decoration: none; border-radius: 5px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🍴 Xác nhận đặt bàn</h1>
                    </div>
                    <div class="content">
                        <p>Xin chào <strong>%s</strong>,</p>
                        
                        <p>Cảm ơn bạn đã đặt bàn tại <strong>%s</strong> qua Tripfinity!</p>
                        
                        <div class="info-box">
                            <h3>📋 Thông tin đặt bàn</h3>
                            <p><strong>Mã đặt bàn:</strong> %s</p>
                            <p><strong>Nhà hàng:</strong> %s</p>
                            <p><strong>Ngày đặt:</strong> %s</p>
                            <p><strong>Số khách:</strong> %d người</p>
                            <p><strong>Tổng tiền:</strong> %s VND</p>
                            <p><strong>Phương thức thanh toán:</strong> %s</p>
                        </div>
                        
                        <p>Vui lòng đến đúng giờ để đảm bảo chỗ ngồi tốt nhất cho bạn!</p>
                        
                        <p>Nếu có bất kỳ thay đổi nào, vui lòng liên hệ với chúng tôi sớm nhất có thể.</p>
                        
                        <p style="text-align: center; margin-top: 20px;">
                            <a href="https://tripfinity.com/my-bookings" class="button">Xem đơn đặt bàn của tôi</a>
                        </p>
                    </div>
                    <div class="footer">
                        <p>Tripfinity - Nền tảng du lịch hàng đầu Việt Nam</p>
                        <p>Email: support@tripfinity.com | Hotline: 1900-xxxx</p>
                    </div>
                </div>
            </body>
            </html>
            """, customerName, restaurantTitle, bookingCode, restaurantTitle, reservationDate, 
            guests, totalPrice, paymentMethodText);
    }

    private String buildSupplierNewRestaurantBookingHtml(String supplierName, String restaurantTitle, String bookingCode,
            String customerName, String reservationDate, String totalPrice, String paymentMethod, int guests) {
        
        String paymentMethodText = switch (paymentMethod.toLowerCase()) {
            case "zalopay" -> "ZaloPay (đã thanh toán)";
            case "vnpay" -> "VNPay (đã thanh toán)";
            case "momo" -> "MoMo (đã thanh toán)";
            case "counter" -> "Thanh toán trực tiếp tại nhà hàng";
            default -> paymentMethod;
        };

        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background-color: #FF6B35; color: white; padding: 20px; text-align: center; }
                    .content { padding: 20px; background-color: #f9f9f9; }
                    .info-box { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #FF6B35; }
                    .footer { text-align: center; padding: 20px; font-size: 12px; color: #777; }
                    .button { display: inline-block; padding: 10px 20px; background-color: #FF6B35; color: white; text-decoration: none; border-radius: 5px; }
                    .highlight { background-color: #fff3cd; padding: 10px; border-radius: 5px; margin: 10px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🍴 Đơn đặt bàn mới</h1>
                    </div>
                    <div class="content">
                        <p>Xin chào <strong>%s</strong>,</p>
                        
                        <div class="highlight">
                            <p>🔔 Bạn có một đơn đặt bàn mới cho <strong>%s</strong></p>
                        </div>
                        
                        <div class="info-box">
                            <h3>📋 Chi tiết đặt bàn</h3>
                            <p><strong>Mã đặt bàn:</strong> %s</p>
                            <p><strong>Khách hàng:</strong> %s</p>
                            <p><strong>Ngày đặt:</strong> %s</p>
                            <p><strong>Số khách:</strong> %d người</p>
                            <p><strong>Tổng tiền:</strong> %s VND</p>
                            <p><strong>Phương thức thanh toán:</strong> %s</p>
                        </div>
                        
                        <p><strong>Lưu ý:</strong> Vui lòng chuẩn bị và sắp xếp chỗ ngồi cho khách hàng.</p>
                        
                        <p style="text-align: center; margin-top: 20px;">
                            <a href="https://supplier.tripfinity.com/bookings" class="button">Xem chi tiết đơn đặt bàn</a>
                        </p>
                    </div>
                    <div class="footer">
                        <p>Tripfinity Supplier Portal</p>
                        <p>Email: supplier@tripfinity.com | Hotline: 1900-xxxx</p>
                    </div>
                </div>
            </body>
            </html>
            """, supplierName, restaurantTitle, bookingCode, customerName, reservationDate, 
            guests, totalPrice, paymentMethodText);
    }
}