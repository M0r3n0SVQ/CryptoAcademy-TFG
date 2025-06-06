package com.example.cryptoacademy.security.auth.service;

import com.example.cryptoacademy.persistance.model.Cartera;
import com.example.cryptoacademy.persistance.model.Usuario;
import com.example.cryptoacademy.persistance.model.RolUsuario;
import com.example.cryptoacademy.persistance.repository.CarteraRepository;
import com.example.cryptoacademy.persistance.repository.UsuarioRepository;
import com.example.cryptoacademy.security.auth.dto.AuthResponseDTO;
import com.example.cryptoacademy.security.auth.dto.LoginRequestDTO;
import com.example.cryptoacademy.security.auth.dto.RegisterRequestDTO;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService implements AuthServiceI {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private CarteraRepository carteraRepository;

    @Autowired
    private JWTServiceImpl jwtService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Override
    public AuthResponseDTO login(LoginRequestDTO request) {
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));
        
        Usuario usuario = usuarioRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        return new AuthResponseDTO(jwtService.getToken(usuario));
    }

    @Override
    public AuthResponseDTO register(RegisterRequestDTO request) {
        RolUsuario rol = RolUsuario.USER;

        Usuario usuario = new Usuario();
        usuario.setNombre(request.getNombre());
        usuario.setHashContrasena(passwordEncoder.encode(request.getPassword()));
        usuario.setEmail(request.getEmail());
        usuario.setRol(rol);

        Usuario usuarioGuardado = usuarioRepository.save(usuario);

        Cartera cartera = new Cartera();
        cartera.setUsuario(usuarioGuardado);
        cartera.setNombre("Cartera Predeterminada");

        cartera.setFechaCreacion(LocalDateTime.now());

        carteraRepository.save(cartera);

        String token = jwtService.getToken(usuarioGuardado);
        return new AuthResponseDTO(token);
    }
}
