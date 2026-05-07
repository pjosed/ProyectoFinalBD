-- ============================================================
-- 03_datos_semilla.sql — DATOS BÁSICOS PARA PRUEBAS
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Responsable: Danilo Vergel
-- Ejecutar DESPUÉS de 02_tablas_negocio.sql
-- ============================================================

USE matriculas_uni;

-- ────────────────────────────────────────────────────────────
-- PROGRAMAS ACADÉMICOS
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO programa (codigo, nombre, modalidad, nivel, total_semestres, total_creditos) VALUES
    ('ING-SIS-P',  'Ingeniería de Sistemas',          'PRESENCIAL', 'PREGRADO',   9, 168),
    ('ING-SIS-V',  'Ingeniería de Sistemas',          'VIRTUAL',    'PREGRADO',   9, 168),
    ('ADM-EMP-P',  'Administración de Empresas',      'PRESENCIAL', 'PREGRADO',   8, 150),
    ('ADM-EMP-M',  'Administración de Empresas',      'MIXTA',      'PREGRADO',   8, 150),
    ('CON-PUB-P',  'Contaduría Pública',              'PRESENCIAL', 'PREGRADO',   8, 145),
    ('PSI-P',      'Psicología',                      'PRESENCIAL', 'PREGRADO',   9, 160),
    ('TEC-SIS-P',  'Tecnología en Sistemas',          'PRESENCIAL', 'TECNOLOGO',  6, 100),
    ('ESP-GER-P',  'Especialización en Gerencia',     'PRESENCIAL', 'POSGRADO',   3,  50);


-- ────────────────────────────────────────────────────────────
-- ASIGNATURAS (catálogo compartido entre programas)
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO asignatura (codigo, nombre, creditos) VALUES
    -- Matemáticas y Ciencias Básicas
    ('MAT101', 'Cálculo Diferencial',              3),
    ('MAT102', 'Cálculo Integral',                 3),
    ('MAT201', 'Álgebra Lineal',                   3),
    ('MAT202', 'Estadística y Probabilidad',       3),
    ('FIS101', 'Física I',                         3),
    ('FIS102', 'Física II',                        3),

    -- Programación y Sistemas
    ('PRG101', 'Fundamentos de Programación',      4),
    ('PRG102', 'Programación Orientada a Objetos', 4),
    ('PRG201', 'Estructuras de Datos',             3),
    ('BDD101', 'Bases de Datos I',                 3),
    ('BDD102', 'Bases de Datos II',                3),
    ('RED101', 'Redes y Comunicaciones',           3),
    ('SOP101', 'Sistemas Operativos',              3),
    ('ING101', 'Ingeniería de Software',           3),
    ('SEG101', 'Seguridad Informática',            3),

    -- Administración y Economía
    ('ADM101', 'Fundamentos de Administración',    3),
    ('ADM102', 'Gestión del Talento Humano',       3),
    ('MKT101', 'Mercadeo',                         3),
    ('ECO101', 'Economía General',                 3),
    ('FIN101', 'Finanzas Empresariales',           3),
    ('DER101', 'Derecho Empresarial',              2),

    -- Contaduría
    ('CON101', 'Contabilidad General',             3),
    ('CON102', 'Contabilidad de Costos',           3),
    ('CON201', 'Auditoría',                        3),
    ('TRI101', 'Tributación',                      3),

    -- Psicología
    ('PSI101', 'Introducción a la Psicología',     3),
    ('PSI102', 'Psicología del Desarrollo',        3),
    ('PSI201', 'Psicopatología',                   3),

    -- Transversales
    ('HUM101', 'Humanidades I',                    2),
    ('HUM102', 'Humanidades II',                   2),
    ('ETI101', 'Ética Profesional',                2),
    ('COM101', 'Comunicación Académica',           2),
    ('EMP101', 'Emprendimiento',                   2);


-- ────────────────────────────────────────────────────────────
-- PLAN DE ESTUDIO — Ingeniería de Sistemas (Presencial)
-- Orden correcto: JOIN subquery x primero, luego asignatura
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO plan_estudio (id_programa, id_asignatura, semestre)
SELECT p.id_programa, a.id_asignatura, x.semestre
FROM programa p
JOIN (
    SELECT 'ING-SIS-P' AS codigo_prog, 'MAT101' AS codigo_asig, 1 AS semestre UNION ALL
    SELECT 'ING-SIS-P', 'FIS101',  1 UNION ALL
    SELECT 'ING-SIS-P', 'PRG101',  1 UNION ALL
    SELECT 'ING-SIS-P', 'HUM101',  1 UNION ALL
    SELECT 'ING-SIS-P', 'COM101',  1 UNION ALL
    SELECT 'ING-SIS-P', 'MAT102',  2 UNION ALL
    SELECT 'ING-SIS-P', 'FIS102',  2 UNION ALL
    SELECT 'ING-SIS-P', 'PRG102',  2 UNION ALL
    SELECT 'ING-SIS-P', 'MAT201',  2 UNION ALL
    SELECT 'ING-SIS-P', 'ECO101',  2 UNION ALL
    SELECT 'ING-SIS-P', 'PRG201',  3 UNION ALL
    SELECT 'ING-SIS-P', 'BDD101',  3 UNION ALL
    SELECT 'ING-SIS-P', 'SOP101',  3 UNION ALL
    SELECT 'ING-SIS-P', 'MAT202',  3 UNION ALL
    SELECT 'ING-SIS-P', 'HUM102',  3 UNION ALL
    SELECT 'ING-SIS-P', 'BDD102',  4 UNION ALL
    SELECT 'ING-SIS-P', 'RED101',  4 UNION ALL
    SELECT 'ING-SIS-P', 'ING101',  4 UNION ALL
    SELECT 'ING-SIS-P', 'ETI101',  4 UNION ALL
    SELECT 'ING-SIS-P', 'SEG101',  5 UNION ALL
    SELECT 'ING-SIS-P', 'EMP101',  5
) x ON p.codigo = x.codigo_prog
JOIN asignatura a ON a.codigo = x.codigo_asig;

-- Plan de estudio — Ing. Sistemas Virtual
INSERT IGNORE INTO plan_estudio (id_programa, id_asignatura, semestre)
SELECT p.id_programa, a.id_asignatura, x.semestre
FROM programa p
JOIN (
    SELECT 'ING-SIS-V' AS codigo_prog, 'MAT101' AS codigo_asig, 1 AS semestre UNION ALL
    SELECT 'ING-SIS-V', 'FIS101',  1 UNION ALL
    SELECT 'ING-SIS-V', 'PRG101',  1 UNION ALL
    SELECT 'ING-SIS-V', 'HUM101',  1 UNION ALL
    SELECT 'ING-SIS-V', 'COM101',  1 UNION ALL
    SELECT 'ING-SIS-V', 'MAT102',  2 UNION ALL
    SELECT 'ING-SIS-V', 'FIS102',  2 UNION ALL
    SELECT 'ING-SIS-V', 'PRG102',  2 UNION ALL
    SELECT 'ING-SIS-V', 'MAT201',  2 UNION ALL
    SELECT 'ING-SIS-V', 'ECO101',  2 UNION ALL
    SELECT 'ING-SIS-V', 'PRG201',  3 UNION ALL
    SELECT 'ING-SIS-V', 'BDD101',  3 UNION ALL
    SELECT 'ING-SIS-V', 'SOP101',  3 UNION ALL
    SELECT 'ING-SIS-V', 'MAT202',  3 UNION ALL
    SELECT 'ING-SIS-V', 'HUM102',  3 UNION ALL
    SELECT 'ING-SIS-V', 'BDD102',  4 UNION ALL
    SELECT 'ING-SIS-V', 'RED101',  4 UNION ALL
    SELECT 'ING-SIS-V', 'ING101',  4 UNION ALL
    SELECT 'ING-SIS-V', 'ETI101',  4 UNION ALL
    SELECT 'ING-SIS-V', 'SEG101',  5 UNION ALL
    SELECT 'ING-SIS-V', 'EMP101',  5
) x ON p.codigo = x.codigo_prog
JOIN asignatura a ON a.codigo = x.codigo_asig;

-- Plan de estudio — Administración de Empresas (Presencial)
INSERT IGNORE INTO plan_estudio (id_programa, id_asignatura, semestre)
SELECT p.id_programa, a.id_asignatura, x.semestre
FROM programa p
JOIN (
    SELECT 'ADM-EMP-P' AS codigo_prog, 'ADM101' AS codigo_asig, 1 AS semestre UNION ALL
    SELECT 'ADM-EMP-P', 'ECO101',  1 UNION ALL
    SELECT 'ADM-EMP-P', 'CON101',  1 UNION ALL
    SELECT 'ADM-EMP-P', 'COM101',  1 UNION ALL
    SELECT 'ADM-EMP-P', 'HUM101',  1 UNION ALL
    SELECT 'ADM-EMP-P', 'MAT101',  2 UNION ALL
    SELECT 'ADM-EMP-P', 'ADM102',  2 UNION ALL
    SELECT 'ADM-EMP-P', 'MKT101',  2 UNION ALL
    SELECT 'ADM-EMP-P', 'DER101',  2 UNION ALL
    SELECT 'ADM-EMP-P', 'MAT202',  3 UNION ALL
    SELECT 'ADM-EMP-P', 'FIN101',  3 UNION ALL
    SELECT 'ADM-EMP-P', 'ETI101',  3 UNION ALL
    SELECT 'ADM-EMP-P', 'EMP101',  3
) x ON p.codigo = x.codigo_prog
JOIN asignatura a ON a.codigo = x.codigo_asig;

-- Plan de estudio — Contaduría Pública (Presencial)
INSERT IGNORE INTO plan_estudio (id_programa, id_asignatura, semestre)
SELECT p.id_programa, a.id_asignatura, x.semestre
FROM programa p
JOIN (
    SELECT 'CON-PUB-P' AS codigo_prog, 'CON101' AS codigo_asig, 1 AS semestre UNION ALL
    SELECT 'CON-PUB-P', 'ECO101',  1 UNION ALL
    SELECT 'CON-PUB-P', 'MAT101',  1 UNION ALL
    SELECT 'CON-PUB-P', 'COM101',  1 UNION ALL
    SELECT 'CON-PUB-P', 'CON102',  2 UNION ALL
    SELECT 'CON-PUB-P', 'TRI101',  2 UNION ALL
    SELECT 'CON-PUB-P', 'DER101',  2 UNION ALL
    SELECT 'CON-PUB-P', 'FIN101',  2 UNION ALL
    SELECT 'CON-PUB-P', 'CON201',  3 UNION ALL
    SELECT 'CON-PUB-P', 'MAT202',  3 UNION ALL
    SELECT 'CON-PUB-P', 'ETI101',  3
) x ON p.codigo = x.codigo_prog
JOIN asignatura a ON a.codigo = x.codigo_asig;


-- ────────────────────────────────────────────────────────────
-- PERIODOS ACADÉMICOS
-- activo = 1 en el periodo vigente (2026-1)
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO periodo_academico (codigo, nombre, fecha_inicio, fecha_fin, activo) VALUES
    ('2025-2', 'Segundo Semestre 2025', '2025-08-01', '2025-11-28', 0),
    ('2026-1', 'Primer Semestre 2026',  '2026-02-02', '2026-06-19', 1),
    ('2026-2', 'Segundo Semestre 2026', '2026-08-03', '2026-11-27', 0);


-- ────────────────────────────────────────────────────────────
-- REGLAS DE COBRO — periodo 2026-1
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_por_credito)
SELECT per.id_periodo, prog.id_programa, x.modalidad_cobro, x.valor_global, x.valor_por_credito
FROM periodo_academico per
JOIN (
    SELECT '2026-1' AS cod_per, 'ING-SIS-P' AS codigo_prog, 'GLOBAL'       AS modalidad_cobro, 4800000.00 AS valor_global, NULL     AS valor_por_credito UNION ALL
    SELECT '2026-1', 'ING-SIS-V', 'POR_CREDITOS', NULL,       95000.00 UNION ALL
    SELECT '2026-1', 'ADM-EMP-P', 'GLOBAL',       3900000.00, NULL     UNION ALL
    SELECT '2026-1', 'ADM-EMP-M', 'POR_CREDITOS', NULL,       88000.00 UNION ALL
    SELECT '2026-1', 'CON-PUB-P', 'GLOBAL',       3700000.00, NULL     UNION ALL
    SELECT '2026-1', 'PSI-P',     'GLOBAL',       4200000.00, NULL     UNION ALL
    SELECT '2026-1', 'TEC-SIS-P', 'POR_CREDITOS', NULL,       75000.00 UNION ALL
    SELECT '2026-1', 'ESP-GER-P', 'GLOBAL',       6500000.00, NULL
) x ON per.codigo = x.cod_per
JOIN programa prog ON prog.codigo = x.codigo_prog;

-- Reglas de cobro — periodo 2025-2 (historial)
INSERT IGNORE INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_por_credito)
SELECT per.id_periodo, prog.id_programa, x.modalidad_cobro, x.valor_global, x.valor_por_credito
FROM periodo_academico per
JOIN (
    SELECT '2025-2' AS cod_per, 'ING-SIS-P' AS codigo_prog, 'GLOBAL'       AS modalidad_cobro, 4600000.00 AS valor_global, NULL     AS valor_por_credito UNION ALL
    SELECT '2025-2', 'ING-SIS-V', 'POR_CREDITOS', NULL,       90000.00 UNION ALL
    SELECT '2025-2', 'ADM-EMP-P', 'GLOBAL',       3750000.00, NULL     UNION ALL
    SELECT '2025-2', 'ADM-EMP-M', 'POR_CREDITOS', NULL,       84000.00 UNION ALL
    SELECT '2025-2', 'CON-PUB-P', 'GLOBAL',       3550000.00, NULL     UNION ALL
    SELECT '2025-2', 'PSI-P',     'GLOBAL',       4050000.00, NULL     UNION ALL
    SELECT '2025-2', 'TEC-SIS-P', 'POR_CREDITOS', NULL,       72000.00
) x ON per.codigo = x.cod_per
JOIN programa prog ON prog.codigo = x.codigo_prog;


-- ────────────────────────────────────────────────────────────
-- CÓDIGOS DE DETALLE
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO codigo_detalle (grupo, codigo, nombre, descripcion) VALUES
    ('COBRO', 'MATRICULA',   'Matrícula ordinaria',           'Cobro principal de matrícula por periodo académico'),
    ('COBRO', 'DERECHOS',    'Derechos de grado',             'Cobro para trámite de grado'),
    ('COBRO', 'SEGURO',      'Seguro estudiantil',            'Seguro de accidentes obligatorio por semestre'),
    ('COBRO', 'CARNET',      'Carnet estudiantil',            'Expedición o renovación del carnet'),
    ('COBRO', 'REPETICION',  'Habilitación / Repetición',     'Cobro por curso en segunda o tercera matrícula'),
    ('PAGO',  'PAGO_EFE',    'Pago en efectivo (caja)',       'Abono recibido en caja física'),
    ('PAGO',  'PAGO_PSE',    'Pago en línea PSE',             'Abono recibido a través de pasarela PSE'),
    ('PAGO',  'PAGO_TRF',    'Transferencia bancaria',        'Abono por transferencia o consignación bancaria'),
    ('PAGO',  'PAGO_TC',     'Tarjeta de crédito',            'Abono con tarjeta de crédito o débito'),
    ('PAGO',  'DESC_BECA',   'Beca institucional',            'Descuento porcentual asignado por la institución'),
    ('PAGO',  'DESC_MERITO', 'Descuento por mérito académico','Descuento para estudiantes con promedio >= 4.5'),
    ('PAGO',  'DESC_EMP',    'Descuento empleado',            'Descuento para colaboradores y familiares directos'),
    ('PAGO',  'DESC_CONV',   'Descuento por convenio',        'Descuento aplicado a empresas con convenio institucional');
