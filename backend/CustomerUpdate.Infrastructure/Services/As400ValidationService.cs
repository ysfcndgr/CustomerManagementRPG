using System.Data.Odbc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace CustomerUpdate.Infrastructure.Services;

public interface IAs400ValidationService
{
    Task<ValidationResult> ValidateCustomerAsync(string name, string? phone, string? email, string address, string taxId);
}

public class ValidationResult
{
    public bool IsValid { get; set; }
    public string Message { get; set; } = string.Empty;
    public List<string> Errors { get; set; } = new();
}

public class As400ValidationService : IAs400ValidationService
{
    private readonly string _connectionString;
    private readonly ILogger<As400ValidationService> _logger;

    public As400ValidationService(IConfiguration configuration, ILogger<As400ValidationService> logger)
    {
        _connectionString = configuration.GetConnectionString("AS400") ?? 
            throw new InvalidOperationException("AS400 connection string not found");
        _logger = logger;
    }

    public async Task<ValidationResult> ValidateCustomerAsync(string name, string? phone, string? email, string address, string taxId)
    {
        try
        {
            _logger.LogInformation("Calling AS400 RPG program MUSTVALID for customer validation");

            using var connection = new OdbcConnection(_connectionString);
            using var command = new OdbcCommand("CALL CUSTLIB.MUSTVALID(?,?,?,?,?,?)", connection);

            // Add input parameters
            command.Parameters.AddWithValue("@name", name);
            command.Parameters.AddWithValue("@phone", phone ?? "");
            command.Parameters.AddWithValue("@email", email ?? "");
            command.Parameters.AddWithValue("@address", address);
            command.Parameters.AddWithValue("@taxId", taxId);
            
            // Add output parameter for result
            var resultParam = command.Parameters.Add("@result", OdbcType.VarChar, 500);
            resultParam.Direction = System.Data.ParameterDirection.Output;

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();

            var result = resultParam.Value?.ToString() ?? "";
            
            _logger.LogInformation("AS400 RPG validation result: {Result}", result);

            return ParseValidationResult(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling AS400 RPG program MUSTVALID");
            return new ValidationResult
            {
                IsValid = false,
                Message = "AS400 system error",
                Errors = new List<string> { "Unable to connect to AS400 validation system" }
            };
        }
    }

    private ValidationResult ParseValidationResult(string result)
    {
        if (string.IsNullOrEmpty(result))
        {
            return new ValidationResult
            {
                IsValid = false,
                Message = "No response from validation system",
                Errors = new List<string> { "Empty response from AS400" }
            };
        }

        // Parse RPG program response
        if (result.StartsWith("SUCCESS:", StringComparison.OrdinalIgnoreCase))
        {
            return new ValidationResult
            {
                IsValid = true,
                Message = result,
                Errors = new List<string>()
            };
        }
        else if (result.StartsWith("VALIDATION_ERROR:", StringComparison.OrdinalIgnoreCase))
        {
            var errorMessage = result.Substring("VALIDATION_ERROR:".Length).Trim();
            var errors = errorMessage.Split(new[] { ". " }, StringSplitOptions.RemoveEmptyEntries)
                                   .Where(e => !string.IsNullOrWhiteSpace(e))
                                   .ToList();

            return new ValidationResult
            {
                IsValid = false,
                Message = errorMessage,
                Errors = errors
            };
        }
        else if (result.StartsWith("ERROR:", StringComparison.OrdinalIgnoreCase))
        {
            var errorMessage = result.Substring("ERROR:".Length).Trim();
            return new ValidationResult
            {
                IsValid = false,
                Message = errorMessage,
                Errors = new List<string> { errorMessage }
            };
        }
        else
        {
            return new ValidationResult
            {
                IsValid = false,
                Message = "Unknown response format",
                Errors = new List<string> { result }
            };
        }
    }
} 