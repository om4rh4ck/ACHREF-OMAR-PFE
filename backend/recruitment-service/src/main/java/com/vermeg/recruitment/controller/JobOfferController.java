package com.vermeg.recruitment.controller;

import com.vermeg.recruitment.model.JobOffer;
import com.vermeg.recruitment.repository.JobOfferRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;
import org.springframework.core.ParameterizedTypeReference;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
public class JobOfferController {

    private final JobOfferRepository jobOfferRepository;
    private final RestClient restClient = RestClient.create();

    @Value("${app.employee-service-url:http://employee-service:8082}")
    private String employeeServiceUrl;

    public JobOfferController(JobOfferRepository jobOfferRepository) {
        this.jobOfferRepository = jobOfferRepository;
    }

    @GetMapping("/api/public/jobs")
    public List<JobOffer> publicJobs() {
        return jobOfferRepository.findByTypeAndStatusOrderByCreatedAtDesc("EXTERNAL", "PUBLISHED").stream()
                .filter(this::isVisibleToday)
                .toList();
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/api/jobs/visible")
    public List<JobOffer> visibleJobs(Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        String department = stringValue(user.get("department"));

        if ("EMPLOYEE".equals(role)) {
            if (department.isBlank()) return List.of();
            return jobOfferRepository.findByTypeAndDepartmentAndStatusOrderByCreatedAtDesc("INTERNAL", department, "PUBLISHED")
                    .stream().filter(this::isVisibleToday).toList();
        }
        if ("CANDIDATE".equals(role)) {
            return jobOfferRepository.findByTypeAndStatusOrderByCreatedAtDesc("EXTERNAL", "PUBLISHED")
                    .stream().filter(this::isVisibleToday).toList();
        }
        return jobOfferRepository.findByStatusOrderByCreatedAtDesc("PUBLISHED").stream().filter(this::isVisibleToday).toList();
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','RECRUITER','MANAGER')")
    @GetMapping("/api/jobs")
    public List<JobOffer> allJobs(Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));
        if ("MANAGER".equals(role) && userId != null) {
            return jobOfferRepository.findByRecruiterIdOrderByCreatedAtDesc(userId);
        }
        return jobOfferRepository.findAll();
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','RECRUITER','MANAGER')")
    @PostMapping("/api/jobs")
    public ResponseEntity<?> create(@RequestBody Map<String, Object> dto, Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));
        String userDept = stringValue(user.get("department"));

        String type = Objects.toString(dto.getOrDefault("type", "EXTERNAL"), "EXTERNAL").toUpperCase();
        if ("MANAGER".equals(role)) {
            if (!"INTERNAL".equals(type)) {
                return ResponseEntity.status(403).body(Map.of("error", "Un manager peut publier uniquement des offres internes"));
            }
        } else if (!List.of("HR_ADMIN", "RECRUITER").contains(role)) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces refuse"));
        }

        JobOffer job = new JobOffer();
        job.setTitle(Objects.toString(dto.get("title"), ""));
        String department = Objects.toString(dto.get("department"), "").trim();
        if ("MANAGER".equals(role)) {
            department = userDept;
        }
        if ("INTERNAL".equals(type) && (department == null || department.isBlank())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Departement requis pour une offre interne"));
        }
        job.setDepartment(department);
        job.setDescription(Objects.toString(dto.get("description"), ""));
        job.setRequirements(Objects.toString(dto.get("requirements"), ""));
        job.setEligibilityCriteria(Objects.toString(dto.get("eligibility_criteria"), ""));
        job.setType(type);
        job.setStatus(Objects.toString(dto.getOrDefault("status", "PUBLISHED"), "PUBLISHED").toUpperCase());
        if (userId != null) {
            job.setRecruiterId(userId);
        }
        job.setSalaryRange(Objects.toString(dto.get("salary_range"), ""));
        job.setProject(Objects.toString(dto.get("project"), ""));
        if (dto.get("opening_date") != null && !Objects.toString(dto.get("opening_date")).isBlank()) {
            job.setOpeningDate(LocalDate.parse(Objects.toString(dto.get("opening_date"))));
        }
        if (dto.get("closing_date") != null && !Objects.toString(dto.get("closing_date")).isBlank()) {
            job.setClosingDate(LocalDate.parse(Objects.toString(dto.get("closing_date"))));
        }
        return ResponseEntity.ok(jobOfferRepository.save(job));
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','RECRUITER','MANAGER')")
    @PutMapping("/api/jobs/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> dto, Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));
        return jobOfferRepository.findById(id).map(job -> {
            if ("MANAGER".equals(role) && !Objects.equals(job.getRecruiterId(), userId)) {
                return ResponseEntity.status(403).body(Map.of("error", "Acces refuse"));
            }
            if (dto.get("title") != null) job.setTitle(Objects.toString(dto.get("title"), job.getTitle()));
            if (dto.get("department") != null) {
                String dept = Objects.toString(dto.get("department"), job.getDepartment());
                if ("MANAGER".equals(role)) {
                    dept = stringValue(user.get("department"));
                }
                job.setDepartment(dept);
            }
            if (dto.get("description") != null) job.setDescription(Objects.toString(dto.get("description"), job.getDescription()));
            if (dto.get("requirements") != null) job.setRequirements(Objects.toString(dto.get("requirements"), job.getRequirements()));
            if (dto.get("eligibility_criteria") != null) job.setEligibilityCriteria(Objects.toString(dto.get("eligibility_criteria"), job.getEligibilityCriteria()));
            if (dto.get("type") != null) job.setType(Objects.toString(dto.get("type"), job.getType()).toUpperCase());
            if (dto.get("status") != null) job.setStatus(Objects.toString(dto.get("status"), job.getStatus()).toUpperCase());
            if ("MANAGER".equals(role) && "EXTERNAL".equalsIgnoreCase(job.getType())) {
                job.setType("INTERNAL");
            }
            if (dto.get("salary_range") != null) job.setSalaryRange(Objects.toString(dto.get("salary_range"), job.getSalaryRange()));
            if (dto.get("project") != null) job.setProject(Objects.toString(dto.get("project"), job.getProject()));
            if (dto.get("opening_date") != null && !Objects.toString(dto.get("opening_date")).isBlank()) {
                job.setOpeningDate(LocalDate.parse(Objects.toString(dto.get("opening_date"))));
            }
            if (dto.get("closing_date") != null && !Objects.toString(dto.get("closing_date")).isBlank()) {
                job.setClosingDate(LocalDate.parse(Objects.toString(dto.get("closing_date"))));
            }
            return ResponseEntity.ok(jobOfferRepository.save(job));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','RECRUITER','MANAGER')")
    @DeleteMapping("/api/jobs/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id, Authentication authentication, HttpServletRequest request) {
        Map<String, Object> user = currentUser(authentication, request);
        String role = stringValue(user.get("role"));
        Long userId = longValue(user.get("id"));
        if (!jobOfferRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        if ("MANAGER".equals(role)) {
            JobOffer offer = jobOfferRepository.findById(id).orElse(null);
            if (offer == null || !Objects.equals(offer.getRecruiterId(), userId)) {
                return ResponseEntity.status(403).body(Map.of("error", "Acces refuse"));
            }
        }
        jobOfferRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    private boolean isVisibleToday(JobOffer job) {
        LocalDate today = LocalDate.now();
        if (job.getOpeningDate() != null && job.getOpeningDate().isAfter(today)) return false;
        if (job.getClosingDate() != null && job.getClosingDate().isBefore(today)) return false;
        return true;
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
