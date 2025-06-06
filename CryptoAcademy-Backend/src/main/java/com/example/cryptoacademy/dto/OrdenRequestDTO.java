package com.example.cryptoacademy.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrdenRequestDTO {

    @NotNull(message = "El ID de la cartera no puede ser nulo.")
    private Long idCartera;

    @NotBlank(message = "El ID de la criptomoneda no puede estar vacío.")
    private String idCriptomoneda;

    @NotNull(message = "La cantidad no puede ser nula.")
    @DecimalMin(value = "0.00000001", message = "La cantidad debe ser positiva.")
    private BigDecimal cantidad;

}
