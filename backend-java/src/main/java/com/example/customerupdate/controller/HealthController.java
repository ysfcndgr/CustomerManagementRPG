package com.example.customerupdate.controller;

import com.example.customerupdate.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {
    @Value("${spring.profiles.active:development}")
    private String environment;

    @GetMapping
    public ApiResponse<Object> getHealth() {
        Map<String, Object> data = new HashMap<>();
        data.put("status", "Healthy");
        data.put("timestamp", Instant.now());
        data.put("version", "1.0.0");
        data.put("environment", environment);
        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccess(true);
        response.setMessage("API is healthy");
        response.setData(data);
        return response;
    }
} 