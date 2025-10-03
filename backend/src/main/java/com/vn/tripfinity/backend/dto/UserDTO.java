package com.vn.tripfinity.backend.dto;

import com.vn.tripfinity.backend.model.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO {
    private Integer userId;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng")
    @Size(max = 255)
    private String email;

    // @NotBlank(message = "Mật khẩu không được để trống")
    @Size(min = 6, max = 64, message = "Mật khẩu phải từ 6–64 ký tự")
    // @Pattern(
    // regexp =
    // "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]+$",
    // message = "Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký
    // tự đặc biệt"
    // )
    private String passwordHash;
    private String confirmPassword;

    @NotBlank(message = "Họ tên không được để trống")
    @Size(max = 255, message = "Họ tên tối đa 255 ký tự")
    private String fullName;

    private String phoneNumber;

    @Size(max = 512)
    private String avatarUrl;

    @NotNull(message = "Quyền truy cập không được để trống")
    @Builder.Default
    private String accountRole = User.AccountRole.tourist.name(); // TOURIST, PROVIDER, ADMIN

    @NotNull(message = "Trạng thái tài khoản không được để trống")
    @Builder.Default
    private String accountStatus = User.AccountStatus.active.name(); // ACTIVE, BANNED

    private LocalDate dateOfBirth;

    private String gender; // MALE, FEMALE, OTHER

    private String resetOtp;
    private LocalDateTime otpExpiryTime;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
