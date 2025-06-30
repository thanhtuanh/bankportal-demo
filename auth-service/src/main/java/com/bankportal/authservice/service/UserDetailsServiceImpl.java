// src/main/java/com/bankportal/authservice/service/UserDetailsServiceImpl.java
package com.bankportal.authservice.service;

import com.bankportal.authservice.model.UserEntity;
import com.bankportal.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository repository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UserEntity user = repository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return org.springframework.security.core.userdetails.User.builder()
            .username(user.getUsername())
            .password(user.getPassword())       // <-- hier das Feld mit Hash
            .authorities(new SimpleGrantedAuthority(user.getRole()))
            .build();
    }
}
