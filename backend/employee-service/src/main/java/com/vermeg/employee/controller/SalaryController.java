package com.vermeg.employee.controller;

import com.vermeg.employee.model.Employee;
import com.vermeg.employee.model.SalaryRequest;
import com.vermeg.employee.repository.EmployeeRepository;
import com.vermeg.employee.repository.SalaryRequestRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/salaries")
public class SalaryController {

    private final SalaryRequestRepository salaryRequestRepository;
    private final EmployeeRepository employeeRepository;

    public SalaryController(SalaryRequestRepository salaryRequestRepository, EmployeeRepository employeeRepository) {
        this.salaryRequestRepository = salaryRequestRepository;
        this.employeeRepository = employeeRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(Authentication authentication, @RequestBody Map<String, Object> payload) {
        Employee me = employeeRepository.findByEmail(authentication.getName()).orElse(null);
        if (me == null) return ResponseEntity.status(401).build();
        SalaryRequest request = new SalaryRequest();
        request.setUserId(me.getId());
        request.setEmployeeEmail(me.getEmail());
        request.setMonth(Integer.parseInt(Objects.toString(payload.getOrDefault("month", "1"))));
        request.setYear(Integer.parseInt(Objects.toString(payload.getOrDefault("year", "2026"))));
        request.setDetails(Objects.toString(payload.get("details"), ""));
        request.setStatus("PENDING");
        return ResponseEntity.ok(salaryRequestRepository.save(request));
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/admin")
    public ResponseEntity<?> createForEmployee(@RequestBody Map<String, Object> payload) {
        String email = Objects.toString(payload.get("employee_email"), "");
        if (email.isBlank()) return ResponseEntity.badRequest().body(Map.of("error", "Email requis"));
        Employee target = employeeRepository.findByEmail(email).orElse(null);
        if (target == null) return ResponseEntity.badRequest().body(Map.of("error", "Employe introuvable"));
        SalaryRequest request = new SalaryRequest();
        request.setUserId(target.getId());
        request.setEmployeeEmail(target.getEmail());
        request.setMonth(Integer.parseInt(Objects.toString(payload.getOrDefault("month", "1"))));
        request.setYear(Integer.parseInt(Objects.toString(payload.getOrDefault("year", "2026"))));
        request.setDetails(Objects.toString(payload.get("details"), ""));
        request.setStatus("APPROVED");
        return ResponseEntity.ok(salaryRequestRepository.save(request));
    }

    @GetMapping("/my")
    public List<SalaryRequest> my(Authentication authentication) {
        Employee me = employeeRepository.findByEmail(authentication.getName()).orElse(null);
        if (me == null) return List.of();
        return salaryRequestRepository.findByUserIdOrderByCreatedAtDesc(me.getId());
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @GetMapping("/pending")
    public List<SalaryRequest> pending() {
        return salaryRequestRepository.findByStatusOrderByCreatedAtDesc("PENDING");
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PutMapping("/{id}/status")
    public ResponseEntity<SalaryRequest> updateStatus(@PathVariable Long id, @RequestParam String status) {
        return salaryRequestRepository.findById(id)
                .map(existing -> {
                    existing.setStatus(status.toUpperCase());
                    return ResponseEntity.ok(salaryRequestRepository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
