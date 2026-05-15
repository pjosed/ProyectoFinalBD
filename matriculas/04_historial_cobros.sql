-- ============================================================
-- 03_historial_cobros.sql — DATOS HISTÓRICOS DE COBROS
-- Sistema de Matrículas — UniCaribe
-- Periodos: 2025-1 y 2025-2
-- ============================================================
-- INSTRUCCIONES:
--   Ejecutar DESPUÉS de 02_datos_semilla_completo_v2.sql
--   y DESPUÉS de haber creado el usuario administrador.
-- ============================================================

USE matriculas_uni;

-- ============================================================
-- VARIABLES DE APOYO
-- Usamos subconsultas para obtener IDs dinámicamente
-- así no depende del orden de inserción
-- ============================================================

-- ============================================================
-- PERIODO 2025-1
-- Estudiantes 1-8 con diferentes programas
-- ============================================================

-- Cuentas corrientes 2025-1
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-01-25 08:00:00'
FROM estudiante e, periodo_academico pa
WHERE pa.nombre = '2025-1'
  AND e.num_doc IN (
    '1001234501','1001234502','1001234503','1001234504',
    '1001234505','1001234506','1001234507','1001234508'
  );

-- Volantes 2025-1 — modalidad GLOBAL (ADM-EMP, CON-PUB, DER, PSI)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT
    e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global',
    rc.valor_global, '2025-01-25 09:00:00',
    cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-1'
JOIN usuario u ON u.username = 'admin'
JOIN (
    SELECT '1001234501' num_doc, 'ADM-EMP' cod_prog, 1 semestre UNION ALL
    SELECT '1001234502', 'ADM-EMP', 2 UNION ALL
    SELECT '1001234503', 'CON-PUB', 1 UNION ALL
    SELECT '1001234504', 'DER', 1 UNION ALL
    SELECT '1001234505', 'PSI', 2
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

-- Movimientos COBRO 2025-1 (GLOBAL)
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    cc.id_cuenta,
    cd.id_codigo,
    CONCAT('Matrícula semestre ', vm.semestre, ' — ', pa.nombre),
    vm.val_tot,
    '2025-01-25 09:30:00',
    u.id_usuario
FROM volante_matricula vm
JOIN cuenta_corriente cc ON vm.id_cuenta = cc.id_cuenta
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN codigo_detalle cd ON cd.codigo = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario u ON u.username = 'admin';

-- Pagos 2025-1 — todos pagaron completo
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT
    cc.id_cuenta,
    u.id_usuario,
    CASE (cc.id_cuenta % 3)
        WHEN 0 THEN 'PSE'
        WHEN 1 THEN 'Efectivo'
        ELSE 'Cheque'
    END,
    CONCAT('REF-2025-1-', cc.id_cuenta),
    vm.val_tot,
    '2025-02-05 10:00:00'
FROM cuenta_corriente cc
JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo AND pa.nombre = '2025-1'
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN usuario u ON u.username = 'admin';

-- Movimientos PAGO 2025-1
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    p.id_cuenta,
    cd.id_codigo,
    CONCAT('Pago recibido — ', p.medio),
    p.monto,
    p.fecha,
    p.id_usuario
FROM pago p
JOIN cuenta_corriente cc ON p.id_cuenta = cc.id_cuenta
JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo AND pa.nombre = '2025-1'
JOIN codigo_detalle cd ON cd.codigo = 'MPAG' AND cd.grupo = 'PAGO';


-- ============================================================
-- PERIODO 2025-2
-- Estudiantes 1-12, algunos con descuentos, algunos pendientes
-- ============================================================

-- Cuentas corrientes 2025-2
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-07-20 08:00:00'
FROM estudiante e, periodo_academico pa
WHERE pa.nombre = '2025-2'
  AND e.num_doc IN (
    '1001234501','1001234502','1001234503','1001234504',
    '1001234505','1001234506','1001234507','1001234508',
    '1001234509','1001234510','1001234511','1001234512'
  );

-- Volantes 2025-2 — modalidad GLOBAL
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT
    e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global',
    rc.valor_global, '2025-07-20 09:00:00',
    cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
JOIN usuario u ON u.username = 'admin'
JOIN (
    SELECT '1001234501' num_doc, 'ADM-EMP' cod_prog, 2 semestre UNION ALL
    SELECT '1001234502', 'ADM-EMP', 3 UNION ALL
    SELECT '1001234503', 'CON-PUB', 2 UNION ALL
    SELECT '1001234504', 'DER', 2 UNION ALL
    SELECT '1001234505', 'PSI', 3 UNION ALL
    SELECT '1001234507', 'ADM-EMP', 1 UNION ALL
    SELECT '1001234508', 'CON-PUB', 1 UNION ALL
    SELECT '1001234509', 'DER', 1 UNION ALL
    SELECT '1001234510', 'PSI', 1 UNION ALL
    SELECT '1001234511', 'ADM-EMP', 4 UNION ALL
    SELECT '1001234512', 'CON-PUB', 3
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

-- Volante 2025-2 — modalidad POR_CREDITOS (ING-SIS)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT
    e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, 3, 'Creditos',
    rc.valor_credito * 14, '2025-07-20 09:00:00',
    cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
JOIN usuario u ON u.username = 'admin'
JOIN programa_academico prog ON prog.codigo = 'ING-SIS'
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo
WHERE e.num_doc = '1001234506';

-- Movimientos COBRO 2025-2
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    cc.id_cuenta,
    cd.id_codigo,
    CONCAT('Matrícula semestre ', vm.semestre, ' — ', pa.nombre),
    vm.val_tot,
    '2025-07-20 09:30:00',
    u.id_usuario
FROM volante_matricula vm
JOIN cuenta_corriente cc ON vm.id_cuenta = cc.id_cuenta
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN codigo_detalle cd ON cd.codigo = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario u ON u.username = 'admin';

-- Pagos 2025-2 — estudiantes 1-9 pagaron, 10-12 pendientes
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT
    cc.id_cuenta,
    u.id_usuario,
    CASE (cc.id_cuenta % 3)
        WHEN 0 THEN 'PSE'
        WHEN 1 THEN 'Efectivo'
        ELSE 'Cheque'
    END,
    CONCAT('REF-2025-2-', cc.id_cuenta),
    vm.val_tot,
    '2025-08-10 10:00:00'
FROM cuenta_corriente cc
JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo AND pa.nombre = '2025-2'
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN estudiante e ON cc.id_estudiante = e.id_estudiante
JOIN usuario u ON u.username = 'admin'
WHERE e.num_doc IN (
    '1001234501','1001234502','1001234503',
    '1001234504','1001234505','1001234506',
    '1001234507','1001234508','1001234509'
);

-- Descuento beca 2025-2 para estudiante 1001234510
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT cc.id_cuenta, u.id_usuario, 'DESCUENTO',
    CONCAT('DESC-2025-2-', cc.id_cuenta),
    vm.val_tot * 0.25, '2025-08-01 10:00:00'
FROM cuenta_corriente cc
JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo AND pa.nombre = '2025-2'
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN estudiante e ON cc.id_estudiante = e.id_estudiante
JOIN usuario u ON u.username = 'admin'
WHERE e.num_doc = '1001234510';

-- Movimientos PAGO 2025-2
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    p.id_cuenta,
    cd.id_codigo,
    CONCAT('Pago recibido — ', p.medio),
    p.monto,
    p.fecha,
    p.id_usuario
FROM pago p
JOIN cuenta_corriente cc ON p.id_cuenta = cc.id_cuenta
JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo AND pa.nombre = '2025-2'
JOIN codigo_detalle cd ON cd.codigo = 'MPAG' AND cd.grupo = 'PAGO';

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT 'Historial cargado:' AS info;
SELECT pa.nombre AS periodo,
       COUNT(DISTINCT cc.id_cuenta) AS cuentas,
       COUNT(DISTINCT vm.id_volante) AS volantes,
       COUNT(DISTINCT p.id_pago) AS pagos,
       SUM(vm.val_tot) AS total_cobrado,
       SUM(p.monto) AS total_pagado
FROM periodo_academico pa
LEFT JOIN cuenta_corriente cc ON pa.id_periodo = cc.id_periodo
LEFT JOIN volante_matricula vm ON cc.id_cuenta = vm.id_cuenta
LEFT JOIN pago p ON cc.id_cuenta = p.id_cuenta
WHERE pa.nombre IN ('2025-1','2025-2')
GROUP BY pa.nombre
ORDER BY pa.nombre;
