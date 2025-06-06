package com.example.cryptoacademy.service;

import com.example.cryptoacademy.dto.PortfolioResponseDTO;
import com.example.cryptoacademy.dto.TransaccionResponseDTO;
import com.example.cryptoacademy.exception.CantidadInsuficienteException;
import com.example.cryptoacademy.exception.RecursoNoEncontradoException;
import com.example.cryptoacademy.exception.SaldoInsuficienteException;
import com.example.cryptoacademy.persistance.model.TipoTransaccion;
import com.example.cryptoacademy.persistance.model.Transaccion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

public interface TradingServiceI {

    Transaccion comprarCripto(Integer idUsuario, Long idCartera, String idCriptomoneda, BigDecimal cantidadComprar)
            throws RecursoNoEncontradoException, SaldoInsuficienteException, IllegalArgumentException;

    Transaccion venderCripto(Integer idUsuario, Long idCartera, String idCriptomoneda, BigDecimal cantidadVender)
            throws RecursoNoEncontradoException, CantidadInsuficienteException, IllegalArgumentException;

    PortfolioResponseDTO obtenerPortfolio(Integer idUsuario, Long idCartera)
            throws RecursoNoEncontradoException;

    Page<TransaccionResponseDTO> obtenerHistorialTransaccionesUsuario(
            Integer idUsuario,
            TipoTransaccion tipoTransaccion,
            Pageable pageable
    ) throws RecursoNoEncontradoException;

    BigDecimal getSaldoFiatTotalPorUsuario(Integer idUsuario);

    @Transactional(readOnly = true)
    BigDecimal getValorCriptoTotalPorUsuario(Integer idUsuario);
}
