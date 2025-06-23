package com.example.customerupdate.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Service
public class As400ValidationService {
    @Value("${as400.connection-string}")
    private String as400ConnectionString;

    public CompletableFuture<ValidationResult> validateCustomerAsync(String name, String phone, String email, String address, String taxId) {
        // TODO: Implement ODBC call to AS400 RPG program
        // For now, always return valid
        ValidationResult result = new ValidationResult();
        result.setValid(true);
        result.setMessage("Stub: Validation passed");
        result.setErrors(List.of());
        return CompletableFuture.completedFuture(result);
    }

    public static class ValidationResult {
        private boolean isValid;
        private String message;
        private List<String> errors;

        public boolean isValid() { return isValid; }
        public void setValid(boolean valid) { isValid = valid; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public List<String> getErrors() { return errors; }
        public void setErrors(List<String> errors) { this.errors = errors; }
    }
} 