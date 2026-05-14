-- ============================================================
-- 09_cuenta_corriente.sql — VISUALIZACIÓN CUENTA CORRIENTE
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar DESPUÉS de 08_Descuentos&Becas.sql
-- ============================================================
-- NOTAS DE ESTANDARIZACIÓN (v2):
--   • Todas las vistas y SPs usan e.nombres / e.apellidos /
--     e.num_doc / e.email (sin join a persona) para ser
--     compatibles con la tabla estudiante del script 05.
--   • Se elimina el campo e.codigo de todas las vistas ya que
--     esa columna no existe en el script 05.
--   • La lógica de negocio (window functions, triggers, SPs)
--     permanece sin cambios.
-- ============================================================

USE matriculas_uni;

-- ============================================================
-- VISTA: v_movimientos_con_saldo
-- ============================================================
DROP VIEW IF EXISTS v_movimientos_con_saldo;

CREATE OR REPLACE VIEW v_movimientos_con_saldo AS
SELECT
    sub.id_movimiento,
    sub.id_cuenta,
    sub.id_estudiante,
    sub.id_periodo,
    sub.movimiento,
    sub.codigo,
    sub.tipo,
    sub.valor,
    sub.saldo_acumulado,
    sub.fecha,
    sub.fecha_registro
FROM (
    SELECT
        mc.id_movimiento,
        cc.id_cuenta,
        cc.id_estudiante,
        cc.id_periodo,
        cd.nombre                                   AS movimiento,
        cd.codigo,
        mc.tipo,
        mc.valor,
        SUM(
            CASE mc.tipo
                WHEN 'COBRO' THEN  mc.valor
                WHEN 'PAGO'  THEN -mc.valor
            END
        ) OVER (
            PARTITION BY mc.id_cuenta
            ORDER BY mc.fecha ASC, mc.id_movimiento ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS saldo_acumulado,
        mc.fecha,
        mc.fecha_registro
    FROM movimiento_cuenta mc
    JOIN cuenta_corriente  cc ON mc.id_cuenta = cc.id_cuenta
    JOIN codigo_detalle    cd ON mc.id_codigo  = cd.id_codigo
) sub;


-- ============================================================
-- VISTA: v_cuenta_corriente_resumen
-- ADAPTACIÓN: e.nombres/apellidos/num_doc/email sin persona
-- ============================================================
CREATE OR REPLACE VIEW v_cuenta_corriente_resumen AS
SELECT
    cc.id_cuenta,
    cc.id_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos)         AS estudiante,
    e.num_doc,
    e.email,
    cc.id_periodo,
    pa.nombre                                   AS periodo,
    pa.fecha_inicio,
    pa.fecha_fin,
    cc.total_cobros,
    cc.total_pagos,
    cc.saldo_pendiente,
    (cc.total_cobros - cc.total_pagos - cc.saldo_pendiente) AS diferencia_balance,
    CASE
        WHEN cc.saldo_pendiente  > 0 THEN 'PENDIENTE'
        WHEN cc.saldo_pendiente  = 0 THEN 'BALANCEADO'
        WHEN cc.saldo_pendiente  < 0 THEN 'A FAVOR'
    END                                         AS estado,
    cc.fecha_creacion
FROM cuenta_corriente  cc
JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo;


-- ============================================================
-- STORED PROCEDURE: sp_cuenta_corriente
-- ADAPTACIÓN: Result Set 1 usa e.nombres/apellidos sin e.codigo
-- ============================================================
DROP PROCEDURE IF EXISTS sp_cuenta_corriente;

DELIMITER $$

CREATE PROCEDURE sp_cuenta_corriente(
    IN p_id_estudiante INT,
    IN p_id_periodo    INT
)
sp_cuenta_corriente: BEGIN
    -- ── Result Set 1: Resumen de cuenta ───────────────────────
    SELECT
        cc.id_cuenta,
        CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
        e.num_doc,
        pa.nombre                               AS periodo,
        cc.total_cobros,
        cc.total_pagos,
        cc.saldo_pendiente,
        (cc.total_cobros - cc.total_pagos - cc.saldo_pendiente) AS diferencia_balance,
        CASE
            WHEN cc.saldo_pendiente  > 0 THEN 'PENDIENTE'
            WHEN cc.saldo_pendiente  = 0 THEN 'BALANCEADO'
            WHEN cc.saldo_pendiente  < 0 THEN 'A FAVOR'
        END AS estado
    FROM cuenta_corriente  cc
    JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
    JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
    WHERE cc.id_estudiante = p_id_estudiante
      AND cc.id_periodo    = p_id_periodo
    LIMIT 1;

    -- ── Result Set 2: Movimientos con saldo acumulado ─────────
    SELECT
        cd.nombre           AS movimiento,
        cd.codigo,
        mc.tipo,
        mc.valor,
        SUM(
            CASE mc.tipo
                WHEN 'COBRO' THEN  mc.valor
                WHEN 'PAGO'  THEN -mc.valor
            END
        ) OVER (
            PARTITION BY mc.id_cuenta
            ORDER BY mc.fecha ASC, mc.id_movimiento ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                   AS saldo_acumulado,
        mc.fecha,
        mc.descripcion      AS observacion
    FROM movimiento_cuenta mc
    JOIN cuenta_corriente  cc ON mc.id_cuenta = cc.id_cuenta
    JOIN codigo_detalle    cd ON mc.id_codigo  = cd.id_codigo
    WHERE cc.id_estudiante = p_id_estudiante
      AND cc.id_periodo    = p_id_periodo
    ORDER BY mc.fecha ASC, mc.id_movimiento ASC;
END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURE: sp_verificar_balance
-- ADAPTACIÓN: usa e.nombres/apellidos sin e.codigo
-- ============================================================
DROP PROCEDURE IF EXISTS sp_verificar_balance;

DELIMITER $$

CREATE PROCEDURE sp_verificar_balance()
BEGIN
    SELECT
        cc.id_cuenta,
        CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
        pa.nombre                               AS periodo,
        cc.total_cobros,
        cc.total_pagos,
        cc.saldo_pendiente,
        (cc.total_cobros - cc.total_pagos)      AS balance_calculado,
        (cc.total_cobros - cc.total_pagos - cc.saldo_pendiente) AS diferencia,
        CASE
            WHEN ABS(cc.total_cobros - cc.total_pagos - cc.saldo_pendiente) < 0.01
            THEN 'OK'
            ELSE '⚠ DESBALANCEADO'
        END AS estado_balance
    FROM cuenta_corriente  cc
    JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
    JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
    ORDER BY ABS(cc.total_cobros - cc.total_pagos - cc.saldo_pendiente) DESC;
END$$

DELIMITER ;


-- ============================================================
-- TRIGGER: trg_balance_cobro
-- ============================================================
DROP TRIGGER IF EXISTS trg_balance_cobro;

DELIMITER $$

CREATE TRIGGER trg_balance_cobro
AFTER INSERT ON movimiento_cuenta
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'COBRO' THEN
        UPDATE cuenta_corriente
        SET total_cobros    = total_cobros + NEW.valor,
            saldo_pendiente = (total_cobros + NEW.valor) - total_pagos
        WHERE id_cuenta = NEW.id_cuenta;
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- TRIGGER: trg_balance_pago
-- ============================================================
DROP TRIGGER IF EXISTS trg_balance_pago;

DELIMITER $$

CREATE TRIGGER trg_balance_pago
AFTER INSERT ON movimiento_cuenta
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'PAGO' THEN
        UPDATE cuenta_corriente
        SET total_pagos     = total_pagos + NEW.valor,
            saldo_pendiente = total_cobros - (total_pagos + NEW.valor)
        WHERE id_cuenta = NEW.id_cuenta;
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- EJEMPLO DE USO (descomentar para probar):
-- ============================================================
/*
CALL sp_cuenta_corriente(1, 1);
CALL sp_verificar_balance();
SELECT * FROM v_movimientos_con_saldo WHERE id_estudiante = 1 AND id_periodo = 1;
SELECT * FROM v_cuenta_corriente_resumen;
*/
