package com.vermeg.recruitment.controller;

import com.vermeg.recruitment.model.JobApplication;
import com.vermeg.recruitment.model.JobOffer;
import com.vermeg.recruitment.repository.JobApplicationRepository;
import com.vermeg.recruitment.repository.JobOfferRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
public class ApplicationController {

    private final JobApplicationRepository jobApplicationRepository;
    private final JobOfferRepository jobOfferRepository;

    public ApplicationController(JobApplicationRepository jobApplicationRepository, JobOfferRepository jobOfferRepository) {
        this.jobApplicationRepository = jobApplicationRepository;
        this.jobOfferRepository = jobOfferRepository;
    }

    @PostMapping("/api/jobs/{jobId}/apply")
    public ResponseEntity<?> apply(@PathVariable Long jobId, @RequestBody Map<String, Object> dto, Authentication authentication) {
        JobOffer job = jobOfferRepository.findById(jobId).orElse(null);
        if (job == null) return ResponseEntity.notFound().build();

        JobApplication app = new JobApplication();
        app.setJobId(job.getId());
        app.setJobTitle(job.getTitle());
        app.setEmail(authentication.getName());
        app.setFullName(Objects.toString(dto.get("full_name"), authentication.getName()));
        app.setPhone(Objects.toString(dto.get("phone"), ""));
        app.setCity(Objects.toString(dto.get("city"), ""));
        app.setCountry(Objects.toString(dto.get("country"), ""));
        app.setCoverLetter(Objects.toString(dto.get("cover_letter"), ""));
        app.setDiplomaFile(Objects.toString(dto.get("diploma_file"), ""));
        app.setCinFile(Objects.toString(dto.get("cin_file"), ""));
        app.setCvFile(Objects.toString(dto.get("cv_file"), ""));
        app.setStatus("PENDING");

        return ResponseEntity.ok(jobApplicationRepository.save(app));
    }

    @GetMapping("/api/applications")
    public List<JobApplication> list(Authentication authentication) {
        if (hasAnyRole(authentication, "ROLE_HR_ADMIN", "ROLE_RECRUITER", "ROLE_MANAGER")) {
            return jobApplicationRepository.findAllByOrderByAppliedAtDesc();
        }
        return jobApplicationRepository.findByEmailOrderByAppliedAtDesc(authentication.getName());
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN','RECRUITER')")
    @PutMapping("/api/applications/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable Long id, @RequestBody Map<String, Object> dto) {
        return jobApplicationRepository.findById(id).map(existing -> {
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
}
