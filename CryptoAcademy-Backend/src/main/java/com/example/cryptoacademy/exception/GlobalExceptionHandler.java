package com.example.cryptoacademy.exception;

import com.example.cryptoacademy.api.response.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice 
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(EmailExistente.class)
    public ResponseEntity<ApiResponse<Object>> handleEmailAlreadyExistsException(
            EmailExistente ex, WebRequest request) {
        
        ApiResponse<Object> apiResponse = new ApiResponse<>(
                false, 
                ex.getMessage(),
                null 
        );
        
        return new ResponseEntity<>(apiResponse, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ResponseEntity<ApiResponse<Object>> handleRecursoNoEncontradoException(
            RecursoNoEncontradoException ex, WebRequest request) {
        
        ApiResponse<Object> apiResponse = new ApiResponse<>(
                false,
                ex.getMessage(),
                null
        );
        
        return new ResponseEntity<>(apiResponse, HttpStatus.NOT_FOUND);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleGlobalException(Exception ex, WebRequest request) {
        logger.error("Error no controlado: ", ex);
        ApiResponse<Object> apiResponse = new ApiResponse<>(
                false,
                "Ha ocurrido un error inesperado en el servidor.",
                null
        );
        return new ResponseEntity<>(apiResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
