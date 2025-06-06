package com.example.cryptoacademy.persistance.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "criptos_almacenadas", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"id_cartera", "id_criptomoneda"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CriptosAlmacenadas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_almacenada")
    private Long idAlmacenada;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_cartera", nullable = false)
    private Cartera cartera;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_criptomoneda", nullable = false)
    private Criptomoneda criptomoneda;

    @Column(nullable = false, precision = 24, scale = 8)
    private BigDecimal cantidad;

    @Column(name = "fecha_ultima_actualizacion", nullable = false)
    private LocalDateTime fechaUltimaActualizacion;

    @PrePersist
    protected void onCreate() {
        fechaUltimaActualizacion = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        fechaUltimaActualizacion = LocalDateTime.now();
    }

    public CriptosAlmacenadas(Cartera cartera, Criptomoneda criptomoneda, BigDecimal cantidad) {
        this.cartera = cartera;
        this.criptomoneda = criptomoneda;
        this.cantidad = cantidad;
        this.fechaUltimaActualizacion = LocalDateTime.now();
    }
}
