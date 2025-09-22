package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.auth.LoginRequest;
import com.vn.tripfinity.backend.service.auth.AuthService;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/provider/login")
    public ResponseEntity<?> loginProvider(@RequestBody LoginRequest loginRequest) {
        return authService.loginProvider(loginRequest);
    }

    @PostMapping("/provider/oauth-login")
    public ResponseEntity<?> oauthProviderLogin(@RequestBody Map<String, String> body) {
        String idToken = body.get("id_token");
        if (idToken == null || idToken.isEmpty()) {
            return ResponseEntity.badRequest().body("Missing Google ID token");
        }
        return authService.handleGoogleLoginProvider(idToken);
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {
        return authService.authenticateUser(loginRequest);
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logoutUser(HttpServletRequest request,
            HttpServletResponse response) {
        // Xóa SecurityContext
        SecurityContextHolder.clearContext();
        // Hủy session nếu có
        var session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        // Xóa cookie JSESSIONID
        Cookie cookie = new Cookie("JSESSIONID", null);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(0);
        response.addCookie(cookie);

        return ResponseEntity.ok("User logged out successfully");
    }

    // Google Login
    @GetMapping("/google")
    public void redirectToGoogle(HttpServletResponse response) throws IOException {
        response.sendRedirect("/oauth2/authorization/google");
    }

    @PostMapping("/oauth-login")
    public ResponseEntity<?> oauthLogin(@RequestBody Map<String, String> body) {
        String idToken = body.get("id_token");
        if (idToken == null || idToken.isEmpty()) {
            return ResponseEntity.badRequest().body("Missing Google ID token");
        }
        return authService.handleGoogleLogin(idToken);
    }

    @GetMapping(value = "/me", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> getCurrentUser(
            @AuthenticationPrincipal OAuth2User oauth2User) {

        // Nếu oauth2User null thì request chưa authenticated
        if (oauth2User == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Map<String, Object> attrs = oauth2User.getAttributes();
        return ResponseEntity.ok(attrs);
    }
}