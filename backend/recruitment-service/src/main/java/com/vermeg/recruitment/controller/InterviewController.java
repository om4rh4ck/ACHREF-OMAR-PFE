package com.vermeg.recruitment.controller;

import com.vermeg.recruitment.model.Interview;
import com.vermeg.recruitment.model.JobApplication;
import com.vermeg.recruitment.repository.InterviewRepository;
import com.vermeg.recruitment.repository.JobApplicationRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
public class InterviewController {

    private final InterviewRepository interviewRepository;
    private final JobApplicationRepository jobApplicationRepository;

    public InterviewController(InterviewRepository interviewRepository, JobApplicationRepository jobApplicationRepository) {
        this.interviewRepository = interviewRepository;
        this.jobApplicationRepository = jobApplicationRepository;
    }

    @GetMapping("/api/interviews")
    public List<Interview> list() {
        return interviewRepository.findAll();
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN','RECRUITER')")
    @PostMapping("/api/interviews")
    public ResponseEntity<?> create(@RequestBody Map<String, Object> dto) {
        Long applicationId = Long.parseLong(Objects.toString(dto.get("application_id")));
        JobApplication app = jobApplicationRepository.findById(applicationId).orElse(null);
        if (app == null) return ResponseEntity.notFound().build();
        if (!"APPROVED".equalsIgnoreCase(app.getStatus())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Only approved applications can be scheduled"));
        }

        Interview interview = new Interview();
        interview.setApplicationId(applicationId);
        interview.setCandidateName(app.getFullName());
        interview.setCandidateEmail(app.getEmail());
        interview.setJobTitle(app.getJobTitle());
        interview.setDate(Objects.toString(dto.get("date"), ""));
        interview.setEvaluatorId(dto.get("evaluator_id") == null ? null : Long.parseLong(Objects.toString(dto.get("evaluator_id"))));
        interview.setStatus("SCHEDULED");

        app.setStatus("INTERVIEW_SCHEDULED");
        jobApplicationRepository.save(app);

        return ResponseEntity.ok(interviewRepository.save(interview));
    }

    @PreAuthorize("hasAnyRole('MANAGER','HR_ADMIN','RECRUITER')")
    @PutMapping("/api/interviews/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> dto) {
        return interviewRepository.findById(id).map(existing -> {
            if (dto.get("score") != null) existing.setScore(Integer.parseInt(Objects.toString(dto.get("score"))));
            existing.setComments(Objects.toString(dto.get("comments"), existing.getComments()));
            existing.setStatus(Objects.toString(dto.getOrDefault("status", existing.getStatus()), existing.getStatus()));
            return ResponseEntity.ok(interviewRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }
}
