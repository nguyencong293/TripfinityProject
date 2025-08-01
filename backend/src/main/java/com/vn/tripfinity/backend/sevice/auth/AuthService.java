package com.vn.tripfinity.backend.sevice.auth;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.vn.tripfinity.backend.dto.auth.LoginRequest;
import com.vn.tripfinity.backend.dto.auth.LoginResponse;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.sevice.UserService;
import com.vn.tripfinity.backend.sevice.auth.token.JwtTokenProvider;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@Transactional
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final GoogleIdTokenVerifier tokenVerifier;
    private final UserService userService;

    public AuthService(AuthenticationManager authenticationManager,
                       JwtTokenProvider tokenProvider,
                       UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       GoogleIdTokenVerifier tokenVerifier,
                       UserService userService) {
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenVerifier = tokenVerifier;
        this.userService = userService;
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

    public ResponseEntity<?> handleGoogleLogin(String idTokenString) {
//        System.out.println("Nhận token Google: " + idTokenString);
        try {
            // Xác minh ID token
            GoogleIdToken idToken = tokenVerifier.verify(idTokenString);
            if (idToken == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token Google sai");
            }

            // Trích xuất thông tin
            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String avatar = (String) payload.get("picture");

            User user = findOrCreateUser(email, name, avatar);

            Map<String, Object> tokens = generateTokens(user);

            return ResponseEntity.ok(tokens);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Lỗi đăng nhập Google: " + e.getMessage());
        }
    }

    private User findOrCreateUser(String email,
                                  String name,
                                  String avatar) {
        return userRepository.findByEmail(email).orElseGet(() -> {
            User newUser = new User();
            newUser.setEmail(email);
            newUser.setFullName(name);
            newUser.setAvatarUrl(avatar);
            newUser.setAccountStatus(User.AccountStatus.active);
            newUser.setAccountRole(User.AccountRole.tourist);
            newUser.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
            User savedUser = userRepository.save(newUser);
            userService.sendWelcomeEmail(savedUser);
            return savedUser;
        });
    }

    private Map<String, Object> generateTokens(User user) {
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getAccountRole().name()))
        );

        String jwt = tokenProvider.generateToken(userDetails);

        Map<String, Object> tokens = new HashMap<>();
        tokens.put("token", jwt);
        tokens.put("userId", user.getUserId());
        tokens.put("email", user.getEmail());
        tokens.put("name", user.getFullName());
        return tokens;
    }
}
