package com.example.cryptoacademy.controller;

import com.example.cryptoacademy.dto.RankingItemDTO;
import com.example.cryptoacademy.service.RankingService;
import com.example.cryptoacademy.api.response.ApiResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/ranking")
public class RankingController {

    private static final Logger log = LoggerFactory.getLogger(RankingController.class);

    private final RankingService rankingService;

    @Value("${ranking.default-limit:50}")
    private int defaultRankingLimit;

    public RankingController(RankingService rankingService) {
        this.rankingService = rankingService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<RankingItemDTO>>> obtenerRanking(
            @RequestParam(required = false) Integer limite) {

        int limitToApply = (limite != null && limite > 0) ? limite : defaultRankingLimit;
        log.info("Solicitud GET /api/ranking con límite: {}", limitToApply);

        try {
            List<RankingItemDTO> ranking = rankingService.obtenerRanking(limitToApply);
            if (ranking.isEmpty()) {
                log.info("El ranking está vacío o no hay usuarios para mostrar.");
                return ResponseEntity.ok(
                        new ApiResponse<>(true, "Ranking vacío o no disponible.", ranking)
                );
            }
            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Ranking obtenido correctamente.", ranking)
            );
        } catch (Exception e) {
            log.error("Error al obtener el ranking: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().body(
                    new ApiResponse<>(false, "Error interno al obtener el ranking.", null)
            );
        }
    }
}
