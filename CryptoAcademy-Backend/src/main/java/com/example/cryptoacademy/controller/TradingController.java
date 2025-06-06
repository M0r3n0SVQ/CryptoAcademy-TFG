package com.example.cryptoacademy.controller;

import com.example.cryptoacademy.dto.OrdenRequestDTO;
import com.example.cryptoacademy.dto.PortfolioResponseDTO;
import com.example.cryptoacademy.dto.TransaccionResponseDTO;
import com.example.cryptoacademy.exception.CantidadInsuficienteException;
import com.example.cryptoacademy.exception.RecursoNoEncontradoException;
import com.example.cryptoacademy.exception.SaldoInsuficienteException;
import com.example.cryptoacademy.persistance.model.TipoTransaccion;
import com.example.cryptoacademy.persistance.model.Transaccion;
import com.example.cryptoacademy.persistance.model.Usuario;
import com.example.cryptoacademy.service.TradingServiceI;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api")
public class TradingController {

    private static final Logger log = LoggerFactory.getLogger(TradingController.class);
    private final TradingServiceI tradingService;

    private static final DateTimeFormatter API_DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public TradingController(TradingServiceI tradingService) {
        this.tradingService = tradingService;
    }

    @PostMapping("/transacciones/comprar")
    public ResponseEntity<?> comprarCriptomoneda(
            @Valid @RequestBody OrdenRequestDTO ordenRequestDTO,
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario no autenticado.");
        }

        try {
            Transaccion transaccionRealizada = tradingService.comprarCripto(
                    usuarioAutenticado.getId(),
                    ordenRequestDTO.getIdCartera(),
                    ordenRequestDTO.getIdCriptomoneda(),
                    ordenRequestDTO.getCantidad()
            );
            TransaccionResponseDTO responseDTO = mapTransaccionToResponseDTO(transaccionRealizada);
            return ResponseEntity.status(HttpStatus.CREATED).body(responseDTO);

        } catch (RecursoNoEncontradoException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (SaldoInsuficienteException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            log.error("ERROR INESPERADO durante compra para Usuario [{}], ...: {}", usuarioAutenticado.getEmail(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Ocurrió un error inesperado al procesar la compra.");
        }
    }

    @PostMapping("/transacciones/vender")
    public ResponseEntity<?> venderCriptomoneda(
            @Valid @RequestBody OrdenRequestDTO ordenRequestDTO,
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario no autenticado.");
        }

        try {
            Transaccion transaccionRealizada = tradingService.venderCripto(
                    usuarioAutenticado.getId(),
                    ordenRequestDTO.getIdCartera(),
                    ordenRequestDTO.getIdCriptomoneda(),
                    ordenRequestDTO.getCantidad()
            );
            TransaccionResponseDTO responseDTO = mapTransaccionToResponseDTO(transaccionRealizada);
            return ResponseEntity.status(HttpStatus.CREATED).body(responseDTO);

        } catch (RecursoNoEncontradoException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (CantidadInsuficienteException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            log.error("ERROR INESPERADO durante venta para Usuario [{}], Cartera [{}], Cripto [{}]: {}",
                    usuarioAutenticado.getEmail(), ordenRequestDTO.getIdCartera(), ordenRequestDTO.getIdCriptomoneda(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Ocurrió un error inesperado al procesar la venta.");
        }
    }

    @GetMapping("/portfolio/{idCartera}")
    public ResponseEntity<?> obtenerPortfolioPorCartera(
            @PathVariable Long idCartera,
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario no autenticado.");
        }

        try {
            PortfolioResponseDTO portfolioDTO = tradingService.obtenerPortfolio(
                    usuarioAutenticado.getId(),
                    idCartera
            );
            return ResponseEntity.ok(portfolioDTO);
        } catch (RecursoNoEncontradoException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            log.error("ERROR INESPERADO al obtener portfolio para Usuario [{}] y Cartera [{}]: {}",
                    usuarioAutenticado.getEmail(), idCartera, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Ocurrió un error inesperado al obtener el portfolio.");
        }
    }

    @GetMapping("/transacciones/historial")
    public ResponseEntity<?> obtenerHistorialTransacciones(
            Pageable pageable,
            @RequestParam(required = false) TipoTransaccion tipo,
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario no autenticado.");
        }

        try {
            Page<TransaccionResponseDTO> historialDTOPage = tradingService.obtenerHistorialTransaccionesUsuario(
                    usuarioAutenticado.getId(),
                    tipo,
                    pageable
            );
            return ResponseEntity.ok(historialDTOPage);
        } catch (RecursoNoEncontradoException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            log.error("ERROR INESPERADO al obtener historial para Usuario [{}], Tipo [{}]: {}",
                    usuarioAutenticado.getEmail(), tipo, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Ocurrió un error inesperado al obtener el historial de transacciones.");
        }
    }

    private TransaccionResponseDTO mapTransaccionToResponseDTO(Transaccion transaccion) {
        if (transaccion == null) return null;
        return TransaccionResponseDTO.builder()
                .idTransaccion(transaccion.getIdTransaccion())
                .usuarioEmail(transaccion.getUsuario().getEmail())
                .idCartera(transaccion.getCartera().getIdCartera())
                .idCriptomoneda(transaccion.getCriptomoneda().getId_Criptomoneda())
                .simboloCriptomoneda(transaccion.getCriptomoneda().getSimbolo())
                .nombreCriptomoneda(transaccion.getCriptomoneda().getNombre())
                .tipoTransaccion(transaccion.getTipoTransaccion())
                .cantidadCripto(transaccion.getCantidadCripto())
                .precioPorUnidadEUR(transaccion.getPrecioPorUnidadeEUR())
                .valorTotalEUR(transaccion.getValorTotalEUR())
                .fechaTransaccion(transaccion.getFechaTransaccion() != null ?
                        transaccion.getFechaTransaccion().format(API_DATE_TIME_FORMATTER) : null)
                .build();
    }
}