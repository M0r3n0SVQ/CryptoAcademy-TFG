package com.example.cryptoacademy.service;

import com.example.cryptoacademy.dto.CoinGeckoChartDataDTO;
import com.example.cryptoacademy.dto.MarketCoinDTO;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@Service
public class CoinGeckoService {

    private static final Logger log = LoggerFactory.getLogger(CoinGeckoService.class);

    private final OkHttpClient okHttpClient;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String apiUrlBase;

    public CoinGeckoService(OkHttpClient okHttpClient,
                            ObjectMapper objectMapper,
                            @Value("${coingecko.api.key}") String apiKey,
                            @Value("${coingecko.api.url}") String apiUrlBase) {
        this.okHttpClient = okHttpClient;
        this.objectMapper = objectMapper;
        this.apiKey = apiKey;
        this.apiUrlBase = apiUrlBase;
    }

    private Request buildGetRequest(String url) {
        return new Request.Builder()
                .url(url)
                .get()
                .addHeader("accept", "application/json")
                .addHeader("x-cg-demo-api-key", this.apiKey)
                .build();
    }

    private <T> T handleResponse(Response response, TypeReference<T> typeReference, String context) throws IOException {
        String responseBodyString = "";
        try (ResponseBody body = response.body()) {
            if (body != null) {
                responseBodyString = body.string();
            }
        } catch (IOException e) {
            log.error("Error al leer cuerpo de respuesta para {}. Código: {}", context, response.code(), e);
            if (response.isSuccessful()) throw e;
        }

        if (!response.isSuccessful()) {
            log.error("Error en llamada a CoinGecko para {}. Status: {}, Body: {}", context, response.code(), responseBodyString);
            throw new IOException("Respuesta no exitosa (" + response.code() + ") de CoinGecko para " + context);
        }
        if (responseBodyString.isEmpty() && response.code() == 200) {
            if (typeReference.getType().equals(new TypeReference<List<?>>() {
            }.getType())) {
                return objectMapper.readValue("[]", typeReference);
            }
        }
        return objectMapper.readValue(responseBodyString, typeReference);
    }

    public List<MarketCoinDTO> getTopMarketData(int limit) throws IOException {
        String url = String.format("%s/coins/markets?vs_currency=eur&order=market_cap_desc&per_page=%d&page=1&sparkline=false", apiUrlBase, limit);
        Request request = buildGetRequest(url);
        try (Response response = this.okHttpClient.newCall(request).execute()) {
            return handleResponse(response, new TypeReference<>() {
            }, "top market data");
        }
    }

    public List<MarketCoinDTO> getMarketDataForIds(List<String> ids) throws IOException {
        if (ids == null || ids.isEmpty()) {
            return Collections.emptyList();
        }
        String joinedIds = String.join(",", ids);
        int perPage = Math.max(ids.size(), 1);
        if (perPage > 250) {
            perPage = 250;
        }
        String url = String.format("%s/coins/markets?vs_currency=eur&ids=%s&order=market_cap_desc&per_page=%d&page=1&sparkline=false", apiUrlBase, joinedIds, perPage);
        // log.info("Obteniendo datos de mercado para {} IDs de CoinGecko: {}", ids.size(), url);
        Request request = buildGetRequest(url);
        try (Response response = this.okHttpClient.newCall(request).execute()) {
            return handleResponse(response, new TypeReference<>() {
            }, "market data for specific IDs");
        }
    }

    public MarketCoinDTO getMarketDataForId(String id) throws IOException {
        if (id == null || id.trim().isEmpty()) {
            return null;
        }
        String url = String.format("%s/coins/markets?vs_currency=eur&ids=%s&order=market_cap_desc&per_page=1&page=1&sparkline=false", apiUrlBase, id);
        Request request = buildGetRequest(url);
        try (Response response = this.okHttpClient.newCall(request).execute()) {
            if (response.code() == 404) {
                return null;
            }
            List<MarketCoinDTO> coinList = handleResponse(response, new TypeReference<>() {
            }, "market data for ID " + id);

            if (coinList == null || coinList.isEmpty()) {
                return null;
            }
            return coinList.get(0);
        }
    }

    public CoinGeckoChartDataDTO getCoinMarketChart(String coinId, String vsCurrency, String days) throws IOException {
        if (coinId == null || coinId.trim().isEmpty() ||
                vsCurrency == null || vsCurrency.trim().isEmpty() ||
                days == null || days.trim().isEmpty()) {
            throw new IllegalArgumentException("coinId, vsCurrency y days no pueden ser vacíos.");
        }
        String url = String.format("%s/coins/%s/market_chart?vs_currency=%s&days=%s",
                apiUrlBase, coinId, vsCurrency, days);

        Request request = buildGetRequest(url);

        try (Response response = this.okHttpClient.newCall(request).execute()) {
            return handleResponse(response, new TypeReference<>() {
            }, "datos de gráfico para " + coinId);
        }
    }
}