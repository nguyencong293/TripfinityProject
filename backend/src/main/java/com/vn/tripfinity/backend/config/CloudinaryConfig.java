package com.vn.tripfinity.backend.config;

import com.cloudinary.Cloudinary;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class CloudinaryConfig {
    @Bean
    public Cloudinary cloudinary() {
        Map<String, Object> config = new HashMap<>();
        config.put("cloud_name", "tripfinity-img");
        config.put("api_key", "411282154756183");
        config.put("api_secret", "vpBe5pBrhJoTYc7VxAXQxHiopQo");
        config.put("secure", true);

        return new Cloudinary(config);
    }
}
