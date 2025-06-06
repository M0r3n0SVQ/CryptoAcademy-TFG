package com.example.cryptoacademy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PortfolioResponseDTO {

    private Long idCartera;
    private String nombreCartera;
    private BigDecimal saldoVirtualEUR;
    private List<PortfolioItemDTO> items;
    private BigDecimal valorTotalCriptosEUR;
    private BigDecimal valorTotalPortfolioEUR;
}
