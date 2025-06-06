using Microsoft.AspNetCore.Mvc;
using CustomerUpdate.API.DTOs;

namespace CustomerUpdate.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public ActionResult<ApiResponse<object>> GetHealth()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "API is healthy",
            Data = new 
            { 
                status = "Healthy",
                timestamp = DateTime.UtcNow,
                version = "1.0.0",
                environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development"
            }
        });
    }
} 