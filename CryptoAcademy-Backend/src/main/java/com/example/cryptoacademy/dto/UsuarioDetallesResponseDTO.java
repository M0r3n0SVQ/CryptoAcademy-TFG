package com.example.cryptoacademy.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
@NoArgsConstructor
public class UsuarioDetallesResponseDTO {
    private Integer id;
    private String nombre;
    private String email;
    private String fechaRegistro;
    private String rol;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    public UsuarioDetallesResponseDTO(Integer id, String nombre, String email, LocalDateTime fechaRegistroRaw, String rol) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.fechaRegistro = (fechaRegistroRaw != null) ? fechaRegistroRaw.format(FORMATTER) : null;
        this.rol = rol;
    }
}