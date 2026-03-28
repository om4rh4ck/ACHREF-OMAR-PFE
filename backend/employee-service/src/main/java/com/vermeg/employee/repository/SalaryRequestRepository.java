package com.vermeg.employee.repository;

import com.vermeg.employee.model.SalaryRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SalaryRequestRepository extends JpaRepository<SalaryRequest, Long> {
    List<SalaryRequest> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<SalaryRequest> findByEmployeeEmailOrderByCreatedAtDesc(String employeeEmail);
    List<SalaryRequest> findByStatusOrderByCreatedAtDesc(String status);
}
