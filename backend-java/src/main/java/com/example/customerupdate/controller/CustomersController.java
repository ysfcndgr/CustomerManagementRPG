package com.example.customerupdate.controller;

import com.example.customerupdate.dto.*;
import com.example.customerupdate.entity.Customer;
import com.example.customerupdate.repository.CustomerRepository;
import com.example.customerupdate.service.As400ValidationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/customers")
public class CustomersController {
    @Autowired
    private CustomerRepository customerRepository;
    @Autowired
    private As400ValidationService as400ValidationService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<CustomerDto>>> getAllCustomers() {
        List<CustomerDto> customers = customerRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
        ApiResponse<List<CustomerDto>> response = new ApiResponse<>();
        response.setSuccess(true);
        response.setMessage("Customers retrieved successfully");
        response.setData(customers);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CustomerDto>> getCustomer(@PathVariable Integer id) {
        Optional<Customer> customerOpt = customerRepository.findById(id);
        ApiResponse<CustomerDto> response = new ApiResponse<>();
        if (customerOpt.isPresent()) {
            response.setSuccess(true);
            response.setMessage("Customer retrieved successfully");
            response.setData(toDto(customerOpt.get()));
            return ResponseEntity.ok(response);
        } else {
            response.setSuccess(false);
            response.setMessage("Customer not found");
            response.setError("Customer with ID " + id + " does not exist");
            return ResponseEntity.status(404).body(response);
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CustomerDto>> createCustomer(@Valid @RequestBody CreateCustomerDto dto, BindingResult bindingResult) throws Exception {
        ApiResponse<CustomerDto> response = new ApiResponse<>();
        if (bindingResult.hasErrors()) {
            response.setSuccess(false);
            response.setMessage("Validation failed");
            response.setErrors(bindingResult.getAllErrors().stream().map(e -> e.getDefaultMessage()).collect(Collectors.toList()));
            return ResponseEntity.badRequest().body(response);
        }
        // AS400 validation
        var validation = as400ValidationService.validateCustomerAsync(dto.getName(), dto.getPhone(), dto.getEmail(), dto.getAddress(), dto.getTaxId()).get();
        if (!validation.isValid()) {
            response.setSuccess(false);
            response.setMessage("AS400 validation failed");
            response.setError(validation.getMessage());
            response.setErrors(validation.getErrors());
            return ResponseEntity.badRequest().body(response);
        }
        Customer customer = new Customer();
        customer.setName(dto.getName());
        customer.setPhone(dto.getPhone());
        customer.setEmail(dto.getEmail());
        customer.setAddress(dto.getAddress());
        customer.setTaxId(dto.getTaxId());
        customer.setStatus("Active");
        Customer saved = customerRepository.save(customer);
        response.setSuccess(true);
        response.setMessage("Customer created successfully");
        response.setData(toDto(saved));
        return ResponseEntity.status(201).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CustomerDto>> updateCustomer(@PathVariable Integer id, @Valid @RequestBody UpdateCustomerDto dto, BindingResult bindingResult) {
        ApiResponse<CustomerDto> response = new ApiResponse<>();
        if (bindingResult.hasErrors()) {
            response.setSuccess(false);
            response.setMessage("Validation failed");
            response.setErrors(bindingResult.getAllErrors().stream().map(e -> e.getDefaultMessage()).collect(Collectors.toList()));
            return ResponseEntity.badRequest().body(response);
        }
        Optional<Customer> customerOpt = customerRepository.findById(id);
        if (customerOpt.isEmpty()) {
            response.setSuccess(false);
            response.setMessage("Customer not found");
            response.setError("Customer with ID " + id + " does not exist");
            return ResponseEntity.status(404).body(response);
        }
        // Check for duplicate Tax ID
        Optional<Customer> taxIdCustomer = customerRepository.findByTaxId(dto.getTaxId());
        if (taxIdCustomer.isPresent() && !taxIdCustomer.get().getCustomerId().equals(id)) {
            response.setSuccess(false);
            response.setMessage("Tax ID already exists");
            response.setError("A customer with this Tax ID already exists in the system");
            return ResponseEntity.badRequest().body(response);
        }
        Customer customer = customerOpt.get();
        customer.setName(dto.getName());
        customer.setPhone(dto.getPhone());
        customer.setEmail(dto.getEmail());
        customer.setAddress(dto.getAddress());
        customer.setTaxId(dto.getTaxId());
        customer.setUpdatedAt(java.time.LocalDateTime.now());
        Customer saved = customerRepository.save(customer);
        response.setSuccess(true);
        response.setMessage("Customer updated successfully");
        response.setData(toDto(saved));
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> deleteCustomer(@PathVariable Integer id) {
        ApiResponse<Object> response = new ApiResponse<>();
        if (!customerRepository.existsById(id)) {
            response.setSuccess(false);
            response.setMessage("Customer not found");
            response.setError("Customer with ID " + id + " does not exist");
            return ResponseEntity.status(404).body(response);
        }
        customerRepository.deleteById(id);
        response.setSuccess(true);
        response.setMessage("Customer deleted successfully");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/validate-tax-id/{taxId}")
    public ResponseEntity<ApiResponse<Object>> validateTaxId(@PathVariable String taxId) {
        ApiResponse<Object> response = new ApiResponse<>();
        boolean exists = customerRepository.existsByTaxId(taxId);
        if (exists) {
            response.setSuccess(false);
            response.setMessage("Tax ID already exists");
            response.setError("A customer with this Tax ID already exists in the system");
            return ResponseEntity.badRequest().body(response);
        } else {
            response.setSuccess(true);
            response.setMessage("Tax ID is available");
            return ResponseEntity.ok(response);
        }
    }

    private CustomerDto toDto(Customer c) {
        CustomerDto dto = new CustomerDto();
        dto.setCustomerId(c.getCustomerId());
        dto.setName(c.getName());
        dto.setPhone(c.getPhone());
        dto.setEmail(c.getEmail());
        dto.setAddress(c.getAddress());
        dto.setTaxId(c.getTaxId());
        dto.setCreatedAt(c.getCreatedAt());
        dto.setUpdatedAt(c.getUpdatedAt());
        dto.setStatus(c.getStatus());
        return dto;
    }
} 