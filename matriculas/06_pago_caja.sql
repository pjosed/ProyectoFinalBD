-- ============================================================
-- 06_pago_caja.sql — MÓDULO DE PAGO POR CAJA
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar DESPUÉS de 05_tablas_estudiantes.sql
-- ============================================================
-- NOTAS DE ESTANDARIZACIÓN (v2):
--   • La tabla `estudiante` viene del script 05: no tiene id_persona,
--     id_programa ni codigo. Las vistas usan los campos reales:
--     e.nombres, e.apellidos, e.num_doc.
--   • cuenta_corriente del script 05 solo tiene id_cuenta, id_estudiante,
--     id_periodo y fecha_cre. Se agregan las columnas faltantes con
--     ALTER TABLE IF NOT EXISTS para no romper si ya existe la tabla.
--   • pago y movimiento_cuenta del script 05 se reemplazan con DROP +
--     CREATE para usar el esquema completo del módulo (con tipo, valor,
--     metodo_pago, etc.).
--   • volante_matricula del script 05 se reemplaza con la versión que
--     referencia cuenta_corriente.
--   • Los INSERT a codigo_detalle incluyen la columna `nombre`
--     (requerida según 02_tablas_negocio.sql).
-- ============================================================

USE matriculas_uni;

-- ────────────────────────────────────────────────────────────
-- PASO 1: Ampliar cuenta_corriente con columnas de totales
-- Se usa un SP temporal para verificar si cada columna existe
-- antes de agregarla (compatible con MySQL 5.7 y 8.x).
-- ────────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS _tmp_agregar_columnas_cuenta;

DELIMITER $$

CREATE PROCEDURE _tmp_agregar_columnas_cuenta()
BEGIN
    -- total_cobros
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'cuenta_corriente'
          AND COLUMN_NAME  = 'total_cobros'
    ) THEN
        ALTER TABLE cuenta_corriente
            ADD COLUMN total_cobros DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER id_periodo;
    END IF;

    -- total_pagos
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'cuenta_corriente'
          AND COLUMN_NAME  = 'total_pagos'
    ) THEN
        ALTER TABLE cuenta_corriente
            ADD COLUMN total_pagos DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER total_cobros;
    END IF;

    -- saldo_pendiente
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'cuenta_corriente'
          AND COLUMN_NAME  = 'saldo_pendiente'
    ) THEN
        ALTER TABLE cuenta_corriente
            ADD COLUMN saldo_pendiente DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER total_pagos;
    END IF;

    -- fecha_creacion
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'cuenta_corriente'
          AND COLUMN_NAME  = 'fecha_creacion'
    ) THEN
        ALTER TABLE cuenta_corriente
            ADD COLUMN fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER saldo_pendiente;
    END IF;
END$$

DELIMITER ;

CALL _tmp_agregar_columnas_cuenta();
DROP PROCEDURE IF EXISTS _tmp_agregar_columnas_cuenta;

-- ────────────────────────────────────────────────────────────
-- PASO 2: Reemplazar tabla pago con esquema completo
-- (el script 05 tenía: medio, ref, monto; aquí usamos:
--  metodo_pago, valor, fecha_pago, id_codigo, observacion)
-- ────────────────────────────────────────────────────────────
SET FOREIGN_KEY_CHECKS = 0;

-- tablas hijas primero
DROP TABLE IF EXISTS pago_pse;
DROP TABLE IF EXISTS movimiento_cuenta;
DROP TABLE IF EXISTS volante_asignatura;
DROP TABLE IF EXISTS volante_matricula;

-- luego tabla padre
DROP TABLE IF EXISTS pago;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE pago (
    id_pago         INT             NOT NULL AUTO_INCREMENT,
    id_cuenta       INT             NOT NULL,
    id_codigo       INT             NOT NULL,   -- FK a codigo_detalle (grupo PAGO)
    valor           DECIMAL(12,2)   NOT NULL,
    metodo_pago     ENUM('EFECTIVO','PSE','TRANSFERENCIA','TARJETA') NOT NULL,
    fecha_pago      DATE            NOT NULL,
    observacion     VARCHAR(255),
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_pago          PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_cuenta   FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_pago_codigo   FOREIGN KEY (id_codigo) REFERENCES codigo_detalle(id_codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- PASO 3: Reemplazar movimiento_cuenta con esquema completo
-- (el script 05 tenía: monto, descrip; aquí usamos:
--  tipo ENUM, valor, descripcion, id_pago)
-- ────────────────────────────────────────────────────────────
CREATE TABLE movimiento_cuenta (
    id_movimiento   INT             NOT NULL AUTO_INCREMENT,
    id_cuenta       INT             NOT NULL,
    id_codigo       INT             NOT NULL,
    id_pago         INT             DEFAULT NULL,   -- NULL si es cobro
    tipo            ENUM('COBRO','PAGO') NOT NULL,
    valor           DECIMAL(12,2)   NOT NULL,
    descripcion     VARCHAR(255),
    fecha           DATE            NOT NULL,
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_movimiento        PRIMARY KEY (id_movimiento),
    CONSTRAINT fk_mov_cuenta        FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_mov_codigo        FOREIGN KEY (id_codigo) REFERENCES codigo_detalle(id_codigo),
    CONSTRAINT fk_mov_pago          FOREIGN KEY (id_pago)   REFERENCES pago(id_pago)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- PASO 4: Reemplazar volante_matricula con esquema basado en cuenta_corriente
-- ────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS volante_asignatura;
DROP TABLE IF EXISTS volante_matricula;

CREATE TABLE volante_matricula (
    id_volante      INT             NOT NULL AUTO_INCREMENT,
    id_cuenta       INT             NOT NULL,
    id_prog         INT             NOT NULL,   -- programa al que pertenece el volante
    semestre        INT             NOT NULL,   -- semestre cursado en este volante
    fecha_emision   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_cobros    DECIMAL(12,2)   NOT NULL,
    total_pagos     DECIMAL(12,2)   NOT NULL,
    saldo_pendiente DECIMAL(12,2)   NOT NULL,
    observacion     VARCHAR(255),
    CONSTRAINT pk_volante       PRIMARY KEY (id_volante),
    CONSTRAINT fk_vol_cuenta    FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_vol_programa  FOREIGN KEY (id_prog)   REFERENCES programa(id_programa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- PASO 5: Códigos de detalle del módulo
-- Incluye columna `nombre` (requerida por 02_tablas_negocio.sql)
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO codigo_detalle (grupo, codigo, nombre, descripcion) VALUES
    -- COBROS
    ('COBRO', 'PMAT', 'Matrícula ordinaria',      'Cobro de matrícula ordinaria del periodo'),
    ('COBRO', 'PCRE', 'Créditos adicionales',     'Cobro por créditos adicionales matriculados'),
    ('COBRO', 'PCAR', 'Carnet estudiantil',        'Cobro por carnet estudiantil'),
    ('COBRO', 'PLAB', 'Uso de laboratorios',       'Cobro por uso de laboratorios'),
    ('COBRO', 'PEXA', 'Derechos de examen',        'Cobro por derechos de examen'),
    -- PAGOS
    ('PAGO',  'MPAG', 'Valor pagado matrícula',    'Valor pagado matrícula'),
    ('PAGO',  'ANT',  'Anticipo matrícula',         'Anticipo o pago anticipado de matrícula'),
    ('PAGO',  'DESC', 'Descuento / Beca',           'Descuento o beca porcentual aplicado'),
    ('PAGO',  'CRED', 'Crédito a favor',            'Crédito a favor del estudiante');


-- ============================================================
-- STORED PROCEDURE: sp_pago_caja
-- Registra un pago presencial y actualiza cuenta corriente.
--
-- ADAPTACIÓN: usa e.nombres / e.apellidos / e.num_doc del
-- script 05 (sin join a persona).
--
-- Parámetros IN:
--   p_id_estudiante  INT
--   p_id_periodo     INT
--   p_valor          DECIMAL(12,2)
--   p_metodo_pago    ENUM  EFECTIVO | PSE | TRANSFERENCIA | TARJETA
--   p_fecha_pago     DATE
--   p_observacion    VARCHAR(255)
-- Parámetros OUT:
--   o_id_pago        INT
--   o_saldo          DECIMAL(12,2)
--   o_mensaje        VARCHAR(255)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_pago_caja;

DELIMITER $$

CREATE PROCEDURE sp_pago_caja(
    IN  p_id_estudiante  INT,
    IN  p_id_periodo     INT,
    IN  p_valor          DECIMAL(12,2),
    IN  p_metodo_pago    VARCHAR(20),
    IN  p_fecha_pago     DATE,
    IN  p_observacion    VARCHAR(255),
    OUT o_id_pago        INT,
    OUT o_saldo          DECIMAL(12,2),
    OUT o_mensaje        VARCHAR(255)
)
sp_pago_caja: BEGIN
    DECLARE v_id_cuenta     INT           DEFAULT NULL;
    DECLARE v_id_codigo     INT           DEFAULT NULL;
    DECLARE v_id_pago       INT           DEFAULT NULL;
    DECLARE v_saldo         DECIMAL(12,2) DEFAULT 0;

    -- ── 1. Validaciones básicas ───────────────────────────────
    IF p_valor IS NULL OR p_valor <= 0 THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: El valor del pago debe ser mayor a cero.';
        LEAVE sp_pago_caja;
    END IF;

    IF p_metodo_pago NOT IN ('EFECTIVO','PSE','TRANSFERENCIA','TARJETA') THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Método de pago no válido.';
        LEAVE sp_pago_caja;
    END IF;

    -- ── 2. Verificar estudiante activo ────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM estudiante
        WHERE id_estudiante = p_id_estudiante AND activo = TRUE
    ) THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Estudiante no encontrado o inactivo.';
        LEAVE sp_pago_caja;
    END IF;

    -- ── 3. Verificar periodo ──────────────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM periodo_academico WHERE id_periodo = p_id_periodo
    ) THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Periodo académico no encontrado.';
        LEAVE sp_pago_caja;
    END IF;

    -- ── 4. Obtener o crear cuenta corriente ───────────────────
    SELECT id_cuenta INTO v_id_cuenta
    FROM cuenta_corriente
    WHERE id_estudiante = p_id_estudiante AND id_periodo = p_id_periodo
    LIMIT 1;

    IF v_id_cuenta IS NULL THEN
        INSERT INTO cuenta_corriente (id_estudiante, id_periodo, total_cobros, total_pagos, saldo_pendiente)
        VALUES (p_id_estudiante, p_id_periodo, 0, 0, 0);
        SET v_id_cuenta = LAST_INSERT_ID();
    END IF;

    -- ── 5. Obtener id_codigo MPAG ────────────────────────────
    SELECT id_codigo INTO v_id_codigo
    FROM codigo_detalle WHERE codigo = 'MPAG' AND grupo = 'PAGO' LIMIT 1;

    IF v_id_codigo IS NULL THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Código MPAG no encontrado en codigo_detalle.';
        LEAVE sp_pago_caja;
    END IF;

    -- ── 6. Insertar en tabla pago ─────────────────────────────
    INSERT INTO pago (id_cuenta, id_codigo, valor, metodo_pago, fecha_pago, observacion)
    VALUES (v_id_cuenta, v_id_codigo, p_valor, p_metodo_pago, p_fecha_pago, p_observacion);
    SET v_id_pago = LAST_INSERT_ID();

    -- ── 7. Registrar movimiento ───────────────────────────────
    INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, id_pago, tipo, valor, descripcion, fecha)
    VALUES (v_id_cuenta, v_id_codigo, v_id_pago, 'PAGO', p_valor, 'Valor pagado matrícula', p_fecha_pago);

    -- ── 8. Actualizar cuenta corriente ────────────────────────
    UPDATE cuenta_corriente
    SET total_pagos     = total_pagos + p_valor,
        saldo_pendiente = total_cobros - (total_pagos + p_valor)
    WHERE id_cuenta = v_id_cuenta;

    -- ── 9. Leer saldo actualizado ─────────────────────────────
    SELECT saldo_pendiente INTO v_saldo FROM cuenta_corriente WHERE id_cuenta = v_id_cuenta;

    SET o_id_pago = v_id_pago;
    SET o_saldo   = v_saldo;
    SET o_mensaje = CONCAT('OK: Pago registrado. Saldo pendiente: $', FORMAT(v_saldo, 2));

END$$

DELIMITER ;


-- ============================================================
-- VISTA: v_cuenta_corriente
-- ADAPTACIÓN: sin join a persona (estudiante es independiente
-- en script 05). Se usan e.nombres, e.apellidos, e.num_doc.
-- ============================================================
CREATE OR REPLACE VIEW v_cuenta_corriente AS
SELECT
    e.id_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
    e.num_doc,
    e.email,
    pa.nombre                               AS periodo,
    cc.total_cobros,
    cc.total_pagos,
    cc.saldo_pendiente,
    cc.fecha_creacion
FROM cuenta_corriente  cc
JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo;


-- ============================================================
-- VISTA: v_movimientos_cuenta
-- ADAPTACIÓN: sin join a persona; usa campos de estudiante 05.
-- ============================================================
CREATE OR REPLACE VIEW v_movimientos_cuenta AS
SELECT
    mc.id_movimiento,
    cc.id_cuenta,
    CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
    e.num_doc                               AS documento,
    pa.nombre                               AS periodo,
    cd.grupo,
    cd.codigo                               AS codigo_detalle,
    cd.nombre                               AS concepto,
    mc.tipo,
    mc.valor,
    mc.descripcion                          AS observacion,
    mc.fecha,
    mc.fecha_registro
FROM movimiento_cuenta mc
JOIN cuenta_corriente  cc ON mc.id_cuenta    = cc.id_cuenta
JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico pa ON cc.id_periodo   = pa.id_periodo
JOIN codigo_detalle    cd ON mc.id_codigo    = cd.id_codigo
ORDER BY mc.fecha DESC, mc.fecha_registro DESC;
