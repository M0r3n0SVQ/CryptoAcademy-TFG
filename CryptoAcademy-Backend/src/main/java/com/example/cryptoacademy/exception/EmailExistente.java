package com.example.cryptoacademy.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class EmailExistente extends RuntimeException {
    public EmailExistente(String message) {
        super(message);
    }
}
