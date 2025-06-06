package com.example.cryptoacademy.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ActualizarNombreCarteraRequestDTO {

    @NotBlank(message = "El nuevo nombre de la cartera no puede estar vacío.")
    @Size(min = 1, max = 100, message = "El nombre de la cartera debe tener entre 1 y 100 caracteres.")
    private String nuevoNombre;
}