package com.vermeg.employee.repository;

import com.vermeg.employee.model.ContractTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ContractTypeRepository extends JpaRepository<ContractTypeEntity, Long> {
}