// src/main/java/com/bankportal/authservice/model/User.java
package com.bankportal.authservice.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Set;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<String> roles;

    // … existierender Code …

    // Alias-Getter/Setter für Tests und AuthService.register
    public String getPassword() {
        // Intern speichern wir das Hash, Tests erwarten aber getPassword()
        return this.getPasswordHash();
    }

    public void setPassword(String rawPassword) {
        // Damit service.register(raw)->hash richtig aufnimmt
        this.setPasswordHash(rawPassword);
    }

}
