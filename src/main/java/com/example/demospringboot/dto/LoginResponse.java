package com.example.demospringboot.dto;

public record LoginResponse(
        String token,
        String email,
        String name
) {
}
