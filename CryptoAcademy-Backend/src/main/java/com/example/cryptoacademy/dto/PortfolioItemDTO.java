package com.example.cryptoacademy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PortfolioItemDTO {

    private String idCriptomoneda;
    private String nombreCriptomoneda;
    private String simboloCriptomoneda;
    private String imagenUrl;

    private BigDecimal cantidadPoseida;
    private BigDecimal precioActualPorUnidadEUR;
    private BigDecimal valorTotalTenenciaEUR;
    private Double cambioPorcentaje24h;
}
