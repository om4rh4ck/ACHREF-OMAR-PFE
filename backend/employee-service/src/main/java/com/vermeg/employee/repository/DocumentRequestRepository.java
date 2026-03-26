package com.vermeg.employee.repository;

import com.vermeg.employee.model.DocumentRequest;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DocumentRequestRepository extends JpaRepository<DocumentRequest, Long> {
    boolean existsByUserIdAndStatus(Long userId, String status);
    java.util.List<DocumentRequest> findByUserIdOrderByCreatedAtDesc(Long userId);
    java.util.List<DocumentRequest> findByStatusOrderByCreatedAtDesc(String status);
}
