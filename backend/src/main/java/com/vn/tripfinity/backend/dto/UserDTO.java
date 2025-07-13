package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
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

    @NotBlank(message = "Họ tên không được để trống")
    @Size(max = 255, message = "Họ tên tối đa 255 ký tự")
    private String fullName;

    private String phoneNumber;

    @Size(max = 512)
    private String avatarUrl;

    @NotNull(message = "Quyền truy cập không được để trống")
    private String accountRole;    // TOURIST, PROVIDER, ADMIN

    @NotNull(message = "Trạng thái tài khoản không được để trống")
    private String accountStatus;  // ACTIVE, BANNED

    private LocalDate dateOfBirth;

    private String gender;         // MALE, FEMALE, OTHER

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
