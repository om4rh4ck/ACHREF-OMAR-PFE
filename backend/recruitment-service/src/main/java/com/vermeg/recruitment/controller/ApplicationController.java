package com.vermeg.recruitment.controller;

import com.vermeg.recruitment.model.JobApplication;
import com.vermeg.recruitment.model.JobOffer;
import com.vermeg.recruitment.repository.JobApplicationRepository;
import com.vermeg.recruitment.repository.JobOfferRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@RestController
public class ApplicationController {

    private final JobApplicationRepository jobApplicationRepository;
    private final JobOfferRepository jobOfferRepository;
    private final RestClient restClient = RestClient.create();

    @Value("${app.employee-service-url:http://employee-service:8082}")
    private String employeeServiceUrl;

    public ApplicationController(JobApplicationRepository jobApplicationRepository, JobOfferRepository jobOfferRepository) {
        this.jobApplicationRepository = jobApplicationRepository;
        this.jobOfferRepository = jobOfferRepository;
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/api/jobs/{jobId}/apply")
    public ResponseEntity<?> apply(@PathVariable Long jobId, @RequestBody Map<String, Object> dto, Authentication authentication, HttpServletRequest request) {
        JobOffer job = jobOfferRepository.findById(jobId).orElse(null);
        if (job == null) return ResponseEntity.notFound().build();

        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));
        String department = stringValue(user.get("department"));

        if ("INTERNAL".equalsIgnoreCase(job.getType())) {
            if (!"EMPLOYEE".equals(role)) {
                return ResponseEntity.status(403).body(Map.of("error", "Offre interne reservee aux employes"));
            }
            if (job.getDepartment() != null && !job.getDepartment().isBlank()
                    && department != null && !department.isBlank()
                    && !job.getDepartment().equalsIgnoreCase(department)) {
                return ResponseEntity.status(403).body(Map.of("error", "Departement non autorise"));
            }
        } else if ("EXTERNAL".equalsIgnoreCase(job.getType())) {
            if (!"CANDIDATE".equals(role)) {
                return ResponseEntity.status(403).body(Map.of("error", "Offre externe reservee aux candidats"));
            }
        }

        JobApplication app = new JobApplication();
        app.setJobId(job.getId());
        app.setJobTitle(job.getTitle());
        app.setEmail(stringValue(user.getOrDefault("email", authentication == null ? "" : authentication.getName())));
        app.setFullName(Objects.toString(dto.get("full_name"), app.getEmail()));
        app.setPhone(Objects.toString(dto.get("phone"), ""));
        app.setCity(Objects.toString(dto.get("city"), ""));
        app.setCountry(Objects.toString(dto.get("country"), ""));
        app.setCoverLetter(Objects.toString(dto.get("cover_letter"), ""));
        app.setDiplomaFile(Objects.toString(dto.get("diploma_file"), ""));
        app.setCinFile(Objects.toString(dto.get("cin_file"), ""));
        app.setCvFile(Objects.toString(dto.get("cv_file"), ""));
        app.setStatus("PENDING");
        app.setUserId(userId);
        app.setManagerId(job.getRecruiterId());

        return ResponseEntity.ok(jobApplicationRepository.save(app));
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/api/applications")
    public List<JobApplication> list(Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));

        if ("HR_ADMIN".equals(role) || "RECRUITER".equals(role)) {
            return jobApplicationRepository.findAllByOrderByAppliedAtDesc();
        }
        if ("MANAGER".equals(role) && userId != null) {
            return jobApplicationRepository.findByManagerIdOrderByAppliedAtDesc(userId);
        }
        if (userId != null) {
            return jobApplicationRepository.findByUserIdOrderByAppliedAtDesc(userId);
        }
        return jobApplicationRepository.findByEmailOrderByAppliedAtDesc(authentication.getName());
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN','RECRUITER')")
    @PutMapping("/api/applications/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable Long id, @RequestBody Map<String, Object> dto, Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));
        return jobApplicationRepository.findById(id).map(existing -> {
            if ("MANAGER".equals(role) && userId != null && !Objects.equals(existing.getManagerId(), userId)) {
                return ResponseEntity.status(403).body(Map.of("error", "Acces refuse"));
            }
            existing.setStatus(Objects.toString(dto.getOrDefault("status", existing.getStatus()), existing.getStatus()).toUpperCase());
            return ResponseEntity.ok(jobApplicationRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    private boolean hasAnyRole(Authentication authentication, String... roles) {
        if (authentication == null) return false;
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            for (String role : roles) {
                if (role.equals(authority.getAuthority())) return true;
            }
        }
        return false;
    }

    private Map<String, Object> currentUser(Authentication authentication, HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) authHeader = "";
        try {
            Map<String, Object> resp = restClient.get()
                    .uri(employeeServiceUrl + "/api/auth/me")
                    .header("Authorization", authHeader)
                    .retrieve()
                    .body(new ParameterizedTypeReference<Map<String, Object>>() {});
            Object userObj = resp == null ? null : resp.get("user");
            if (userObj instanceof Map<?, ?> map) {
                Map<String, Object> user = new HashMap<>();
                map.forEach((k, v) -> user.put(String.valueOf(k), v));
                return user;
            }
        } catch (Exception ignored) {
        }
        Map<String, Object> fallback = new HashMap<>();
        fallback.put("email", authentication == null ? "" : authentication.getName());
        fallback.put("role", extractRole(authentication));
        return fallback;
    }

    private String extractRole(Authentication authentication) {
        if (authentication == null) return "";
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            String role = authority.getAuthority();
            if (role.startsWith("ROLE_")) {
                return role.replace("ROLE_", "");
            }
        }
        return "";
    }

    private String stringValue(Object value) {
        return value == null ? "" : value.toString();
    }

    private Long longValue(Object value) {
        if (value == null) return null;
        try { return Long.parseLong(value.toString()); } catch (Exception e) { return null; }
    }
}
