package com.example.cryptoacademy.persistance.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "criptomonedas")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Criptomoneda {

    @Id
    @Column(name = "id_criptomoneda", length = 100, nullable = false, unique = true)
    private String id_Criptomoneda;

    @Column(nullable = false)
    private String simbolo;

    @Column(nullable = false)
    private String nombre;

    @Column(precision = 19, scale = 4)
    private BigDecimal precio_actual;

    private String imagen;

    @Column(precision = 24, scale = 2)
    private BigDecimal capitalizacion;

    @Column(name = "volumen_24h", precision = 24, scale = 2)
    private BigDecimal volumen_24h;

    @Column(name = "cambio_porcentaje_24h")
    private Double cambioPorcentaje24h;

    private LocalDateTime fecha_actualizacion;
}