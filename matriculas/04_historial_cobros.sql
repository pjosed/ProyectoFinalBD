-- ============================================================
-- 04_historial_cobros.sql — DATOS HISTÓRICOS DE COBROS
-- Sistema de Matrículas — UniCaribe
-- Periodos: 2025-1 y 2025-2
-- ============================================================
-- INSTRUCCIONES:
--   Ejecutar DESPUÉS de 02_datos_semilla.sql
--   y DESPUÉS de haber creado el usuario administrador.
--
-- DISEÑO:
--   - Los 20 estudiantes del semilla (1001234501–1001234520)
--     son los del PERIODO ACTIVO (2026-1). No se tocan aquí.
--   - Este script inserta 16 estudiantes históricos propios,
--     con nombres únicos y reales, distribuidos en 2025-1 y 2025-2.
--   - Cada cuenta_corriente tiene su volante correspondiente.
--     No hay cuentas huérfanas sin programa.
-- ============================================================

USE matriculas_uni;

-- ============================================================
-- ESTUDIANTES HISTÓRICOS (usados solo en este script)
-- Nombres únicos, distintos a los del semilla
-- ============================================================
INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC','1003001001','Alejandro',  'Pedraza Niño',       'apedraza@estudiante.edu.co',    '3201110001'),
    ('CC','1003001002','Natalia',    'Cifuentes Prada',    'ncifuentes@estudiante.edu.co',  '3201110002'),
    ('CC','1003001003','Ricardo',    'Palomino Useche',    'rpalomino@estudiante.edu.co',   '3201110003'),
    ('CC','1003001004','Paola',      'Acosta Barrera',     'pacosta@estudiante.edu.co',     '3201110004'),
    ('CC','1003001005','Cristian',   'Bohórquez Leal',     'cbohorquez@estudiante.edu.co',  '3201110005'),
    ('CC','1003001006','Luisa',      'Serrano Palacios',   'lserrano@estudiante.edu.co',    '3201110006'),
    ('CC','1003001007','Esteban',    'Amaya Contreras',    'eamaya@estudiante.edu.co',      '3201110007'),
    ('CC','1003001008','Juliana',    'Becerra Pinzón',     'jbecerra@estudiante.edu.co',    '3201110008'),
    ('CC','1003001009','Héctor',     'Fuentes Alvarado',   'hfuentes@estudiante.edu.co',    '3201110009'),
    ('CC','1003001010','Marcela',    'Iglesias Buitrago',  'miglesias@estudiante.edu.co',   '3201110010'),
    ('CC','1003001011','Omar',       'Castellanos Vega',   'ocastellanos@estudiante.edu.co','3201110011'),
    ('CC','1003001012','Patricia',   'Naranjo Correa',     'pnaranjo@estudiante.edu.co',    '3201110012'),
    ('CC','1003001013','Germán',     'Suárez Triana',      'gsuarez@estudiante.edu.co',     '3201110013'),
    ('CC','1003001014','Claudia',    'Rangel Mendoza',     'crangel@estudiante.edu.co',     '3201110014'),
    ('CC','1003001015','Iván',       'Portilla Sandoval',  'iportilla@estudiante.edu.co',   '3201110015'),
    ('CC','1003001016','Andrea',     'Solano Villamizar',  'asolano@estudiante.edu.co',     '3201110016');


-- ============================================================
-- PERIODO 2025-1
-- 8 estudiantes, cada uno con cuenta + volante + cobro + pago
-- ============================================================

-- Cuentas corrientes 2025-1
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-01-25 08:00:00'
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-1'
WHERE e.num_doc IN (
    '1003001001','1003001002','1003001003','1003001004',
    '1003001005','1003001006','1003001007','1003001008'
);

-- Volantes 2025-1
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT
    e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global',
    rc.valor_global, '2025-01-25 09:00:00',
    cc.id_cuenta
FROM estudiante e
JOIN periodo_academico  pa   ON pa.nombre          = '2025-1'
JOIN usuario            u    ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1003001001' num_doc, 'ADM-EMP' cod_prog, 1 semestre UNION ALL
    SELECT '1003001002', 'CON-PUB', 1                           UNION ALL
    SELECT '1003001003', 'DER',     1                           UNION ALL
    SELECT '1003001004', 'PSI',     2                           UNION ALL
    SELECT '1003001005', 'ADM-EMP', 3                           UNION ALL
    SELECT '1003001006', 'CON-PUB', 2                           UNION ALL
    SELECT '1003001007', 'DER',     2                           UNION ALL
    SELECT '1003001008', 'PSI',     1
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo         = t.cod_prog
JOIN regla_cobro        rc   ON rc.id_periodo        = pa.id_periodo
                             AND rc.id_programa       = prog.id_programa
JOIN cuenta_corriente   cc   ON cc.id_estudiante     = e.id_estudiante
                             AND cc.id_periodo         = pa.id_periodo;

-- Cobros 2025-1 (movimiento_cuenta PMAT)
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    cc.id_cuenta,
    cd.id_codigo,
    CONCAT('Matrícula semestre ', vm.semestre, ' — 2025-1'),
    vm.val_tot,
    '2025-01-25 10:00:00',
    u.id_usuario
FROM cuenta_corriente   cc
JOIN volante_matricula  vm  ON vm.id_cuenta  = cc.id_cuenta
JOIN codigo_detalle     cd  ON cd.codigo     = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario            u   ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico  pa  ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante         e   ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1003001001','1003001002','1003001003','1003001004',
    '1003001005','1003001006','1003001007','1003001008'
);

-- Pagos completos 2025-1 (todos pagaron)
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT
    cc.id_cuenta,
    u.id_usuario,
    'PSE',
    CONCAT('PSE-2025-1-', e.num_doc),
    vm.val_tot,
    '2025-02-05 14:00:00'
FROM cuenta_corriente   cc
JOIN volante_matricula  vm  ON vm.id_cuenta    = cc.id_cuenta
JOIN usuario            u   ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico  pa  ON pa.id_periodo   = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante         e   ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1003001001','1003001002','1003001003','1003001004',
    '1003001005','1003001006','1003001007','1003001008'
);

-- Movimiento de pago MPAG 2025-1
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    p.id_cuenta,
    cd.id_codigo,
    'Pago recibido — PSE',
    p.monto,
    p.fecha,
    p.id_usuario
FROM pago p
JOIN codigo_detalle     cd  ON cd.codigo    = 'MPAG' AND cd.grupo = 'PAGO'
JOIN cuenta_corriente   cc  ON cc.id_cuenta = p.id_cuenta
JOIN periodo_academico  pa  ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante         e   ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1003001001','1003001002','1003001003','1003001004',
    '1003001005','1003001006','1003001007','1003001008'
);


-- ============================================================
-- PERIODO 2025-2
-- 8 estudiantes nuevos, mezcla de pagados y pendientes
-- ============================================================

-- Cuentas corrientes 2025-2
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-07-20 08:00:00'
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
WHERE e.num_doc IN (
    '1003001009','1003001010','1003001011','1003001012',
    '1003001013','1003001014','1003001015','1003001016'
);

-- Volantes 2025-2 (6 GLOBAL + 2 POR_CREDITOS)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT
    e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global',
    rc.valor_global, '2025-07-20 09:00:00',
    cc.id_cuenta
FROM estudiante e
JOIN periodo_academico  pa   ON pa.nombre          = '2025-2'
JOIN usuario            u    ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1003001009' num_doc, 'ADM-EMP' cod_prog, 2 semestre UNION ALL
    SELECT '1003001010', 'CON-PUB', 1                           UNION ALL
    SELECT '1003001011', 'DER',     3                           UNION ALL
    SELECT '1003001012', 'PSI',     2                           UNION ALL
    SELECT '1003001013', 'ADM-EMP', 4                           UNION ALL
    SELECT '1003001014', 'CON-PUB', 3
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo         = t.cod_prog
JOIN regla_cobro        rc   ON rc.id_periodo        = pa.id_periodo
                             AND rc.id_programa       = prog.id_programa
JOIN cuenta_corriente   cc   ON cc.id_estudiante     = e.id_estudiante
                             AND cc.id_periodo         = pa.id_periodo;

-- Volantes 2025-2 — POR_CREDITOS (ING-SIS)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT
    e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Creditos',
    rc.valor_credito * t.creditos, '2025-07-20 09:00:00',
    cc.id_cuenta
FROM estudiante e
JOIN periodo_academico  pa   ON pa.nombre          = '2025-2'
JOIN usuario            u    ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1003001015' num_doc, 'ING-SIS' cod_prog, 2 semestre, 15 creditos UNION ALL
    SELECT '1003001016', 'ING-SIS', 3, 16
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo         = t.cod_prog
JOIN regla_cobro        rc   ON rc.id_periodo        = pa.id_periodo
                             AND rc.id_programa       = prog.id_programa
JOIN cuenta_corriente   cc   ON cc.id_estudiante     = e.id_estudiante
                             AND cc.id_periodo         = pa.id_periodo;

-- Cobros 2025-2
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    cc.id_cuenta,
    cd.id_codigo,
    CONCAT('Matrícula semestre ', vm.semestre, ' — 2025-2'),
    vm.val_tot,
    '2025-07-20 10:00:00',
    u.id_usuario
FROM cuenta_corriente   cc
JOIN volante_matricula  vm  ON vm.id_cuenta  = cc.id_cuenta
JOIN codigo_detalle     cd  ON cd.codigo     = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario            u   ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico  pa  ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante         e   ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1003001009','1003001010','1003001011','1003001012',
    '1003001013','1003001014','1003001015','1003001016'
);

-- Pagos 2025-2 — solo los primeros 5 pagaron, los últimos 3 quedan pendientes
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT
    cc.id_cuenta,
    u.id_usuario,
    'CAJA',
    CONCAT('CAJA-2025-2-', e.num_doc),
    vm.val_tot,
    '2025-08-01 11:00:00'
FROM cuenta_corriente   cc
JOIN volante_matricula  vm  ON vm.id_cuenta    = cc.id_cuenta
JOIN usuario            u   ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico  pa  ON pa.id_periodo   = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante         e   ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1003001009','1003001010','1003001011','1003001012','1003001013'
);

-- Movimiento MPAG 2025-2 (solo los que pagaron)
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    p.id_cuenta,
    cd.id_codigo,
    'Pago recibido — Caja',
    p.monto,
    p.fecha,
    p.id_usuario
FROM pago p
JOIN codigo_detalle     cd  ON cd.codigo    = 'MPAG' AND cd.grupo = 'PAGO'
JOIN cuenta_corriente   cc  ON cc.id_cuenta = p.id_cuenta
JOIN periodo_academico  pa  ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante         e   ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1003001009','1003001010','1003001011','1003001012','1003001013'
);

-- ============================================================
-- ASIGNATURAS DE VOLANTES POR CRÉDITOS
-- Iván Portilla (semestre 2, ING-SIS) y Andrea Solano (semestre 3, ING-SIS)
-- ============================================================

INSERT INTO volante_asignatura (id_volante, id_asig)
SELECT vm.id_volante, pe.id_asignatura
FROM volante_matricula vm
JOIN estudiante e ON e.id_estudiante = vm.id_estu
JOIN plan_estudio pe ON pe.id_programa = vm.id_prog AND pe.semestre = vm.semestre
WHERE e.num_doc IN ('1003001015', '1003001016')
  AND vm.modalidad = 'Creditos';

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT
    e.nombres, e.apellidos, e.num_doc,
    pa.nombre AS periodo,
    pr.nombre AS programa,
    vm.semestre, vm.modalidad, vm.val_tot,
    CASE WHEN p.id_pago IS NOT NULL THEN 'PAGADO' ELSE 'PENDIENTE' END AS estado_pago
FROM estudiante         e
JOIN cuenta_corriente   cc  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico  pa  ON pa.id_periodo    = cc.id_periodo
JOIN volante_matricula  vm  ON vm.id_cuenta     = cc.id_cuenta
JOIN programa_academico pr  ON pr.id_programa   = vm.id_prog
LEFT JOIN pago          p   ON p.id_cuenta      = cc.id_cuenta
WHERE e.num_doc LIKE '1003%'
ORDER BY pa.nombre, e.apellidos;
