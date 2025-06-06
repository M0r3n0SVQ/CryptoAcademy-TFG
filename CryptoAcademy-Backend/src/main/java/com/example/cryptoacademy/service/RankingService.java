package com.example.cryptoacademy.service;

import com.example.cryptoacademy.dto.RankingItemDTO;
import java.util.List;

public interface RankingService {
    List<RankingItemDTO> obtenerRanking(int limite);
}
