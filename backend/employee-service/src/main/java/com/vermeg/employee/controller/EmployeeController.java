package com.vermeg.employee.controller;

import com.vermeg.employee.model.Employee;
import com.vermeg.employee.repository.EmployeeRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {
    private final EmployeeRepository employeeRepository;

    public EmployeeController(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
    }

    @GetMapping("/me")
    public ResponseEntity<Employee> me(Authentication authentication) {
        String email = authentication.getName();
        return employeeRepository.findByEmail(email)
                .map(ResponseEntity::ok)
                .orElseGet(() -> {
                    Employee employee = new Employee();
                    employee.setEmail(email);
                    employee.setFullName(email);
                    employee.setRole("EMPLOYEE");
                    return ResponseEntity.ok(employeeRepository.save(employee));
                });
    }

    @GetMapping
    public List<Employee> all() {
        return employeeRepository.findAll();
    }
}