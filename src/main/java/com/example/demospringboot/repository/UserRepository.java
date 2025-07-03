package com.example.demospringboot.repository;

import com.example.demospringboot.model.User;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public class UserRepository {
    
    private final JdbcClient jdbcClient;
    
    public UserRepository(JdbcClient jdbcClient) {
        this.jdbcClient = jdbcClient;
    }
    
    public Optional<User> findByEmail(String email) {
        return jdbcClient
                .sql("SELECT id, name, email, password, created_at FROM users WHERE email = ?")
                .param(email)
                .query((rs, rowNum) -> new User(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getTimestamp("created_at").toLocalDateTime()
                ))
                .optional();
    }
    
    public boolean existsByEmail(String email) {
        return jdbcClient
                .sql("SELECT COUNT(*) FROM users WHERE email = ?")
                .param(email)
                .query(Integer.class)
                .single() > 0;
    }
    
    public User save(User user) {
        if (user.id() == null) {
            return insert(user);
        } else {
            return update(user);
        }
    }
    
    private User insert(User user) {
        // Use a simpler approach with RETURNING clause if supported, otherwise use a sequence query
        try {
            // First, insert the user and get the generated ID using a different approach
            jdbcClient
                    .sql("INSERT INTO users (name, email, password) VALUES (?, ?, ?)")
                    .param(user.name())
                    .param(user.email())
                    .param(user.password())
                    .update();
            
            // Get the user back by email (since email is unique)
            return jdbcClient
                    .sql("SELECT id, name, email, password, created_at FROM users WHERE email = ?")
                    .param(user.email())
                    .query((rs, rowNum) -> new User(
                            rs.getLong("id"),
                            rs.getString("name"),
                            rs.getString("email"),
                            rs.getString("password"),
                            rs.getTimestamp("created_at").toLocalDateTime()
                    ))
                    .single();
                    
        } catch (Exception e) {
            throw new IllegalStateException("Failed to insert user: " + e.getMessage(), e);
        }
    }
    
    private User update(User user) {
        jdbcClient
                .sql("UPDATE users SET name = ?, email = ?, password = ? WHERE id = ?")
                .param(user.name())
                .param(user.email())
                .param(user.password())
                .param(user.id())
                .update();
        
        return user;
    }
}
