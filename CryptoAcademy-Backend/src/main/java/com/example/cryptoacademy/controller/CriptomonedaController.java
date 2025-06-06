package com.example.cryptoacademy.controller;

import com.example.cryptoacademy.dto.CoinGeckoChartDataDTO;
import com.example.cryptoacademy.dto.CriptoApiDTO;
import com.example.cryptoacademy.dto.MarketCoinDTO;
import com.example.cryptoacademy.persistance.model.Criptomoneda;
import com.example.cryptoacademy.persistance.repository.CriptomonedaRepository;
import com.example.cryptoacademy.service.CoinGeckoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Optional;

@RestController
@RequestMapping("/api/criptomonedas")
public class CriptomonedaController {

    private static final Logger log = LoggerFactory.getLogger(CriptomonedaController.class);

    private final CriptomonedaRepository criptomonedaRepository;
    private final CoinGeckoService coinGeckoService;

    private static final DateTimeFormatter API_DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public CriptomonedaController(CriptomonedaRepository criptomonedaRepository,
                                  CoinGeckoService coinGeckoService) {
        this.criptomonedaRepository = criptomonedaRepository;
        this.coinGeckoService = coinGeckoService;
    }

    @GetMapping
    public ResponseEntity<Page<CriptoApiDTO>> getAllCriptomonedas(Pageable pageable) {
        Page<Criptomoneda> criptomonedasPage = criptomonedaRepository.findAll(pageable);
        Page<CriptoApiDTO> dtoPage = criptomonedasPage.map(this::mapEntidadToApiDTO);
        return ResponseEntity.ok(dtoPage);
    }

    @GetMapping("/{criptoId}")
    public ResponseEntity<CriptoApiDTO> getCriptomonedaById(@PathVariable String criptoId) {
        Optional<Criptomoneda> criptomonedaOpt = criptomonedaRepository.findById(criptoId);

        if (criptomonedaOpt.isPresent()) {
            return ResponseEntity.ok(mapEntidadToApiDTO(criptomonedaOpt.get()));
        } else {
            try {
                MarketCoinDTO marketCoinDTO = coinGeckoService.getMarketDataForId(criptoId);
                if (marketCoinDTO != null) {
                    Criptomoneda nuevaCripto = mapMarketCoinDTOToEntidad(marketCoinDTO);
                    Criptomoneda guardada = criptomonedaRepository.save(nuevaCripto);
                    return ResponseEntity.status(HttpStatus.CREATED).body(mapEntidadToApiDTO(guardada));
                } else {
                    return ResponseEntity.notFound().build();
                }
            } catch (IOException e) {
                log.error("Error de IO al obtener detalles de {} desde CoinGecko: {}", criptoId, e.getMessage());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
            }
        }
    }

    @GetMapping("/buscar")
    public ResponseEntity<Page<CriptoApiDTO>> buscarCriptomonedas(
            @RequestParam String termino,
            Pageable pageable) {
        Page<Criptomoneda> resultadosPage = criptomonedaRepository
                .findByNombreContainingOrSimboloContaining(termino, termino, pageable);
        Page<CriptoApiDTO> dtoPage = resultadosPage.map(this::mapEntidadToApiDTO);
        return ResponseEntity.ok(dtoPage);
    }
    @GetMapping("/{criptoId}/grafico")
    public ResponseEntity<?> obtenerDatosGraficoCriptomoneda(
            @PathVariable String criptoId,
            @RequestParam(defaultValue = "eur") String vsCurrency,
            @RequestParam(defaultValue = "7") String dias) {

        try {
            CoinGeckoChartDataDTO chartData = coinGeckoService.getCoinMarketChart(criptoId, vsCurrency, dias);
            if (chartData != null && chartData.getPrices() != null && !chartData.getPrices().isEmpty()) {
                return ResponseEntity.ok(chartData);
            } else {
                return ResponseEntity.status(HttpStatus.NO_CONTENT).body("No se encontraron datos de gráfico para los parámetros especificados.");
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (IOException e) {
            log.error("Error de IO al obtener datos de gráfico para Cripto ID [{}] desde CoinGecko: {}", criptoId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al contactar el servicio de datos de mercado.");
        } catch (Exception e) {
            log.error("Error inesperado al obtener datos de gráfico para Cripto ID [{}]: {}", criptoId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Ocurrió un error inesperado.");
        }
    }


    private CriptoApiDTO mapEntidadToApiDTO(Criptomoneda entidad) {
        if (entidad == null) return null;
        return new CriptoApiDTO(
                entidad.getId_Criptomoneda(),
                entidad.getNombre(),
                entidad.getSimbolo(),
                entidad.getPrecio_actual(),
                entidad.getImagen(),
                entidad.getCapitalizacion(),
                entidad.getVolumen_24h(),
                entidad.getCambioPorcentaje24h(),
                entidad.getFecha_actualizacion() != null ? entidad.getFecha_actualizacion().format(API_DATE_TIME_FORMATTER) : null
        );
    }

    private Criptomoneda mapMarketCoinDTOToEntidad(MarketCoinDTO dto) {
        if (dto == null) return null;

        Criptomoneda criptomoneda = new Criptomoneda();
        criptomoneda.setId_Criptomoneda(dto.getId());
        criptomoneda.setNombre(dto.getName());
        if (dto.getSymbol() != null) {
            criptomoneda.setSimbolo(dto.getSymbol().toLowerCase());
        }
        criptomoneda.setPrecio_actual(dto.getCurrentPrice());
        criptomoneda.setImagen(dto.getImage());
        criptomoneda.setCapitalizacion(dto.getMarketCap());
        criptomoneda.setVolumen_24h(dto.getTotalVolume());

        if (dto.getPriceChangePercentage24h() != null) {
            criptomoneda.setCambioPorcentaje24h(dto.getPriceChangePercentage24h());
        }

        if (dto.getLastUpdated() != null && !dto.getLastUpdated().isEmpty()) {
            try {
                Instant instant = Instant.parse(dto.getLastUpdated());
                criptomoneda.setFecha_actualizacion(LocalDateTime.ofInstant(instant, ZoneOffset.UTC));
            } catch (DateTimeParseException e) {
                criptomoneda.setFecha_actualizacion(LocalDateTime.now(ZoneOffset.UTC));
            }
        } else {
            criptomoneda.setFecha_actualizacion(LocalDateTime.now(ZoneOffset.UTC));
        }
        return criptomoneda;
    }
}