package com.vermeg.recruitment.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;

public class JobOfferCreateDto {
    @NotBlank
    private String title;
    private String department;
    private String description;
    private String requirements;
    private String type = "INTERNAL";
    private String salaryRange;
    private LocalDate closingDate;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getRequirements() { return requirements; }
    public void setRequirements(String requirements) { this.requirements = requirements; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getSalaryRange() { return salaryRange; }
    public void setSalaryRange(String salaryRange) { this.salaryRange = salaryRange; }
    public LocalDate getClosingDate() { return closingDate; }
    public void setClosingDate(LocalDate closingDate) { this.closingDate = closingDate; }
}
