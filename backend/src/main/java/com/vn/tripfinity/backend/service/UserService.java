package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.UserDTO;
import com.vn.tripfinity.backend.exception.DuplicateResourceException;
import com.vn.tripfinity.backend.exception.PasswordMismatchException;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailTemplateService emailTemplateService;
    private final CloudinaryService cloudinaryService;

    public List<UserDTO> getAllUsers() {
        log.debug("Lấy toàn bộ người dùng");
        return userRepository.findAll().stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public UserDTO getUserById(Integer userId) {
        log.debug("Lấy user theo ID: {}", userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));
        return convertToDTO(user);
    }

    public UserDTO creatUserProvider(UserDTO userDTO) {

        if (!userDTO.getPasswordHash().equals(userDTO.getConfirmPassword())) {
            throw new PasswordMismatchException("Mật khẩu nhập lại không khớp");
        }
        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new DuplicateResourceException("Email đã tồn tại: " + userDTO.getEmail());
        }

        User user = convertToEntity(userDTO);
        user.setPasswordHash(passwordEncoder.encode(userDTO.getPasswordHash()));
        user.setAccountRole(User.AccountRole.provider);
        user.setAccountStatus(User.AccountStatus.active);
        User savedUser = userRepository.save(user);

        sendWelcomeEmail(savedUser);

        return convertToDTO(savedUser);
    }

    public UserDTO createUser(UserDTO userDTO) {
        log.debug("Tạo User {}", userDTO);

        if (!userDTO.getPasswordHash().equals(userDTO.getConfirmPassword())) {
            throw new PasswordMismatchException("Mật khẩu nhập lại không khớp");
        }
        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new DuplicateResourceException("Email đã tồn tại: " + userDTO.getEmail());
        }

        User user = convertToEntity(userDTO);
        user.setPasswordHash(passwordEncoder.encode(userDTO.getPasswordHash()));
        user.setAccountRole(User.AccountRole.tourist);
        user.setAccountStatus(User.AccountStatus.active);
        User savedUser = userRepository.save(user);
        log.info("Tạo User ID: {}", savedUser.getUserId());

        sendWelcomeEmail(savedUser);

        return convertToDTO(savedUser);
    }

    public UserDTO updateUser(Integer userId, UserDTO userDTO) {
        log.debug("Cập nhật User ID: {}", userId);
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        // Cập nhật các trường được phép
        if (userDTO.getFullName() != null) {
            existingUser.setFullName(userDTO.getFullName());
        }
        if (userDTO.getPhoneNumber() != null) {
            existingUser.setPhoneNumber(userDTO.getPhoneNumber());
        }
        if (userDTO.getDateOfBirth() != null) {
            existingUser.setDateOfBirth(userDTO.getDateOfBirth());
        }
        if (userDTO.getGender() != null) {
            existingUser.setGender(User.Gender.valueOf(userDTO.getGender()));
        }

        User updatedUser = userRepository.save(existingUser);
        log.info("Đã cập nhật User ID: {}", updatedUser.getUserId());

        return convertToDTO(updatedUser);
    }

    public UserDTO uploadAvatar(Integer userId, MultipartFile file) throws IOException {
        log.debug("Upload avatar cho User ID: {}", userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        // Xóa avatar cũ nếu có
        if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImageByUrl(user.getAvatarUrl());
                log.info("Đã xóa avatar cũ: {}", user.getAvatarUrl());
            } catch (Exception e) {
                log.warn("Không thể xóa avatar cũ: {}", e.getMessage());
            }
        }

        // Upload avatar mới
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
        String avatarUrl = (String) uploadResult.get("secure_url");

        user.setAvatarUrl(avatarUrl);
        User savedUser = userRepository.save(user);
        log.info("Đã upload avatar mới cho User ID: {}", savedUser.getUserId());

        return convertToDTO(savedUser);
    }

    public UserDTO deleteAvatar(Integer userId) throws IOException {
        log.debug("Xóa avatar cho User ID: {}", userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        // Xóa avatar trên Cloudinary
        if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
            try {
                cloudinaryService.deleteImageByUrl(user.getAvatarUrl());
                log.info("Đã xóa avatar: {}", user.getAvatarUrl());
            } catch (Exception e) {
                log.warn("Không thể xóa avatar: {}", e.getMessage());
            }
        }

        user.setAvatarUrl(null);
        User savedUser = userRepository.save(user);
        log.info("Đã xóa avatar cho User ID: {}", savedUser.getUserId());

        return convertToDTO(savedUser);
    }

    /**
     * Upload ảnh từ URL (dùng cho Google OAuth) lên Cloudinary
     */
    public String uploadAvatarFromUrl(String imageUrl) {
        if (imageUrl == null || imageUrl.isEmpty()) {
            return null;
        }

        try {
            log.info("Đang tải ảnh từ URL: {}", imageUrl);
            URL url = new URL(imageUrl);

            // Tải ảnh từ URL
            try (InputStream inputStream = url.openStream()) {
                // Tạo MultipartFile từ InputStream
                MultipartFile multipartFile = new MultipartFile() {
                    @Override
                    public String getName() {
                        return "avatar";
                    }

                    @Override
                    public String getOriginalFilename() {
                        return "google-avatar.jpg";
                    }

                    @Override
                    public String getContentType() {
                        return "image/jpeg";
                    }

                    @Override
                    public boolean isEmpty() {
                        return false;
                    }

                    @Override
                    public long getSize() {
                        try {
                            return inputStream.available();
                        } catch (IOException e) {
                            return 0;
                        }
                    }

                    @Override
                    public byte[] getBytes() throws IOException {
                        return inputStream.readAllBytes();
                    }

                    @Override
                    public InputStream getInputStream() throws IOException {
                        return inputStream;
                    }

                    @Override
                    public void transferTo(java.io.File dest) throws IOException, IllegalStateException {
                        throw new UnsupportedOperationException();
                    }
                };

                // Upload lên Cloudinary
                Map<String, Object> uploadResult = cloudinaryService.uploadImage(multipartFile);
                String cloudinaryUrl = (String) uploadResult.get("secure_url");
                log.info("Đã upload ảnh Google lên Cloudinary: {}", cloudinaryUrl);
                return cloudinaryUrl;
            }
        } catch (Exception e) {
            log.error("Lỗi khi upload ảnh từ URL: {}", e.getMessage());
            return imageUrl; // Trả về URL gốc nếu upload thất bại
        }
    }

    public String forgotPassword(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Email không tồn tại!"));

        String otp = String.format("%06d", new Random().nextInt(999999));
        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(5);

        user.setResetOtp(otp);
        user.setOtpExpiryTime(expiryTime);
        User savedUser = userRepository.save(user);

        sendPasswordResetEmail(savedUser, otp);

        return "Mã xác minh đã được gửi đến email của bạn.";
    }

    public boolean verifyOtp(String email,
            String otp) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Email không tồn tại!"));

        // Log kiểm tra OTP và thời gian hết hạn
        System.out.println("OTP nhận được: " + otp);
        System.out.println("OTP đã lưu trong cơ sở dữ liệu: " + user.getResetOtp());
        System.out.println("Thời gian hết hạn OTP: " + user.getOtpExpiryTime());

        if (user.getResetOtp() == null || !user.getResetOtp().equals(otp)) {
            return false;
        }

        if (user.getOtpExpiryTime() == null || user.getOtpExpiryTime().isBefore(LocalDateTime.now())) {
            return false;
        }

        return true;
    }

    public String resetPassword(String email,
            String otp,
            String newPassword,
            String newConfirmPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Email không tồn tại!"));

        if (!newPassword.equals(newConfirmPassword)) {
            throw new PasswordMismatchException("Mật khẩu nhập lại không khớp");
        }

        if (user.getResetOtp() == null || !user.getResetOtp().equals(otp)) {
            return "Mã OTP không đúng hoặc đã hết hạn!";
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setResetOtp(null); // Xóa OTP sau khi sử dụng
        user.setOtpExpiryTime(null);
        userRepository.save(user);

        return "Mật khẩu đã được cập nhật thành công.";
    }

    public void sendPasswordResetEmail(User user,
            String otp) {
        EmailTemplateService.EmailData emailData = EmailTemplateService.EmailData.builder()
                .recipientName(user.getFullName())
                .mainTitle("Khôi phục mật khẩu")
                .mainMessage("Chúng tôi đã nhận được yêu cầu khôi phục mật khẩu cho tài khoản của bạn. " +
                        "Vui lòng sử dụng mã xác minh bên dưới để tiến hành đặt lại mật khẩu.")
                .highlightText("🔐 Mã xác minh của bạn: " + otp)
                .ctaButton("Đặt lại mật khẩu", "#")
                .warningMessage("Mã xác minh có hiệu lực trong 5 phút. Nếu bạn không thực hiện yêu cầu này, " +
                        "vui lòng bỏ qua email này hoặc liên hệ với chúng tôi ngay lập tức.")
                .addFeature("⏰", "Có hiệu lực trong 5 phút")
                .addFeature("🔒", "Bảo mật tuyệt đối")
                .addFeature("📞", "Hỗ trợ 24/7");

        emailTemplateService.sendEmail(user.getEmail(), EmailTemplateService.EmailType.PASSWORD_RESET, emailData);
    }

    public void sendWelcomeEmail(User user) {
        EmailTemplateService.EmailData emailData = EmailTemplateService.EmailData.builder()
                .recipientName(user.getFullName())
                .mainTitle("Chào mừng bạn đến với cộng đồng du lịch!")
                .mainMessage("Chúng tôi vô cùng vui mừng chào đón bạn gia nhập cộng đồng du lịch TRIPFINITY! " +
                        "Tài khoản của bạn đã được tạo thành công và sẵn sàng để khám phá những chuyến đi tuyệt vời.")
                .highlightText("🎉 Chúc mừng! Bạn đã chính thức trở thành thành viên TRIPFINITY")
                .ctaButton("Bắt đầu khám phá ngay!", "#")
                .warningMessage(
                        "Nếu bạn không thực hiện yêu cầu tạo tài khoản này, vui lòng liên hệ với chúng tôi ngay lập tức để được hỗ trợ.")
                .addFeature("🗺️", "Khám phá điểm đến")
                .addFeature("🏨", "Tìm khách sạn")
                .addFeature("📱", "Quản lý hành trình");

        emailTemplateService.sendEmail(user.getEmail(), EmailTemplateService.EmailType.WELCOME, emailData);
    }

    private UserDTO convertToDTO(User user) {
        return UserDTO.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phoneNumber(user.getPhoneNumber())
                .avatarUrl(user.getAvatarUrl())
                .accountRole(user.getAccountRole().name())
                .accountStatus(user.getAccountStatus().name())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender() != null ? user.getGender().name() : null)
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    private User convertToEntity(UserDTO userDTO) {
        return new User(
                userDTO.getUserId(),
                userDTO.getEmail(),
                userDTO.getPasswordHash(),
                userDTO.getFullName(),
                userDTO.getPhoneNumber(),
                userDTO.getAvatarUrl(),
                User.AccountRole.valueOf(userDTO.getAccountRole()),
                User.AccountStatus.valueOf(userDTO.getAccountStatus()),
                userDTO.getDateOfBirth(),
                userDTO.getGender() != null ? User.Gender.valueOf(userDTO.getGender()) : null,
                null,
                null,
                userDTO.getCreatedAt(),
                userDTO.getUpdatedAt());
    }
}