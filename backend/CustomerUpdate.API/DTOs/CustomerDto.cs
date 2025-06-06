using System.ComponentModel.DataAnnotations;

namespace CustomerUpdate.API.DTOs;

public class CustomerDto
{
    public int CustomerId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public string Address { get; set; } = string.Empty;
    public string TaxId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Status { get; set; } = "Active";
}

public class CreateCustomerDto
{
    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Name { get; set; } = string.Empty;
    
    [Phone]
    public string? Phone { get; set; }
    
    [EmailAddress]
    public string? Email { get; set; }
    
    [Required]
    [StringLength(500, MinimumLength = 5)]
    public string Address { get; set; } = string.Empty;
    
    [Required]
    [StringLength(11, MinimumLength = 11)]
    [RegularExpression(@"^\d{11}$", ErrorMessage = "Tax ID must be exactly 11 digits")]
    public string TaxId { get; set; } = string.Empty;
}

public class UpdateCustomerDto
{
    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Name { get; set; } = string.Empty;
    
    [Phone]
    public string? Phone { get; set; }
    
    [EmailAddress]
    public string? Email { get; set; }
    
    [Required]
    [StringLength(500, MinimumLength = 5)]
    public string Address { get; set; } = string.Empty;
    
    [Required]
    [StringLength(11, MinimumLength = 11)]
    [RegularExpression(@"^\d{11}$", ErrorMessage = "Tax ID must be exactly 11 digits")]
    public string TaxId { get; set; } = string.Empty;
}

public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public List<string>? Errors { get; set; }
    public string? Error { get; set; }
} 