package com.vermeg.recruitment.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "applications")
public class JobApplication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long jobId;
    private String jobTitle;
    private Long userId;
    private String status = "PENDING";
    private LocalDateTime appliedAt = LocalDateTime.now();

    @Column(columnDefinition = "TEXT")
    private String coverLetter;
    @Column(columnDefinition = "TEXT")
    private String cvFile;
    @Column(columnDefinition = "TEXT")
    private String diplomaFile;
    @Column(columnDefinition = "TEXT")
    private String cinFile;

    private String phone;
    private String city;
    private String country;
    private String fullName;
    private String email;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getJobId() { return jobId; }
    public void setJobId(Long jobId) { this.jobId = jobId; }
    public String getJobTitle() { return jobTitle; }
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getAppliedAt() { return appliedAt; }
    public void setAppliedAt(LocalDateTime appliedAt) { this.appliedAt = appliedAt; }
    public String getCoverLetter() { return coverLetter; }
    public void setCoverLetter(String coverLetter) { this.coverLetter = coverLetter; }
    public String getCvFile() { return cvFile; }
    public void setCvFile(String cvFile) { this.cvFile = cvFile; }
    public String getDiplomaFile() { return diplomaFile; }
    public void setDiplomaFile(String diplomaFile) { this.diplomaFile = diplomaFile; }
    public String getCinFile() { return cinFile; }
    public void setCinFile(String cinFile) { this.cinFile = cinFile; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}