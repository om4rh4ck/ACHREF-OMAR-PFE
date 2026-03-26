package com.vermeg.employee.controller;

import com.vermeg.employee.model.DocumentRequest;
import com.vermeg.employee.model.Employee;
import com.vermeg.employee.repository.DocumentRequestRepository;
import com.vermeg.employee.repository.EmployeeRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {

    private final DocumentRequestRepository documentRequestRepository;
    private final EmployeeRepository employeeRepository;

    public DocumentController(DocumentRequestRepository documentRequestRepository, EmployeeRepository employeeRepository) {
        this.documentRequestRepository = documentRequestRepository;
        this.employeeRepository = employeeRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(Authentication authentication, @RequestBody Map<String, Object> payload) {
        Employee me = employeeRepository.findByEmail(authentication.getName()).orElse(null);
        if (me == null) return ResponseEntity.status(401).build();
        DocumentRequest d = new DocumentRequest();
        d.setUserId(me.getId());
        d.setEmployeeEmail(me.getEmail());
        d.setType(Objects.toString(payload.get("type"), "ATTESTATION_TRAVAIL"));
        d.setDetails(Objects.toString(payload.get("details"), ""));
        d.setStatus("PENDING");
        return ResponseEntity.ok(documentRequestRepository.save(d));
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/admin")
    public ResponseEntity<?> createForEmployee(@RequestBody Map<String, Object> payload) {
        String email = Objects.toString(payload.get("employee_email"), "");
        if (email.isBlank()) return ResponseEntity.badRequest().body(Map.of("error", "Email requis"));
        Employee target = employeeRepository.findByEmail(email).orElse(null);
        if (target == null) return ResponseEntity.badRequest().body(Map.of("error", "Employe introuvable"));
        DocumentRequest d = new DocumentRequest();
        d.setUserId(target.getId());
        d.setEmployeeEmail(target.getEmail());
        d.setType(Objects.toString(payload.get("type"), "ATTESTATION_TRAVAIL"));
        d.setDetails(Objects.toString(payload.get("details"), ""));
        d.setStatus("APPROVED");
        return ResponseEntity.ok(documentRequestRepository.save(d));
    }

    @GetMapping("/my")
    public List<DocumentRequest> my(Authentication authentication) {
        Employee me = employeeRepository.findByEmail(authentication.getName()).orElse(null);
        if (me == null) return List.of();
        return documentRequestRepository.findByUserIdOrderByCreatedAtDesc(me.getId());
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @GetMapping("/pending")
    public List<DocumentRequest> pending() {
        return documentRequestRepository.findByStatusOrderByCreatedAtDesc("PENDING");
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PutMapping("/{id}/status")
    public ResponseEntity<DocumentRequest> updateStatus(@PathVariable Long id, @RequestParam String status) {
        return documentRequestRepository.findById(id)
                .map(existing -> {
                    existing.setStatus(status.toUpperCase());
                    return ResponseEntity.ok(documentRequestRepository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
