# Customer Update Backend API

🚀 **.NET 8 Web API for Customer Information Management with AS400 Integration**

## 🎯 Overview

This is the backend API component of the Customer Information Update System, built with .NET 8 following Clean Architecture principles. It provides RESTful endpoints for customer data management, integrates with AS400 RPG programs, and handles data validation through IBM DB2 database operations.

## 🏗️ Architecture

The solution follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    CustomerUpdate.API                      │
│              (Controllers, Middleware, DI)                 │
├─────────────────────────────────────────────────────────────┤
│                 CustomerUpdate.Core                        │
│           (Entities, Interfaces, Use Cases)               │
├─────────────────────────────────────────────────────────────┤
│              CustomerUpdate.Infrastructure                 │
│        (DB Context, Repositories, AS400 Integration)      │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Features

- ✅ **Clean Architecture**: Maintainable and testable codebase
- ✅ **RESTful API**: Standard HTTP methods and status codes
- ✅ **AS400 Integration**: Direct RPG program calls and DB2 access
- ✅ **Validation**: FluentValidation for robust input validation
- ✅ **Logging**: Structured logging with Serilog
- ✅ **Documentation**: Auto-generated Swagger/OpenAPI docs
- ✅ **CORS**: Cross-origin resource sharing support
- ✅ **Error Handling**: Comprehensive error handling middleware
- ✅ **Health Checks**: API and database health monitoring

## 🛠️ Technology Stack

- **Framework**: .NET 8 Web API
- **Database**: IBM DB2 with Entity Framework Core
- **Architecture**: Clean Architecture + CQRS with MediatR
- **Validation**: FluentValidation
- **Logging**: Serilog
- **Documentation**: Swagger/OpenAPI
- **Testing**: xUnit, Moq, FluentAssertions
- **AS400 Integration**: IBM.Data.DB2.Core + ODBC

## 📁 Project Structure

```
backend/
├── CustomerUpdate.API/          # Web API Layer
│   ├── Controllers/             # API Controllers
│   │   ├── CustomerController.cs
│   │   └── HealthController.cs
│   ├── Middleware/              # Custom middleware
│   │   ├── ErrorHandlingMiddleware.cs
│   │   └── LoggingMiddleware.cs
│   ├── Program.cs               # Application entry point
│   ├── appsettings.json         # Configuration
│   └── appsettings.Development.json
├── CustomerUpdate.Core/         # Domain Layer
│   ├── Entities/                # Domain entities
│   │   ├── Customer.cs
│   │   ├── CustomerLog.cs
│   │   └── CustomerTemp.cs
│   ├── Interfaces/              # Contracts
│   │   ├── ICustomerRepository.cs
│   │   ├── IAs400Service.cs
│   │   └── IUnitOfWork.cs
│   ├── UseCases/                # Application use cases
│   │   ├── UpdateCustomer/
│   │   ├── GetCustomer/
│   │   └── ValidateCustomer/
│   └── DTOs/                    # Data transfer objects
│       ├── CustomerUpdateDto.cs
│       └── ApiResponseDto.cs
├── CustomerUpdate.Infrastructure/ # Infrastructure Layer
│   ├── Data/                    # Database context
│   │   ├── CustomerDbContext.cs
│   │   └── Configurations/
│   ├── Repositories/            # Data access
│   │   ├── CustomerRepository.cs
│   │   └── UnitOfWork.cs
│   ├── Services/                # External integrations
│   │   └── As400Service.cs
│   └── Migrations/              # EF Core migrations
└── CustomerUpdate.Tests/        # Test Projects
    ├── Unit/
    ├── Integration/
    └── E2E/
```

## 🔧 Installation & Setup

### Prerequisites
- .NET 8 SDK
- IBM DB2 Client
- AS400 System Access
- Visual Studio 2022 or VS Code

### Step 1: Clone and Restore Packages
```bash
cd backend
dotnet restore
```

### Step 2: Configuration
Update `appsettings.json` with your environment settings:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=your-db2-server;Database=CUSTOMER_DB;UID=username;PWD=password;",
    "AS400Connection": "Driver={IBM i Access ODBC Driver};System=your-as400-system;UID=username;PWD=password;"
  },
  "AS400Settings": {
    "SystemName": "your-as400-system",
    "Library": "CUSTLIB",
    "ValidationProgram": "MUSTVALID",
    "TimeoutSeconds": 30
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "CorsOrigins": [
    "http://localhost:3000",
    "https://your-frontend-domain.com"
  ]
}
```

### Step 3: Database Migration
```bash
dotnet ef database update --project CustomerUpdate.Infrastructure --startup-project CustomerUpdate.API
```

### Step 4: Run the Application
```bash
dotnet run --project CustomerUpdate.API
```

The API will be available at:
- **HTTP**: http://localhost:5000
- **HTTPS**: https://localhost:5001
- **Swagger UI**: http://localhost:5000/swagger

## 🌍 Available Scripts

```bash
# Development
dotnet run --project CustomerUpdate.API           # Run development server
dotnet watch --project CustomerUpdate.API         # Run with hot reload
dotnet build                                      # Build solution
dotnet test                                       # Run all tests

# Database Operations
dotnet ef migrations add MigrationName --project CustomerUpdate.Infrastructure --startup-project CustomerUpdate.API
dotnet ef database update --project CustomerUpdate.Infrastructure --startup-project CustomerUpdate.API

# Production
dotnet publish -c Release -o ./publish           # Publish for deployment
```

## 📝 API Endpoints

### Customer Management
```http
POST   /api/customer/update          # Update customer information
GET    /api/customer/{id}            # Get customer by ID
GET    /api/customer/tax-id/{taxId}  # Get customer by Tax ID
POST   /api/customer/validate        # Validate customer data
```

### Health & Monitoring
```http
GET    /health                       # Health check endpoint
GET    /health/db                   # Database health check
GET    /health/as400               # AS400 connectivity check
```

### Documentation
```http
GET    /swagger                     # Swagger UI
GET    /swagger/v1/swagger.json    # OpenAPI specification
```

## 🔌 AS400 Integration

### RPG Program Integration
The API integrates with AS400 RPG program `MUSTVALID` for data validation:

```csharp
public class As400Service : IAs400Service
{
    public async Task<ValidationResult> ValidateCustomerAsync(CustomerUpdateDto customer)
    {
        // Call AS400 RPG program MUSTVALID
        using var connection = new OdbcConnection(_connectionString);
        using var command = new OdbcCommand("CALL CUSTLIB.MUSTVALID(?,?,?,?,?,?)", connection);
        
        // Add parameters for customer data
        command.Parameters.AddWithValue("@name", customer.Name);
        command.Parameters.AddWithValue("@phone", customer.Phone);
        command.Parameters.AddWithValue("@email", customer.Email);
        command.Parameters.AddWithValue("@address", customer.Address);
        command.Parameters.AddWithValue("@taxId", customer.TaxId);
        command.Parameters.Add("@result", OdbcType.VarChar, 500).Direction = ParameterDirection.Output;
        
        await connection.OpenAsync();
        await command.ExecuteNonQueryAsync();
        
        var result = command.Parameters["@result"].Value?.ToString();
        return ParseValidationResult(result);
    }
}
```

### Database Tables
The system works with three main DB2 tables:

#### CUSTOMER (Main Records)
```sql
CREATE TABLE CUSTOMER (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    TaxID CHAR(11) UNIQUE,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
```

#### CUSTOMER_TEMP (Validation Staging)
```sql
CREATE TABLE CUSTOMER_TEMP (
    TempID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    TaxID CHAR(11),
    ErrorMessage NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    ProcessedAt DATETIME2
);
```

#### CUSTOMER_LOG (Audit Trail)
```sql
CREATE TABLE CUSTOMER_LOG (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    Action NVARCHAR(50),
    OldValues NVARCHAR(MAX),
    NewValues NVARCHAR(MAX),
    UserId NVARCHAR(100),
    Timestamp DATETIME2 DEFAULT GETDATE()
);
```

## 🔄 Data Flow

1. **Frontend Request**: Next.js sends POST to `/api/customer/update`
2. **API Validation**: FluentValidation validates input data
3. **Staging**: Data inserted into `CUSTOMER_TEMP` table
4. **AS400 Call**: RPG program `MUSTVALID` processes data
5. **Validation**: AS400 validates phone, email, tax ID, address
6. **Success Path**: Valid data moved to `CUSTOMER` table + audit log
7. **Error Path**: Error message written to `CUSTOMER_TEMP.ErrorMessage`
8. **Response**: API returns success/error status to frontend

## 🛡️ Security Features

- **Input Validation**: FluentValidation with custom rules
- **SQL Injection Prevention**: Parameterized queries
- **CORS Configuration**: Configurable allowed origins
- **Error Handling**: Sanitized error responses
- **Logging**: Comprehensive audit trail
- **Health Checks**: System monitoring endpoints

## 🧪 Testing

### Unit Tests
```bash
dotnet test CustomerUpdate.Tests.Unit
```

### Integration Tests
```bash
dotnet test CustomerUpdate.Tests.Integration
```

### Test Coverage
```bash
dotnet test --collect:"XPlat Code Coverage"
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:**/coverage.cobertura.xml -targetdir:coverage-report
```

## 📊 Monitoring & Observability

### Structured Logging
```csharp
Log.Information("Customer update requested for TaxID: {TaxId}", request.TaxId);
Log.Warning("AS400 validation failed for customer {TaxId}: {Error}", taxId, error);
Log.Error(ex, "Failed to update customer {TaxId}", request.TaxId);
```

### Health Checks
```http
GET /health
{
  "status": "Healthy",
  "checks": {
    "database": "Healthy",
    "as400": "Healthy"
  },
  "duration": "00:00:00.0123456"
}
```

## 🚀 Deployment

### Docker Support
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CustomerUpdate.API/CustomerUpdate.API.csproj", "CustomerUpdate.API/"]
RUN dotnet restore "CustomerUpdate.API/CustomerUpdate.API.csproj"
COPY . .
WORKDIR "/src/CustomerUpdate.API"
RUN dotnet build "CustomerUpdate.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CustomerUpdate.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CustomerUpdate.API.dll"]
```

### Environment Variables
```bash
export ConnectionStrings__DefaultConnection="your-db2-connection"
export AS400Settings__SystemName="your-as400-system"
export ASPNETCORE_ENVIRONMENT="Production"
```

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Write comprehensive unit tests
3. Use conventional commit messages
4. Update API documentation
5. Ensure AS400 integration compatibility

## 🔗 Related Documentation

- [Frontend Documentation](../frontend/README.md)
- [AS400 Integration Guide](../as400/README.md)
- [Database Schema](../docs/database-schema.md)
- [API Specification](../docs/api-specification.md)
- [Deployment Guide](../docs/deployment-guide.md)

## 📞 Support

For technical issues:
- Check existing GitHub issues
- Review application logs in `/logs` directory
- Verify AS400 connectivity and RPG program status
- Test database connectivity

---

**API Base URL**: http://localhost:5000  
**Swagger Documentation**: http://localhost:5000/swagger  
**Health Check**: http://localhost:5000/health 