package com.example.cryptoacademy.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RankingItemDTO {
    private int posicion;
    private int idUsuario;
    private String nombreUsuario;
    private String emailOculto;
    private BigDecimal valorTotalPortfolioEUR;
}
