package com.example.cryptoacademy.service;

import com.example.cryptoacademy.dto.PortfolioItemDTO;
import com.example.cryptoacademy.dto.PortfolioResponseDTO;
import com.example.cryptoacademy.dto.TransaccionResponseDTO;
import com.example.cryptoacademy.exception.CantidadInsuficienteException;
import com.example.cryptoacademy.exception.RecursoNoEncontradoException;
import com.example.cryptoacademy.exception.SaldoInsuficienteException;
import com.example.cryptoacademy.persistance.model.*;
import com.example.cryptoacademy.persistance.repository.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class TradingServiceImpl implements TradingServiceI {

    private static final Logger log = LoggerFactory.getLogger(TradingServiceImpl.class);

    private final UsuarioRepository usuarioRepository;
    private final CarteraRepository carteraRepository;
    private final CriptomonedaRepository criptomonedaRepository;
    private final CriptosAlmacenadasRepository criptosAlmacenadasRepository;
    private final TransaccionRepository transaccionRepository;

    @PersistenceContext
    private EntityManager entityManager;

    private static final int MONETARY_SCALE = 4;
    private static final int CRYPTO_QUANTITY_SCALE = 8;
    private static final int PORTFOLIO_VALUE_SCALE = 2;
    private static final DateTimeFormatter API_DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;


    public TradingServiceImpl(UsuarioRepository usuarioRepository,
                              CarteraRepository carteraRepository,
                              CriptomonedaRepository criptomonedaRepository,
                              CriptosAlmacenadasRepository criptosAlmacenadasRepository,
                              TransaccionRepository transaccionRepository
    ) {
        this.usuarioRepository = usuarioRepository;
        this.carteraRepository = carteraRepository;
        this.criptomonedaRepository = criptomonedaRepository;
        this.criptosAlmacenadasRepository = criptosAlmacenadasRepository;
        this.transaccionRepository = transaccionRepository;
    }

    @Override
    @Transactional
    public Transaccion comprarCripto(Integer idUsuario, Long idCartera, String idCriptomoneda, BigDecimal cantidadComprar)
            throws RecursoNoEncontradoException, SaldoInsuficienteException, IllegalArgumentException {


        if (cantidadComprar == null || cantidadComprar.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("La cantidad a comprar debe ser positiva y mayor que cero.");
        }
        cantidadComprar = cantidadComprar.setScale(CRYPTO_QUANTITY_SCALE, RoundingMode.HALF_UP);

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con ID: " + idUsuario));

        Cartera cartera = carteraRepository.findByIdCarteraAndUsuario(idCartera, usuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cartera no encontrada con ID: " + idCartera + " para el usuario " + usuario.getEmail()));

        Criptomoneda criptomoneda = criptomonedaRepository.findById(idCriptomoneda)
                .orElseThrow(() -> new RecursoNoEncontradoException("Criptomoneda no encontrada con ID: " + idCriptomoneda + ". No se puede operar."));

        BigDecimal precioActualCripto = criptomoneda.getPrecio_actual();
        if (precioActualCripto == null || precioActualCripto.compareTo(BigDecimal.ZERO) <= 0) {
            log.error("Precio inválido o no disponible para la criptomoneda {} (ID: {}) en la base de datos. Precio: {}",
                    criptomoneda.getNombre(), idCriptomoneda, precioActualCripto);
            throw new IllegalStateException("El precio para la criptomoneda " + criptomoneda.getNombre() + " no está disponible o es inválido. No se puede realizar la transacción.");
        }
        precioActualCripto = precioActualCripto.setScale(MONETARY_SCALE, RoundingMode.HALF_UP);

        BigDecimal costoTotalEUR = cantidadComprar.multiply(precioActualCripto).setScale(MONETARY_SCALE, RoundingMode.HALF_UP);

        BigDecimal saldoActualCartera = cartera.getSaldoVirtualEUR();
        if (saldoActualCartera == null || saldoActualCartera.compareTo(costoTotalEUR) < 0) {
            throw new SaldoInsuficienteException("Saldo insuficiente en la cartera. Saldo disponible: " + saldoActualCartera + ", costo requerido: " + costoTotalEUR);
        }

        cartera.setSaldoVirtualEUR(saldoActualCartera.subtract(costoTotalEUR));
        carteraRepository.save(cartera);

        Optional<CriptosAlmacenadas> tenenciaOpt = criptosAlmacenadasRepository.findByCarteraAndCriptomoneda(cartera, criptomoneda);
        CriptosAlmacenadas tenencia;
        if (tenenciaOpt.isPresent()) {
            tenencia = tenenciaOpt.get();
            BigDecimal nuevaCantidad = tenencia.getCantidad().add(cantidadComprar);
            tenencia.setCantidad(nuevaCantidad.setScale(CRYPTO_QUANTITY_SCALE, RoundingMode.HALF_UP));
        } else {
            tenencia = new CriptosAlmacenadas(cartera, criptomoneda, cantidadComprar.setScale(CRYPTO_QUANTITY_SCALE, RoundingMode.HALF_UP));
        }
        criptosAlmacenadasRepository.save(tenencia);

        Transaccion transaccion = new Transaccion(
                usuario,
                cartera,
                criptomoneda,
                TipoTransaccion.COMPRA,
                cantidadComprar,
                precioActualCripto
        );

        return transaccionRepository.save(transaccion);
    }

    @Override
    @Transactional
    public Transaccion venderCripto(Integer idUsuario, Long idCartera, String idCriptomoneda, BigDecimal cantidadVender)
            throws RecursoNoEncontradoException, CantidadInsuficienteException, IllegalArgumentException {

        if (cantidadVender == null || cantidadVender.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("La cantidad a vender debe ser positiva y mayor que cero.");
        }
        cantidadVender = cantidadVender.setScale(CRYPTO_QUANTITY_SCALE, RoundingMode.HALF_UP);

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con ID: " + idUsuario));

        Cartera cartera = carteraRepository.findByIdCarteraAndUsuario(idCartera, usuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cartera no encontrada con ID: " + idCartera + " para el usuario " + usuario.getEmail()));

        Criptomoneda criptomoneda = criptomonedaRepository.findById(idCriptomoneda)
                .orElseThrow(() -> new RecursoNoEncontradoException("Criptomoneda no encontrada con ID: " + idCriptomoneda + ". No se puede operar."));

        CriptosAlmacenadas tenencia = criptosAlmacenadasRepository.findByCarteraAndCriptomoneda(cartera, criptomoneda)
                .orElseThrow(() -> new RecursoNoEncontradoException("No posee " + criptomoneda.getNombre() + " en la cartera especificada."));

        if (tenencia.getCantidad() == null || tenencia.getCantidad().compareTo(cantidadVender) < 0) {

            throw new CantidadInsuficienteException("Cantidad insuficiente de " + criptomoneda.getNombre() + " para vender. Posee: " + tenencia.getCantidad());
        }

        BigDecimal precioActualCripto = criptomoneda.getPrecio_actual();
        if (precioActualCripto == null || precioActualCripto.compareTo(BigDecimal.ZERO) <= 0) {
            log.error("Precio inválido o no disponible para la criptomoneda {} (ID: {}) al intentar vender. Precio: {}",
                    criptomoneda.getNombre(), idCriptomoneda, precioActualCripto);
            throw new IllegalStateException("El precio para la criptomoneda " + criptomoneda.getNombre() + " no está disponible o es inválido. No se puede realizar la transacción.");
        }
        precioActualCripto = precioActualCripto.setScale(MONETARY_SCALE, RoundingMode.HALF_UP);

        BigDecimal ingresoTotalEUR = cantidadVender.multiply(precioActualCripto).setScale(MONETARY_SCALE, RoundingMode.HALF_UP);

        BigDecimal nuevaCantidadTenencia = tenencia.getCantidad().subtract(cantidadVender);
        tenencia.setCantidad(nuevaCantidadTenencia.setScale(CRYPTO_QUANTITY_SCALE, RoundingMode.HALF_UP));

        criptosAlmacenadasRepository.save(tenencia);

        BigDecimal saldoActualCartera = cartera.getSaldoVirtualEUR() != null ? cartera.getSaldoVirtualEUR() : BigDecimal.ZERO;
        cartera.setSaldoVirtualEUR(saldoActualCartera.add(ingresoTotalEUR));
        carteraRepository.save(cartera);

        Transaccion transaccion = new Transaccion(
                usuario,
                cartera,
                criptomoneda,
                TipoTransaccion.VENTA,
                cantidadVender,
                precioActualCripto
        );

        return transaccionRepository.save(transaccion);
    }

    @Override
    @Transactional(readOnly = true)
    public PortfolioResponseDTO obtenerPortfolio(Integer idUsuario, Long idCartera)
            throws RecursoNoEncontradoException {

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con ID: " + idUsuario));

        Cartera cartera = carteraRepository.findByIdCarteraAndUsuario(idCartera, usuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cartera no encontrada con ID: " + idCartera + " para el usuario " + usuario.getEmail()));

        List<CriptosAlmacenadas> tenencias = criptosAlmacenadasRepository.findByCartera(cartera);

        List<PortfolioItemDTO> itemsDTO = new ArrayList<>();
        BigDecimal valorTotalCriptosEnEUR = BigDecimal.ZERO.setScale(PORTFOLIO_VALUE_SCALE, RoundingMode.HALF_UP);

        for (CriptosAlmacenadas tenencia : tenencias) {
            Criptomoneda cripto = tenencia.getCriptomoneda();
            BigDecimal precioActual = cripto.getPrecio_actual() != null ? cripto.getPrecio_actual().setScale(MONETARY_SCALE, RoundingMode.HALF_UP) : BigDecimal.ZERO;
            BigDecimal cantidad = tenencia.getCantidad().setScale(CRYPTO_QUANTITY_SCALE, RoundingMode.HALF_UP);
            BigDecimal valorTenenciaActual = cantidad.multiply(precioActual).setScale(PORTFOLIO_VALUE_SCALE, RoundingMode.HALF_UP);

            PortfolioItemDTO itemDTO = PortfolioItemDTO.builder()
                    .idCriptomoneda(cripto.getId_Criptomoneda())
                    .nombreCriptomoneda(cripto.getNombre())
                    .simboloCriptomoneda(cripto.getSimbolo())
                    .imagenUrl(cripto.getImagen())
                    .cantidadPoseida(cantidad)
                    .precioActualPorUnidadEUR(precioActual)
                    .valorTotalTenenciaEUR(valorTenenciaActual)
                    .cambioPorcentaje24h(cripto.getCambioPorcentaje24h())
                    .build();
            itemsDTO.add(itemDTO);
            valorTotalCriptosEnEUR = valorTotalCriptosEnEUR.add(valorTenenciaActual);
        }

        BigDecimal saldoFiat = cartera.getSaldoVirtualEUR() != null ? cartera.getSaldoVirtualEUR().setScale(PORTFOLIO_VALUE_SCALE, RoundingMode.HALF_UP) : BigDecimal.ZERO.setScale(PORTFOLIO_VALUE_SCALE, RoundingMode.HALF_UP);
        BigDecimal valorTotalPortfolio = saldoFiat.add(valorTotalCriptosEnEUR);

        return PortfolioResponseDTO.builder()
                .idCartera(cartera.getIdCartera())
                .nombreCartera(cartera.getNombre())
                .saldoVirtualEUR(saldoFiat)
                .items(itemsDTO)
                .valorTotalCriptosEUR(valorTotalCriptosEnEUR)
                .valorTotalPortfolioEUR(valorTotalPortfolio)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<TransaccionResponseDTO> obtenerHistorialTransaccionesUsuario(
            Integer idUsuario,
            TipoTransaccion tipoTransaccion,
            Pageable pageable)
            throws RecursoNoEncontradoException {

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con ID: " + idUsuario));

        Page<Transaccion> transaccionesPage;
        if (tipoTransaccion != null) {
            transaccionesPage = transaccionRepository.findByUsuarioAndTipoTransaccionOrderByFechaTransaccionDesc(
                    usuario, tipoTransaccion, pageable);
        } else {
            transaccionesPage = transaccionRepository.findByUsuarioOrderByFechaTransaccionDesc(usuario, pageable);
        }

        return transaccionesPage.map(this::mapTransaccionToResponseDTO);
    }

    private TransaccionResponseDTO mapTransaccionToResponseDTO(Transaccion transaccion) {
        if (transaccion == null) return null;
        return TransaccionResponseDTO.builder()
                .idTransaccion(transaccion.getIdTransaccion())
                .usuarioEmail(transaccion.getUsuario().getEmail())
                .idCartera(transaccion.getCartera().getIdCartera())
                .idCriptomoneda(transaccion.getCriptomoneda().getId_Criptomoneda())
                .simboloCriptomoneda(transaccion.getCriptomoneda().getSimbolo())
                .nombreCriptomoneda(transaccion.getCriptomoneda().getNombre())
                .tipoTransaccion(transaccion.getTipoTransaccion())
                .cantidadCripto(transaccion.getCantidadCripto())
                .precioPorUnidadEUR(transaccion.getPrecioPorUnidadeEUR())
                .valorTotalEUR(transaccion.getValorTotalEUR())
                .fechaTransaccion(transaccion.getFechaTransaccion() != null ?
                        transaccion.getFechaTransaccion().format(API_DATE_TIME_FORMATTER) : null)
                .build();
    }

    @Transactional(readOnly = true) // Adecuado para una función que solo lee datos
    public BigDecimal getSaldoFiatTotalPorUsuario(Integer idUsuario) {
        if (idUsuario == null) {
            log.warn("ID de usuario nulo proporcionado a getSaldoFiatTotalPorUsuario.");
            return BigDecimal.ZERO;
        }
        log.debug("Obteniendo saldo fiat total para el usuario ID: {}", idUsuario);

        Query query = entityManager.createNativeQuery("SELECT ObtenerSaldoFiatTotalUsuario(?1)");
        query.setParameter(1, idUsuario);

        Object resultado;
        try {
            resultado = query.getSingleResult();
        } catch (NoResultException e) {
            log.warn("No se encontró resultado para ObtenerSaldoFiatTotalUsuario con idUsuario: {}. Asumiendo saldo cero.", idUsuario);
            return BigDecimal.ZERO;
        } catch (Exception e) {
            log.error("Error al ejecutar la función ObtenerSaldoFiatTotalUsuario para idUsuario: {}", idUsuario, e);
            throw new RuntimeException("Error al obtener saldo fiat total del usuario.", e);
        }


        if (resultado instanceof BigDecimal) {
            return (BigDecimal) resultado;
        } else if (resultado instanceof Number) {
            return new BigDecimal(resultado.toString());
        } else if (resultado == null) {
            log.warn("La función ObtenerSaldoFiatTotalUsuario devolvió null para idUsuario: {}. Asumiendo saldo cero.", idUsuario);
            return BigDecimal.ZERO;
        } else {
            log.error("Tipo de resultado inesperado de la función ObtenerSaldoFiatTotalUsuario: {} para idUsuario: {}", resultado.getClass().getName(), idUsuario);
            throw new RuntimeException("Tipo de resultado inesperado al obtener saldo fiat total del usuario.");
        }
    }
    @Transactional(readOnly = true)
    @Override
    public BigDecimal getValorCriptoTotalPorUsuario(Integer idUsuario) {
        if (idUsuario == null) {
            log.warn("ID de usuario nulo proporcionado a getValorCriptoTotalPorUsuario.");
            return BigDecimal.ZERO;
        }
        log.debug("Obteniendo valor cripto total para el usuario ID: {}", idUsuario);

        Query query = entityManager.createNativeQuery("SELECT ObtenerValorCriptoTotalUsuario(?1)");
        query.setParameter(1, idUsuario);

        Object resultado = null;
        try {
            resultado = query.getSingleResult();
        } catch (NoResultException e) {
            log.warn("No se encontró resultado para ObtenerValorCriptoTotalUsuario con idUsuario: {}. Asumiendo valor cero.", idUsuario);
            return BigDecimal.ZERO;
        } catch (Exception e) {
            log.error("Error al ejecutar la función ObtenerValorCriptoTotalUsuario para idUsuario: {}", idUsuario, e);
            throw new RuntimeException("Error al obtener valor cripto total del usuario.", e);
        }

        if (resultado instanceof BigDecimal) {
            return (BigDecimal) resultado;
        } else if (resultado instanceof Number) {
            return new BigDecimal(((Number) resultado).toString());
        } else if (resultado == null) {
            log.warn("La función ObtenerValorCriptoTotalUsuario devolvió null para idUsuario: {}. Asumiendo valor cero.", idUsuario);
            return BigDecimal.ZERO;
        } else {
            log.error("Tipo de resultado inesperado de la función ObtenerValorCriptoTotalUsuario: {} para idUsuario: {}", resultado.getClass().getName(), idUsuario);
            throw new RuntimeException("Tipo de resultado inesperado al obtener valor cripto total del usuario.");
        }
    }
}
