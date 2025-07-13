package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.UserDTO;
import com.vn.tripfinity.backend.exception.DuplicateResourceException;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailTemplateService emailTemplateService;

    public List<UserDTO> getAllUsers() {
        log.debug("Fetching all users");
        return userRepository.findAll().stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public UserDTO createUser(UserDTO userDTO) throws IOException {
        log.debug("Creating user {}", userDTO);
        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new DuplicateResourceException("Email đã tồn tại: " + userDTO.getEmail());
        }

        User user = convertToEntity(userDTO);
        user.setPasswordHash(passwordEncoder.encode(userDTO.getPasswordHash()));
        User savedUser = userRepository.save(user);
        log.info("User created successfully with ID: {}", savedUser.getUserId());

        sendWelcomeEmail(savedUser);

        return convertToDTO(savedUser);
    }

    private void sendWelcomeEmail(User user) {
        EmailTemplateService.EmailData emailData = EmailTemplateService.EmailData.builder()
                .recipientName(user.getFullName())
                .mainTitle("Chào mừng bạn đến với cộng đồng du lịch!")
                .mainMessage("Chúng tôi vô cùng vui mừng chào đón bạn gia nhập cộng đồng du lịch TRIPFINITY! " +
                        "Tài khoản của bạn đã được tạo thành công và sẵn sàng để khám phá những chuyến đi tuyệt vời.")
                .highlightText("🎉 Chúc mừng! Bạn đã chính thức trở thành thành viên TRIPFINITY")
                .ctaButton("Bắt đầu khám phá ngay!", "https://tripfinity.com/dashboard")
                .warningMessage("Nếu bạn không thực hiện yêu cầu tạo tài khoản này, vui lòng liên hệ với chúng tôi ngay lập tức để được hỗ trợ.")
                .addFeature("🗺️", "Khám phá điểm đến")
                .addFeature("🏨", "Tìm khách sạn")
                .addFeature("📱", "Quản lý hành trình");

        emailTemplateService.sendEmail(user.getEmail(), EmailTemplateService.EmailType.WELCOME, emailData);
    }


    private UserDTO convertToDTO(User user) {
        return new UserDTO(
                user.getUserId(),
                user.getEmail(),
                user.getPasswordHash(),
                user.getFullName(),
                user.getPhoneNumber(),
                user.getAvatarUrl(),
                user.getAccountRole().name(),
                user.getAccountStatus().name(),
                user.getDateOfBirth(),
                user.getGender() != null ? user.getGender().name() : null,
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
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
                userDTO.getUpdatedAt()
        );
    }
}
