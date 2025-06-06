package com.example.cryptoacademy.security.auth.service;

import com.example.cryptoacademy.security.auth.dto.AuthResponseDTO;
import com.example.cryptoacademy.security.auth.dto.LoginRequestDTO;
import com.example.cryptoacademy.security.auth.dto.RegisterRequestDTO;

public interface AuthServiceI {

    AuthResponseDTO login(LoginRequestDTO request);

    AuthResponseDTO register(RegisterRequestDTO request);
}
