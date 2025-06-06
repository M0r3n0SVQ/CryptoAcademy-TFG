package com.example.cryptoacademy.service;

import com.example.cryptoacademy.dto.RankingItemDTO;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;


@Service
public class RankingServiceImpl implements RankingService {

    private static final Logger log = LoggerFactory.getLogger(RankingServiceImpl.class);

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    public RankingServiceImpl(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    private String ocultarEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "N/A";
        }
        String[] parts = email.split("@");
        String localPart = parts[0];
        String domainPart = parts[1];

        if (localPart.length() <= 3) {
            return localPart.substring(0, Math.min(localPart.length(), 1)) + "***@" + domainPart;
        } else {
            return localPart.substring(0, 3) + "***@" + domainPart;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<RankingItemDTO> obtenerRanking(int limite) {
        log.info("Calculando ranking para el Top {} usuarios usando procedimiento almacenado.", limite);
        Query query = entityManager.createNativeQuery("CALL CalcularRankingUsuarios(:limiteParam)")
                .setParameter("limiteParam", limite);

        @SuppressWarnings("unchecked")
        List<Object[]> resultadosNativos = query.getResultList();

        List<RankingItemDTO> rankingFinal = new ArrayList<>();

        for (Object[] fila : resultadosNativos) {

            int posicion = ((Number) fila[0]).intValue();
            Integer idUsuario = ((Number) fila[1]).intValue();
            String nombreUsuario = (String) fila[2];
            String emailDevueltoPorSP = (String) fila[3]; // Email devuelto por el SP
            BigDecimal valorTotalPortfolioEUR = (BigDecimal) fila[4];

            rankingFinal.add(new RankingItemDTO(
                    posicion,
                    idUsuario,
                    nombreUsuario,
                    ocultarEmail(emailDevueltoPorSP),
                    valorTotalPortfolioEUR
            ));
        }

        log.info("Ranking calculado con {} usuarios desde el procedimiento almacenado.", rankingFinal.size());
        return rankingFinal;
    }

}
