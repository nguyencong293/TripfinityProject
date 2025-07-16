package com.vn.tripfinity.backend.sevice.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;
import com.vn.tripfinity.backend.sevice.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Component
public class CustomOAuth2SuccessHandler implements AuthenticationSuccessHandler {
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private UserService userService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        OAuth2User oauth2User = (OAuth2User) authentication.getPrincipal();
        String email = oauth2User.getAttribute("email");
        String name = oauth2User.getAttribute("name");
        String avatar = oauth2User.getAttribute("picture");
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            String randomPassword = UUID.randomUUID().toString();
            User newUser = new User();
            newUser.setEmail(email);
            newUser.setFullName(name);
            newUser.setAvatarUrl(avatar);
            newUser.setAccountRole(User.AccountRole.tourist);
            newUser.setAccountStatus(User.AccountStatus.active);
            newUser.setPasswordHash(passwordEncoder.encode(randomPassword));
            userRepository.save(newUser);

            userService.sendWelcomeEmail(newUser);
        }
        // Trả về JSON message thông báo đăng nhập thành công
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, String> result = new HashMap<>();
        result.put("message", "Đăng nhập Google thành công!");
        ObjectMapper mapper = new ObjectMapper();
        response.getWriter().write(mapper.writeValueAsString(result));
    }
}
