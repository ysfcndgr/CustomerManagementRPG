package com.example.customerupdate.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
import java.util.List;

public class CustomerDto {
    private Integer customerId;
    private String name;
    private String phone;
    private String email;
    private String address;
    private String taxId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String status;
    // Getters and setters omitted for brevity
}

class CreateCustomerDto {
    @NotBlank
    @Size(min = 2, max = 100)
    private String name;
    @Pattern(regexp = "^$|^[+]?[0-9\- ]{7,20}$", message = "Invalid phone number")
    private String phone;
    @Email
    private String email;
    @NotBlank
    @Size(min = 5, max = 500)
    private String address;
    @NotBlank
    @Size(min = 11, max = 11)
    @Pattern(regexp = "^\\d{11}$", message = "Tax ID must be exactly 11 digits")
    private String taxId;
    // Getters and setters omitted for brevity
}

class UpdateCustomerDto {
    @NotBlank
    @Size(min = 2, max = 100)
    private String name;
    @Pattern(regexp = "^$|^[+]?[0-9\- ]{7,20}$", message = "Invalid phone number")
    private String phone;
    @Email
    private String email;
    @NotBlank
    @Size(min = 5, max = 500)
    private String address;
    @NotBlank
    @Size(min = 11, max = 11)
    @Pattern(regexp = "^\\d{11}$", message = "Tax ID must be exactly 11 digits")
    private String taxId;
    // Getters and setters omitted for brevity
}

class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private List<String> errors;
    private String error;
    // Getters and setters omitted for brevity
} 