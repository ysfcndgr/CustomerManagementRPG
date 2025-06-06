using Microsoft.EntityFrameworkCore;
using CustomerUpdate.Infrastructure.Data;
using CustomerUpdate.Core.Interfaces;
using CustomerUpdate.Infrastructure.Repositories;
using CustomerUpdate.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend",
        policy =>
        {
            policy.WithOrigins("http://localhost:3000")
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
});

// Add DbContext (using in-memory database for demo)
builder.Services.AddDbContext<CustomerDbContext>(options =>
    options.UseInMemoryDatabase("CustomerDatabase"));

// Register repositories
builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();

// Register AS400 services based on configuration
var useRealAs400 = builder.Configuration.GetValue<bool>("AS400:UseRealConnection", false);
if (useRealAs400)
{
    builder.Services.AddScoped<IAs400ValidationService, As400ValidationService>();
    builder.Logging.AddConsole().AddDebug();
    Console.WriteLine("✅ Using REAL AS400 RPG connection");
}
else
{
    builder.Services.AddScoped<IAs400ValidationService, MockAs400ValidationService>();
    Console.WriteLine("🧪 Using MOCK AS400 RPG simulation");
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFrontend");

app.UseAuthorization();

app.MapControllers();

// Seed some initial data
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<CustomerDbContext>();
    context.Database.EnsureCreated();
}

app.Run(); 