package com.example.cryptoacademy.controller;

import com.example.cryptoacademy.persistance.model.Transaccion;
import com.example.cryptoacademy.service.TransaccionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/transacciones")
public class TransaccionController {

    @Autowired
    private TransaccionService transaccionService;

    @PostMapping
    public ResponseEntity<Transaccion> crearTransaccion(@RequestBody Transaccion transaccion) {
        Transaccion transaccionGuardada = transaccionService.guardarTransaccion(transaccion);
        return ResponseEntity.ok(transaccionGuardada);
    }

}
