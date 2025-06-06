package com.example.cryptoacademy.persistance.repository;

import com.example.cryptoacademy.persistance.model.Cartera;
import com.example.cryptoacademy.persistance.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CarteraRepository extends JpaRepository<Cartera, Long> {

    List<Cartera> findByUsuario(Usuario usuario);
    List<Cartera> findByUsuarioId(Integer idUsuario);
    Optional<Cartera> findByIdCarteraAndUsuario(Long idCartera, Usuario usuario);
}
