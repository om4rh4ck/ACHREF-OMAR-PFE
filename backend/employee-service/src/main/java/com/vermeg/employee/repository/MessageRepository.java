package com.vermeg.employee.repository;

import com.vermeg.employee.model.MessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<MessageEntity, Long> {
    List<MessageEntity> findBySenderIdOrReceiverIdOrderByCreatedAtAsc(Long senderId, Long receiverId);
}