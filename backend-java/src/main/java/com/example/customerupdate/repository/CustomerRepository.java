package com.example.customerupdate.repository;

import com.example.customerupdate.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
    Optional<Customer> findByTaxId(String taxId);
    boolean existsByTaxId(String taxId);
} 