package com.example.cryptoacademy.persistance.repository;

import com.example.cryptoacademy.persistance.model.TipoTransaccion;
import com.example.cryptoacademy.persistance.model.Transaccion;
import com.example.cryptoacademy.persistance.model.Usuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;


public interface TransaccionRepository extends JpaRepository<Transaccion, Long> {

    Page<Transaccion> findByUsuarioOrderByFechaTransaccionDesc(Usuario usuario, Pageable pageable);
    Page<Transaccion> findByUsuarioAndTipoTransaccionOrderByFechaTransaccionDesc(
            Usuario usuario,
            TipoTransaccion tipoTransaccion,
            Pageable pageable
    );
}
