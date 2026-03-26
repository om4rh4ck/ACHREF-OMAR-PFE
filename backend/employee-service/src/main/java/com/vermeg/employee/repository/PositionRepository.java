package com.vermeg.employee.repository;

import com.vermeg.employee.model.PositionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PositionRepository extends JpaRepository<PositionEntity, Long> {}
