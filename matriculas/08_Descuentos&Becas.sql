-- ============================================================
-- 08_Descuentos&Becas.sql — MÓDULO DE DESCUENTOS Y BECAS
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar DESPUÉS de 07_pago_PSE.sql
-- ============================================================
-- NOTAS DE ESTANDARIZACIÓN (v2):
--   • La vista v_descuentos_aplicados usa e.nombres/apellidos
--     sin join a persona (compatibilidad con script 05).
--   • El SP sp_aplicar_descuento valida el estudiante contra
--     la tabla estudiante del script 05 (sin id_persona).
--   • El join al usuario (para obtener el rol) sigue usando la
--     tabla usuario que viene del script 01 a través de persona,
--     ya que los usuarios del sistema son personal admin, no
--     estudiantes. Ese vínculo permanece intacto.
-- ============================================================

USE matriculas_uni;

-- ────────────────────────────────────────────────────────────
-- TABLA: tipo_descuento
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tipo_descuento (
    id_tipo         INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    descripcion     VARCHAR(255),
    porcentaje      DECIMAL(5,2)    NOT NULL,
    activo          TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_tipo_descuento PRIMARY KEY (id_tipo),
    CONSTRAINT chk_porcentaje    CHECK (porcentaje IN (10, 20, 25, 50, 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO tipo_descuento (nombre, descripcion, porcentaje) VALUES
    ('Beca Excelencia Académica',  'Para estudiantes con promedio >= 4.5',         25.00),
    ('Beca Socioeconómica',        'Apoyo a estudiantes de bajos recursos',         50.00),
    ('Descuento Empleado',         'Para colaboradores y familiares directos',      20.00),
    ('Beca Deportiva',             'Para deportistas de alto rendimiento',          25.00),
    ('Descuento por Convenio',     'Empresa con convenio institucional activo',     10.00),
    ('Beca Total',                 'Cobertura completa de matrícula',              100.00);


-- ────────────────────────────────────────────────────────────
-- TABLA: descuento_aplicado
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS descuento_aplicado (
    id_descuento     INT             NOT NULL AUTO_INCREMENT,
    id_cuenta        INT             NOT NULL,
    id_tipo          INT             NOT NULL,
    id_pago          INT             NOT NULL,
    id_usuario       INT             NOT NULL,
    porcentaje       DECIMAL(5,2)    NOT NULL,
    valor_descuento  DECIMAL(12,2)   NOT NULL,
    observacion      VARCHAR(255),
    fecha_aplicacion DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_descuento      PRIMARY KEY (id_descuento),
    CONSTRAINT fk_desc_cuenta    FOREIGN KEY (id_cuenta)  REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_desc_tipo      FOREIGN KEY (id_tipo)    REFERENCES tipo_descuento(id_tipo),
    CONSTRAINT fk_desc_pago      FOREIGN KEY (id_pago)    REFERENCES pago(id_pago),
    CONSTRAINT fk_desc_usuario   FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- STORED PROCEDURE: sp_aplicar_descuento
-- ADAPTACIÓN: valida estudiante con activo = TRUE (BOOLEAN)
-- según script 05 (no usa TINYINT(1) con valor 1).
-- El join para obtener el rol del usuario sigue apuntando a
-- usuario → rol (tablas del script 01).
-- ============================================================
DROP PROCEDURE IF EXISTS sp_aplicar_descuento;

DELIMITER $$

CREATE PROCEDURE sp_aplicar_descuento(
    IN  p_id_estudiante INT,
    IN  p_id_periodo    INT,
    IN  p_id_tipo       INT,
    IN  p_porcentaje    DECIMAL(5,2),
    IN  p_observacion   VARCHAR(255),
    IN  p_id_usuario    INT,
    OUT o_id_descuento  INT,
    OUT o_valor_desc    DECIMAL(12,2),
    OUT o_saldo         DECIMAL(12,2),
    OUT o_mensaje       VARCHAR(255)
)
sp_aplicar_descuento: BEGIN
    DECLARE v_id_cuenta     INT;
    DECLARE v_total_cobros  DECIMAL(12,2);
    DECLARE v_id_codigo     INT;
    DECLARE v_id_pago       INT;
    DECLARE v_valor_desc    DECIMAL(12,2);
    DECLARE v_rol_nombre    VARCHAR(50);
    DECLARE v_saldo         DECIMAL(12,2);

    -- ── 1. Validar porcentaje ─────────────────────────────────
    IF p_porcentaje NOT IN (10, 20, 25, 50, 100) THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Porcentaje no válido. Use 10, 20, 25, 50 o 100.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- ── 2. Validar rol del usuario ────────────────────────────
    SELECT r.nombre INTO v_rol_nombre
    FROM usuario u
    JOIN rol r ON u.id_rol = r.id_rol
    WHERE u.id_usuario = p_id_usuario AND u.activo = 1
    LIMIT 1;

    IF v_rol_nombre IS NULL THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Usuario no encontrado o inactivo.';
        LEAVE sp_aplicar_descuento;
    END IF;

    IF v_rol_nombre NOT IN ('ADMINISTRADOR', 'SUPERVISOR') THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = CONCAT('ERROR: El rol ', v_rol_nombre, ' no tiene permiso para aplicar descuentos.');
        LEAVE sp_aplicar_descuento;
    END IF;

    -- ── 3. Validar estudiante activo (BOOLEAN del script 05) ──
    IF NOT EXISTS (
        SELECT 1 FROM estudiante
        WHERE id_estudiante = p_id_estudiante AND activo = TRUE
    ) THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Estudiante no encontrado o inactivo.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- ── 4. Validar tipo de descuento ──────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM tipo_descuento WHERE id_tipo = p_id_tipo AND activo = 1
    ) THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Tipo de descuento no válido o inactivo.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- ── 5. Obtener cuenta corriente ───────────────────────────
    SELECT id_cuenta, total_cobros
    INTO   v_id_cuenta, v_total_cobros
    FROM   cuenta_corriente
    WHERE  id_estudiante = p_id_estudiante AND id_periodo = p_id_periodo
    LIMIT 1;

    IF v_id_cuenta IS NULL THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: No existe cuenta corriente para ese estudiante y periodo.';
        LEAVE sp_aplicar_descuento;
    END IF;

    IF v_total_cobros <= 0 THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: La cuenta no tiene cobros registrados. Genere los cobros primero.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- ── 6. Calcular valor del descuento ───────────────────────
    SET v_valor_desc = ROUND(v_total_cobros * (p_porcentaje / 100), 2);

    -- ── 7. Obtener código DESC ────────────────────────────────
    SELECT id_codigo INTO v_id_codigo
    FROM   codigo_detalle WHERE codigo = 'DESC' AND grupo = 'PAGO' LIMIT 1;

    IF v_id_codigo IS NULL THEN
        SET o_id_descuento = NULL; SET o_valor_desc = NULL;
        SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Código DESC no encontrado en codigo_detalle.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- ── 8. Insertar en tabla pago ─────────────────────────────
    INSERT INTO pago (id_cuenta, id_codigo, valor, metodo_pago, fecha_pago, observacion)
    VALUES (
        v_id_cuenta, v_id_codigo, v_valor_desc,
        'EFECTIVO',   -- marcador; no aplica para descuentos
        CURDATE(),
        COALESCE(p_observacion, CONCAT('Descuento aplicado: ', p_porcentaje, '%'))
    );
    SET v_id_pago = LAST_INSERT_ID();

    -- ── 9. Registrar movimiento tipo PAGO con código DESC ─────
    INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, id_pago, tipo, valor, descripcion, fecha)
    VALUES (
        v_id_cuenta, v_id_codigo, v_id_pago, 'PAGO', v_valor_desc,
        COALESCE(p_observacion, CONCAT('Descuento aplicado: ', p_porcentaje, '%')),
        CURDATE()
    );

    -- ── 10. Actualizar cuenta corriente ───────────────────────
    UPDATE cuenta_corriente
    SET total_pagos     = total_pagos + v_valor_desc,
        saldo_pendiente = total_cobros - (total_pagos + v_valor_desc)
    WHERE id_cuenta = v_id_cuenta;

    -- ── 11. Registrar en descuento_aplicado ───────────────────
    INSERT INTO descuento_aplicado
        (id_cuenta, id_tipo, id_pago, id_usuario, porcentaje, valor_descuento, observacion)
    VALUES
        (v_id_cuenta, p_id_tipo, v_id_pago, p_id_usuario, p_porcentaje, v_valor_desc,
         COALESCE(p_observacion, CONCAT('Descuento ', p_porcentaje, '% por usuario ', p_id_usuario)));

    -- ── 12. Leer saldo actualizado ────────────────────────────
    SELECT saldo_pendiente INTO v_saldo FROM cuenta_corriente WHERE id_cuenta = v_id_cuenta;

    SET o_id_descuento = LAST_INSERT_ID();
    SET o_valor_desc   = v_valor_desc;
    SET o_saldo        = v_saldo;
    SET o_mensaje      = CONCAT(
        'OK: Descuento de ', p_porcentaje, '% aplicado. ',
        'Valor: $', FORMAT(v_valor_desc, 2), '. ',
        'Saldo pendiente: $', FORMAT(v_saldo, 2)
    );

END$$

DELIMITER ;


-- ============================================================
-- VISTA: v_descuentos_aplicados
-- ADAPTACIÓN: usa e.nombres/apellidos (sin join a persona
-- para el estudiante). El usuario aplicador sí une a persona
-- porque los usuarios admin pertenecen al modelo de script 01.
-- ============================================================
CREATE OR REPLACE VIEW v_descuentos_aplicados AS
SELECT
    da.id_descuento,
    CONCAT(e.nombres, ' ', e.apellidos)         AS estudiante,
    e.num_doc                                   AS documento,
    pa.nombre                                   AS periodo,
    td.nombre                                   AS tipo_beca,
    da.porcentaje,
    da.valor_descuento,
    cc.total_cobros,
    cc.total_pagos,
    cc.saldo_pendiente,
    da.observacion,
    CONCAT(up.nombres, ' ', up.apellidos)       AS aplicado_por,
    da.fecha_aplicacion
FROM descuento_aplicado   da
JOIN cuenta_corriente     cc  ON da.id_cuenta      = cc.id_cuenta
JOIN estudiante           e   ON cc.id_estudiante  = e.id_estudiante
JOIN periodo_academico    pa  ON cc.id_periodo     = pa.id_periodo
JOIN tipo_descuento       td  ON da.id_tipo        = td.id_tipo
JOIN usuario              u   ON da.id_usuario     = u.id_usuario
JOIN persona              up  ON u.id_persona      = up.id_persona   -- usuario admin → persona (script 01)
ORDER BY da.fecha_aplicacion DESC;


-- ============================================================
-- EJEMPLO DE USO (descomentar para probar):
-- ============================================================
/*
CALL sp_aplicar_descuento(
    1,                               -- id_estudiante
    1,                               -- id_periodo
    1,                               -- id_tipo (Beca Excelencia)
    25,                              -- porcentaje
    'Beca mérito académico 2026-1',  -- observacion
    1,                               -- id_usuario (ADMINISTRADOR)
    @id_desc, @valor, @saldo, @msg
);
SELECT @id_desc, @valor, @saldo, @msg;
SELECT * FROM v_descuentos_aplicados;
*/
