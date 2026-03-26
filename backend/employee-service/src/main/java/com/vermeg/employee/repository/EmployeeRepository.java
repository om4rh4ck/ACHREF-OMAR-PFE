package com.vermeg.employee.repository;

import com.vermeg.employee.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {
    Optional<Employee> findByEmail(String email);
    List<Employee> findByRole(String role);
    List<Employee> findByManagerId(Long managerId);
}