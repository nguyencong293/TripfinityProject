package com.vn.tripfinity.backend.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "app.zalopay")
public class ZaloPayProperties {
    private String appid;
    private String key1;
    private String key2;
    private String endpoint;
    private String returnUrl;
    private String callbackUrl;
}
