package com.vermeg.recruitment.repository;

import com.vermeg.recruitment.model.Interview;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewRepository extends JpaRepository<Interview, Long> {
}