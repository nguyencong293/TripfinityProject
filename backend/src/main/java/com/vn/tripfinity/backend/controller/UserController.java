package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.UserDTO;
import com.vn.tripfinity.backend.sevice.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
