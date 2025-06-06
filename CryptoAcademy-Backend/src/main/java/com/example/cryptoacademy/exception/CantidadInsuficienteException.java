package com.example.cryptoacademy.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class CantidadInsuficienteException extends RuntimeException {
    public CantidadInsuficienteException(String message) {
        super(message);
    }
}