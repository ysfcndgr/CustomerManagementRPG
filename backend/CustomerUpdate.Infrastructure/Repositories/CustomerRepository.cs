using Microsoft.EntityFrameworkCore;
using CustomerUpdate.Core.Entities;
using CustomerUpdate.Core.Interfaces;
using CustomerUpdate.Infrastructure.Data;

namespace CustomerUpdate.Infrastructure.Repositories;

public class CustomerRepository : ICustomerRepository
{
    private readonly CustomerDbContext _context;

    public CustomerRepository(CustomerDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Customer>> GetAllAsync()
    {
        return await _context.Customers
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<Customer?> GetByIdAsync(int id)
    {
        return await _context.Customers
            .FirstOrDefaultAsync(c => c.CustomerId == id);
    }

    public async Task<Customer?> GetByTaxIdAsync(string taxId)
    {
        return await _context.Customers
            .FirstOrDefaultAsync(c => c.TaxId == taxId);
    }

    public async Task<Customer> CreateAsync(Customer customer)
    {
        customer.CreatedAt = DateTime.UtcNow;
        customer.UpdatedAt = DateTime.UtcNow;
        
        _context.Customers.Add(customer);
        await _context.SaveChangesAsync();
        return customer;
    }

    public async Task<Customer> UpdateAsync(Customer customer)
    {
        customer.UpdatedAt = DateTime.UtcNow;
        
        _context.Customers.Update(customer);
        await _context.SaveChangesAsync();
        return customer;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var customer = await GetByIdAsync(id);
        if (customer == null)
            return false;

        _context.Customers.Remove(customer);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> TaxIdExistsAsync(string taxId)
    {
        return await _context.Customers
            .AnyAsync(c => c.TaxId == taxId);
    }
} 