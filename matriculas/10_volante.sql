-- ============================================================
-- 10_volante.sql — VISTA DEL VOLANTE DE MATRÍCULA
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar DESPUÉS de 09_cuenta_corriente.sql
-- ============================================================
-- NOTAS DE ESTANDARIZACIÓN (v2):
--   • La tabla estudiante (script 05) NO tiene: codigo,
--     semestre_actual, id_persona, id_programa.
--   • Las vistas del volante obtienen el programa y semestre
--     a través de volante_matricula → cuenta_corriente →
--     regla_cobro, o bien dejando esos campos como NULL
--     cuando no apliquen (modalidad GLOBAL sin asignaturas).
--   • Se elimina toda referencia a e.codigo, e.semestre_actual,
--     e.id_programa, p.* (persona) en los joins de estudiante.
--   • El SP sp_volante_matricula adapta su lógica para leer
--     programa y semestre desde regla_cobro y plan_estudio
--     usando el volante_matricula que tiene id_prog y semestre.
--   • La columna rc.valor_credito del script 02 se llama
--     valor_por_credito — se corrige en todas las referencias.
-- ============================================================
-- CORRECCIÓN (v3):
--   • El script 05 crea volante_matricula SIN la columna
--     id_cuenta. Este script agrega dicha columna con ALTER
--     TABLE (solo si no existe) para que las vistas y el SP
--     puedan hacer JOIN por vm.id_cuenta = cc.id_cuenta.
--   • El UPDATE posterior sincroniza id_cuenta en filas
--     existentes cruzando por id_estu + id_per.
-- ============================================================

USE matriculas_uni;

-- ============================================================
-- PASO 0: Agregar id_cuenta a volante_matricula (si no existe)
-- ============================================================
-- Se usa un bloque de procedure anónimo para hacer el ADD
-- solo cuando la columna todavía no existe, evitando error
-- al ejecutar el script más de una vez.

DROP PROCEDURE IF EXISTS _tmp_add_id_cuenta;

DELIMITER $$
CREATE PROCEDURE _tmp_add_id_cuenta()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'volante_matricula'
          AND COLUMN_NAME  = 'id_cuenta'
    ) THEN
        ALTER TABLE volante_matricula
            ADD COLUMN id_cuenta INT NULL
                AFTER id_usuario,
            ADD CONSTRAINT fk_vm_cuenta
                FOREIGN KEY (id_cuenta)
                REFERENCES cuenta_corriente(id_cuenta);

        -- Sincronizar filas ya existentes
        UPDATE volante_matricula vm
        JOIN cuenta_corriente cc
            ON cc.id_estudiante = vm.id_estu
           AND cc.id_periodo    = vm.id_per
        SET vm.id_cuenta = cc.id_cuenta;
    END IF;
END$$
DELIMITER ;

CALL _tmp_add_id_cuenta();
DROP PROCEDURE IF EXISTS _tmp_add_id_cuenta;

-- ============================================================
-- VISTA: v_volante_global
-- Volante modalidad GLOBAL — valor fijo por regla_cobro.
-- Sin asignaturas. Semestre y programa desde volante_matricula.
-- ============================================================
CREATE OR REPLACE VIEW v_volante_global AS
SELECT
    -- Estudiante (campos del script 05)
    e.id_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos)             AS estudiante,
    e.num_doc,
    e.email,
    e.telefono,

    -- Programa (desde volante_matricula)
    pr.id_programa,
    pr.codigo                                       AS codigo_programa,
    pr.nombre                                       AS programa,
    vm.semestre,

    -- Periodo
    pa.id_periodo,
    pa.nombre                                       AS periodo,
    pa.fecha_inicio,
    pa.fecha_fin,

    -- Regla de cobro (GLOBAL)
    rc.valor_global                                 AS valor_matricula,
    NULL                                            AS valor_credito,
    NULL                                            AS total_creditos,
    'GLOBAL'                                        AS modalidad_cobro,

    -- Cuenta corriente
    cc.id_cuenta,
    cc.total_cobros,
    cc.total_pagos,
    cc.saldo_pendiente,

    -- Estado
    CASE
        WHEN cc.saldo_pendiente  > 0 THEN 'PENDIENTE'
        WHEN cc.saldo_pendiente  = 0 THEN 'BALANCEADO'
        WHEN cc.saldo_pendiente  < 0 THEN 'A FAVOR'
    END                                             AS estado

FROM cuenta_corriente  cc
JOIN estudiante        e   ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico pa  ON cc.id_periodo    = pa.id_periodo
JOIN volante_matricula vm  ON vm.id_cuenta     = cc.id_cuenta
JOIN programa          pr  ON vm.id_prog       = pr.id_programa
JOIN regla_cobro       rc  ON rc.id_periodo    = pa.id_periodo
                          AND rc.id_programa   = pr.id_programa
WHERE rc.modalidad_cobro = 'GLOBAL'
  AND rc.valor_global    IS NOT NULL;


-- ============================================================
-- VISTA: v_volante_creditos
-- Volante modalidad POR_CREDITOS — total créditos × valor.
-- Asignaturas del plan de estudio en el semestre del volante.
-- ============================================================
CREATE OR REPLACE VIEW v_volante_creditos AS
SELECT
    -- Estudiante
    e.id_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos)             AS estudiante,
    e.num_doc,
    e.email,
    e.telefono,

    -- Programa
    pr.id_programa,
    pr.codigo                                       AS codigo_programa,
    pr.nombre                                       AS programa,
    vm.semestre,

    -- Periodo
    pa.id_periodo,
    pa.nombre                                       AS periodo,
    pa.fecha_inicio,
    pa.fecha_fin,

    -- Regla de cobro (POR_CREDITOS)
    rc.valor_por_credito                            AS valor_credito,
    SUM(a.creditos)                                 AS total_creditos,
    SUM(a.creditos) * rc.valor_por_credito          AS valor_matricula,
    'POR_CREDITOS'                                  AS modalidad_cobro,

    -- Cuenta corriente
    cc.id_cuenta,
    cc.total_cobros,
    cc.total_pagos,
    cc.saldo_pendiente,

    -- Estado
    CASE
        WHEN cc.saldo_pendiente  > 0 THEN 'PENDIENTE'
        WHEN cc.saldo_pendiente  = 0 THEN 'BALANCEADO'
        WHEN cc.saldo_pendiente  < 0 THEN 'A FAVOR'
    END                                             AS estado

FROM cuenta_corriente  cc
JOIN estudiante        e   ON cc.id_estudiante  = e.id_estudiante
JOIN periodo_academico pa  ON cc.id_periodo     = pa.id_periodo
JOIN volante_matricula vm  ON vm.id_cuenta      = cc.id_cuenta
JOIN programa          pr  ON vm.id_prog        = pr.id_programa
JOIN regla_cobro       rc  ON rc.id_periodo     = pa.id_periodo
                          AND rc.id_programa    = pr.id_programa
JOIN plan_estudio      pe  ON pe.id_programa    = pr.id_programa
                          AND pe.semestre       = vm.semestre
JOIN asignatura        a   ON a.id_asignatura   = pe.id_asignatura
WHERE rc.modalidad_cobro  = 'POR_CREDITOS'
  AND rc.valor_por_credito IS NOT NULL
GROUP BY
    e.id_estudiante, e.nombres, e.apellidos, e.num_doc, e.email, e.telefono,
    pr.id_programa, pr.codigo, pr.nombre, vm.semestre,
    pa.id_periodo, pa.nombre, pa.fecha_inicio, pa.fecha_fin,
    rc.valor_por_credito,
    cc.id_cuenta, cc.total_cobros, cc.total_pagos, cc.saldo_pendiente;


-- ============================================================
-- STORED PROCEDURE: sp_volante_matricula
-- Obtiene todos los datos del volante en 4 result sets.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_volante_matricula;

DELIMITER $$

CREATE PROCEDURE sp_volante_matricula(
    IN p_id_estudiante INT,
    IN p_id_periodo    INT
)
sp_volante_matricula: BEGIN
    DECLARE v_modalidad       VARCHAR(20);
    DECLARE v_id_programa     INT;
    DECLARE v_semestre        INT;
    DECLARE v_valor_credito   DECIMAL(12,2);
    DECLARE v_id_cuenta       INT;

    -- Obtener cuenta corriente
    SELECT id_cuenta INTO v_id_cuenta
    FROM cuenta_corriente
    WHERE id_estudiante = p_id_estudiante AND id_periodo = p_id_periodo
    LIMIT 1;

    -- Obtener modalidad, programa y semestre desde volante_matricula
    SELECT
        rc.modalidad_cobro,
        vm.id_prog,
        vm.semestre,
        rc.valor_por_credito
    INTO v_modalidad, v_id_programa, v_semestre, v_valor_credito
    FROM volante_matricula vm
    JOIN regla_cobro       rc ON rc.id_programa = vm.id_prog
                             AND rc.id_periodo  = p_id_periodo
    WHERE vm.id_cuenta = v_id_cuenta
    LIMIT 1;

    -- ── Result Set 1: Cabecera del volante ────────────────────
    SELECT
        CONCAT(e.nombres, ' ', e.apellidos)         AS estudiante,
        e.num_doc,
        e.email,
        e.telefono,
        pr.codigo                                   AS codigo_programa,
        pr.nombre                                   AS programa,
        v_semestre                                  AS semestre,
        pa.nombre                                   AS periodo,
        pa.fecha_inicio,
        pa.fecha_fin,
        v_modalidad                                 AS modalidad_cobro,
        CASE
            WHEN v_modalidad = 'GLOBAL'
            THEN rc.valor_global
            ELSE (
                SELECT SUM(a2.creditos) * rc.valor_por_credito
                FROM plan_estudio pe2
                JOIN asignatura   a2 ON a2.id_asignatura = pe2.id_asignatura
                WHERE pe2.id_programa = v_id_programa
                  AND pe2.semestre    = v_semestre
            )
        END                                         AS valor_matricula,
        rc.valor_por_credito                        AS valor_credito,
        CASE
            WHEN v_modalidad = 'POR_CREDITOS'
            THEN (
                SELECT SUM(a3.creditos)
                FROM plan_estudio pe3
                JOIN asignatura   a3 ON a3.id_asignatura = pe3.id_asignatura
                WHERE pe3.id_programa = v_id_programa
                  AND pe3.semestre    = v_semestre
            )
            ELSE NULL
        END                                         AS total_creditos,
        cc.total_cobros,
        cc.total_pagos,
        cc.saldo_pendiente,
        CASE
            WHEN cc.saldo_pendiente  > 0 THEN 'PENDIENTE'
            WHEN cc.saldo_pendiente  = 0 THEN 'BALANCEADO'
            WHEN cc.saldo_pendiente  < 0 THEN 'A FAVOR'
        END                                         AS estado
    FROM cuenta_corriente  cc
    JOIN estudiante        e   ON cc.id_estudiante = e.id_estudiante
    JOIN volante_matricula vm  ON vm.id_cuenta     = cc.id_cuenta
    JOIN programa          pr  ON vm.id_prog       = pr.id_programa
    JOIN periodo_academico pa  ON cc.id_periodo    = pa.id_periodo
    JOIN regla_cobro       rc  ON rc.id_periodo    = p_id_periodo
                              AND rc.id_programa   = v_id_programa
    WHERE cc.id_estudiante = p_id_estudiante
      AND cc.id_periodo    = p_id_periodo
    LIMIT 1;

    -- ── Result Set 2: Asignaturas (solo POR_CREDITOS) ─────────
    IF v_modalidad = 'POR_CREDITOS' THEN
        SELECT
            a.codigo                                AS codigo_asig,
            a.nombre                                AS asignatura,
            a.creditos,
            a.creditos * v_valor_credito            AS valor_asignatura
        FROM plan_estudio pe
        JOIN asignatura   a ON a.id_asignatura = pe.id_asignatura
        WHERE pe.id_programa = v_id_programa
          AND pe.semestre    = v_semestre
        ORDER BY a.nombre;
    ELSE
        SELECT
            NULL AS codigo_asig,
            NULL AS asignatura,
            NULL AS creditos,
            NULL AS valor_asignatura
        WHERE 1 = 0;
    END IF;

    -- ── Result Set 3: Descuentos aplicados ────────────────────
    SELECT
        td.nombre                                   AS tipo_beca,
        da.porcentaje,
        da.valor_descuento,
        da.observacion,
        da.fecha_aplicacion
    FROM descuento_aplicado   da
    JOIN tipo_descuento       td  ON da.id_tipo   = td.id_tipo
    WHERE da.id_cuenta = v_id_cuenta
    ORDER BY da.fecha_aplicacion;

    -- ── Result Set 4: Pagos realizados ────────────────────────
    SELECT
        cd.nombre                                   AS concepto,
        pg.metodo_pago,
        pg.valor,
        pg.fecha_pago,
        pg.observacion
    FROM pago           pg
    JOIN codigo_detalle cd  ON pg.id_codigo = cd.id_codigo
    WHERE pg.id_cuenta = v_id_cuenta
      AND cd.codigo   != 'DESC'
    ORDER BY pg.fecha_pago;

END$$

DELIMITER ;


-- ============================================================
-- EJEMPLO DE USO (descomentar para probar):
-- ============================================================
/*
CALL sp_volante_matricula(1, 1);
-- RS1: cabecera + totales + estado
-- RS2: asignaturas (si POR_CREDITOS) o vacío (si GLOBAL)
-- RS3: descuentos aplicados
-- RS4: pagos realizados
*/
