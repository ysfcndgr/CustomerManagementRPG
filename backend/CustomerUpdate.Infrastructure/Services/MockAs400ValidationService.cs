using Microsoft.Extensions.Logging;
using System.Text.RegularExpressions;

namespace CustomerUpdate.Infrastructure.Services;

public class MockAs400ValidationService : IAs400ValidationService
{
    private readonly ILogger<MockAs400ValidationService> _logger;
    private readonly List<string> _existingTaxIds;

    public MockAs400ValidationService(ILogger<MockAs400ValidationService> logger)
    {
        _logger = logger;
        // Simulated existing Tax IDs in the system
        _existingTaxIds = new List<string>
        {
            "12345678901",
            "98765432109", 
            "11111111111"
        };
    }

    public async Task<ValidationResult> ValidateCustomerAsync(string name, string? phone, string? email, string address, string taxId)
    {
        await Task.Delay(100); // Simulate network latency to AS400

        _logger.LogInformation("Mock AS400 RPG program MUSTVALID - validating customer: {TaxId}", taxId);

        var errors = new List<string>();

        // Simulate RPG validation logic from MUSTVALID.rpgle

        // 1. Name validation (validateName procedure)
        if (string.IsNullOrWhiteSpace(name))
        {
            errors.Add("Customer name is required");
        }
        else if (name.Length < 2 || name.Length > 100)
        {
            errors.Add("Customer name must be 2-100 characters");
        }
        else if (!Regex.IsMatch(name, @"^[a-zA-Z\s'-]+$"))
        {
            errors.Add("Customer name contains invalid characters");
        }

        // 2. Phone validation (validatePhone procedure)
        if (!string.IsNullOrWhiteSpace(phone))
        {
            var cleanPhone = Regex.Replace(phone, @"[\s\-\(\)\+]", "");
            if (!Regex.IsMatch(cleanPhone, @"^\d{10,}$"))
            {
                errors.Add("Phone number must contain at least 10 digits");
            }
            if (Regex.IsMatch(phone, @"[^0-9\s\-\(\)\+]"))
            {
                errors.Add("Phone number contains invalid characters");
            }
        }

        // 3. Email validation (validateEmail procedure)
        if (!string.IsNullOrWhiteSpace(email))
        {
            if (email.Length > 100)
            {
                errors.Add("Email address too long (max 100 characters)");
            }
            else if (!email.Contains("@"))
            {
                errors.Add("Email address must contain @ symbol");
            }
            else if (!Regex.IsMatch(email, @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"))
            {
                errors.Add("Invalid email address format");
            }
        }

        // 4. Address validation (validateAddress procedure)
        if (string.IsNullOrWhiteSpace(address))
        {
            errors.Add("Address is required");
        }
        else if (address.Length < 5)
        {
            errors.Add("Address must be at least 5 characters");
        }
        else if (address.Length > 255)
        {
            errors.Add("Address too long (max 255 characters)");
        }

        // 5. Tax ID validation (validateTaxId procedure)
        if (string.IsNullOrWhiteSpace(taxId))
        {
            errors.Add("Tax ID is required");
        }
        else if (taxId.Length != 11)
        {
            errors.Add("Tax ID must be exactly 11 characters");
        }
        else if (!Regex.IsMatch(taxId, @"^\d{11}$"))
        {
            errors.Add("Tax ID must contain only digits");
        }
        else if (_existingTaxIds.Contains(taxId))
        {
            errors.Add("Tax ID already exists in database");
        }

        // Simulate RPG program response format
        if (errors.Any())
        {
            var errorMessage = string.Join(". ", errors) + ".";
            _logger.LogWarning("Mock AS400 validation failed: {Errors}", errorMessage);
            
            return new ValidationResult
            {
                IsValid = false,
                Message = $"VALIDATION_ERROR: {errorMessage}",
                Errors = errors
            };
        }

        // Simulate successful validation and customer ID generation
        var customerId = new Random().Next(1000, 9999);
        var successMessage = $"SUCCESS: Customer information validated and saved successfully. Customer ID: {customerId}";
        
        _logger.LogInformation("Mock AS400 validation successful: {Message}", successMessage);

        // Add the new Tax ID to our simulated database
        _existingTaxIds.Add(taxId);

        return new ValidationResult
        {
            IsValid = true,
            Message = successMessage,
            Errors = new List<string>()
        };
    }
} 