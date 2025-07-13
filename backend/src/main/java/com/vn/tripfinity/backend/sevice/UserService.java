package com.vn.tripfinity.backend.sevice;

import com.vn.tripfinity.backend.dto.UserDTO;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {
    private final UserRepository userRepository;

    public List<UserDTO> getAllUsers() {
        log.debug("Fetching all users");
        return userRepository.findAll().stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    private UserDTO convertToDTO(User user) {
        return new UserDTO(
                user.getUserId(),
                user.getEmail(),
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
                null,
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
