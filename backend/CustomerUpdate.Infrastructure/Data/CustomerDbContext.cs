using Microsoft.EntityFrameworkCore;
using CustomerUpdate.Core.Entities;

namespace CustomerUpdate.Infrastructure.Data;

public class CustomerDbContext : DbContext
{
    public CustomerDbContext(DbContextOptions<CustomerDbContext> options) : base(options)
    {
    }

    public DbSet<Customer> Customers { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Customer>(entity =>
        {
            entity.HasKey(e => e.CustomerId);
            entity.HasIndex(e => e.TaxId).IsUnique();
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("GETUTCDATE()");
        });

        // Seed some initial data
        modelBuilder.Entity<Customer>().HasData(
            new Customer 
            { 
                CustomerId = 1001, 
                Name = "John Doe", 
                Phone = "(555) 123-4567", 
                Email = "john.doe@example.com", 
                Address = "123 Main Street, Anytown, ST 12345", 
                TaxId = "12345678901", 
                CreatedAt = DateTime.UtcNow.AddDays(-5), 
                UpdatedAt = DateTime.UtcNow.AddDays(-1) 
            },
            new Customer 
            { 
                CustomerId = 1002, 
                Name = "Jane Smith", 
                Phone = "(555) 234-5678", 
                Email = "jane.smith@example.com", 
                Address = "456 Oak Avenue, Springfield, IL 62701", 
                TaxId = "23456789012", 
                CreatedAt = DateTime.UtcNow.AddDays(-3), 
                UpdatedAt = DateTime.UtcNow.AddDays(-3) 
            },
            new Customer 
            { 
                CustomerId = 1003, 
                Name = "Robert Johnson", 
                Phone = "(555) 345-6789", 
                Email = "", 
                Address = "789 Pine Street, Metro City, NY 10001", 
                TaxId = "34567890123", 
                CreatedAt = DateTime.UtcNow.AddDays(-7), 
                UpdatedAt = DateTime.UtcNow.AddDays(-2) 
            }
        );
    }
} 