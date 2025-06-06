package com.example.cryptoacademy.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CarteraRequestDTO {
    private String nombre;
    private BigDecimal saldo;
}
