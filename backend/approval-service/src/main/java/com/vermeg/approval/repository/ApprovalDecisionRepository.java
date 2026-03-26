package com.vermeg.approval.repository;

import com.vermeg.approval.model.ApprovalDecision;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ApprovalDecisionRepository extends JpaRepository<ApprovalDecision, Long> {
    List<ApprovalDecision> findByTargetTypeOrderByDecidedAtDesc(String targetType);
}
