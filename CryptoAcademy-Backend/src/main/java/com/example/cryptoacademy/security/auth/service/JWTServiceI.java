package com.example.cryptoacademy.security.auth.service;

import org.springframework.security.core.userdetails.UserDetails;

import com.example.cryptoacademy.persistance.model.Usuario;

import javax.crypto.SecretKey;
import java.util.Map;

public interface JWTServiceI {

    String getToken(Usuario usuario);

    String getToken(Map<String, Object> extraClaims, Usuario usuario);

    SecretKey getKey();

    String getEmailFromToken(String token);

    boolean isTokenValid(String token, UserDetails userDetails);
}
