package com.example.cryptoacademy.controller;

import com.example.cryptoacademy.api.response.ApiResponse;
import com.example.cryptoacademy.dto.ActualizarNombreRequestDTO;
import com.example.cryptoacademy.dto.UsuarioDetallesResponseDTO;
import com.example.cryptoacademy.security.auth.dto.LoginRequestDTO;
import com.example.cryptoacademy.security.auth.dto.AuthResponseDTO;
import com.example.cryptoacademy.dto.UsuarioRequestDTO;
import com.example.cryptoacademy.persistance.model.Usuario;
import com.example.cryptoacademy.persistance.repository.UsuarioRepository;
import com.example.cryptoacademy.security.auth.service.JWTServiceI;
import com.example.cryptoacademy.service.TradingServiceI;

import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private static final Logger log = LoggerFactory.getLogger(UsuarioController.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private JWTServiceI jwtService;

    @Autowired
    private TradingServiceI tradingService;

    @PostMapping("/registro")
    public ResponseEntity<ApiResponse<String>> crearUsuario(@RequestBody UsuarioRequestDTO dto) {
        try {
            Optional<Usuario> existente = usuarioRepository.findByEmail(dto.getEmail());
            if (existente.isPresent()) {
                return ResponseEntity.badRequest().body(
                        new ApiResponse<>(false, "Ya existe un usuario con este email", null)
                );
            }

            Usuario usuario = new Usuario();
            usuario.setNombre(dto.getNombre());
            usuario.setEmail(dto.getEmail());
            usuario.setHashContrasena(new BCryptPasswordEncoder().encode(dto.getHashContrasena()));

            usuarioRepository.save(usuario);

            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Usuario creado correctamente", null)
            );

        } catch (Exception e) {
            log.error("Error al registrar el usuario {}: {}", dto.getEmail(), e.getMessage(), e); // Log del error
            return ResponseEntity.internalServerError().body(
                    new ApiResponse<>(false, "Error al registrar el usuario: " + e.getMessage(), null)
            );
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponseDTO>> login(@RequestBody LoginRequestDTO request) {
        try {
            Optional<Usuario> usuarioOptional = usuarioRepository.findByEmail(request.getEmail());

            if (usuarioOptional.isPresent()) {
                Usuario usuario = usuarioOptional.get();

                if (new BCryptPasswordEncoder().matches(request.getPassword(), usuario.getHashContrasena())) {
                    String token = jwtService.getToken(usuario);
                    return ResponseEntity.ok(
                            new ApiResponse<>(true, "Login exitoso", new AuthResponseDTO(token))
                    );
                } else {
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                            new ApiResponse<>(false, "Contraseña incorrecta", null)
                    );
                }
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                        new ApiResponse<>(false, "Usuario no encontrado", null)
                );
            }

        } catch (Exception e) {
            log.error("Error en el login para el email {}: {}", request.getEmail(), e.getMessage(), e);
            return ResponseEntity.internalServerError().body(
                    new ApiResponse<>(false, "Error en el login: " + e.getMessage(), null)
            );
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Iterable<Usuario>>> obtenerUsuarios() {
        try {
            Iterable<Usuario> usuarios = usuarioRepository.findAll();
            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Usuarios obtenidos correctamente", usuarios)
            );
        } catch (Exception e) {
            log.error("Error al obtener usuarios: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().body(
                    new ApiResponse<>(false, "Error al obtener usuarios: " + e.getMessage(), null)
            );
        }
    }

    @GetMapping("/me/saldo-fiat-total")
    public ResponseEntity<ApiResponse<BigDecimal>> getMiSaldoFiatTotal(
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de acceso a /me/saldo-fiat-total sin autenticación.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "Usuario no autenticado. Se requiere iniciar sesión.", null));
        }

        try {
            Integer idUsuario = usuarioAutenticado.getId();
            log.info("Solicitando saldo fiat total para el usuario autenticado ID: {}", idUsuario);
            BigDecimal saldoTotal = tradingService.getSaldoFiatTotalPorUsuario(idUsuario);
            log.info("Saldo fiat total para el usuario ID {}: {}", idUsuario, saldoTotal);
            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Saldo fiat total del usuario obtenido correctamente.", saldoTotal)
            );
        } catch (Exception e) {
            log.error("Error al obtener saldo fiat total para el usuario autenticado ID {}: {}",
                    usuarioAutenticado.getId(),
                    e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Error interno al obtener el saldo fiat total del usuario.", null));
        }
    }

    @GetMapping("/me/details")
    public ResponseEntity<ApiResponse<UsuarioDetallesResponseDTO>> getMyUserDetails(
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de acceso a /me/details sin un principal autenticado.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "Usuario no autenticado. Se requiere iniciar sesión.", null));
        }

        try {
            log.info("Solicitando detalles para el usuario autenticado ID: {}", usuarioAutenticado.getId());

            UsuarioDetallesResponseDTO userDetailsDto = new UsuarioDetallesResponseDTO(
                    usuarioAutenticado.getId(),
                    usuarioAutenticado.getNombre(),
                    usuarioAutenticado.getEmail(),
                    usuarioAutenticado.getFechaRegistro(),
                    usuarioAutenticado.getRol().name()
            );

            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Detalles del usuario obtenidos correctamente.", userDetailsDto)
            );
        } catch (Exception e) {
            log.error("Error al obtener detalles para el usuario autenticado ID {}: {}",
                    (usuarioAutenticado != null ? usuarioAutenticado.getId() : "desconocido"),
                    e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Error interno al obtener los detalles del usuario.", null));
        }
    }
    @GetMapping("/me/valorcriptototal")
    public ResponseEntity<ApiResponse<BigDecimal>> getMiValorCriptoTotal(
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de acceso a /me/valor-cripto-total sin autenticación.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "Usuario no autenticado. Se requiere iniciar sesión.", null));
        }

        try {
            Integer idUsuario = usuarioAutenticado.getId();
            log.info("Solicitando valor cripto total para el usuario autenticado ID: {}", idUsuario);
            BigDecimal valorCriptoTotal = tradingService.getValorCriptoTotalPorUsuario(idUsuario);
            log.info("Valor cripto total para el usuario ID {}: {}", idUsuario, valorCriptoTotal);
            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Valor cripto total del usuario obtenido correctamente.", valorCriptoTotal)
            );
        } catch (Exception e) {
            log.error("Error al obtener valor cripto total para el usuario autenticado ID {}: {}",
                    (usuarioAutenticado.getId()),
                    e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Error interno al obtener el valor cripto total del usuario.", null));
        }
    }
    @PutMapping("/me/nombre")
    public ResponseEntity<ApiResponse<UsuarioDetallesResponseDTO>> updateMyNombre(
            @AuthenticationPrincipal Usuario usuarioAutenticado,
            @Valid @RequestBody ActualizarNombreRequestDTO actualizarNombreRequestDTO) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de acceso a /me/nombre (PUT) sin un principal autenticado.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "Usuario no autenticado. Se requiere iniciar sesión.", null));
        }

        try {
            log.info("Usuario ID {} solicitando actualizar nombre a: {}", usuarioAutenticado.getId(), actualizarNombreRequestDTO.getNuevoNombre());

            usuarioAutenticado.setNombre(actualizarNombreRequestDTO.getNuevoNombre());

            Usuario usuarioActualizado = usuarioRepository.save(usuarioAutenticado);
            log.info("Nombre actualizado para el usuario ID {}. Nuevo nombre: {}", usuarioActualizado.getId(), usuarioActualizado.getNombre());

            UsuarioDetallesResponseDTO userDetailsDto = new UsuarioDetallesResponseDTO(
                    usuarioActualizado.getId(),
                    usuarioActualizado.getNombre(),
                    usuarioActualizado.getEmail(),
                    usuarioActualizado.getFechaRegistro(),
                    usuarioActualizado.getRol().name()
            );

            return ResponseEntity.ok(
                    new ApiResponse<>(true, "Nombre actualizado correctamente.", userDetailsDto)
            );

        } catch (Exception e) {
            log.error("Error al actualizar el nombre para el usuario ID {}: {}",
                    usuarioAutenticado.getId(),
                    e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Error interno al actualizar el nombre del usuario.", null));
        }
    }
}

