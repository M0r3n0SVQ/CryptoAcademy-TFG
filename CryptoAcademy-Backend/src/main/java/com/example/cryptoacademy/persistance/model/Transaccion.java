package com.example.cryptoacademy.persistance.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transacciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaccion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_transaccion")
    private Long idTransaccion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_cartera", nullable = false)
    private Cartera cartera;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_criptomoneda", referencedColumnName = "id_criptomoneda", nullable = false)
    private Criptomoneda criptomoneda;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_transaccion", nullable = false, length = 10)
    private TipoTransaccion tipoTransaccion;

    @Column(name = "cantidad_cripto", nullable = false, precision = 24, scale = 8)
    private BigDecimal cantidadCripto;

    @Column(name = "precio_por_unidad_eur", nullable = false, precision = 19, scale = 4)
    private BigDecimal precioPorUnidadeEUR;

    @Column(name = "valor_total_eur", nullable = false, precision = 19, scale = 4)
    private BigDecimal valorTotalEUR;

    @Column(name = "fecha_transaccion", nullable = false, updatable = false)
    private LocalDateTime fechaTransaccion;

    @PrePersist
    protected void onCreate() {
        if (fechaTransaccion == null) {
            fechaTransaccion = LocalDateTime.now();
        }
    }

    public Transaccion(Usuario usuario, Cartera cartera, Criptomoneda criptomoneda,
                       TipoTransaccion tipoTransaccion, BigDecimal cantidadCripto,
                       BigDecimal precioPorUnidadeEUR) {
        this.usuario = usuario;
        this.cartera = cartera;
        this.criptomoneda = criptomoneda;
        this.tipoTransaccion = tipoTransaccion;
        this.cantidadCripto = cantidadCripto;
        this.precioPorUnidadeEUR = precioPorUnidadeEUR;
        if (cantidadCripto != null && precioPorUnidadeEUR != null) {
            this.valorTotalEUR = cantidadCripto.multiply(precioPorUnidadeEUR);
        }
        this.fechaTransaccion = LocalDateTime.now();
    }
}
