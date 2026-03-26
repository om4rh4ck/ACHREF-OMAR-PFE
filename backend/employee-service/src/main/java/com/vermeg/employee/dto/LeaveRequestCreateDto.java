package com.vermeg.employee.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;

public class LeaveRequestCreateDto {
    @NotBlank
    private String type;
    private LocalDate startDate;
    private LocalDate endDate;
    private String reason;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
