package com.example.cryptoacademy.dto;

import lombok.Data;

@Data
public class UsuarioRequestDTO {
    private String nombre;
    private String email;
    private String hashContrasena;
}

