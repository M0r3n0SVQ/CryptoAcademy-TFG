package com.example.cryptoacademy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CriptoApiDTO {

    private String id;

    private String nombre;

    private String simbolo;

    private BigDecimal precioActual;

    private String imagen;

    private BigDecimal capitalizacionMercado;

    private BigDecimal volumen24h;

    private Double cambio24h;

    private String fechaActualizacion;
}
