package com.vermeg.approval.controller;

import com.vermeg.approval.dto.DecisionDto;
import com.vermeg.approval.model.ApprovalDecision;
import com.vermeg.approval.repository.ApprovalDecisionRepository;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/approvals")
public class ApprovalController {

    private final ApprovalDecisionRepository approvalDecisionRepository;

    public ApprovalController(ApprovalDecisionRepository approvalDecisionRepository) {
        this.approvalDecisionRepository = approvalDecisionRepository;
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN')")
    @PostMapping
    public ApprovalDecision decide(@RequestBody DecisionDto dto, Authentication authentication) {
        ApprovalDecision decision = new ApprovalDecision();
        decision.setTargetType(dto.getTargetType());
        decision.setTargetId(dto.getTargetId());
        decision.setStatus(dto.getStatus() == null ? "APPROVED" : dto.getStatus().toUpperCase());
        decision.setComment(dto.getComment());
        decision.setDecidedBy(authentication.getName());
        return approvalDecisionRepository.save(decision);
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN','RECRUITER')")
    @GetMapping
    public List<ApprovalDecision> list(@RequestParam(required = false) String targetType) {
        if (targetType == null || targetType.isBlank()) {
            return approvalDecisionRepository.findAll();
        }
        return approvalDecisionRepository.findByTargetTypeOrderByDecidedAtDesc(targetType.toUpperCase());
    }
}
