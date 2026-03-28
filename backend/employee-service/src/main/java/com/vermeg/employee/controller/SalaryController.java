package com.vermeg.employee.controller;

import com.vermeg.employee.model.Employee;
import com.vermeg.employee.model.NotificationEntity;
import com.vermeg.employee.model.SalaryRequest;
import com.vermeg.employee.repository.EmployeeRepository;
import com.vermeg.employee.repository.NotificationRepository;
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
    private final NotificationRepository notificationRepository;

    public SalaryController(SalaryRequestRepository salaryRequestRepository, EmployeeRepository employeeRepository, NotificationRepository notificationRepository) {
        this.salaryRequestRepository = salaryRequestRepository;
        this.employeeRepository = employeeRepository;
        this.notificationRepository = notificationRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(Authentication authentication, @RequestBody Map<String, Object> payload) {
        Employee me = employeeRepository.findByEmail(authEmail(authentication)).orElse(null);
        if (me == null) return ResponseEntity.status(401).build();
        SalaryRequest request = new SalaryRequest();
        request.setUserId(me.getId());
        request.setEmployeeEmail(me.getEmail());
        request.setMonth(Integer.parseInt(Objects.toString(payload.getOrDefault("month", "1"))));
        request.setYear(Integer.parseInt(Objects.toString(payload.getOrDefault("year", "2026"))));
        request.setDetails(Objects.toString(payload.get("details"), ""));
        request.setFileData(Objects.toString(payload.get("file_data"), ""));
        request.setFileName(Objects.toString(payload.get("file_name"), ""));
        request.setStatus("PENDING");
        SalaryRequest saved = salaryRequestRepository.save(request);
        notifyUser(me.getId(), "Nouvelle demande de fiche de paie en attente.", "INFO");
        return ResponseEntity.ok(saved);
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
        request.setFileData(Objects.toString(payload.get("file_data"), ""));
        request.setFileName(Objects.toString(payload.get("file_name"), ""));
        request.setStatus("APPROVED");
        SalaryRequest saved = salaryRequestRepository.save(request);
        notifyUser(target.getId(), "Votre fiche de paie " + saved.getMonth() + "/" + saved.getYear() + " est disponible.", "SUCCESS");
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/my")
    public List<SalaryRequest> my(Authentication authentication) {
        String email = authEmail(authentication);
        Employee me = employeeRepository.findByEmail(email).orElse(null);
        if (me == null) {
            return salaryRequestRepository.findByEmployeeEmailOrderByCreatedAtDesc(email);
        }
        List<SalaryRequest> byUserId = salaryRequestRepository.findByUserIdOrderByCreatedAtDesc(me.getId());
        if (!byUserId.isEmpty()) return byUserId;
        return salaryRequestRepository.findByEmployeeEmailOrderByCreatedAtDesc(email);
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
                    SalaryRequest saved = salaryRequestRepository.save(existing);
                    notifyUser(saved.getUserId(), "Votre demande de fiche de paie est " + status.toUpperCase() + ".", "INFO");
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    private String authEmail(Authentication authentication) {
        if (authentication == null) return "";
        return authentication.getName();
    }

    private void notifyUser(Long userId, String message, String type) {
        if (userId == null) return;
        NotificationEntity notification = new NotificationEntity();
        notification.setUserId(userId);
        notification.setMessage(message);
        notification.setType(type);
        notification.setIsRead(false);
        notificationRepository.save(notification);
    }
}
