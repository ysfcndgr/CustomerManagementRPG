using Microsoft.AspNetCore.Mvc;
using CustomerUpdate.Core.Interfaces;
using CustomerUpdate.Core.Entities;
using CustomerUpdate.API.DTOs;
using CustomerUpdate.Infrastructure.Services;

namespace CustomerUpdate.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    private readonly ICustomerRepository _customerRepository;
    private readonly IAs400ValidationService _as400ValidationService;

    public CustomersController(ICustomerRepository customerRepository, IAs400ValidationService as400ValidationService)
    {
        _customerRepository = customerRepository;
        _as400ValidationService = as400ValidationService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<CustomerDto>>>> GetAllCustomers()
    {
        try
        {
            var customers = await _customerRepository.GetAllAsync();
            var customerDtos = customers.Select(c => new CustomerDto
            {
                CustomerId = c.CustomerId,
                Name = c.Name,
                Phone = c.Phone,
                Email = c.Email,
                Address = c.Address,
                TaxId = c.TaxId,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt,
                Status = c.Status
            });

            return Ok(new ApiResponse<IEnumerable<CustomerDto>>
            {
                Success = true,
                Message = "Customers retrieved successfully",
                Data = customerDtos
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new ApiResponse<IEnumerable<CustomerDto>>
            {
                Success = false,
                Message = "An error occurred while retrieving customers",
                Error = ex.Message
            });
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> GetCustomer(int id)
    {
        try
        {
            var customer = await _customerRepository.GetByIdAsync(id);
            
            if (customer == null)
            {
                return NotFound(new ApiResponse<CustomerDto>
                {
                    Success = false,
                    Message = "Customer not found",
                    Error = $"Customer with ID {id} does not exist"
                });
            }

            var customerDto = new CustomerDto
            {
                CustomerId = customer.CustomerId,
                Name = customer.Name,
                Phone = customer.Phone,
                Email = customer.Email,
                Address = customer.Address,
                TaxId = customer.TaxId,
                CreatedAt = customer.CreatedAt,
                UpdatedAt = customer.UpdatedAt,
                Status = customer.Status
            };

            return Ok(new ApiResponse<CustomerDto>
            {
                Success = true,
                Message = "Customer retrieved successfully",
                Data = customerDto
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new ApiResponse<CustomerDto>
            {
                Success = false,
                Message = "An error occurred while retrieving the customer",
                Error = ex.Message
            });
        }
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> CreateCustomer(CreateCustomerDto createCustomerDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();

                return BadRequest(new ApiResponse<CustomerDto>
                {
                    Success = false,
                    Message = "Validation failed",
                    Errors = errors
                });
            }

            // Call AS400 RPG program for validation
            var validationResult = await _as400ValidationService.ValidateCustomerAsync(
                createCustomerDto.Name,
                createCustomerDto.Phone,
                createCustomerDto.Email,
                createCustomerDto.Address,
                createCustomerDto.TaxId);

            if (!validationResult.IsValid)
            {
                return BadRequest(new ApiResponse<CustomerDto>
                {
                    Success = false,
                    Message = "AS400 validation failed",
                    Error = validationResult.Message,
                    Errors = validationResult.Errors
                });
            }

            var customer = new Customer
            {
                Name = createCustomerDto.Name,
                Phone = createCustomerDto.Phone,
                Email = createCustomerDto.Email,
                Address = createCustomerDto.Address,
                TaxId = createCustomerDto.TaxId,
                Status = "Active"
            };

            var createdCustomer = await _customerRepository.CreateAsync(customer);

            var customerDto = new CustomerDto
            {
                CustomerId = createdCustomer.CustomerId,
                Name = createdCustomer.Name,
                Phone = createdCustomer.Phone,
                Email = createdCustomer.Email,
                Address = createdCustomer.Address,
                TaxId = createdCustomer.TaxId,
                CreatedAt = createdCustomer.CreatedAt,
                UpdatedAt = createdCustomer.UpdatedAt,
                Status = createdCustomer.Status
            };

            return Created($"api/customers/{createdCustomer.CustomerId}", new ApiResponse<CustomerDto>
            {
                Success = true,
                Message = "Customer created successfully",
                Data = customerDto
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new ApiResponse<CustomerDto>
            {
                Success = false,
                Message = "An error occurred while creating the customer",
                Error = ex.Message
            });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> UpdateCustomer(int id, UpdateCustomerDto updateCustomerDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();

                return BadRequest(new ApiResponse<CustomerDto>
                {
                    Success = false,
                    Message = "Validation failed",
                    Errors = errors
                });
            }

            var existingCustomer = await _customerRepository.GetByIdAsync(id);
            if (existingCustomer == null)
            {
                return NotFound(new ApiResponse<CustomerDto>
                {
                    Success = false,
                    Message = "Customer not found",
                    Error = $"Customer with ID {id} does not exist"
                });
            }

            // Check if Tax ID already exists (excluding current customer)
            var existingTaxIdCustomer = await _customerRepository.GetByTaxIdAsync(updateCustomerDto.TaxId);
            if (existingTaxIdCustomer != null && existingTaxIdCustomer.CustomerId != id)
            {
                return BadRequest(new ApiResponse<CustomerDto>
                {
                    Success = false,
                    Message = "Tax ID already exists",
                    Error = "A customer with this Tax ID already exists in the system"
                });
            }

            existingCustomer.Name = updateCustomerDto.Name;
            existingCustomer.Phone = updateCustomerDto.Phone;
            existingCustomer.Email = updateCustomerDto.Email;
            existingCustomer.Address = updateCustomerDto.Address;
            existingCustomer.TaxId = updateCustomerDto.TaxId;

            var updatedCustomer = await _customerRepository.UpdateAsync(existingCustomer);

            var customerDto = new CustomerDto
            {
                CustomerId = updatedCustomer.CustomerId,
                Name = updatedCustomer.Name,
                Phone = updatedCustomer.Phone,
                Email = updatedCustomer.Email,
                Address = updatedCustomer.Address,
                TaxId = updatedCustomer.TaxId,
                CreatedAt = updatedCustomer.CreatedAt,
                UpdatedAt = updatedCustomer.UpdatedAt,
                Status = updatedCustomer.Status
            };

            return Ok(new ApiResponse<CustomerDto>
            {
                Success = true,
                Message = "Customer updated successfully",
                Data = customerDto
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new ApiResponse<CustomerDto>
            {
                Success = false,
                Message = "An error occurred while updating the customer",
                Error = ex.Message
            });
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<object>>> DeleteCustomer(int id)
    {
        try
        {
            var success = await _customerRepository.DeleteAsync(id);
            
            if (!success)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Customer not found",
                    Error = $"Customer with ID {id} does not exist"
                });
            }

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Customer deleted successfully"
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while deleting the customer",
                Error = ex.Message
            });
        }
    }

    [HttpGet("validate-tax-id/{taxId}")]
    public async Task<ActionResult<ApiResponse<object>>> ValidateTaxId(string taxId)
    {
        try
        {
            var exists = await _customerRepository.TaxIdExistsAsync(taxId);
            
            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Tax ID validation completed",
                Data = new { 
                    isValid = taxId.Length == 11 && taxId.All(char.IsDigit),
                    exists = exists 
                }
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while validating Tax ID",
                Error = ex.Message
            });
        }
    }
} 