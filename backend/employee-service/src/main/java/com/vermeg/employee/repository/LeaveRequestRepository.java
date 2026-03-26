package com.vermeg.employee.repository;

import com.vermeg.employee.model.LeaveRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {
    List<LeaveRequest> findByEmployeeEmailOrderByCreatedAtDesc(String employeeEmail);
    List<LeaveRequest> findByStatusOrderByCreatedAtDesc(String status);
    boolean existsByUserIdAndStatus(Long userId, String status);
}
