package com.example.cryptoacademy.service;

import com.example.cryptoacademy.dto.MarketCoinDTO;
import com.example.cryptoacademy.persistance.model.Criptomoneda;
import com.example.cryptoacademy.persistance.repository.CriptomonedaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class CriptomonedaUpdateService {

    private static final Logger log = LoggerFactory.getLogger(CriptomonedaUpdateService.class);

    private final CoinGeckoService coinGeckoService;
    private final CriptomonedaRepository criptomonedaRepository;

    @Value("${coingecko.update.enabled:true}")
    private boolean updateEnabled;

    public CriptomonedaUpdateService(CoinGeckoService coinGeckoService,
                                     CriptomonedaRepository criptomonedaRepository) {
        this.coinGeckoService = coinGeckoService;
        this.criptomonedaRepository = criptomonedaRepository;
    }

    @Scheduled(fixedRateString = "${coingecko.update.interval.ms:60000}", initialDelayString = "${coingecko.update.initial-delay.ms:60000}")
    @Transactional
    public void actualizarDatosCriptomonedas() {
        if (!updateEnabled) {
            return;
        }

        List<Criptomoneda> monedasLocales = criptomonedaRepository.findAll();
        if (monedasLocales.isEmpty()) {
            return;
        }

        List<String> idsParaActualizar = monedasLocales.stream()
                .map(Criptomoneda::getId_Criptomoneda)
                .collect(Collectors.toList());

        try {
            List<MarketCoinDTO> datosExternos = coinGeckoService.getMarketDataForIds(idsParaActualizar);

            if (datosExternos == null || datosExternos.isEmpty()) {
                return;
            }

            Map<String, Criptomoneda> mapaMonedasLocales = monedasLocales.stream()
                    .collect(Collectors.toMap(Criptomoneda::getId_Criptomoneda, Function.identity()));

            List<Criptomoneda> monedasParaGuardar = new ArrayList<>();
            for (MarketCoinDTO dto : datosExternos) {
                if (dto.getId() == null) {
                    continue;
                }

                Criptomoneda entidadLocal = mapaMonedasLocales.get(dto.getId());
                if (entidadLocal != null) {
                    boolean fueActualizada = mapDtoToExistingEntity(dto, entidadLocal);
                    if (fueActualizada) {
                        monedasParaGuardar.add(entidadLocal);
                    }
                }
            }

            if (!monedasParaGuardar.isEmpty()) {
                criptomonedaRepository.saveAll(monedasParaGuardar);
            }

        } catch (IOException e) {
            log.error("IOException durante actualización de criptomonedas desde CoinGecko: {}", e.getMessage(), e);
        } catch (Exception e) {
            log.error("Error inesperado durante actualización de criptomonedas: {}", e.getMessage(), e);
        }
    }

    private boolean mapDtoToExistingEntity(MarketCoinDTO dto, Criptomoneda entidad) {
        boolean actualizada = false;

        if (dto.getName() != null && !dto.getName().equals(entidad.getNombre())) {
            entidad.setNombre(dto.getName());
            actualizada = true;
        }
        if (dto.getSymbol() != null && !dto.getSymbol().equalsIgnoreCase(entidad.getSimbolo())) {
            entidad.setSimbolo(dto.getSymbol().toLowerCase());
            actualizada = true;
        }
        if (dto.getCurrentPrice() != null && (entidad.getPrecio_actual() == null || dto.getCurrentPrice().compareTo(entidad.getPrecio_actual()) != 0)) {
            entidad.setPrecio_actual(dto.getCurrentPrice());
            actualizada = true;
        }
        if (dto.getImage() != null && !dto.getImage().equals(entidad.getImagen())) {
            entidad.setImagen(dto.getImage());
            actualizada = true;
        }
        if (dto.getMarketCap() != null && (entidad.getCapitalizacion() == null || dto.getMarketCap().compareTo(entidad.getCapitalizacion()) != 0)) {
            entidad.setCapitalizacion(dto.getMarketCap());
            actualizada = true;
        }
        if (dto.getPriceChangePercentage24h() != null && !Objects.equals(dto.getPriceChangePercentage24h(), entidad.getCambioPorcentaje24h())) {
            entidad.setCambioPorcentaje24h(dto.getPriceChangePercentage24h());
            actualizada = true;
        }
        if (dto.getTotalVolume() != null && (entidad.getVolumen_24h() == null || dto.getTotalVolume().compareTo(entidad.getVolumen_24h()) != 0)) {
            entidad.setVolumen_24h(dto.getTotalVolume());
            actualizada = true;
        }

        LocalDateTime nuevaFechaActualizacion = null;
        if (dto.getLastUpdated() != null && !dto.getLastUpdated().isEmpty()) {
            try {
                Instant instant = Instant.parse(dto.getLastUpdated());
                nuevaFechaActualizacion = LocalDateTime.ofInstant(instant, ZoneOffset.UTC);
            } catch (DateTimeParseException e) {
            }
        }

        if (actualizada) {
            entidad.setFecha_actualizacion(nuevaFechaActualizacion != null ? nuevaFechaActualizacion : LocalDateTime.now(ZoneOffset.UTC));
        } else if (nuevaFechaActualizacion != null && (entidad.getFecha_actualizacion() == null || nuevaFechaActualizacion.isAfter(entidad.getFecha_actualizacion()))) {
            entidad.setFecha_actualizacion(nuevaFechaActualizacion);
            actualizada = true;
        }

        return actualizada;
    }
}