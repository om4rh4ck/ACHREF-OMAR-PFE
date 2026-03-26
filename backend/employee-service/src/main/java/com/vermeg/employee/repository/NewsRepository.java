package com.vermeg.employee.repository;

import com.vermeg.employee.model.NewsItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NewsRepository extends JpaRepository<NewsItem, Long> {
    List<NewsItem> findAllByOrderByCreatedAtDesc();
}