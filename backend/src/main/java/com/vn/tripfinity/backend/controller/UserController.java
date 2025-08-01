package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.ForgotPasswordRequest;
import com.vn.tripfinity.backend.dto.ResetPasswordRequest;
import com.vn.tripfinity.backend.dto.UserDTO;
import com.vn.tripfinity.backend.dto.VerifyOtpRequest;
import com.vn.tripfinity.backend.sevice.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class UserController {
    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        log.info("Get /api/users - Getting all users");
        List<UserDTO> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @PostMapping("/provider")
    public ResponseEntity<UserDTO> creatUserProvider(@Valid @RequestBody UserDTO userDTO) {
        UserDTO createUserProvider = userService.creatUserProvider(userDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createUserProvider);
    }

    @PostMapping
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody UserDTO userDTO) {
        log.info("Create /api/users - Creating user {}", userDTO);
        UserDTO createUser = userService.createUser(userDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createUser);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        String responseMessage = userService.forgotPassword(request.getEmail());
        return ResponseEntity.ok(responseMessage);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody VerifyOtpRequest request) {
        boolean isOtpValid = userService.verifyOtp(request.getEmail(), request.getOtp());

        if (isOtpValid) {
            return ResponseEntity.ok("Mã OTP hợp lệ.");
        } else {
            return ResponseEntity.badRequest().body("Mã OTP không đúng hoặc đã hết hạn.");
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        String responseMessage = userService.resetPassword(request.getEmail(), request.getOtp(), request.getNewPassword(), request.getNewConfirmPassword());

        if (responseMessage.equals("Mật khẩu đã được cập nhật thành công.")) {
            return ResponseEntity.ok(responseMessage);
        } else {
            return ResponseEntity.badRequest().body(responseMessage);
        }
    }
}
