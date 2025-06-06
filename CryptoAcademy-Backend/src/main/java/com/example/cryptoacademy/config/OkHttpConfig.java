package com.example.cryptoacademy.config;

import okhttp3.OkHttpClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.util.concurrent.TimeUnit;

@Configuration
public class OkHttpConfig {

    @Bean
    public OkHttpClient okHttpClient() {
        // Esto evita que la aplicación se quede bloqueada si la API externa no responde.
        return new OkHttpClient.Builder()
                .connectTimeout(10, TimeUnit.SECONDS) // Timeout de conexión de 10 segundos
                .writeTimeout(10, TimeUnit.SECONDS)   // Timeout de escritura de 10 segundos
                .readTimeout(30, TimeUnit.SECONDS)    // Timeout de lectura de 30 segundos
                .build();
    }
}