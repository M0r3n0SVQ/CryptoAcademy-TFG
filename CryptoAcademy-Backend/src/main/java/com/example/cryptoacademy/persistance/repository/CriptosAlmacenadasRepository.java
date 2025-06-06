package com.example.cryptoacademy.persistance.repository;

import com.example.cryptoacademy.persistance.model.Cartera;
import com.example.cryptoacademy.persistance.model.Criptomoneda;
import com.example.cryptoacademy.persistance.model.CriptosAlmacenadas;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CriptosAlmacenadasRepository extends JpaRepository<CriptosAlmacenadas, Long> {

    Optional<CriptosAlmacenadas> findByCarteraAndCriptomoneda(Cartera cartera, Criptomoneda criptomoneda);
    List<CriptosAlmacenadas> findByCartera(Cartera cartera);
}
