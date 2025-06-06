package com.example.cryptoacademy.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import com.example.cryptoacademy.persistance.model.Cartera;

@Data
@NoArgsConstructor
public class CarteraResponseDTO {
    private Long idCartera;
    private Integer idUsuario;
    private String nombre;
    private BigDecimal saldo;
    private LocalDateTime fechaCreacion;

    public CarteraResponseDTO(Cartera cartera) {
        this.idCartera = cartera.getIdCartera();
        if (cartera.getUsuario() != null) {
            this.idUsuario = cartera.getUsuario().getId();
        }
        this.nombre = cartera.getNombre();
        this.saldo = cartera.getSaldoVirtualEUR();
        this.fechaCreacion = cartera.getFechaCreacion();
    }
}
