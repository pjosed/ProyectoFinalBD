-- ============================================================
-- 02_datos_semilla.sql — DATOS DE PRUEBA
-- Sistema de Matrículas — UniCaribe

USE matriculas_uni;

-- ============================================================
-- ROLES
-- ============================================================
INSERT INTO rol (nombre, descripcion) VALUES
    ('ADMINISTRADOR', 'Acceso total al sistema. Gestiona usuarios, roles y configuración.'),
    ('SUPERVISOR',    'Gestiona programas, planes de estudio, reglas de cobro y reportes.'),
    ('ASISTENTE',     'Registra cobros, pagos y gestiona la cuenta corriente.');


-- ============================================================
-- PROGRAMAS ACADÉMICOS
-- ============================================================
INSERT INTO programa_academico (codigo, nombre, num_sem, activo) VALUES
    ('ING-SIS',  'Ingeniería de Sistemas y Telecomunicaciones', 9, 1),
    ('ADM-EMP',  'Administración de Empresas',                  8, 1),
    ('CON-PUB',  'Contaduría Pública',                          8, 1),
    ('PSI',      'Psicología',                                   9, 1),
    ('DER',      'Derecho',                                     10, 1),
    ('TEC-SIS',  'Tecnología en Sistemas',                       6, 1),
    ('ESP-GER',  'Especialización en Gerencia',                  3, 1),
    ('MED',      'Medicina',                                    12, 1);


-- ============================================================
-- ASIGNATURAS (sin créditos — los créditos van en plan_estudio)
-- ============================================================
INSERT INTO asignatura (codigo, nombre) VALUES
    ('MAT101', 'Cálculo Diferencial'),
    ('MAT102', 'Cálculo Integral'),
    ('MAT201', 'Álgebra Lineal'),
    ('MAT202', 'Estadística y Probabilidad'),
    ('FIS101', 'Física I'),
    ('FIS102', 'Física II'),
    ('PRG101', 'Fundamentos de Programación'),
    ('PRG102', 'Programación Orientada a Objetos'),
    ('PRG201', 'Estructuras de Datos'),
    ('BDD101', 'Bases de Datos I'),
    ('BDD102', 'Bases de Datos II'),
    ('RED101', 'Redes y Comunicaciones'),
    ('SOP101', 'Sistemas Operativos'),
    ('ING101', 'Ingeniería de Software'),
    ('SEG101', 'Seguridad Informática'),
    ('ADM101', 'Fundamentos de Administración'),
    ('ADM102', 'Gestión del Talento Humano'),
    ('MKT101', 'Mercadeo'),
    ('ECO101', 'Economía General'),
    ('FIN101', 'Finanzas Empresariales'),
    ('DER101', 'Derecho Empresarial'),
    ('CON101', 'Contabilidad General'),
    ('CON102', 'Contabilidad de Costos'),
    ('CON201', 'Auditoría'),
    ('TRI101', 'Tributación'),
    ('PSI101', 'Introducción a la Psicología'),
    ('PSI102', 'Psicología del Desarrollo'),
    ('PSI201', 'Psicopatología'),
    ('HUM101', 'Humanidades I'),
    ('HUM102', 'Humanidades II'),
    ('ETI101', 'Ética Profesional'),
    ('COM101', 'Comunicación Académica'),
    ('EMP101', 'Emprendimiento');


-- ============================================================
-- PLAN DE ESTUDIO — Ingeniería de Sistemas (id_programa = 1)
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, x.semestre, x.creditos
FROM programa_academico p
JOIN (
    SELECT 'ING-SIS' AS cod, 'MAT101' AS asig, 1 AS semestre, 3 AS creditos UNION ALL
    SELECT 'ING-SIS','FIS101', 1, 3  UNION ALL
    SELECT 'ING-SIS','PRG101', 1, 4  UNION ALL
    SELECT 'ING-SIS','HUM101', 1, 2  UNION ALL
    SELECT 'ING-SIS','COM101', 1, 2  UNION ALL
    SELECT 'ING-SIS','MAT102', 2, 3  UNION ALL
    SELECT 'ING-SIS','FIS102', 2, 3  UNION ALL
    SELECT 'ING-SIS','PRG102', 2, 4  UNION ALL
    SELECT 'ING-SIS','MAT201', 2, 3  UNION ALL
    SELECT 'ING-SIS','ECO101', 2, 3  UNION ALL
    SELECT 'ING-SIS','PRG201', 3, 3  UNION ALL
    SELECT 'ING-SIS','BDD101', 3, 3  UNION ALL
    SELECT 'ING-SIS','SOP101', 3, 3  UNION ALL
    SELECT 'ING-SIS','MAT202', 3, 3  UNION ALL
    SELECT 'ING-SIS','HUM102', 3, 2  UNION ALL
    SELECT 'ING-SIS','BDD102', 4, 3  UNION ALL
    SELECT 'ING-SIS','RED101', 4, 3  UNION ALL
    SELECT 'ING-SIS','ING101', 4, 3  UNION ALL
    SELECT 'ING-SIS','ETI101', 4, 2  UNION ALL
    SELECT 'ING-SIS','SEG101', 5, 3  UNION ALL
    SELECT 'ING-SIS','EMP101', 5, 2
) x ON p.codigo = x.cod
JOIN asignatura a ON a.codigo = x.asig;


-- ============================================================
-- PLAN DE ESTUDIO — Administración de Empresas (id_programa = 2)
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, x.semestre, x.creditos
FROM programa_academico p
JOIN (
    SELECT 'ADM-EMP' AS cod, 'ADM101' AS asig, 1 AS semestre, 3 AS creditos UNION ALL
    SELECT 'ADM-EMP','ECO101', 1, 3  UNION ALL
    SELECT 'ADM-EMP','CON101', 1, 3  UNION ALL
    SELECT 'ADM-EMP','COM101', 1, 2  UNION ALL
    SELECT 'ADM-EMP','HUM101', 1, 2  UNION ALL
    SELECT 'ADM-EMP','MAT101', 2, 3  UNION ALL
    SELECT 'ADM-EMP','ADM102', 2, 3  UNION ALL
    SELECT 'ADM-EMP','MKT101', 2, 3  UNION ALL
    SELECT 'ADM-EMP','DER101', 2, 2  UNION ALL
    SELECT 'ADM-EMP','MAT202', 3, 3  UNION ALL
    SELECT 'ADM-EMP','FIN101', 3, 3  UNION ALL
    SELECT 'ADM-EMP','ETI101', 3, 2  UNION ALL
    SELECT 'ADM-EMP','EMP101', 3, 2
) x ON p.codigo = x.cod
JOIN asignatura a ON a.codigo = x.asig;


-- ============================================================
-- PLAN DE ESTUDIO — Contaduría Pública (id_programa = 3)
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, x.semestre, x.creditos
FROM programa_academico p
JOIN (
    SELECT 'CON-PUB' AS cod, 'CON101' AS asig, 1 AS semestre, 3 AS creditos UNION ALL
    SELECT 'CON-PUB','ECO101', 1, 3  UNION ALL
    SELECT 'CON-PUB','MAT101', 1, 3  UNION ALL
    SELECT 'CON-PUB','COM101', 1, 2  UNION ALL
    SELECT 'CON-PUB','CON102', 2, 3  UNION ALL
    SELECT 'CON-PUB','TRI101', 2, 3  UNION ALL
    SELECT 'CON-PUB','DER101', 2, 2  UNION ALL
    SELECT 'CON-PUB','FIN101', 2, 3  UNION ALL
    SELECT 'CON-PUB','CON201', 3, 3  UNION ALL
    SELECT 'CON-PUB','MAT202', 3, 3  UNION ALL
    SELECT 'CON-PUB','ETI101', 3, 2
) x ON p.codigo = x.cod
JOIN asignatura a ON a.codigo = x.asig;


-- ============================================================
-- PERIODOS ACADÉMICOS
-- activo = 1 solo en el periodo vigente (2026-1)
-- ============================================================
INSERT INTO periodo_academico (nombre, fecha_inicio, fecha_fin, activo) VALUES
    ('2025-2', '2025-07-14', '2025-11-28', 0),
    ('2026-1', '2026-01-19', '2026-06-14', 1),
    ('2026-2', '2026-08-03', '2026-11-27', 0);


-- ============================================================
-- REGLAS DE COBRO — Periodo 2026-1
-- modalidad_cobro: GLOBAL = valor fijo | POR_CREDITOS = por crédito
-- ============================================================
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, x.modalidad, x.v_global, x.v_credito
FROM periodo_academico per
JOIN (
    SELECT '2026-1' AS cod_per, 'ING-SIS'  AS cod_prog, 'POR_CREDITOS' AS modalidad, NULL        AS v_global, 320000.00 AS v_credito UNION ALL
    SELECT '2026-1', 'ADM-EMP', 'GLOBAL',       3800000.00, NULL     UNION ALL
    SELECT '2026-1', 'CON-PUB', 'GLOBAL',       3700000.00, NULL     UNION ALL
    SELECT '2026-1', 'PSI',     'GLOBAL',       4200000.00, NULL     UNION ALL
    SELECT '2026-1', 'DER',     'GLOBAL',       4500000.00, NULL     UNION ALL
    SELECT '2026-1', 'TEC-SIS', 'POR_CREDITOS', NULL,       280000.00 UNION ALL
    SELECT '2026-1', 'ESP-GER', 'GLOBAL',       6500000.00, NULL
) x ON per.nombre = x.cod_per
JOIN programa_academico prog ON prog.codigo = x.cod_prog;

-- Reglas periodo 2025-2 (historial)
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, x.modalidad, x.v_global, x.v_credito
FROM periodo_academico per
JOIN (
    SELECT '2025-2' AS cod_per, 'ING-SIS'  AS cod_prog, 'POR_CREDITOS' AS modalidad, NULL        AS v_global, 300000.00 AS v_credito UNION ALL
    SELECT '2025-2', 'ADM-EMP', 'GLOBAL',       3600000.00, NULL     UNION ALL
    SELECT '2025-2', 'CON-PUB', 'GLOBAL',       3500000.00, NULL
) x ON per.nombre = x.cod_per
JOIN programa_academico prog ON prog.codigo = x.cod_prog;


-- ============================================================
-- CÓDIGOS DE DETALLE
-- grupo COBRO = generan deuda
-- grupo PAGO  = reducen deuda (incluye descuentos)
-- ============================================================
INSERT INTO codigo_detalle (grupo, codigo, descripcion) VALUES
    ('COBRO', 'PMAT',  'Matrícula ordinaria del periodo'),
    ('COBRO', 'PCRE',  'Cobro por créditos adicionales'),
    ('COBRO', 'PCAR',  'Carnet estudiantil'),
    ('COBRO', 'PLAB',  'Uso de laboratorios'),
    ('COBRO', 'PEXA',  'Derechos de examen'),
    ('PAGO',  'MPAG',  'Valor pagado para matrícula'),
    ('PAGO',  'ANT',   'Anticipo de matrícula'),
    ('PAGO',  'DESC',  'Descuento o beca porcentual'),
    ('PAGO',  'CRED',  'Crédito a favor del estudiante');


-- ============================================================
-- BANCOS PSE
-- ============================================================
INSERT INTO banco_pse (codigo, nombre) VALUES
    ('BCOL', 'Bancolombia'),
    ('BBOG', 'Banco de Bogotá'),
    ('DAVY', 'Davivienda'),
    ('AVVL', 'AV Villas'),
    ('BBVA', 'BBVA Colombia'),
    ('OCCB', 'Banco de Occidente'),
    ('NQBN', 'Nequi'),
    ('ITAU', 'Itaú Colombia'),
    ('POPU', 'Banco Popular'),
    ('FALB', 'Banco Falabella');


-- ============================================================
-- TIPOS DE DESCUENTO / BECAS
-- ============================================================
INSERT INTO tipo_descuento (nombre, descripcion, porcentaje) VALUES
    ('Beca Excelencia Académica',  'Estudiantes con promedio >= 4.5',          25.00),
    ('Beca Socioeconómica',        'Apoyo a estudiantes de bajos recursos',     50.00),
    ('Descuento Empleado',         'Colaboradores y familiares directos',       20.00),
    ('Beca Deportiva',             'Deportistas de alto rendimiento',           25.00),
    ('Descuento por Convenio',     'Empresa con convenio institucional activo', 10.00),
    ('Beca Total',                 'Cobertura completa de matrícula',          100.00);


-- ============================================================
-- ESTUDIANTES DE PRUEBA
-- ============================================================
INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC', '1001234501', 'Valentina', 'Torres Sánchez',  'vtorres@estudiante.edu.co',  '3101112233'),
    ('CC', '1001234502', 'Juan',      'Ramos Díaz',      'jramos@estudiante.edu.co',   '3112223344'),
    ('CC', '1001234503', 'Sofía',     'Castro Mejía',    'scastro@estudiante.edu.co',  '3123334455'),
    ('CC', '1001234504', 'Miguel',    'Vargas López',    'mvargas@estudiante.edu.co',  '3134445566'),
    ('CC', '1001234505', 'Camila',    'Herrera Ríos',    'cherrera@estudiante.edu.co', '3145556677');


-- ============================================================
-- NOTA: El usuario ADMINISTRADOR se crea ejecutando:
--   python generar_admin.py
-- desde la carpeta matriculas/ y pegando el SQL generado aquí.
-- ============================================================
