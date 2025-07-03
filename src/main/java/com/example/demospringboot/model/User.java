package com.example.demospringboot.model;

import java.time.LocalDateTime;

public record User(
        Long id,
        String name,
        String email,
        String password,
        LocalDateTime createdAt
) {
    public User(String name, String email, String password) {
        this(null, name, email, password, null);
    }
    
    public User withId(Long id) {
        return new User(id, this.name, this.email, this.password, this.createdAt);
    }
    
    public User withCreatedAt(LocalDateTime createdAt) {
        return new User(this.id, this.name, this.email, this.password, createdAt);
    }
}
