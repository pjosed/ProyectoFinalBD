-- ============================================================
-- 07_pago_PSE.sql — MÓDULO DE PAGO EN LÍNEA PSE
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar DESPUÉS de 06_pago_caja.sql
-- ============================================================
-- NOTAS DE ESTANDARIZACIÓN (v2):
--   • La vista v_pagos_pse usa e.nombres/apellidos/num_doc
--     (sin join a persona) para ser compatible con script 05.
--   • El resto del script es idéntico al original ya que sólo
--     crea banco_pse, pago_pse y los stored procedures, que no
--     dependen directamente del modelo de estudiante.
-- ============================================================

USE matriculas_uni;

-- ────────────────────────────────────────────────────────────
-- TABLA: banco_pse
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS banco_pse (
    id_banco    INT          NOT NULL AUTO_INCREMENT,
    codigo      VARCHAR(10)  NOT NULL UNIQUE,
    nombre      VARCHAR(100) NOT NULL,
    activo      TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_banco_pse PRIMARY KEY (id_banco)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO banco_pse (codigo, nombre) VALUES
    ('BCOL',  'Bancolombia'),
    ('BBOG',  'Banco de Bogotá'),
    ('DAVY',  'Davivienda'),
    ('AVVL',  'AV Villas'),
    ('OCCB',  'Banco de Occidente'),
    ('BBVA',  'BBVA Colombia'),
    ('POPU',  'Banco Popular'),
    ('ITAU',  'Itaú Colombia'),
    ('FALB',  'Banco Falabella'),
    ('NQBN',  'Nequi / Bancolombia Digital');


-- ────────────────────────────────────────────────────────────
-- TABLA: pago_pse
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pago_pse (
    id_pse              INT             NOT NULL AUTO_INCREMENT,
    id_cuenta           INT             NOT NULL,
    id_banco            INT             NOT NULL,
    id_pago             INT             DEFAULT NULL,
    valor               DECIMAL(12,2)   NOT NULL,
    referencia          VARCHAR(50)     NOT NULL UNIQUE,
    estado              ENUM('PENDIENTE','APROBADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
    usuario_banco       VARCHAR(60),
    fecha_transaccion   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_confirmacion  DATETIME        DEFAULT NULL,
    CONSTRAINT pk_pago_pse      PRIMARY KEY (id_pse),
    CONSTRAINT fk_pse_cuenta    FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_pse_banco     FOREIGN KEY (id_banco)  REFERENCES banco_pse(id_banco),
    CONSTRAINT fk_pse_pago      FOREIGN KEY (id_pago)   REFERENCES pago(id_pago)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- STORED PROCEDURE: sp_iniciar_pago_pse
-- ============================================================
DROP PROCEDURE IF EXISTS sp_iniciar_pago_pse;

DELIMITER $$

CREATE PROCEDURE sp_iniciar_pago_pse(
    IN  p_id_cuenta     INT,
    IN  p_id_banco      INT,
    IN  p_valor         DECIMAL(12,2),
    IN  p_usuario_banco VARCHAR(60),
    OUT o_id_pse        INT,
    OUT o_referencia    VARCHAR(50),
    OUT o_mensaje       VARCHAR(255)
)
sp_iniciar_pago_pse: BEGIN
    DECLARE v_referencia VARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM cuenta_corriente WHERE id_cuenta = p_id_cuenta) THEN
        SET o_id_pse = NULL; SET o_referencia = NULL;
        SET o_mensaje = 'ERROR: Cuenta corriente no encontrada.';
        LEAVE sp_iniciar_pago_pse;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM banco_pse WHERE id_banco = p_id_banco AND activo = 1) THEN
        SET o_id_pse = NULL; SET o_referencia = NULL;
        SET o_mensaje = 'ERROR: Banco no válido o inactivo.';
        LEAVE sp_iniciar_pago_pse;
    END IF;

    IF p_valor IS NULL OR p_valor <= 0 THEN
        SET o_id_pse = NULL; SET o_referencia = NULL;
        SET o_mensaje = 'ERROR: El valor debe ser mayor a cero.';
        LEAVE sp_iniciar_pago_pse;
    END IF;

    SET v_referencia = CONCAT('PSE', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), LPAD(FLOOR(RAND() * 9999), 4, '0'));

    INSERT INTO pago_pse (id_cuenta, id_banco, valor, referencia, estado, usuario_banco)
    VALUES (p_id_cuenta, p_id_banco, p_valor, v_referencia, 'PENDIENTE', p_usuario_banco);

    SET o_id_pse     = LAST_INSERT_ID();
    SET o_referencia = v_referencia;
    SET o_mensaje    = CONCAT('OK: Transacción PSE iniciada. Referencia: ', v_referencia);
END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURE: sp_confirmar_pago_pse
-- ============================================================
DROP PROCEDURE IF EXISTS sp_confirmar_pago_pse;

DELIMITER $$

CREATE PROCEDURE sp_confirmar_pago_pse(
    IN  p_id_pse    INT,
    OUT o_id_pago   INT,
    OUT o_saldo     DECIMAL(12,2),
    OUT o_mensaje   VARCHAR(255)
)
sp_confirmar_pago_pse: BEGIN
    DECLARE v_id_cuenta   INT;
    DECLARE v_valor       DECIMAL(12,2);
    DECLARE v_referencia  VARCHAR(50);
    DECLARE v_estado      VARCHAR(20);
    DECLARE v_id_codigo   INT;
    DECLARE v_id_pago     INT;
    DECLARE v_saldo       DECIMAL(12,2);

    SELECT id_cuenta, valor, referencia, estado
    INTO   v_id_cuenta, v_valor, v_referencia, v_estado
    FROM   pago_pse WHERE id_pse = p_id_pse LIMIT 1;

    IF v_id_cuenta IS NULL THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Transacción PSE no encontrada.';
        LEAVE sp_confirmar_pago_pse;
    END IF;

    IF v_estado != 'PENDIENTE' THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = CONCAT('ERROR: La transacción ya fue procesada con estado: ', v_estado);
        LEAVE sp_confirmar_pago_pse;
    END IF;

    SELECT id_codigo INTO v_id_codigo
    FROM   codigo_detalle WHERE codigo = 'MPAG' AND grupo = 'PAGO' LIMIT 1;

    IF v_id_codigo IS NULL THEN
        SET o_id_pago = NULL; SET o_saldo = NULL;
        SET o_mensaje = 'ERROR: Código MPAG no encontrado.';
        LEAVE sp_confirmar_pago_pse;
    END IF;

    INSERT INTO pago (id_cuenta, id_codigo, valor, metodo_pago, fecha_pago, observacion)
    VALUES (v_id_cuenta, v_id_codigo, v_valor, 'PSE', CURDATE(),
            CONCAT('Pago PSE - Ref: ', v_referencia));
    SET v_id_pago = LAST_INSERT_ID();

    INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, id_pago, tipo, valor, descripcion, fecha)
    VALUES (v_id_cuenta, v_id_codigo, v_id_pago, 'PAGO', v_valor,
            CONCAT('Valor pagado matrícula vía PSE - Ref: ', v_referencia), CURDATE());

    UPDATE cuenta_corriente
    SET total_pagos     = total_pagos + v_valor,
        saldo_pendiente = total_cobros - (total_pagos + v_valor)
    WHERE id_cuenta = v_id_cuenta;

    UPDATE pago_pse
    SET estado             = 'APROBADO',
        id_pago            = v_id_pago,
        fecha_confirmacion = NOW()
    WHERE id_pse = p_id_pse;

    SELECT saldo_pendiente INTO v_saldo FROM cuenta_corriente WHERE id_cuenta = v_id_cuenta;

    SET o_id_pago = v_id_pago;
    SET o_saldo   = v_saldo;
    SET o_mensaje = CONCAT('OK: Pago PSE aprobado. Saldo pendiente: $', FORMAT(v_saldo, 2));
END$$

DELIMITER ;


-- ============================================================
-- VISTA: v_pagos_pse
-- ADAPTACIÓN: usa e.nombres/apellidos/num_doc sin join a persona
-- ============================================================
CREATE OR REPLACE VIEW v_pagos_pse AS
SELECT
    pp.id_pse,
    CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
    e.num_doc                               AS documento,
    pa.nombre                               AS periodo,
    bp.nombre                               AS banco,
    pp.valor,
    pp.referencia,
    pp.estado,
    pp.usuario_banco,
    pp.fecha_transaccion,
    pp.fecha_confirmacion
FROM pago_pse          pp
JOIN cuenta_corriente  cc ON pp.id_cuenta     = cc.id_cuenta
JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
JOIN banco_pse         bp ON pp.id_banco      = bp.id_banco
ORDER BY pp.fecha_transaccion DESC;
