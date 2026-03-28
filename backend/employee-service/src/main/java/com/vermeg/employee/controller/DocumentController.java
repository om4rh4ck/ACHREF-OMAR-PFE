package com.vermeg.employee.controller;

import com.vermeg.employee.model.DocumentRequest;
import com.vermeg.employee.model.Employee;
import com.vermeg.employee.model.NotificationEntity;
import com.vermeg.employee.repository.DocumentRequestRepository;
import com.vermeg.employee.repository.EmployeeRepository;
import com.vermeg.employee.repository.NotificationRepository;
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
    private final NotificationRepository notificationRepository;

    public DocumentController(DocumentRequestRepository documentRequestRepository, EmployeeRepository employeeRepository, NotificationRepository notificationRepository) {
        this.documentRequestRepository = documentRequestRepository;
        this.employeeRepository = employeeRepository;
        this.notificationRepository = notificationRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(Authentication authentication, @RequestBody Map<String, Object> payload) {
        Employee me = employeeRepository.findByEmail(authEmail(authentication)).orElse(null);
        if (me == null) return ResponseEntity.status(401).build();
        DocumentRequest d = new DocumentRequest();
        d.setUserId(me.getId());
        d.setEmployeeEmail(me.getEmail());
        d.setType(Objects.toString(payload.get("type"), "ATTESTATION_TRAVAIL"));
        d.setDetails(Objects.toString(payload.get("details"), ""));
        d.setFileData(Objects.toString(payload.get("file_data"), ""));
        d.setFileName(Objects.toString(payload.get("file_name"), ""));
        d.setStatus("PENDING");
        DocumentRequest saved = documentRequestRepository.save(d);
        notifyUser(me.getId(), "Nouvelle demande de document en attente.", "INFO");
        return ResponseEntity.ok(saved);
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
        d.setFileData(Objects.toString(payload.get("file_data"), ""));
        d.setFileName(Objects.toString(payload.get("file_name"), ""));
        d.setStatus("APPROVED");
        DocumentRequest saved = documentRequestRepository.save(d);
        notifyUser(target.getId(), "Votre document " + saved.getType() + " est disponible.", "SUCCESS");
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/my")
    public List<DocumentRequest> my(Authentication authentication) {
        String email = authEmail(authentication);
        Employee me = employeeRepository.findByEmail(email).orElse(null);
        if (me == null) {
            return documentRequestRepository.findByEmployeeEmailOrderByCreatedAtDesc(email);
        }
        List<DocumentRequest> byUserId = documentRequestRepository.findByUserIdOrderByCreatedAtDesc(me.getId());
        if (!byUserId.isEmpty()) return byUserId;
        return documentRequestRepository.findByEmployeeEmailOrderByCreatedAtDesc(email);
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
                    DocumentRequest saved = documentRequestRepository.save(existing);
                    notifyUser(saved.getUserId(), "Votre demande de document est " + status.toUpperCase() + ".", "INFO");
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
