package com.example.cryptoacademy.security.auth.controller;

import com.example.cryptoacademy.api.response.ApiResponse;
import com.example.cryptoacademy.persistance.model.Usuario;
import com.example.cryptoacademy.persistance.repository.UsuarioRepository;
import com.example.cryptoacademy.security.auth.dto.AuthResponseDTO;
import com.example.cryptoacademy.security.auth.dto.LoginRequestDTO;
import com.example.cryptoacademy.security.auth.dto.RegisterRequestDTO;
import com.example.cryptoacademy.security.auth.service.AuthServiceI;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private AuthServiceI authService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponseDTO>> login(@RequestBody LoginRequestDTO request) {
        try {
            AuthResponseDTO response = authService.login(request);
            return ResponseEntity.ok(new ApiResponse<>(true, "Login exitoso", response));
        } catch (Exception e) {
            return ResponseEntity.status(401).body(new ApiResponse<>(false, "Credenciales inválidas", null));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponseDTO>> register(@Validated @RequestBody RegisterRequestDTO request) {
        try {
            AuthResponseDTO response = authService.register(request);
            return ResponseEntity.ok(new ApiResponse<>(true, "Usuario registrado con éxito", response));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                new ApiResponse<>(false, "Error al registrar usuario: " + e.getMessage(), null)
            );
        }
    }

    @GetMapping("/userId")
    public ResponseEntity<ApiResponse<Integer>> getUserId(@AuthenticationPrincipal UserDetails userDetails) {
        try {
            Usuario usuario = usuarioRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
            return ResponseEntity.ok(new ApiResponse<>(true, "ID del usuario obtenido correctamente", usuario.getId()));
        } catch (Exception e) {
            return ResponseEntity.status(404).body(
                new ApiResponse<>(false, "No se pudo obtener el ID del usuario", null)
            );
        }
    }
}
