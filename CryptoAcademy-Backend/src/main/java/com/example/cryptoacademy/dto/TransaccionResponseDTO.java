package com.example.cryptoacademy.dto;

import com.example.cryptoacademy.persistance.model.TipoTransaccion;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransaccionResponseDTO {

    private Long idTransaccion;
    private String usuarioEmail;
    private Long idCartera;
    private String idCriptomoneda;
    private String simboloCriptomoneda;
    private String nombreCriptomoneda;
    private TipoTransaccion tipoTransaccion;
    private BigDecimal cantidadCripto;
    private BigDecimal precioPorUnidadEUR;
    private BigDecimal valorTotalEUR;
    private String fechaTransaccion;
}
