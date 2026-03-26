package com.vermeg.recruitment.repository;

import com.vermeg.recruitment.model.JobApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JobApplicationRepository extends JpaRepository<JobApplication, Long> {
    List<JobApplication> findByEmailOrderByAppliedAtDesc(String email);
    List<JobApplication> findAllByOrderByAppliedAtDesc();
}
