package com.example.cryptoacademy.config;

import com.example.cryptoacademy.dto.MarketCoinDTO;
import com.example.cryptoacademy.persistance.model.Criptomoneda;
import com.example.cryptoacademy.persistance.repository.CriptomonedaRepository;
import com.example.cryptoacademy.service.CoinGeckoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final CoinGeckoService coinGeckoService;
    private final CriptomonedaRepository criptomonedaRepository;

    @Value("${initializer.load-top-coins:50}")
    private int numCriptosCargar;

    @Value("${initializer.enabled:true}")
    private boolean initializerEnabled;

    public DataInitializer(CoinGeckoService coinGeckoService, CriptomonedaRepository criptomonedaRepository) {
        this.coinGeckoService = coinGeckoService;
        this.criptomonedaRepository = criptomonedaRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (!initializerEnabled) {
            return;
        }
        if (criptomonedaRepository.count() > 0) {
            return;
        }
        if (numCriptosCargar <= 0) {
            return;
        }

        try {
            List<MarketCoinDTO> marketCoinDTOs = coinGeckoService.getTopMarketData(numCriptosCargar);

            if (marketCoinDTOs == null || marketCoinDTOs.isEmpty()) {
                return;
            }

            List<Criptomoneda> nuevasCriptomonedas = new ArrayList<>();

            for (MarketCoinDTO dto : marketCoinDTOs) {
                if (dto.getId() == null) {
                    continue;
                }

                Criptomoneda nuevaCripto = new Criptomoneda();
                nuevaCripto.setId_Criptomoneda(dto.getId());
                nuevaCripto.setNombre(dto.getName());
                if (dto.getSymbol() != null) {
                    nuevaCripto.setSimbolo(dto.getSymbol().toLowerCase());
                }
                nuevaCripto.setPrecio_actual(dto.getCurrentPrice());
                nuevaCripto.setImagen(dto.getImage());
                nuevaCripto.setCapitalizacion(dto.getMarketCap());
                nuevaCripto.setVolumen_24h(dto.getTotalVolume());
                if (dto.getPriceChangePercentage24h() != null) {
                    nuevaCripto.setCambioPorcentaje24h(dto.getPriceChangePercentage24h());
                }

                if (dto.getLastUpdated() != null && !dto.getLastUpdated().isEmpty()) {
                    try {
                        Instant instant = Instant.parse(dto.getLastUpdated());
                        nuevaCripto.setFecha_actualizacion(LocalDateTime.ofInstant(instant, ZoneOffset.UTC));
                    } catch (DateTimeParseException e) {
                        nuevaCripto.setFecha_actualizacion(LocalDateTime.now(ZoneOffset.UTC));
                    }
                } else {
                    nuevaCripto.setFecha_actualizacion(LocalDateTime.now(ZoneOffset.UTC));
                }
                nuevasCriptomonedas.add(nuevaCripto);
            }

            if (!nuevasCriptomonedas.isEmpty()) {
                criptomonedaRepository.saveAll(nuevasCriptomonedas);
            }
        } catch (IOException e) {
            log.error("IOException durante la carga inicial de criptomonedas desde CoinGecko: {}", e.getMessage(), e);
        } catch (Exception e) {
            log.error("Error inesperado durante la carga inicial de criptomonedas: {}", e.getMessage(), e);
        }
    }
}