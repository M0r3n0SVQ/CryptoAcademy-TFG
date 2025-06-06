package com.example.cryptoacademy.controller;

import com.example.cryptoacademy.dto.ActualizarNombreCarteraRequestDTO;
import com.example.cryptoacademy.dto.CarteraRequestDTO;
import com.example.cryptoacademy.dto.CarteraResponseDTO;
import com.example.cryptoacademy.persistance.model.Cartera;
import com.example.cryptoacademy.persistance.model.Usuario;
import com.example.cryptoacademy.persistance.repository.CarteraRepository;
import com.example.cryptoacademy.api.response.ApiResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/carteras")
public class CarteraController {

    private static final Logger log = LoggerFactory.getLogger(CarteraController.class);

    private final CarteraRepository carteraRepository;

    @Autowired
    public CarteraController(CarteraRepository carteraRepository) {
        this.carteraRepository = carteraRepository;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CarteraResponseDTO>> crearCartera(
            @Valid @RequestBody CarteraRequestDTO requestDTO,
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de crear cartera sin autenticación.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    new ApiResponse<>(false, "Usuario no autenticado.", null)
            );
        }

        try {
            log.info("Usuario [{}] solicitando crear cartera con nombre: {}", usuarioAutenticado.getEmail(), requestDTO.getNombre());
            Cartera cartera = new Cartera();
            cartera.setUsuario(usuarioAutenticado);
            cartera.setNombre(requestDTO.getNombre());

            if (requestDTO.getSaldo() != null) {
                cartera.setSaldoVirtualEUR(requestDTO.getSaldo());
            }

            Cartera carteraGuardada = carteraRepository.save(cartera);
            log.info("Cartera creada con ID {} para usuario [{}]", carteraGuardada.getIdCartera(), usuarioAutenticado.getEmail());

            return ResponseEntity.status(HttpStatus.CREATED).body(
                    new ApiResponse<>(
                            true,
                            "Cartera creada correctamente",
                            new CarteraResponseDTO(carteraGuardada)
                    )
            );
        } catch (Exception e) {
            log.error("Error interno al crear la cartera para Usuario [{}]: {}", usuarioAutenticado.getEmail(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(
                            false,
                            "Error interno al crear la cartera.",
                            null
                    )
            );
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CarteraResponseDTO>>> obtenerCarterasDelUsuario(
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de obtener carteras sin autenticación.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    new ApiResponse<>(false, "Usuario no autenticado.", null)
            );
        }
        log.info("Usuario [{}] solicitando sus carteras.", usuarioAutenticado.getEmail());
        try {
            List<Cartera> carteras = carteraRepository.findByUsuario(usuarioAutenticado);

            List<CarteraResponseDTO> responseList = carteras.stream()
                    .map(CarteraResponseDTO::new)
                    .collect(Collectors.toList());
            log.info("Encontradas {} carteras para usuario [{}]", responseList.size(), usuarioAutenticado.getEmail());
            return ResponseEntity.ok(
                    new ApiResponse<>(
                            true,
                            "Carteras del usuario obtenidas correctamente",
                            responseList
                    )
            );
        } catch (Exception e) {
            log.error("ERROR INTERNO al obtener carteras para el Usuario [{}]: {}", usuarioAutenticado.getEmail(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(
                            false,
                            "Error interno al obtener las carteras.",
                            null
                    )
            );
        }
    }

    @PutMapping("/{idCartera}")
    public ResponseEntity<ApiResponse<CarteraResponseDTO>> actualizarNombreCartera(
            @PathVariable Long idCartera,
            @Valid @RequestBody ActualizarNombreCarteraRequestDTO requestDTO,
            @AuthenticationPrincipal Usuario usuarioAutenticado) {

        if (usuarioAutenticado == null) {
            log.warn("Intento de actualizar cartera ID {} sin autenticación.", idCartera);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    new ApiResponse<>(false, "Usuario no autenticado.", null)
            );
        }

        log.info("Usuario [{}] solicitando actualizar nombre de cartera ID {} a '{}'",
                usuarioAutenticado.getEmail(), idCartera, requestDTO.getNuevoNombre());

        try {
            Optional<Cartera> carteraOpt = carteraRepository.findById(idCartera);

            if (carteraOpt.isEmpty()) {
                log.warn("Usuario [{}] intentó actualizar cartera ID {} no encontrada.", usuarioAutenticado.getEmail(), idCartera);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                        new ApiResponse<>(false, "Cartera no encontrada.", null)
                );
            }

            Cartera cartera = carteraOpt.get();

            if (!cartera.getUsuario().getId().equals(usuarioAutenticado.getId())) {
                log.warn("Usuario [{}] intentó actualizar cartera ID {} que no le pertenece (dueño: {}).",
                        usuarioAutenticado.getEmail(), idCartera, cartera.getUsuario().getEmail());
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(
                        new ApiResponse<>(false, "No tienes permiso para modificar esta cartera.", null)
                );
            }

            cartera.setNombre(requestDTO.getNuevoNombre());
            Cartera carteraActualizada = carteraRepository.save(cartera);
            log.info("Cartera ID {} actualizada por usuario [{}] con nuevo nombre: {}",
                    idCartera, usuarioAutenticado.getEmail(), carteraActualizada.getNombre());

            return ResponseEntity.ok(
                    new ApiResponse<>(
                            true,
                            "Nombre de la cartera actualizado correctamente.",
                            new CarteraResponseDTO(carteraActualizada)
                    )
            );

        } catch (Exception e) {
            log.error("Error interno al actualizar nombre de cartera ID {} para Usuario [{}]: {}",
                    idCartera, usuarioAutenticado.getEmail(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new ApiResponse<>(
                            false,
                            "Error interno al actualizar el nombre de la cartera.",
                            null
                    )
            );
        }
    }
}
