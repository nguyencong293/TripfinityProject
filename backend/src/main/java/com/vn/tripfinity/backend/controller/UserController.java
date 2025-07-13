package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.UserDTO;
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

    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<UserDTO> createUser(@Valid @ModelAttribute UserDTO userDTO) throws IOException {
        log.info("Create /api/users - Creating user {}", userDTO);
        UserDTO createUser = userService.createUser(userDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createUser);
    }
}
