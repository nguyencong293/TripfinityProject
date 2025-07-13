package com.vn.tripfinity.backend.sevice.auth;

import com.vn.tripfinity.backend.dto.auth.LoginRequest;
import com.vn.tripfinity.backend.dto.auth.LoginResponse;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.sevice.auth.token.JwtTokenProvider;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(AuthenticationManager authenticationManager,
                       JwtTokenProvider tokenProvider,
                       UserRepository userRepository,
                       PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public ResponseEntity<?> authenticateUser(LoginRequest loginRequest) {
        if (!userRepository.existsByEmail(loginRequest.getEmail())) {
            return ResponseEntity.badRequest().body("Email không tồn tại!");
        }

        User user = userRepository.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPasswordHash())) {
            return ResponseEntity.badRequest().body("Mật khẩu không đúng!");
        }

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getEmail(),
                        loginRequest.getPassword()
                )
        );

        // Set authentication vào SecurityContext
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Generate JWT token
        String jwt = tokenProvider.generateToken((UserDetails) authentication.getPrincipal());

        return ResponseEntity.ok(new LoginResponse(jwt, user.getUserId(), user.getFullName(), user.getEmail()));
    }
}
