-- ============================================================
-- 03_vistas_sp.sql — VISTAS, TRIGGERS Y STORED PROCEDURES
-- Sistema de Matrículas — UniCaribe

USE matriculas_uni;

-- ============================================================
-- VISTA 1: v_cuenta_corriente_resumen
-- Muestra el estado financiero de cada cuenta corriente.
-- Los totales se calculan dinámicamente (no columnas guardadas).
-- ============================================================

CREATE OR REPLACE VIEW v_cuenta_corriente_resumen AS
SELECT
    cc.id_cuenta,
    cc.id_estudiante,
    cc.id_periodo,
    CONCAT(e.nombres, ' ', e.apellidos)                     AS estudiante,
    e.num_doc,
    e.email,
    pa.nombre                                               AS periodo,
    pa.fecha_inicio,
    pa.fecha_fin,
    COALESCE((
        SELECT SUM(mc.monto)
        FROM movimiento_cuenta mc
        JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
        WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
    ), 0)                                                   AS total_cobros,
    COALESCE((
        SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
    ), 0)                                                   AS total_pagos,
    COALESCE((
        SELECT SUM(mc.monto)
        FROM movimiento_cuenta mc
        JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
        WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
    ), 0) -
    COALESCE((
        SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
    ), 0)                                                   AS saldo_pendiente,
    CASE
        WHEN (
            COALESCE((SELECT SUM(mc.monto) FROM movimiento_cuenta mc
                      JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                      WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0)
            -
            COALESCE((SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta), 0)
        ) > 0 THEN 'PENDIENTE'
        ELSE 'BALANCEADO'
    END                                                     AS estado,
    cc.fecha_cre
FROM cuenta_corriente  cc
JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo;


-- ============================================================
-- VISTA 2: v_movimientos_con_saldo
-- Movimientos con saldo acumulado fila por fila usando
-- window functions (MySQL 8+).
-- ============================================================
CREATE OR REPLACE VIEW v_movimientos_con_saldo AS
SELECT
    mc.id_movimiento,
    cc.id_cuenta,
    cc.id_estudiante,
    cc.id_periodo,
    cd.descripcion                                          AS movimiento,
    cd.codigo,
    cd.grupo                                                AS tipo,
    mc.monto                                                AS valor,
    SUM(
        CASE cd.grupo
            WHEN 'COBRO' THEN  mc.monto
            WHEN 'PAGO'  THEN -mc.monto
            ELSE 0
        END
    ) OVER (
        PARTITION BY mc.id_cuenta
        ORDER BY mc.fecha ASC, mc.id_movimiento ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                       AS saldo_acumulado,
    mc.fecha,
    mc.descrip                                              AS observacion
FROM movimiento_cuenta mc
JOIN cuenta_corriente  cc ON mc.id_cuenta = cc.id_cuenta
JOIN codigo_detalle    cd ON mc.id_codigo  = cd.id_codigo;


-- ============================================================
-- VISTA 3: v_volante_detalle
-- Datos completos del volante para impresión.
-- ============================================================
CREATE OR REPLACE VIEW v_volante_detalle AS
SELECT
    vm.id_volante,
    vm.id_estu,
    vm.id_per,
    vm.id_prog,
    vm.semestre,
    vm.modalidad,
    vm.val_tot,
    vm.fecha_gen,
    vm.id_cuenta,
    CONCAT(e.nombres, ' ', e.apellidos)                     AS estudiante,
    e.num_doc,
    e.email,
    e.telefono,
    pa.nombre                                               AS periodo,
    pa.fecha_inicio,
    pa.fecha_fin,
    pr.codigo                                               AS codigo_programa,
    pr.nombre                                               AS programa,
    rc.modalidad_cobro,
    rc.valor_global,
    rc.valor_credito
FROM volante_matricula vm
JOIN estudiante        e   ON vm.id_estu = e.id_estudiante
JOIN periodo_academico pa  ON vm.id_per  = pa.id_periodo
JOIN programa_academico pr ON vm.id_prog = pr.id_programa
LEFT JOIN regla_cobro   rc ON rc.id_periodo  = vm.id_per
                           AND rc.id_programa = vm.id_prog;


-- ============================================================
-- VISTA 4: v_descuentos_aplicados
-- Descuentos registrados con contexto de estudiante y periodo.
-- ============================================================
CREATE OR REPLACE VIEW v_descuentos_aplicados AS
SELECT
    da.id_descuento,
    CONCAT(e.nombres, ' ', e.apellidos)                     AS estudiante,
    e.num_doc                                               AS documento,
    pa.nombre                                               AS periodo,
    td.nombre                                               AS tipo_beca,
    da.porcentaje,
    da.valor_descuento,
    da.observacion,
    CONCAT(up.nombres, ' ', up.apellidos)                   AS aplicado_por,
    da.fecha_aplicacion
FROM descuento_aplicado   da
JOIN cuenta_corriente     cc  ON da.id_cuenta     = cc.id_cuenta
JOIN estudiante           e   ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico    pa  ON cc.id_periodo    = pa.id_periodo
JOIN tipo_descuento       td  ON da.id_tipo       = td.id_tipo
JOIN usuario              u   ON da.id_usuario    = u.id_usuario
JOIN persona              up  ON u.id_persona     = up.id_persona
ORDER BY da.fecha_aplicacion DESC;


-- ============================================================
-- VISTA 5: v_pagos_pse
-- Transacciones PSE con estado y datos del estudiante.
-- ============================================================
CREATE OR REPLACE VIEW v_pagos_pse AS
SELECT
    pp.id_pse,
    CONCAT(e.nombres, ' ', e.apellidos)                     AS estudiante,
    e.num_doc                                               AS documento,
    pa.nombre                                               AS periodo,
    bp.nombre                                               AS banco,
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


-- ============================================================
-- STORED PROCEDURE 1: sp_verificar_balance
-- Verifica que los cobros y pagos cuadren en todas las cuentas.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_verificar_balance;

DELIMITER $$

CREATE PROCEDURE sp_verificar_balance()
BEGIN
    SELECT
        cc.id_cuenta,
        CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
        pa.nombre                               AS periodo,
        COALESCE((
            SELECT SUM(mc.monto)
            FROM movimiento_cuenta mc
            JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
            WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
        ), 0)                                   AS total_cobros,
        COALESCE((
            SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
        ), 0)                                   AS total_pagos,
        COALESCE((
            SELECT SUM(mc.monto)
            FROM movimiento_cuenta mc
            JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
            WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
        ), 0) -
        COALESCE((
            SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
        ), 0)                                   AS saldo_pendiente,
        CASE
            WHEN (
                COALESCE((SELECT SUM(mc.monto) FROM movimiento_cuenta mc
                          JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                          WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0)
                -
                COALESCE((SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta), 0)
            ) = 0 THEN 'BALANCEADO'
            ELSE 'PENDIENTE'
        END                                     AS estado
    FROM cuenta_corriente  cc
    JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
    JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
    ORDER BY estado DESC, pa.nombre DESC;
END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURE 2: sp_aplicar_descuento
-- Aplica un descuento porcentual a la cuenta corriente
-- de un estudiante y registra el movimiento.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_aplicar_descuento;

DELIMITER $$

CREATE PROCEDURE sp_aplicar_descuento(
    IN  p_id_estudiante INT,
    IN  p_id_periodo    INT,
    IN  p_id_tipo       INT,
    IN  p_porcentaje    DECIMAL(5,2),
    IN  p_observacion   VARCHAR(255),
    IN  p_id_usuario    INT
)
sp_aplicar_descuento: BEGIN
    DECLARE v_id_cuenta     INT;
    DECLARE v_total_cobros  DECIMAL(12,2);
    DECLARE v_valor_desc    DECIMAL(12,2);
    DECLARE v_id_codigo     INT;
    DECLARE v_id_pago       INT;
    DECLARE v_rol           VARCHAR(50);

    -- Validar porcentaje
    IF p_porcentaje NOT IN (10, 20, 25, 50, 100) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Porcentaje no válido. Use 10, 20, 25, 50 o 100.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- Validar rol del usuario
    SELECT r.nombre INTO v_rol
    FROM usuario u JOIN rol r ON u.id_rol = r.id_rol
    WHERE u.id_usuario = p_id_usuario AND u.activo = 1 LIMIT 1;

    IF v_rol NOT IN ('ADMINISTRADOR', 'SUPERVISOR') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sin permiso para aplicar descuentos.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- Obtener cuenta corriente
    SELECT id_cuenta INTO v_id_cuenta
    FROM cuenta_corriente
    WHERE id_estudiante = p_id_estudiante AND id_periodo = p_id_periodo LIMIT 1;

    IF v_id_cuenta IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe cuenta corriente para ese estudiante y periodo.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- Calcular total cobros
    SELECT COALESCE(SUM(mc.monto), 0) INTO v_total_cobros
    FROM movimiento_cuenta mc
    JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
    WHERE mc.id_cuenta = v_id_cuenta AND cd.grupo = 'COBRO';

    IF v_total_cobros <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cuenta no tiene cobros registrados.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- Calcular valor del descuento
    SET v_valor_desc = ROUND(v_total_cobros * (p_porcentaje / 100), 2);

    -- Obtener código DESC
    SELECT id_codigo INTO v_id_codigo
    FROM codigo_detalle WHERE codigo = 'DESC' AND grupo = 'PAGO' LIMIT 1;

    IF v_id_codigo IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Código DESC no encontrado en codigo_detalle.';
        LEAVE sp_aplicar_descuento;
    END IF;

    -- Insertar en tabla pago
    INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
    VALUES (v_id_cuenta, p_id_usuario, 'DESCUENTO', CONCAT('DESC-', NOW()), v_valor_desc, NOW());
    SET v_id_pago = LAST_INSERT_ID();

    -- Registrar movimiento
    INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
    VALUES (v_id_cuenta, v_id_codigo,
            COALESCE(p_observacion, CONCAT('Descuento ', p_porcentaje, '% aplicado')),
            v_valor_desc, NOW(), p_id_usuario);

    -- Registrar en descuento_aplicado
    INSERT INTO descuento_aplicado
        (id_cuenta, id_tipo, id_pago, id_usuario, porcentaje, valor_descuento, observacion)
    VALUES
        (v_id_cuenta, p_id_tipo, v_id_pago, p_id_usuario, p_porcentaje, v_valor_desc,
         COALESCE(p_observacion, CONCAT('Descuento ', p_porcentaje, '%')));

END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURE 3: sp_iniciar_pago_pse
-- Inicia una transacción PSE pendiente de confirmación.
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

    SET v_referencia = CONCAT('PSE', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
                              LPAD(FLOOR(RAND() * 9999), 4, '0'));

    INSERT INTO pago_pse (id_cuenta, id_banco, valor, referencia, estado, usuario_banco)
    VALUES (p_id_cuenta, p_id_banco, p_valor, v_referencia, 'PENDIENTE', p_usuario_banco);

    SET o_id_pse     = LAST_INSERT_ID();
    SET o_referencia = v_referencia;
    SET o_mensaje    = CONCAT('OK: PSE iniciado. Ref: ', v_referencia);
END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURE 4: sp_confirmar_pago_pse
-- Confirma una transacción PSE y registra el pago y movimiento.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_confirmar_pago_pse;

DELIMITER $$

CREATE PROCEDURE sp_confirmar_pago_pse(
    IN  p_id_pse    INT,
    IN  p_id_usuario INT,
    OUT o_id_pago   INT,
    OUT o_mensaje   VARCHAR(255)
)
sp_confirmar_pago_pse: BEGIN
    DECLARE v_id_cuenta  INT;
    DECLARE v_valor      DECIMAL(12,2);
    DECLARE v_referencia VARCHAR(50);
    DECLARE v_estado     VARCHAR(20);
    DECLARE v_id_codigo  INT;
    DECLARE v_id_pago    INT;

    SELECT id_cuenta, valor, referencia, estado
    INTO   v_id_cuenta, v_valor, v_referencia, v_estado
    FROM   pago_pse WHERE id_pse = p_id_pse LIMIT 1;

    IF v_id_cuenta IS NULL THEN
        SET o_id_pago = NULL;
        SET o_mensaje = 'ERROR: Transacción PSE no encontrada.';
        LEAVE sp_confirmar_pago_pse;
    END IF;

    IF v_estado != 'PENDIENTE' THEN
        SET o_id_pago = NULL;
        SET o_mensaje = CONCAT('ERROR: Transacción ya procesada con estado: ', v_estado);
        LEAVE sp_confirmar_pago_pse;
    END IF;

    -- Obtener código MPAG
    SELECT id_codigo INTO v_id_codigo
    FROM codigo_detalle WHERE codigo = 'MPAG' AND grupo = 'PAGO' LIMIT 1;

    -- Insertar pago
    INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
    VALUES (v_id_cuenta, p_id_usuario, 'PSE', v_referencia, v_valor, NOW());
    SET v_id_pago = LAST_INSERT_ID();

    -- Registrar movimiento
    INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
    VALUES (v_id_cuenta, v_id_codigo,
            CONCAT('Pago PSE confirmado - Ref: ', v_referencia),
            v_valor, NOW(), p_id_usuario);

    -- Actualizar pago_pse
    UPDATE pago_pse
    SET estado = 'APROBADO', id_pago = v_id_pago, fecha_confirmacion = NOW()
    WHERE id_pse = p_id_pse;

    SET o_id_pago = v_id_pago;
    SET o_mensaje = CONCAT('OK: Pago PSE aprobado. Ref: ', v_referencia);
END$$

DELIMITER ;


-- ============================================================
-- STORED PROCEDURE 5: sp_cuenta_corriente
-- Devuelve resumen y movimientos de una cuenta corriente.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_cuenta_corriente;

DELIMITER $$

CREATE PROCEDURE sp_cuenta_corriente(
    IN p_id_estudiante INT,
    IN p_id_periodo    INT
)
BEGIN
    -- Result Set 1: Resumen
    SELECT
        cc.id_cuenta,
        CONCAT(e.nombres, ' ', e.apellidos)     AS estudiante,
        e.num_doc,
        pa.nombre                               AS periodo,
        COALESCE((
            SELECT SUM(mc.monto)
            FROM movimiento_cuenta mc
            JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
            WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
        ), 0)                                   AS total_cobros,
        COALESCE((
            SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
        ), 0)                                   AS total_pagos,
        COALESCE((
            SELECT SUM(mc.monto)
            FROM movimiento_cuenta mc
            JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
            WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
        ), 0) -
        COALESCE((
            SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
        ), 0)                                   AS saldo_pendiente
    FROM cuenta_corriente  cc
    JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
    JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
    WHERE cc.id_estudiante = p_id_estudiante
      AND cc.id_periodo    = p_id_periodo
    LIMIT 1;

    -- Result Set 2: Movimientos con saldo acumulado
    SELECT
        cd.descripcion                          AS movimiento,
        cd.codigo,
        cd.grupo                                AS tipo,
        mc.monto                                AS valor,
        SUM(
            CASE cd.grupo
                WHEN 'COBRO' THEN  mc.monto
                WHEN 'PAGO'  THEN -mc.monto
                ELSE 0
            END
        ) OVER (
            PARTITION BY mc.id_cuenta
            ORDER BY mc.fecha ASC, mc.id_movimiento ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                       AS saldo_acumulado,
        mc.fecha,
        mc.descrip                              AS observacion
    FROM movimiento_cuenta mc
    JOIN cuenta_corriente  cc ON mc.id_cuenta  = cc.id_cuenta
    JOIN codigo_detalle    cd ON mc.id_codigo  = cd.id_codigo
    WHERE cc.id_estudiante = p_id_estudiante
      AND cc.id_periodo    = p_id_periodo
    ORDER BY mc.fecha ASC, mc.id_movimiento ASC;
END$$

DELIMITER ;


-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT 'Vistas creadas:' AS info;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

SELECT 'Procedimientos creados:' AS info;
SHOW PROCEDURE STATUS WHERE Db = 'matriculas_uni';

SELECT 'Tablas en la BD:' AS info;
SHOW TABLES;
