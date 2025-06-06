package com.example.cryptoacademy.persistance.repository;

import com.example.cryptoacademy.persistance.model.Criptomoneda;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CriptomonedaRepository extends JpaRepository<Criptomoneda, String> {
    Page<Criptomoneda> findByNombreContainingOrSimboloContaining(String nombre, String simbolo, Pageable pageable);
}