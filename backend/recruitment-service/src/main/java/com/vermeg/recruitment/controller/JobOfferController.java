package com.vermeg.recruitment.controller;

import com.vermeg.recruitment.model.JobOffer;
import com.vermeg.recruitment.repository.JobOfferRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
public class JobOfferController {

    private final JobOfferRepository jobOfferRepository;

    public JobOfferController(JobOfferRepository jobOfferRepository) {
        this.jobOfferRepository = jobOfferRepository;
    }

    @GetMapping("/api/public/jobs")
    public List<JobOffer> publicJobs() {
        return jobOfferRepository.findByStatusOrderByCreatedAtDesc("PUBLISHED");
    }

    @GetMapping("/api/jobs/visible")
    public List<JobOffer> visibleJobs() {
        return jobOfferRepository.findByStatusOrderByCreatedAtDesc("PUBLISHED").stream().filter(job -> {
            LocalDate today = LocalDate.now();
            if (job.getOpeningDate() != null && job.getOpeningDate().isAfter(today)) return false;
            if (job.getClosingDate() != null && job.getClosingDate().isBefore(today)) return false;
            return true;
        }).toList();
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','RECRUITER','MANAGER')")
    @GetMapping("/api/jobs")
    public List<JobOffer> allJobs() {
        return jobOfferRepository.findAll();
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','RECRUITER','MANAGER')")
    @PostMapping("/api/jobs")
    public ResponseEntity<?> create(@RequestBody Map<String, Object> dto) {
        JobOffer job = new JobOffer();
        job.setTitle(Objects.toString(dto.get("title"), ""));
        job.setDepartment(Objects.toString(dto.get("department"), ""));
        job.setDescription(Objects.toString(dto.get("description"), ""));
        job.setRequirements(Objects.toString(dto.get("requirements"), ""));
        job.setEligibilityCriteria(Objects.toString(dto.get("eligibility_criteria"), ""));
        job.setType(Objects.toString(dto.getOrDefault("type", "EXTERNAL"), "EXTERNAL").toUpperCase());
        job.setStatus(Objects.toString(dto.getOrDefault("status", "PUBLISHED"), "PUBLISHED").toUpperCase());
        if (dto.get("recruiter_id") != null) {
            job.setRecruiterId(Long.parseLong(Objects.toString(dto.get("recruiter_id"))));
        }
        job.setSalaryRange(Objects.toString(dto.get("salary_range"), ""));
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
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> dto) {
        return jobOfferRepository.findById(id).map(job -> {
            if (dto.get("title") != null) job.setTitle(Objects.toString(dto.get("title"), job.getTitle()));
            if (dto.get("department") != null) job.setDepartment(Objects.toString(dto.get("department"), job.getDepartment()));
            if (dto.get("description") != null) job.setDescription(Objects.toString(dto.get("description"), job.getDescription()));
            if (dto.get("requirements") != null) job.setRequirements(Objects.toString(dto.get("requirements"), job.getRequirements()));
            if (dto.get("eligibility_criteria") != null) job.setEligibilityCriteria(Objects.toString(dto.get("eligibility_criteria"), job.getEligibilityCriteria()));
            if (dto.get("type") != null) job.setType(Objects.toString(dto.get("type"), job.getType()).toUpperCase());
            if (dto.get("status") != null) job.setStatus(Objects.toString(dto.get("status"), job.getStatus()).toUpperCase());
            if (dto.get("recruiter_id") != null) job.setRecruiterId(Long.parseLong(Objects.toString(dto.get("recruiter_id"))));
            if (dto.get("salary_range") != null) job.setSalaryRange(Objects.toString(dto.get("salary_range"), job.getSalaryRange()));
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
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (!jobOfferRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        jobOfferRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
