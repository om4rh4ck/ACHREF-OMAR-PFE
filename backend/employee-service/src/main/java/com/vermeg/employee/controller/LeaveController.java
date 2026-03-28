package com.vermeg.employee.controller;

import com.vermeg.employee.model.Employee;
import com.vermeg.employee.model.LeaveRequest;
import com.vermeg.employee.model.NotificationEntity;
import com.vermeg.employee.repository.EmployeeRepository;
import com.vermeg.employee.repository.LeaveRequestRepository;
import com.vermeg.employee.repository.NotificationRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/leaves")
public class LeaveController {

    private final LeaveRequestRepository leaveRequestRepository;
    private final EmployeeRepository employeeRepository;
    private final NotificationRepository notificationRepository;

    public LeaveController(LeaveRequestRepository leaveRequestRepository, EmployeeRepository employeeRepository, NotificationRepository notificationRepository) {
        this.leaveRequestRepository = leaveRequestRepository;
        this.employeeRepository = employeeRepository;
        this.notificationRepository = notificationRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> dto, Authentication authentication) {
        Employee me = employeeRepository.findByEmail(authEmail(authentication)).orElse(null);
        if (me == null) return ResponseEntity.status(401).build();

        LeaveRequest leave = new LeaveRequest();
        leave.setUserId(me.getId());
        leave.setEmployeeEmail(me.getEmail());
        leave.setType(Objects.toString(dto.get("type"), "CONGE_PAYE"));
        leave.setStartDate(LocalDate.parse(Objects.toString(dto.get("start_date"))));
        leave.setEndDate(LocalDate.parse(Objects.toString(dto.get("end_date"))));
        leave.setReason(Objects.toString(dto.get("reason"), ""));
        leave.setStatus("PENDING");
        LeaveRequest saved = leaveRequestRepository.save(leave);
        notifyUser(me.getId(), "Nouvelle demande de conge en attente.", "INFO");
        return ResponseEntity.ok(saved);
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/admin")
    public ResponseEntity<?> createForEmployee(@RequestBody Map<String, Object> dto) {
        String email = Objects.toString(dto.get("employee_email"), "");
        if (email.isBlank()) return ResponseEntity.badRequest().body(Map.of("error", "Email requis"));
        Employee target = employeeRepository.findByEmail(email).orElse(null);
        if (target == null) return ResponseEntity.badRequest().body(Map.of("error", "Employe introuvable"));

        LeaveRequest leave = new LeaveRequest();
        leave.setUserId(target.getId());
        leave.setEmployeeEmail(target.getEmail());
        leave.setType(Objects.toString(dto.get("type"), "CONGE_PAYE"));
        leave.setStartDate(LocalDate.parse(Objects.toString(dto.get("start_date"))));
        leave.setEndDate(LocalDate.parse(Objects.toString(dto.get("end_date"))));
        leave.setReason(Objects.toString(dto.get("reason"), ""));
        leave.setStatus("APPROVED");
        LeaveRequest saved = leaveRequestRepository.save(leave);
        notifyUser(target.getId(), "Votre conge a ete enregistre.", "SUCCESS");
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/my")
    public List<LeaveRequest> my(Authentication authentication) {
        return leaveRequestRepository.findByEmployeeEmailOrderByCreatedAtDesc(authEmail(authentication));
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN')")
    @GetMapping("/pending")
    public List<LeaveRequest> pending() {
        return leaveRequestRepository.findByStatusOrderByCreatedAtDesc("PENDING");
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN')")
    @PutMapping("/{id}/status")
    public ResponseEntity<LeaveRequest> updateStatus(@PathVariable Long id, @RequestParam String status) {
        return leaveRequestRepository.findById(id)
                .map(existing -> {
                    existing.setStatus(status.toUpperCase());
                    LeaveRequest saved = leaveRequestRepository.save(existing);
                    notifyUser(saved.getUserId(), "Votre demande de conge est " + status.toUpperCase() + ".", "INFO");
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
