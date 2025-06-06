package com.example.cryptoacademy.service;

import com.example.cryptoacademy.persistance.model.Transaccion;
import com.example.cryptoacademy.persistance.repository.TransaccionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TransaccionService {

    @Autowired
    private TransaccionRepository transaccionRepository;

    public Transaccion guardarTransaccion(Transaccion transaccion) {
        return transaccionRepository.save(transaccion);
    }
}
