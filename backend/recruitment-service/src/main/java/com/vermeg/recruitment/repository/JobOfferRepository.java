package com.vermeg.recruitment.repository;

import com.vermeg.recruitment.model.JobOffer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JobOfferRepository extends JpaRepository<JobOffer, Long> {
    List<JobOffer> findByStatusOrderByCreatedAtDesc(String status);
    List<JobOffer> findByTypeAndStatusOrderByCreatedAtDesc(String type, String status);
    List<JobOffer> findByTypeAndDepartmentAndStatusOrderByCreatedAtDesc(String type, String department, String status);
    List<JobOffer> findByRecruiterIdOrderByCreatedAtDesc(Long recruiterId);
}
