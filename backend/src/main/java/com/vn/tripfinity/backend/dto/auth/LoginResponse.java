package com.vn.tripfinity.backend.dto.auth;

import lombok.Data;

@Data
public class LoginResponse {
    private String token;
    private String type = "Bearer";
    private Integer userId;
    private String name;
    private String email;

    public LoginResponse(String token, Integer userId, String name, String email) {
        this.token = token;
        this.userId = userId;
        this.name = name;
        this.email = email;
    }
}
