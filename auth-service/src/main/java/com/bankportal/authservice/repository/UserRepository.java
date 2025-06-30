// src/main/java/com/bankportal/authservice/repository/UserRepository.java
package com.bankportal.authservice.repository;

import com.bankportal.authservice.model.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {
    Optional<UserEntity> findByUsername(String username);
}
