-- -----------------------------------------------------------------------------------------
-- Script de Configuración Completo para la Base de Datos de CryptoAcademy
-- -----------------------------------------------------------------------------------------
-- Este script realiza las siguientes acciones:
-- 1. Elimina las tablas existentes para una instalación limpia.
-- 2. Crea el esquema completo de tablas con sus relaciones y restricciones.
-- 3. Crea las funciones, procedimientos y triggers necesarios para la lógica de negocio.
-- -----------------------------------------------------------------------------------------
-- Diseñado para MySQL 8.0+
-- -----------------------------------------------------------------------------------------

-- Desactivar temporalmente las comprobaciones de claves foráneas para evitar errores al eliminar tablas
SET FOREIGN_KEY_CHECKS=0;

-- Eliminar objetos de base de datos existentes
DROP TABLE IF EXISTS `audit_log_transacciones`;
DROP TABLE IF EXISTS `transacciones`;
DROP TABLE IF EXISTS `criptos_almacenadas`;
DROP TABLE IF EXISTS `carteras`;
DROP TABLE IF EXISTS `criptomonedas`;
DROP TABLE IF EXISTS `usuarios`;
DROP FUNCTION IF EXISTS `ObtenerSaldoFiatTotalUsuario`;
DROP FUNCTION IF EXISTS `ObtenerValorCriptoTotalUsuario`;
DROP PROCEDURE IF EXISTS `CalcularRankingUsuarios`;
-- Los triggers se eliminan automáticamente cuando se elimina la tabla a la que están asociados.

-- Reactivar las comprobaciones de claves foráneas
SET FOREIGN_KEY_CHECKS=1;

-- -----------------------------------------------------
-- SECCIÓN 1: CREACIÓN DE TABLAS
-- -----------------------------------------------------

-- Table `usuarios`
CREATE TABLE `usuarios` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(255) NULL,
  `email` VARCHAR(255) NOT NULL,
  `hash_contrasena` VARCHAR(255) NOT NULL,
  `fecha_registro` DATETIME(6) NULL,
  `rol` VARCHAR(255) NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `UK_kfsp0s1flr5qjguhrsvtyok2u` (`email` ASC) VISIBLE
);

-- Table `criptomonedas`
CREATE TABLE `criptomonedas` (
  `id_criptomoneda` VARCHAR(100) NOT NULL,
  `simbolo` VARCHAR(255) NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  `precio_actual` DECIMAL(19,4) NULL,
  `imagen` VARCHAR(255) NULL,
  `capitalizacion` DECIMAL(24,2) NULL,
  `volumen_24h` DECIMAL(24,2) NULL,
  `cambio_porcentaje_24h` DOUBLE NULL,
  `fecha_actualizacion` DATETIME(6) NULL,
  PRIMARY KEY (`id_criptomoneda`)
);

-- Table `carteras`
CREATE TABLE `carteras` (
  `id_cartera` BIGINT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(255) NOT NULL,
  `saldo_virtual_eur` DECIMAL(19,4) NOT NULL,
  `fecha_creacion` DATETIME(6) NOT NULL,
  `id_usuario` INT NOT NULL,
  PRIMARY KEY (`id_cartera`),
  INDEX `FK_usuario_cartera` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `FK_usuario_cartera`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);

-- Table `criptos_almacenadas`
CREATE TABLE `criptos_almacenadas` (
  `id_almacenada` BIGINT NOT NULL AUTO_INCREMENT,
  `cantidad` DECIMAL(24,8) NOT NULL,
  `fecha_ultima_actualizacion` DATETIME(6) NOT NULL,
  `id_cartera` BIGINT NOT NULL,
  `id_criptomoneda` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_almacenada`),
  UNIQUE INDEX `UK_cartera_cripto` (`id_cartera` ASC, `id_criptomoneda` ASC) VISIBLE,
  INDEX `FK_cripto_almacenada_idx` (`id_criptomoneda` ASC) VISIBLE,
  CONSTRAINT `FK_cartera_almacenada`
    FOREIGN KEY (`id_cartera`)
    REFERENCES `carteras` (`id_cartera`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_cripto_almacenada`
    FOREIGN KEY (`id_criptomoneda`)
    REFERENCES `criptomonedas` (`id_criptomoneda`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);

-- Table `transacciones`
CREATE TABLE `transacciones` (
  `id_transaccion` BIGINT NOT NULL AUTO_INCREMENT,
  `cantidad_cripto` DECIMAL(24,8) NOT NULL,
  `fecha_transaccion` DATETIME(6) NOT NULL,
  `precio_por_unidad_eur` DECIMAL(19,4) NOT NULL,
  `tipo_transaccion` VARCHAR(10) NOT NULL,
  `valor_total_eur` DECIMAL(19,4) NOT NULL,
  `id_cartera` BIGINT NOT NULL,
  `id_criptomoneda` VARCHAR(100) NOT NULL,
  `id_usuario` INT NOT NULL,
  PRIMARY KEY (`id_transaccion`),
  INDEX `FK_usuario_transaccion_idx` (`id_usuario` ASC) VISIBLE,
  INDEX `FK_cartera_transaccion_idx` (`id_cartera` ASC) VISIBLE,
  INDEX `FK_cripto_transaccion_idx` (`id_criptomoneda` ASC) VISIBLE,
  CONSTRAINT `FK_usuario_transaccion`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_cartera_transaccion`
    FOREIGN KEY (`id_cartera`)
    REFERENCES `carteras` (`id_cartera`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_cripto_transaccion`
    FOREIGN KEY (`id_criptomoneda`)
    REFERENCES `criptomonedas` (`id_criptomoneda`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- Table `audit_log_transacciones`
CREATE TABLE `audit_log_transacciones` (
    `id_audit` INT AUTO_INCREMENT PRIMARY KEY,
    `id_transaccion_original` BIGINT, 
    `tipo_operacion_auditada` VARCHAR(10) DEFAULT 'INSERT',
    `id_usuario_transaccion` INT,
    `id_cartera_transaccion` BIGINT, 
    `id_criptomoneda_transaccion` VARCHAR(100),
    `tipo_transaccion_original` VARCHAR(10),
    `cantidad_cripto_transaccion` DECIMAL(24,8),
    `precio_por_unidad_eur_transaccion` DECIMAL(19,4),
    `valor_total_eur_transaccion` DECIMAL(19,4),
    `fecha_transaccion_original` DATETIME(6),
    `fecha_audit` DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    `usuario_db_accion` VARCHAR(255),
    CONSTRAINT `fk_audit_transaccion_original` 
        FOREIGN KEY (`id_transaccion_original`) 
        REFERENCES `transacciones`(`id_transaccion`) 
        ON DELETE SET NULL
);

-- -----------------------------------------------------
-- SECCIÓN 2: CREACIÓN DE FUNCIONES
-- -----------------------------------------------------

DELIMITER //

CREATE FUNCTION `ObtenerSaldoFiatTotalUsuario`(p_id_usuario INT)
RETURNS DECIMAL(19,4)
READS SQL DATA
BEGIN
    DECLARE v_saldo_total DECIMAL(19,4);

    SELECT COALESCE(SUM(saldo_virtual_eur), 0.00)
    INTO v_saldo_total
    FROM carteras c
    WHERE c.id_usuario = p_id_usuario;

    RETURN v_saldo_total;
END//

DELIMITER ;


DELIMITER //

CREATE FUNCTION `ObtenerValorCriptoTotalUsuario`(p_id_usuario INT)
RETURNS DECIMAL(19,4)
READS SQL DATA
BEGIN
    DECLARE v_valor_cripto_total DECIMAL(19,4);

    SELECT COALESCE(SUM(cs.cantidad * cm.precio_actual), 0.00)
    INTO v_valor_cripto_total
    FROM carteras c
    JOIN criptos_almacenadas cs ON c.id_cartera = cs.id_cartera
    JOIN criptomonedas cm ON cs.id_criptomoneda = cm.id_criptomoneda
    WHERE c.id_usuario = p_id_usuario
      AND cs.cantidad IS NOT NULL
      AND cm.precio_actual IS NOT NULL;

    RETURN v_valor_cripto_total;
END//

DELIMITER ;


-- -----------------------------------------------------
-- SECCIÓN 3: CREACIÓN DE PROCEDIMIENTOS ALMACENADOS
-- -----------------------------------------------------

DELIMITER //

CREATE PROCEDURE `CalcularRankingUsuarios`(IN limite_ranking INT)
BEGIN
    SELECT
        posicion,
        id_usuario,
        nombre_usuario,
        email_para_ofuscar_en_java,
        valor_total_portfolio_eur
    FROM (
        SELECT
            ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(COALESCE(c.saldo_virtual_eur, 0) + COALESCE(valor_criptos_cartera.total_valor_criptos, 0)), 0) DESC) AS posicion,
            u.id_usuario,
            COALESCE(u.nombre, 'Usuario Anónimo') AS nombre_usuario,
            u.email AS email_para_ofuscar_en_java,
            COALESCE(SUM(COALESCE(c.saldo_virtual_eur, 0) + COALESCE(valor_criptos_cartera.total_valor_criptos, 0)), 0) AS valor_total_portfolio_eur
        FROM
            usuarios u
        LEFT JOIN
            carteras c ON u.id_usuario = c.id_usuario
        LEFT JOIN (
            SELECT
                ca.id_cartera,
                SUM(ca.cantidad * cm.precio_actual) AS total_valor_criptos
            FROM
                criptos_almacenadas ca
            JOIN
                criptomonedas cm ON ca.id_criptomoneda = cm.id_criptomoneda
            WHERE
                cm.precio_actual IS NOT NULL AND ca.cantidad IS NOT NULL
            GROUP BY
                ca.id_cartera
        ) AS valor_criptos_cartera ON c.id_cartera = valor_criptos_cartera.id_cartera
        GROUP BY
            u.id_usuario, u.nombre, u.email
    ) AS ranking_calculado
    ORDER BY
        posicion ASC
    LIMIT limite_ranking;
END//

DELIMITER ;


-- -----------------------------------------------------
-- SECCIÓN 4: CREACIÓN DE TRIGGERS
-- -----------------------------------------------------

DELIMITER //

CREATE TRIGGER `TRG_Audit_Transacciones_Insert`
AFTER INSERT ON `transacciones`
FOR EACH ROW
BEGIN
    INSERT INTO `audit_log_transacciones` (
        id_transaccion_original,
        tipo_operacion_auditada,
        id_usuario_transaccion,
        id_cartera_transaccion,
        id_criptomoneda_transaccion,
        tipo_transaccion_original,
        cantidad_cripto_transaccion,
        precio_por_unidad_eur_transaccion,
        valor_total_eur_transaccion,
        fecha_transaccion_original,
        usuario_db_accion
    )
    VALUES (
        NEW.id_transaccion,
        'INSERT',
        NEW.id_usuario,
        NEW.id_cartera,
        NEW.id_criptomoneda,
        NEW.tipo_transaccion,
        NEW.cantidad_cripto,
        NEW.precio_por_unidad_eur,
        NEW.valor_total_eur,
        NEW.fecha_transaccion,
        USER()
    );
END//

DELIMITER ;
