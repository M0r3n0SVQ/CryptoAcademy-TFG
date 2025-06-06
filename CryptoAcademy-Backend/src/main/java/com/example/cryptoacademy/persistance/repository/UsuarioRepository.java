package com.example.cryptoacademy.persistance.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.cryptoacademy.persistance.model.Usuario;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {
    Optional<Usuario> findByEmail(String email);
}
