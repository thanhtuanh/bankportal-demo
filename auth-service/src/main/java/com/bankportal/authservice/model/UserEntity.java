package com.bankportal.authservice.model;

import lombok.Getter;
import lombok.Setter;
import jakarta.persistence.*;

@Entity
@Getter
@Setter
@Table(name = "users")
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;

    @Column(name = "password_hash")
    private String passwordHash;

    private String role;

    public UserEntity() {
    }

    public UserEntity(Long id, String username, String passwordHash, String role) {
        this.id = id;
        this.username = username;
        this.passwordHash = passwordHash;
        this.role = role;
    }

    // 🔁 Alias-Getter für Kompatibilität mit AuthService
    public String getPassword() {
        return this.passwordHash;
    }

    // 🔁 Alias-Setter für Registrierung (rohes Passwort wird als hash gespeichert)
    public void setPassword(String rawPassword) {
        this.passwordHash = rawPassword;
    }
}
