package com.vn.tripfinity.backend.sevice;

import jakarta.mail.MessagingException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;
import java.util.*;

@Service
@Slf4j
public class EmailTemplateService {
    private final EmailService emailService;

    public EmailTemplateService(EmailService emailService) {
        this.emailService = emailService;
    }

    // Enum để định nghĩa các loại email
    public enum EmailType {
        WELCOME("Chào mừng bạn đến với TRIPFINITY!", "✨"),
        PASSWORD_RESET("Đặt lại mật khẩu TRIPFINITY", "🔐"),
        BOOKING_CONFIRMATION("Xác nhận đặt chỗ thành công", "✅"),
        TRIP_REMINDER("Nhắc nhở chuyến đi sắp tới", "🧳"),
        PROMOTION("Ưu đãi đặc biệt dành cho bạn", "🎁"),
        ACCOUNT_VERIFICATION("Xác thực tài khoản", "📧"),
        NEWSLETTER("Bản tin du lịch TRIPFINITY", "📰");

        private final String defaultSubject;
        private final String icon;

        EmailType(String defaultSubject, String icon) {
            this.defaultSubject = defaultSubject;
            this.icon = icon;
        }

        public String getDefaultSubject() {
            return defaultSubject;
        }

        public String getIcon() {
            return icon;
        }
    }

    // Class để chứa dữ liệu email
    public static class EmailData {
        private String recipientName;
        private String customSubject;
        private String mainTitle;
        private String mainMessage;
        private String highlightText;
        private String ctaText;
        private String ctaUrl;
        private String warningMessage;
        private List<FeatureItem> features;
        private Map<String, String> additionalData;

        public EmailData() {
            this.features = new ArrayList<>();
            this.additionalData = new HashMap<>();
        }

        public static EmailData builder() {
            return new EmailData();
        }

        public EmailData recipientName(String recipientName) {
            this.recipientName = recipientName;
            return this;
        }

        public EmailData customSubject(String customSubject) {
            this.customSubject = customSubject;
            return this;
        }

        public EmailData mainTitle(String mainTitle) {
            this.mainTitle = mainTitle;
            return this;
        }

        public EmailData mainMessage(String mainMessage) {
            this.mainMessage = mainMessage;
            return this;
        }

        public EmailData highlightText(String highlightText) {
            this.highlightText = highlightText;
            return this;
        }

        public EmailData ctaButton(String ctaText, String ctaUrl) {
            this.ctaText = ctaText;
            this.ctaUrl = ctaUrl;
            return this;
        }

        public EmailData warningMessage(String warningMessage) {
            this.warningMessage = warningMessage;
            return this;
        }

        public EmailData addFeature(String icon, String title) {
            this.features.add(new FeatureItem(icon, title));
            return this;
        }

        public EmailData addData(String key, String value) {
            this.additionalData.put(key, value);
            return this;
        }

        // Getters
        public String getRecipientName() {
            return recipientName;
        }

        public String getCustomSubject() {
            return customSubject;
        }

        public String getMainTitle() {
            return mainTitle;
        }

        public String getMainMessage() {
            return mainMessage;
        }

        public String getHighlightText() {
            return highlightText;
        }

        public String getCtaText() {
            return ctaText;
        }

        public String getCtaUrl() {
            return ctaUrl;
        }

        public String getWarningMessage() {
            return warningMessage;
        }

        public List<FeatureItem> getFeatures() {
            return features;
        }

        public Map<String, String> getAdditionalData() {
            return additionalData;
        }
    }

    // Class cho feature items
    public static class FeatureItem {
        private String icon;
        private String title;

        public FeatureItem(String icon, String title) {
            this.icon = icon;
            this.title = title;
        }

        public String getIcon() {
            return icon;
        }

        public String getTitle() {
            return title;
        }
    }

    // Method chính để gửi email
    public void sendEmail(String recipientEmail, EmailType emailType, EmailData emailData) {
        String subject = emailData.getCustomSubject() != null ?
                emailData.getCustomSubject() :
                emailType.getIcon() + " " + emailType.getDefaultSubject();

        String body = createEmailTemplate(emailType, emailData);

        try {
            emailService.sendEmail(recipientEmail, subject, body);
            log.info("Email sent successfully to: {} with type: {}", recipientEmail, emailType);
        } catch (MessagingException | UnsupportedEncodingException e) {
            log.error("Failed to send email to: {} with type: {}", recipientEmail, emailType, e);
        }
    }

    // Method tạo template chung
    private String createEmailTemplate(EmailType emailType, EmailData data) {
        String template = getBaseEmailTemplate();

        // Thay thế các placeholder
        template = template.replace("{{RECIPIENT_NAME}}", data.getRecipientName() != null ? data.getRecipientName() : "Khách hàng");
        template = template.replace("{{EMAIL_ICON}}", emailType.getIcon());
        template = template.replace("{{MAIN_TITLE}}", data.getMainTitle() != null ? data.getMainTitle() : "Chào mừng bạn đến với cộng đồng du lịch!");
        template = template.replace("{{MAIN_MESSAGE}}", data.getMainMessage() != null ? data.getMainMessage() : "Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.");
        template = template.replace("{{HIGHLIGHT_TEXT}}", data.getHighlightText() != null ? data.getHighlightText() : "");
        template = template.replace("{{CTA_TEXT}}", data.getCtaText() != null ? data.getCtaText() : "Khám phá ngay!");
        template = template.replace("{{CTA_URL}}", data.getCtaUrl() != null ? data.getCtaUrl() : "https://tripfinity.com");
        template = template.replace("{{WARNING_MESSAGE}}", data.getWarningMessage() != null ? data.getWarningMessage() : "");

        // Tạo features HTML
        String featuresHtml = generateFeaturesHtml(data.getFeatures());
        template = template.replace("{{FEATURES}}", featuresHtml);

        // Thay thế dữ liệu bổ sung
        for (Map.Entry<String, String> entry : data.getAdditionalData().entrySet()) {
            template = template.replace("{{" + entry.getKey().toUpperCase() + "}}", entry.getValue());
        }

        return template;
    }

    // Method tạo features HTML
    private String generateFeaturesHtml(List<FeatureItem> features) {
        if (features.isEmpty()) {
            return "";
        }

        StringBuilder html = new StringBuilder();
        html.append("<div class=\"features-container\">");

        for (FeatureItem feature : features) {
            html.append(String.format(
                    "<div class=\"feature-item\">" +
                            "<div class=\"feature-icon\">%s</div>" +
                            "<div class=\"feature-title\">%s</div>" +
                            "</div>",
                    feature.getIcon(), feature.getTitle()
            ));
        }

        html.append("</div>");
        return html.toString();
    }

    // Base template HTML với thiết kế chuyên nghiệp
    private String getBaseEmailTemplate() {
        return """
                <!DOCTYPE html>
                <html lang="vi">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>TRIPFINITY</title>
                    <style>
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }
                
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                            background-color: #f8fafc;
                            padding: 20px;
                            line-height: 1.6;
                            color: #334155;
                        }
                
                        .email-container {
                            max-width: 600px;
                            margin: 0 auto;
                            background: #ffffff;
                            border-radius: 16px;
                            overflow: hidden;
                            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                        }
                
                        .header {
                            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                            padding: 40px 30px;
                            text-align: center;
                            position: relative;
                        }
                
                        .header::before {
                            content: '';
                            position: absolute;
                            top: 0;
                            left: 0;
                            right: 0;
                            bottom: 0;
                            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="10" cy="10" r="1" fill="white" opacity="0.1"/><circle cx="90" cy="20" r="1" fill="white" opacity="0.1"/><circle cx="30" cy="90" r="1" fill="white" opacity="0.1"/><circle cx="70" cy="70" r="1" fill="white" opacity="0.1"/></svg>') repeat;
                            pointer-events: none;
                        }
                
                        .logo {
                            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
                            color: white;
                            padding: 12px 24px;
                            border-radius: 12px;
                            display: inline-block;
                            font-size: 24px;
                            font-weight: 700;
                            letter-spacing: 1px;
                            position: relative;
                            z-index: 1;
                            box-shadow: 0 4px 14px 0 rgba(59, 130, 246, 0.4);
                        }
                
                        .welcome-text {
                            color: #e2e8f0;
                            font-size: 18px;
                            font-weight: 500;
                            margin-top: 16px;
                            position: relative;
                            z-index: 1;
                        }
                
                        .content {
                            padding: 40px 30px;
                        }
                
                        .greeting {
                            font-size: 24px;
                            color: #1e293b;
                            margin-bottom: 24px;
                            font-weight: 600;
                        }
                
                        .greeting strong {
                            color: #3b82f6;
                        }
                
                        .message {
                            font-size: 16px;
                            color: #64748b;
                            margin-bottom: 32px;
                            line-height: 1.7;
                        }
                
                        .highlight-box {
                            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
                            border-left: 4px solid #3b82f6;
                            padding: 24px;
                            border-radius: 12px;
                            margin: 32px 0;
                            position: relative;
                        }
                
                        .highlight-text {
                            font-size: 16px;
                            font-weight: 600;
                            color: #1e40af;
                            margin: 0;
                        }
                
                        .features-container {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
                            gap: 16px;
                            margin: 32px 0;
                        }
                
                        .feature-item {
                            background: #f8fafc;
                            border: 1px solid #e2e8f0;
                            padding: 20px;
                            margin-bottom: 10px;
                            border-radius: 8px;
                            text-align: center;
                        }
                
                        .feature-icon {
                            font-size: 32px;
                            margin-bottom: 12px;
                            display: block;
                        }
                
                        .feature-title {
                            font-size: 14px;
                            font-weight: 600;
                            color: #475569;
                            line-height: 1.4;
                        }
                
                        .cta-container {
                            text-align: center;
                            margin: 40px 0;
                        }
                
                        .cta-button {
                            display: inline-block;
                            background: #3b82f6;
                            color: white !important;
                            padding: 16px 32px;
                            text-decoration: none;
                            border-radius: 8px;
                            font-weight: 600;
                            font-size: 16px;
                            border: none;
                            mso-style-priority: 100;
                            -webkit-text-size-adjust: none;
                        }
                
                        .divider {
                            height: 1px;
                            background: #e2e8f0;
                            margin: 32px 0;
                        }
                
                        .warning-box {
                            background: #fef3c7;
                            border: 1px solid #fbbf24;
                            border-radius: 12px;
                            padding: 20px;
                            margin: 24px 0;
                        }
                
                        .warning-box strong {
                            color: #92400e;
                            font-weight: 600;
                        }
                
                        .warning-text {
                            color: #92400e;
                            font-size: 14px;
                            line-height: 1.5;
                        }
                
                        .footer {
                            background: #f8fafc;
                            padding: 32px 30px;
                            text-align: center;
                            border-top: 1px solid #e2e8f0;
                        }
                
                        .footer-logo {
                            font-size: 18px;
                            font-weight: 700;
                            color: #1e293b;
                            margin-bottom: 16px;
                        }
                
                        .footer-text {
                            font-size: 14px;
                            color: #64748b;
                            margin-bottom: 16px;
                            line-height: 1.5;
                        }
                
                        .footer-contact {
                            font-size: 14px;
                            color: #64748b;
                            margin-bottom: 20px;
                        }
                
                        .footer-contact strong {
                            color: #334155;
                        }
                
                        .social-links {
                            margin-top: 16px;
                        }
                
                        .social-links a {
                            color: #3b82f6;
                            text-decoration: none;
                            margin: 0 12px;
                            font-size: 14px;
                            font-weight: 500;
                        }
                
                        /* Responsive Design */
                        @media (max-width: 600px) {
                            body {
                                padding: 10px;
                            }
                
                            .email-container {
                                border-radius: 12px;
                            }
                
                            .header {
                                padding: 30px 20px;
                            }
                
                            .content {
                                padding: 30px 20px;
                            }
                
                            .footer {
                                padding: 24px 20px;
                            }
                
                            .logo {
                                font-size: 20px;
                                padding: 10px 20px;
                            }
                
                            .welcome-text {
                                font-size: 16px;
                            }
                
                            .greeting {
                                font-size: 20px;
                            }
                
                            .features-container {
                                grid-template-columns: 1fr;
                                gap: 12px;
                            }
                
                            .cta-button {
                                padding: 14px 28px;
                                font-size: 15px;
                            }
                
                            .social-links a {
                                margin: 0 8px;
                            }
                        }
                
                        /* Print Styles */
                        @media print {
                            body {
                                background: white;
                                padding: 0;
                            }
                
                            .email-container {
                                box-shadow: none;
                                border: 1px solid #e2e8f0;
                            }
                
                            .cta-button {
                                background: #3b82f6 !important;
                                -webkit-print-color-adjust: exact;
                            }
                        }
                    </style>
                </head>
                <body>
                    <div class="email-container">
                        <div class="header">
                            <div class="logo">TRIPFINITY</div>
                            <div class="welcome-text">{{MAIN_TITLE}}</div>
                        </div>
                
                        <div class="content">
                            <div class="greeting">
                                Xin chào <strong>{{RECIPIENT_NAME}}</strong>! <span style="font-size: 20px;">{{EMAIL_ICON}}</span>
                            </div>
                
                            <div class="message">{{MAIN_MESSAGE}}</div>
                
                            <div class="highlight-box" style="{{HIGHLIGHT_TEXT}} ? '' : 'display: none;'">
                                <div class="highlight-text">{{HIGHLIGHT_TEXT}}</div>
                            </div>
                
                            {{FEATURES}}
                
                            <div class="divider"></div>
                
                            <div class="warning-box" style="{{WARNING_MESSAGE}} ? '' : 'display: none;'">
                                <div class="warning-text">
                                    <strong>Lưu ý:</strong> {{WARNING_MESSAGE}}
                                </div>
                            </div>
                
                            <div class="cta-container">
                                <a href="{{CTA_URL}}" class="cta-button" style="background: #3b82f6; color: white; text-decoration: none; display: inline-block; padding: 16px 32px; border-radius: 8px; font-weight: 600; font-size: 16px;">{{CTA_TEXT}}</a>
                            </div>
                        </div>
                
                        <div class="footer">
                            <div class="footer-logo">TRIPFINITY</div>
                            <div class="footer-text">
                                Cảm ơn bạn đã tin tưởng và lựa chọn TRIPFINITY!<br>
                                Hãy cùng chúng tôi tạo nên những kỷ niệm du lịch không thể nào quên.
                            </div>
                            <div class="footer-contact">
                                <strong>Đội ngũ hỗ trợ TRIPFINITY</strong><br>
                                📧 tripfinity2025@gmail.com | 📞 1900-xxx-xxx
                            </div>
                            <div class="social-links">
                                <a href="#">Facebook</a> |
                                <a href="#">Instagram</a> |
                                <a href="#">Twitter</a>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """;
    }
}