package com.vermeg.employee.controller;

import com.vermeg.employee.model.Employee;
import com.vermeg.employee.model.LeaveRequest;
import com.vermeg.employee.repository.EmployeeRepository;
import com.vermeg.employee.repository.LeaveRequestRepository;
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

    public LeaveController(LeaveRequestRepository leaveRequestRepository, EmployeeRepository employeeRepository) {
        this.leaveRequestRepository = leaveRequestRepository;
        this.employeeRepository = employeeRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> dto, Authentication authentication) {
        Employee me = employeeRepository.findByEmail(authentication.getName()).orElse(null);
        if (me == null) return ResponseEntity.status(401).build();

        LeaveRequest leave = new LeaveRequest();
        leave.setUserId(me.getId());
        leave.setEmployeeEmail(me.getEmail());
        leave.setType(Objects.toString(dto.get("type"), "CONGE_PAYE"));
        leave.setStartDate(LocalDate.parse(Objects.toString(dto.get("start_date"))));
        leave.setEndDate(LocalDate.parse(Objects.toString(dto.get("end_date"))));
        leave.setReason(Objects.toString(dto.get("reason"), ""));
        leave.setStatus("PENDING");
        return ResponseEntity.ok(leaveRequestRepository.save(leave));
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
        return ResponseEntity.ok(leaveRequestRepository.save(leave));
    }

    @GetMapping("/my")
    public List<LeaveRequest> my(Authentication authentication) {
        return leaveRequestRepository.findByEmployeeEmailOrderByCreatedAtDesc(authentication.getName());
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
                    return ResponseEntity.ok(leaveRequestRepository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
