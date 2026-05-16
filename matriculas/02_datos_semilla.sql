-- ============================================================
-- 02_datos_semilla.sql — DATOS COMPLETOS DE PRUEBA
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- ============================================================

USE matriculas_uni;

-- ============================================================
-- ROLES
-- ============================================================
INSERT INTO rol (nombre, descripcion) VALUES
    ('ADMINISTRADOR', 'Acceso total al sistema.'),
    ('SUPERVISOR',    'Gestiona información académica y financiera.'),
    ('ASISTENTE',     'Gestiona cobros y pagos.');


-- ============================================================
-- PROGRAMAS ACADÉMICOS
-- ============================================================
INSERT INTO programa_academico (codigo, nombre, num_sem, activo) VALUES
    ('ING-SIS',  'Ingeniería de Sistemas y Telecomunicaciones',  9, 1),
    ('ING-IND',  'Ingeniería Industrial',                        9, 1),
    ('ADM-EMP',  'Administración de Empresas',                   8, 1),
    ('CON-PUB',  'Contaduría Pública',                           8, 1),
    ('DER',      'Derecho',                                     10, 1),
    ('PSI',      'Psicología',                                   9, 1),
    ('MED',      'Medicina',                                    12, 1),
    ('ENF',      'Enfermería',                                   8, 1),
    ('ARQ',      'Arquitectura',                                10, 1),
    ('COM-SOC',  'Comunicación Social y Periodismo',             8, 1),
    ('EDU-INF',  'Licenciatura en Educación Infantil',           8, 1),
    ('NEG-INT',  'Negocios Internacionales',                     8, 1),
    ('TEC-SIS',  'Tecnología en Sistemas',                       6, 1),
    ('TEC-ADM',  'Tecnología en Gestión Empresarial',            6, 1),
    ('TEC-CON',  'Tecnología en Contabilidad Financiera',        6, 1),
    ('ESP-GER',  'Especialización en Gerencia de Proyectos',     3, 1),
    ('ESP-FIN',  'Especialización en Finanzas Corporativas',     3, 1),
    ('ESP-DER',  'Especialización en Derecho Comercial',         3, 1),
    ('ESP-TIC',  'Especialización en Seguridad Informática',     3, 1),
    ('MAS-ADM',  'Maestría en Administración MBA',               4, 1),
    ('MAS-ING',  'Maestría en Ingeniería de Software',           4, 1),
    ('MAS-DER',  'Maestría en Derecho Empresarial',              4, 1);


-- ============================================================
-- ASIGNATURAS
-- ============================================================
INSERT INTO asignatura (codigo, nombre) VALUES
    ('MAT101', 'Cálculo Diferencial'),
    ('MAT102', 'Cálculo Integral'),
    ('MAT201', 'Cálculo Multivariable'),
    ('MAT202', 'Álgebra Lineal'),
    ('MAT203', 'Estadística y Probabilidad'),
    ('MAT204', 'Matemáticas Discretas'),
    ('MAT301', 'Investigación de Operaciones'),
    ('FIS101', 'Física I — Mecánica'),
    ('FIS102', 'Física II — Electromagnetismo'),
    ('FIS201', 'Física III — Ondas y Óptica'),
    ('QUI101', 'Química General'),
    ('BIO101', 'Biología Celular'),
    ('PRG101', 'Fundamentos de Programación'),
    ('PRG102', 'Programación Orientada a Objetos'),
    ('PRG201', 'Estructuras de Datos'),
    ('PRG202', 'Algoritmos Avanzados'),
    ('PRG301', 'Desarrollo Web Frontend'),
    ('PRG302', 'Desarrollo Web Backend'),
    ('PRG401', 'Desarrollo Móvil'),
    ('PRG402', 'Inteligencia Artificial'),
    ('BDD101', 'Bases de Datos I'),
    ('BDD102', 'Bases de Datos II'),
    ('BDD201', 'Bases de Datos Distribuidas'),
    ('BDD202', 'Big Data y Analytics'),
    ('RED101', 'Fundamentos de Redes'),
    ('RED102', 'Redes Avanzadas y Protocolos'),
    ('RED201', 'Seguridad en Redes'),
    ('SEG101', 'Seguridad Informática'),
    ('SEG201', 'Criptografía y Seguridad'),
    ('SEG301', 'Hacking Ético y Pentesting'),
    ('SOP101', 'Sistemas Operativos'),
    ('SOP201', 'Computación en la Nube'),
    ('SOP301', 'DevOps y CI/CD'),
    ('ING101', 'Ingeniería de Software I'),
    ('ING102', 'Ingeniería de Software II'),
    ('ING201', 'Gestión de Proyectos de Software'),
    ('ING301', 'Arquitectura de Software'),
    ('ING401', 'Calidad de Software'),
    ('IND101', 'Introducción a la Ingeniería Industrial'),
    ('IND102', 'Procesos de Manufactura'),
    ('IND201', 'Gestión de la Calidad'),
    ('IND202', 'Logística y Cadena de Suministro'),
    ('IND301', 'Simulación de Sistemas'),
    ('IND302', 'Ergonomía y Salud Ocupacional'),
    ('IND401', 'Gestión de la Producción'),
    ('ADM101', 'Fundamentos de Administración'),
    ('ADM102', 'Gestión del Talento Humano'),
    ('ADM201', 'Comportamiento Organizacional'),
    ('ADM202', 'Gestión Estratégica'),
    ('ADM301', 'Emprendimiento e Innovación'),
    ('ADM401', 'Gerencia de Proyectos'),
    ('MKT101', 'Fundamentos de Mercadeo'),
    ('MKT201', 'Marketing Digital'),
    ('MKT301', 'Investigación de Mercados'),
    ('NEG101', 'Comercio Internacional'),
    ('NEG201', 'Negociación Internacional'),
    ('NEG301', 'Logística Internacional'),
    ('ECO101', 'Economía General'),
    ('ECO102', 'Microeconomía'),
    ('ECO201', 'Macroeconomía'),
    ('FIN101', 'Fundamentos de Finanzas'),
    ('FIN201', 'Análisis Financiero'),
    ('FIN202', 'Finanzas Corporativas'),
    ('FIN301', 'Mercado de Capitales'),
    ('FIN401', 'Valoración de Empresas'),
    ('CON101', 'Contabilidad General'),
    ('CON102', 'Contabilidad de Costos'),
    ('CON201', 'Contabilidad Financiera Avanzada'),
    ('CON202', 'Contabilidad Pública'),
    ('CON301', 'Auditoría Financiera'),
    ('CON302', 'Auditoría de Sistemas'),
    ('TRI101', 'Tributación I'),
    ('TRI201', 'Tributación II — Impuestos Especiales'),
    ('DER101', 'Introducción al Derecho'),
    ('DER102', 'Derecho Constitucional'),
    ('DER201', 'Derecho Civil I'),
    ('DER202', 'Derecho Civil II'),
    ('DER301', 'Derecho Penal'),
    ('DER302', 'Derecho Laboral'),
    ('DER401', 'Derecho Comercial'),
    ('DER402', 'Derecho Internacional'),
    ('DER501', 'Derecho Administrativo'),
    ('DER502', 'Derecho Procesal'),
    ('PSI101', 'Introducción a la Psicología'),
    ('PSI102', 'Psicología del Desarrollo'),
    ('PSI201', 'Psicología Social'),
    ('PSI202', 'Psicopatología'),
    ('PSI301', 'Psicología Clínica'),
    ('PSI302', 'Psicología Organizacional'),
    ('PSI401', 'Evaluación Psicológica'),
    ('PSI402', 'Intervención Psicológica'),
    ('MED101', 'Anatomía I'),
    ('MED102', 'Anatomía II'),
    ('MED201', 'Fisiología I'),
    ('MED202', 'Fisiología II'),
    ('MED301', 'Patología General'),
    ('MED302', 'Farmacología'),
    ('MED401', 'Medicina Interna I'),
    ('MED402', 'Medicina Interna II'),
    ('MED501', 'Cirugía General'),
    ('MED502', 'Pediatría'),
    ('MED601', 'Ginecología y Obstetricia'),
    ('MED602', 'Psiquiatría'),
    ('ENF101', 'Fundamentos de Enfermería'),
    ('ENF102', 'Anatomofisiología para Enfermería'),
    ('ENF201', 'Enfermería Médico-Quirúrgica I'),
    ('ENF202', 'Enfermería Médico-Quirúrgica II'),
    ('ENF301', 'Enfermería Pediátrica'),
    ('ENF302', 'Enfermería en Salud Mental'),
    ('ARQ101', 'Introducción a la Arquitectura'),
    ('ARQ102', 'Dibujo Arquitectónico'),
    ('ARQ201', 'Diseño Arquitectónico I'),
    ('ARQ202', 'Diseño Arquitectónico II'),
    ('ARQ301', 'Urbanismo y Planificación'),
    ('ARQ302', 'Estructuras para Arquitectura'),
    ('ARQ401', 'Instalaciones y Acústica'),
    ('COM101', 'Comunicación Académica y Científica'),
    ('COM102', 'Redacción y Estilo Periodístico'),
    ('COM201', 'Periodismo Digital'),
    ('COM202', 'Producción Audiovisual'),
    ('COM301', 'Comunicación Corporativa'),
    ('HUM101', 'Humanidades I — Pensamiento Crítico'),
    ('HUM102', 'Humanidades II — Ética y Sociedad'),
    ('ETI101', 'Ética Profesional'),
    ('EMP101', 'Emprendimiento'),
    ('ING-E01', 'Inglés I'),
    ('ING-E02', 'Inglés II'),
    ('ING-E03', 'Inglés III'),
    ('ING-E04', 'Inglés IV'),
    ('EST101', 'Estadística Aplicada'),
    ('INV101', 'Metodología de la Investigación'),
    ('INV201', 'Seminario de Investigación'),
    ('TRA101', 'Trabajo de Grado I'),
    ('TRA102', 'Trabajo de Grado II'),
    ('EDU101', 'Fundamentos de Pedagogía'),
    ('EDU102', 'Desarrollo Infantil'),
    ('EDU201', 'Didáctica General'),
    ('EDU202', 'Currículo y Evaluación'),
    ('EDU301', 'Práctica Pedagógica I'),
    ('EDU302', 'Práctica Pedagógica II');


-- ============================================================
-- PERIODOS ACADÉMICOS
-- ============================================================
INSERT INTO periodo_academico (nombre, fecha_inicio, fecha_fin, activo) VALUES
    ('2024-2', '2024-07-15', '2024-11-30', 0),
    ('2025-1', '2025-01-20', '2025-06-14', 0),
    ('2025-2', '2025-07-14', '2025-11-28', 0),
    ('2026-1', '2026-01-19', '2026-06-14', 1),
    ('2026-2', '2026-07-13', '2026-11-27', 0);


-- ============================================================
-- PLAN DE ESTUDIO — Ingeniería de Sistemas (ING-SIS) — 9 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ING-SIS' cod_p, 'MAT101' cod_a, 1 sem, 3 cred UNION ALL
 SELECT 'ING-SIS','FIS101',1,3 UNION ALL SELECT 'ING-SIS','PRG101',1,4 UNION ALL
 SELECT 'ING-SIS','HUM101',1,2 UNION ALL SELECT 'ING-SIS','ING-E01',1,2 UNION ALL
 SELECT 'ING-SIS','MAT102',2,3 UNION ALL SELECT 'ING-SIS','FIS102',2,3 UNION ALL
 SELECT 'ING-SIS','PRG102',2,4 UNION ALL SELECT 'ING-SIS','MAT202',2,3 UNION ALL
 SELECT 'ING-SIS','ING-E02',2,2 UNION ALL SELECT 'ING-SIS','MAT203',3,3 UNION ALL
 SELECT 'ING-SIS','PRG201',3,3 UNION ALL SELECT 'ING-SIS','BDD101',3,3 UNION ALL
 SELECT 'ING-SIS','SOP101',3,3 UNION ALL SELECT 'ING-SIS','HUM102',3,2 UNION ALL
 SELECT 'ING-SIS','MAT204',4,3 UNION ALL SELECT 'ING-SIS','PRG202',4,3 UNION ALL
 SELECT 'ING-SIS','BDD102',4,3 UNION ALL SELECT 'ING-SIS','RED101',4,3 UNION ALL
 SELECT 'ING-SIS','ING101',4,3 UNION ALL SELECT 'ING-SIS','MAT301',5,3 UNION ALL
 SELECT 'ING-SIS','SEG101',5,3 UNION ALL SELECT 'ING-SIS','PRG301',5,3 UNION ALL
 SELECT 'ING-SIS','ING102',5,3 UNION ALL SELECT 'ING-SIS','ING-E03',5,2 UNION ALL
 SELECT 'ING-SIS','PRG302',6,3 UNION ALL SELECT 'ING-SIS','RED102',6,3 UNION ALL
 SELECT 'ING-SIS','BDD201',6,3 UNION ALL SELECT 'ING-SIS','ING201',6,3 UNION ALL
 SELECT 'ING-SIS','ETI101',6,2 UNION ALL SELECT 'ING-SIS','PRG401',7,3 UNION ALL
 SELECT 'ING-SIS','SOP201',7,3 UNION ALL SELECT 'ING-SIS','SEG201',7,3 UNION ALL
 SELECT 'ING-SIS','ING301',7,3 UNION ALL SELECT 'ING-SIS','ING-E04',7,2 UNION ALL
 SELECT 'ING-SIS','PRG402',8,3 UNION ALL SELECT 'ING-SIS','BDD202',8,3 UNION ALL
 SELECT 'ING-SIS','SOP301',8,3 UNION ALL SELECT 'ING-SIS','ING401',8,3 UNION ALL
 SELECT 'ING-SIS','INV101',8,2 UNION ALL SELECT 'ING-SIS','TRA101',9,6 UNION ALL
 SELECT 'ING-SIS','INV201',9,3 UNION ALL SELECT 'ING-SIS','EMP101',9,3) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Administración de Empresas (ADM-EMP) — 8 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ADM-EMP' cod_p,'ADM101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'ADM-EMP','ECO101',1,3 UNION ALL SELECT 'ADM-EMP','CON101',1,3 UNION ALL
 SELECT 'ADM-EMP','COM101',1,2 UNION ALL SELECT 'ADM-EMP','HUM101',1,2 UNION ALL
 SELECT 'ADM-EMP','ADM102',2,3 UNION ALL SELECT 'ADM-EMP','ECO102',2,3 UNION ALL
 SELECT 'ADM-EMP','MAT101',2,3 UNION ALL SELECT 'ADM-EMP','MKT101',2,3 UNION ALL
 SELECT 'ADM-EMP','ING-E01',2,2 UNION ALL SELECT 'ADM-EMP','ADM201',3,3 UNION ALL
 SELECT 'ADM-EMP','ECO201',3,3 UNION ALL SELECT 'ADM-EMP','FIN101',3,3 UNION ALL
 SELECT 'ADM-EMP','MAT203',3,3 UNION ALL SELECT 'ADM-EMP','HUM102',3,2 UNION ALL
 SELECT 'ADM-EMP','ADM202',4,3 UNION ALL SELECT 'ADM-EMP','FIN201',4,3 UNION ALL
 SELECT 'ADM-EMP','MKT201',4,3 UNION ALL SELECT 'ADM-EMP','DER101',4,2 UNION ALL
 SELECT 'ADM-EMP','ING-E02',4,2 UNION ALL SELECT 'ADM-EMP','FIN202',5,3 UNION ALL
 SELECT 'ADM-EMP','MKT301',5,3 UNION ALL SELECT 'ADM-EMP','ADM301',5,3 UNION ALL
 SELECT 'ADM-EMP','INV101',5,3 UNION ALL SELECT 'ADM-EMP','ETI101',5,2 UNION ALL
 SELECT 'ADM-EMP','FIN301',6,3 UNION ALL SELECT 'ADM-EMP','ADM401',6,3 UNION ALL
 SELECT 'ADM-EMP','NEG101',6,3 UNION ALL SELECT 'ADM-EMP','EST101',6,3 UNION ALL
 SELECT 'ADM-EMP','ING-E03',6,2 UNION ALL SELECT 'ADM-EMP','FIN401',7,3 UNION ALL
 SELECT 'ADM-EMP','NEG201',7,3 UNION ALL SELECT 'ADM-EMP','INV201',7,3 UNION ALL
 SELECT 'ADM-EMP','EMP101',7,3 UNION ALL SELECT 'ADM-EMP','TRA101',8,6 UNION ALL
 SELECT 'ADM-EMP','TRA102',8,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Contaduría Pública (CON-PUB) — 8 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'CON-PUB' cod_p,'CON101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'CON-PUB','ECO101',1,3 UNION ALL SELECT 'CON-PUB','MAT101',1,3 UNION ALL
 SELECT 'CON-PUB','COM101',1,2 UNION ALL SELECT 'CON-PUB','HUM101',1,2 UNION ALL
 SELECT 'CON-PUB','CON102',2,3 UNION ALL SELECT 'CON-PUB','ECO102',2,3 UNION ALL
 SELECT 'CON-PUB','FIN101',2,3 UNION ALL SELECT 'CON-PUB','DER101',2,2 UNION ALL
 SELECT 'CON-PUB','ING-E01',2,2 UNION ALL SELECT 'CON-PUB','CON201',3,3 UNION ALL
 SELECT 'CON-PUB','TRI101',3,3 UNION ALL SELECT 'CON-PUB','FIN201',3,3 UNION ALL
 SELECT 'CON-PUB','MAT203',3,3 UNION ALL SELECT 'CON-PUB','HUM102',3,2 UNION ALL
 SELECT 'CON-PUB','CON202',4,3 UNION ALL SELECT 'CON-PUB','TRI201',4,3 UNION ALL
 SELECT 'CON-PUB','FIN202',4,3 UNION ALL SELECT 'CON-PUB','DER302',4,3 UNION ALL
 SELECT 'CON-PUB','ING-E02',4,2 UNION ALL SELECT 'CON-PUB','CON301',5,3 UNION ALL
 SELECT 'CON-PUB','CON302',5,3 UNION ALL SELECT 'CON-PUB','FIN301',5,3 UNION ALL
 SELECT 'CON-PUB','INV101',5,3 UNION ALL SELECT 'CON-PUB','ETI101',5,2 UNION ALL
 SELECT 'CON-PUB','FIN401',6,3 UNION ALL SELECT 'CON-PUB','ADM202',6,3 UNION ALL
 SELECT 'CON-PUB','EST101',6,3 UNION ALL SELECT 'CON-PUB','INV201',6,3 UNION ALL
 SELECT 'CON-PUB','ADM401',7,3 UNION ALL SELECT 'CON-PUB','EMP101',7,3 UNION ALL
 SELECT 'CON-PUB','ING-E03',7,2 UNION ALL SELECT 'CON-PUB','TRA101',7,3 UNION ALL
 SELECT 'CON-PUB','TRA102',8,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Derecho (DER) — 10 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'DER' cod_p,'DER101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'DER','COM101',1,2 UNION ALL SELECT 'DER','HUM101',1,2 UNION ALL
 SELECT 'DER','ECO101',1,2 UNION ALL SELECT 'DER','ING-E01',1,2 UNION ALL
 SELECT 'DER','DER102',2,3 UNION ALL SELECT 'DER','DER201',2,3 UNION ALL
 SELECT 'DER','HUM102',2,2 UNION ALL SELECT 'DER','ING-E02',2,2 UNION ALL
 SELECT 'DER','DER202',3,3 UNION ALL SELECT 'DER','DER301',3,3 UNION ALL
 SELECT 'DER','INV101',3,3 UNION ALL SELECT 'DER','DER302',4,3 UNION ALL
 SELECT 'DER','DER401',4,3 UNION ALL SELECT 'DER','ECO102',4,2 UNION ALL
 SELECT 'DER','DER402',5,3 UNION ALL SELECT 'DER','DER501',5,3 UNION ALL
 SELECT 'DER','ETI101',5,2 UNION ALL SELECT 'DER','DER502',6,3 UNION ALL
 SELECT 'DER','FIN101',6,2 UNION ALL SELECT 'DER','ING-E03',6,2 UNION ALL
 SELECT 'DER','ADM202',7,3 UNION ALL SELECT 'DER','INV201',7,3 UNION ALL
 SELECT 'DER','EMP101',7,2 UNION ALL SELECT 'DER','EST101',8,3 UNION ALL
 SELECT 'DER','ADM401',8,3 UNION ALL SELECT 'DER','TRA101',9,6 UNION ALL
 SELECT 'DER','ING-E04',9,2 UNION ALL SELECT 'DER','TRA102',10,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Psicología (PSI) — 9 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'PSI' cod_p,'PSI101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'PSI','BIO101',1,3 UNION ALL SELECT 'PSI','COM101',1,2 UNION ALL
 SELECT 'PSI','HUM101',1,2 UNION ALL SELECT 'PSI','ING-E01',1,2 UNION ALL
 SELECT 'PSI','PSI102',2,3 UNION ALL SELECT 'PSI','MAT203',2,3 UNION ALL
 SELECT 'PSI','HUM102',2,2 UNION ALL SELECT 'PSI','ING-E02',2,2 UNION ALL
 SELECT 'PSI','PSI201',3,3 UNION ALL SELECT 'PSI','PSI202',3,3 UNION ALL
 SELECT 'PSI','INV101',3,3 UNION ALL SELECT 'PSI','EST101',4,3 UNION ALL
 SELECT 'PSI','PSI301',4,3 UNION ALL SELECT 'PSI','ETI101',4,2 UNION ALL
 SELECT 'PSI','PSI302',5,3 UNION ALL SELECT 'PSI','PSI401',5,3 UNION ALL
 SELECT 'PSI','ING-E03',5,2 UNION ALL SELECT 'PSI','PSI402',6,3 UNION ALL
 SELECT 'PSI','ADM102',6,3 UNION ALL SELECT 'PSI','INV201',6,3 UNION ALL
 SELECT 'PSI','EMP101',7,3 UNION ALL SELECT 'PSI','ING-E04',7,2 UNION ALL
 SELECT 'PSI','ADM202',8,3 UNION ALL SELECT 'PSI','TRA101',8,3 UNION ALL
 SELECT 'PSI','TRA102',9,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Tecnología en Sistemas (TEC-SIS) — 6 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'TEC-SIS' cod_p,'PRG101' cod_a,1 sem,4 cred UNION ALL
 SELECT 'TEC-SIS','MAT101',1,3 UNION ALL SELECT 'TEC-SIS','COM101',1,2 UNION ALL
 SELECT 'TEC-SIS','HUM101',1,2 UNION ALL SELECT 'TEC-SIS','PRG102',2,4 UNION ALL
 SELECT 'TEC-SIS','BDD101',2,3 UNION ALL SELECT 'TEC-SIS','RED101',2,3 UNION ALL
 SELECT 'TEC-SIS','MAT202',2,3 UNION ALL SELECT 'TEC-SIS','PRG201',3,3 UNION ALL
 SELECT 'TEC-SIS','BDD102',3,3 UNION ALL SELECT 'TEC-SIS','SOP101',3,3 UNION ALL
 SELECT 'TEC-SIS','ING101',3,3 UNION ALL SELECT 'TEC-SIS','PRG301',4,3 UNION ALL
 SELECT 'TEC-SIS','SEG101',4,3 UNION ALL SELECT 'TEC-SIS','RED102',4,3 UNION ALL
 SELECT 'TEC-SIS','ETI101',4,2 UNION ALL SELECT 'TEC-SIS','PRG302',5,3 UNION ALL
 SELECT 'TEC-SIS','SOP201',5,3 UNION ALL SELECT 'TEC-SIS','BDD201',5,3 UNION ALL
 SELECT 'TEC-SIS','INV101',5,2 UNION ALL SELECT 'TEC-SIS','TRA101',6,6 UNION ALL
 SELECT 'TEC-SIS','EMP101',6,3) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Especialización en Gerencia de Proyectos (ESP-GER) — 3 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ESP-GER' cod_p,'ADM401' cod_a,1 sem,4 cred UNION ALL
 SELECT 'ESP-GER','FIN201',1,4 UNION ALL SELECT 'ESP-GER','INV101',1,4 UNION ALL
 SELECT 'ESP-GER','ADM202',2,4 UNION ALL SELECT 'ESP-GER','FIN202',2,4 UNION ALL
 SELECT 'ESP-GER','ING201',2,4 UNION ALL SELECT 'ESP-GER','TRA101',3,6 UNION ALL
 SELECT 'ESP-GER','INV201',3,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Maestría en Administración MBA (MAS-ADM) — 4 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'MAS-ADM' cod_p,'ADM202' cod_a,1 sem,4 cred UNION ALL
 SELECT 'MAS-ADM','FIN202',1,4 UNION ALL SELECT 'MAS-ADM','MKT301',1,4 UNION ALL
 SELECT 'MAS-ADM','FIN301',2,4 UNION ALL SELECT 'MAS-ADM','NEG201',2,4 UNION ALL
 SELECT 'MAS-ADM','ADM401',2,4 UNION ALL SELECT 'MAS-ADM','FIN401',3,4 UNION ALL
 SELECT 'MAS-ADM','INV201',3,4 UNION ALL SELECT 'MAS-ADM','EMP101',3,4 UNION ALL
 SELECT 'MAS-ADM','TRA101',4,6 UNION ALL SELECT 'MAS-ADM','TRA102',4,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ============================================================
-- PLAN DE ESTUDIO — Ingeniería Industrial (ING-IND) — 9 semestres
-- ============================================================
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ING-IND' cod_p,'MAT101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'ING-IND','FIS101',1,3 UNION ALL SELECT 'ING-IND','IND101',1,3 UNION ALL
 SELECT 'ING-IND','COM101',1,2 UNION ALL SELECT 'ING-IND','HUM101',1,2 UNION ALL
 SELECT 'ING-IND','MAT102',2,3 UNION ALL SELECT 'ING-IND','FIS102',2,3 UNION ALL
 SELECT 'ING-IND','IND102',2,3 UNION ALL SELECT 'ING-IND','ING-E01',2,2 UNION ALL
 SELECT 'ING-IND','MAT203',3,3 UNION ALL SELECT 'ING-IND','IND201',3,3 UNION ALL
 SELECT 'ING-IND','ECO101',3,3 UNION ALL SELECT 'ING-IND','HUM102',3,2 UNION ALL
 SELECT 'ING-IND','MAT301',4,3 UNION ALL SELECT 'ING-IND','IND202',4,3 UNION ALL
 SELECT 'ING-IND','FIN101',4,3 UNION ALL SELECT 'ING-IND','ING-E02',4,2 UNION ALL
 SELECT 'ING-IND','IND301',5,3 UNION ALL SELECT 'ING-IND','IND302',5,3 UNION ALL
 SELECT 'ING-IND','ADM101',5,3 UNION ALL SELECT 'ING-IND','ETI101',5,2 UNION ALL
 SELECT 'ING-IND','IND401',6,3 UNION ALL SELECT 'ING-IND','ADM202',6,3 UNION ALL
 SELECT 'ING-IND','INV101',6,3 UNION ALL SELECT 'ING-IND','ING-E03',6,2 UNION ALL
 SELECT 'ING-IND','ADM401',7,3 UNION ALL SELECT 'ING-IND','EMP101',7,3 UNION ALL
 SELECT 'ING-IND','INV201',7,3 UNION ALL SELECT 'ING-IND','EST101',8,3 UNION ALL
 SELECT 'ING-IND','ING-E04',8,2 UNION ALL SELECT 'ING-IND','TRA101',9,6 UNION ALL
 SELECT 'ING-IND','TRA102',9,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;


-- ============================================================
-- CÓDIGOS DE DETALLE
-- ============================================================
INSERT INTO codigo_detalle (grupo, codigo, descripcion) VALUES
    ('COBRO', 'PMAT',  'Matrícula ordinaria del periodo'),
    ('COBRO', 'PCRE',  'Cobro adicional por créditos'),
    ('COBRO', 'PCAR',  'Carnet estudiantil'),
    ('COBRO', 'PLAB',  'Uso de laboratorios y talleres'),
    ('COBRO', 'PEXA',  'Derechos de examen'),
    ('COBRO', 'PSEG',  'Seguro estudiantil'),
    ('PAGO',  'MPAG',  'Pago de matrícula'),
    ('PAGO',  'ANT',   'Anticipo de matrícula'),
    ('PAGO',  'DESC',  'Descuento o beca porcentual'),
    ('PAGO',  'CRED',  'Crédito ICETEX u otra entidad'),
    ('PAGO',  'CONV',  'Pago por convenio empresarial');


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
    ('FALB', 'Banco Falabella'),
    ('CAJA', 'Caja Social'),
    ('AGRA', 'Banco Agrario');


-- ============================================================
-- TIPOS DE DESCUENTO / BECAS
-- ============================================================
INSERT INTO tipo_descuento (nombre, descripcion, porcentaje) VALUES
    ('Beca Excelencia Académica',  'Estudiantes con promedio >= 4.5 semestre anterior',  25.00),
    ('Beca Socioeconómica',        'Apoyo a estudiantes de estratos 1 y 2',              50.00),
    ('Descuento Empleado',         'Colaboradores y familiares de primer grado',         20.00),
    ('Beca Deportiva',             'Deportistas de alto rendimiento certificados',        25.00),
    ('Descuento por Convenio',     'Empresa con convenio institucional vigente',         10.00),
    ('Beca Total',                 'Cobertura completa — casos especiales',             100.00);


-- ============================================================
-- REGLAS DE COBRO — 2026-1 (periodo activo)
-- ============================================================
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, t.modalidad, t.v_global, t.v_credito
FROM periodo_academico per,
     programa_academico prog,
(SELECT '2026-1' cod_per,'ING-SIS' cod_prog,'POR_CREDITOS' modalidad, NULL v_global, 320000.00 v_credito UNION ALL
 SELECT '2026-1','ING-IND','POR_CREDITOS',NULL,300000.00 UNION ALL
 SELECT '2026-1','ADM-EMP','GLOBAL',3800000.00,NULL UNION ALL
 SELECT '2026-1','CON-PUB','GLOBAL',3700000.00,NULL UNION ALL
 SELECT '2026-1','DER','GLOBAL',4500000.00,NULL UNION ALL
 SELECT '2026-1','PSI','GLOBAL',4200000.00,NULL UNION ALL
 SELECT '2026-1','MED','GLOBAL',8500000.00,NULL UNION ALL
 SELECT '2026-1','ENF','GLOBAL',4800000.00,NULL UNION ALL
 SELECT '2026-1','ARQ','GLOBAL',4600000.00,NULL UNION ALL
 SELECT '2026-1','COM-SOC','GLOBAL',3500000.00,NULL UNION ALL
 SELECT '2026-1','EDU-INF','GLOBAL',3200000.00,NULL UNION ALL
 SELECT '2026-1','NEG-INT','GLOBAL',4000000.00,NULL UNION ALL
 SELECT '2026-1','TEC-SIS','POR_CREDITOS',NULL,280000.00 UNION ALL
 SELECT '2026-1','TEC-ADM','GLOBAL',2800000.00,NULL UNION ALL
 SELECT '2026-1','TEC-CON','GLOBAL',2600000.00,NULL UNION ALL
 SELECT '2026-1','ESP-GER','GLOBAL',6500000.00,NULL UNION ALL
 SELECT '2026-1','ESP-FIN','GLOBAL',7000000.00,NULL UNION ALL
 SELECT '2026-1','ESP-DER','GLOBAL',6800000.00,NULL UNION ALL
 SELECT '2026-1','ESP-TIC','GLOBAL',6200000.00,NULL UNION ALL
 SELECT '2026-1','MAS-ADM','GLOBAL',12000000.00,NULL UNION ALL
 SELECT '2026-1','MAS-ING','GLOBAL',11000000.00,NULL UNION ALL
 SELECT '2026-1','MAS-DER','GLOBAL',11500000.00,NULL) t
WHERE per.nombre = t.cod_per AND prog.codigo = t.cod_prog;

-- Reglas 2025-1 (todos los programas)
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, t.modalidad, t.v_global, t.v_credito
FROM periodo_academico per, programa_academico prog,
(SELECT '2025-1' cod_per,'ING-SIS'  cod_prog,'POR_CREDITOS' modalidad, NULL    v_global, 290000.00 v_credito UNION ALL
 SELECT '2025-1','ING-IND', 'POR_CREDITOS', NULL,    270000.00 UNION ALL
 SELECT '2025-1','ADM-EMP', 'GLOBAL', 3500000.00, NULL UNION ALL
 SELECT '2025-1','CON-PUB', 'GLOBAL', 3400000.00, NULL UNION ALL
 SELECT '2025-1','DER',     'GLOBAL', 4200000.00, NULL UNION ALL
 SELECT '2025-1','PSI',     'GLOBAL', 3900000.00, NULL UNION ALL
 SELECT '2025-1','MED',     'GLOBAL', 7800000.00, NULL UNION ALL
 SELECT '2025-1','ENF',     'GLOBAL', 4500000.00, NULL UNION ALL
 SELECT '2025-1','ARQ',     'GLOBAL', 4400000.00, NULL UNION ALL
 SELECT '2025-1','COM-SOC', 'GLOBAL', 3300000.00, NULL UNION ALL
 SELECT '2025-1','EDU-INF', 'GLOBAL', 3000000.00, NULL UNION ALL
 SELECT '2025-1','NEG-INT', 'GLOBAL', 3800000.00, NULL UNION ALL
 SELECT '2025-1','TEC-SIS', 'POR_CREDITOS', NULL,    250000.00 UNION ALL
 SELECT '2025-1','TEC-ADM', 'GLOBAL', 2600000.00, NULL UNION ALL
 SELECT '2025-1','TEC-CON', 'GLOBAL', 2400000.00, NULL UNION ALL
 SELECT '2025-1','ESP-GER', 'GLOBAL', 6000000.00, NULL UNION ALL
 SELECT '2025-1','ESP-FIN', 'GLOBAL', 6500000.00, NULL UNION ALL
 SELECT '2025-1','ESP-DER', 'GLOBAL', 6300000.00, NULL UNION ALL
 SELECT '2025-1','ESP-TIC', 'GLOBAL', 5800000.00, NULL UNION ALL
 SELECT '2025-1','MAS-ADM', 'GLOBAL',11000000.00, NULL UNION ALL
 SELECT '2025-1','MAS-ING', 'GLOBAL',10500000.00, NULL UNION ALL
 SELECT '2025-1','MAS-DER', 'GLOBAL',11000000.00, NULL) t
WHERE per.nombre = t.cod_per AND prog.codigo = t.cod_prog;


-- Reglas 2025-2 (todos los programas)
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, t.modalidad, t.v_global, t.v_credito
FROM periodo_academico per, programa_academico prog,
(SELECT '2025-2' cod_per,'ING-SIS' cod_prog,'POR_CREDITOS' modalidad, NULL v_global, 300000.00 v_credito UNION ALL
 SELECT '2025-2','ING-IND', 'POR_CREDITOS', NULL,    285000.00 UNION ALL
 SELECT '2025-2','ADM-EMP', 'GLOBAL', 3600000.00, NULL UNION ALL
 SELECT '2025-2','CON-PUB', 'GLOBAL', 3500000.00, NULL UNION ALL
 SELECT '2025-2','DER',     'GLOBAL', 4300000.00, NULL UNION ALL
 SELECT '2025-2','PSI',     'GLOBAL', 4000000.00, NULL UNION ALL
 SELECT '2025-2','MED',     'GLOBAL', 8000000.00, NULL UNION ALL
 SELECT '2025-2','ENF',     'GLOBAL', 4600000.00, NULL UNION ALL
 SELECT '2025-2','ARQ',     'GLOBAL', 4500000.00, NULL UNION ALL
 SELECT '2025-2','COM-SOC', 'GLOBAL', 3400000.00, NULL UNION ALL
 SELECT '2025-2','EDU-INF', 'GLOBAL', 3100000.00, NULL UNION ALL
 SELECT '2025-2','NEG-INT', 'GLOBAL', 3900000.00, NULL UNION ALL
 SELECT '2025-2','TEC-SIS', 'POR_CREDITOS', NULL,    260000.00 UNION ALL
 SELECT '2025-2','TEC-ADM', 'GLOBAL', 2700000.00, NULL UNION ALL
 SELECT '2025-2','TEC-CON', 'GLOBAL', 2500000.00, NULL UNION ALL
 SELECT '2025-2','ESP-GER', 'GLOBAL', 6200000.00, NULL UNION ALL
 SELECT '2025-2','ESP-FIN', 'GLOBAL', 6700000.00, NULL UNION ALL
 SELECT '2025-2','ESP-DER', 'GLOBAL', 6500000.00, NULL UNION ALL
 SELECT '2025-2','ESP-TIC', 'GLOBAL', 6000000.00, NULL UNION ALL
 SELECT '2025-2','MAS-ADM', 'GLOBAL',11500000.00, NULL UNION ALL
 SELECT '2025-2','MAS-ING', 'GLOBAL',10700000.00, NULL UNION ALL
 SELECT '2025-2','MAS-DER', 'GLOBAL',11200000.00, NULL) t
WHERE per.nombre = t.cod_per AND prog.codigo = t.cod_prog;


-- ============================================================
-- ESTUDIANTES DE PRUEBA (20 estudiantes)
-- ============================================================
INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC','1001234501','Valentina',  'Torres Sánchez',    'vtorres@estudiante.edu.co',     '3101112233'),
    ('CC','1001234502','Juan Pablo', 'Ramos Díaz',        'jpramos@estudiante.edu.co',     '3112223344'),
    ('CC','1001234503','Sofía',      'Castro Mejía',      'scastro@estudiante.edu.co',     '3123334455'),
    ('CC','1001234504','Miguel',     'Vargas López',      'mvargas@estudiante.edu.co',     '3134445566'),
    ('CC','1001234505','Camila',     'Herrera Ríos',      'cherrera@estudiante.edu.co',    '3145556677'),
    ('CC','1001234506','Andrés',     'Morales Peña',      'amorales@estudiante.edu.co',    '3156667788'),
    ('CC','1001234507','Isabella',   'González Ruiz',     'igonzalez@estudiante.edu.co',   '3167778899'),
    ('CC','1001234508','Sebastián',  'Martínez Flores',   'smartinez@estudiante.edu.co',   '3178889900'),
    ('CC','1001234509','Daniela',    'Jiménez Ortiz',     'djimenez@estudiante.edu.co',    '3189990011'),
    ('CC','1001234510','Mateo',      'Rodríguez Silva',   'mrodriguez@estudiante.edu.co',  '3190001122'),
    ('CC','1001234511','Valeria',    'Fernández Cruz',    'vfernandez@estudiante.edu.co',  '3201112233'),
    ('CC','1001234512','Santiago',   'López Bermúdez',    'slopez@estudiante.edu.co',      '3212223344'),
    ('CC','1001234513','Mariana',    'García Pardo',      'mgarcia@estudiante.edu.co',     '3223334455'),
    ('CC','1001234514','Nicolás',    'Reyes Campos',      'nreyes@estudiante.edu.co',      '3234445566'),
    ('CC','1001234515','Gabriela',   'Muñoz Serrano',     'gmunoz@estudiante.edu.co',      '3245556677'),
    ('CE','1001234516','Carlos',     'Mendoza Arbeláez',  'cmendoza@estudiante.edu.co',    '3256667788'),
    ('CC','1001234517','Laura',      'Quintero Vásquez',  'lquintero@estudiante.edu.co',   '3267778899'),
    ('CC','1001234518','David',      'Aguilar Montoya',   'daguilar@estudiante.edu.co',    '3278889900'),
    ('CC','1001234519','Sara',       'Peña Castellanos',  'spena@estudiante.edu.co',       '3289990011'),
    ('CC','1001234520','Felipe',     'Cardona Ríos',      'fcardona@estudiante.edu.co',    '3290001122');


-- ============================================================
-- ESTUDIANTES ADICIONALES (10 por programa, nombres únicos y reales)
-- ============================================================
INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
-- ING-SIS
('CC','1002000001','Alejandro',  'Pedraza Niño',        'apedraza@estudiante.edu.co',     '3001001001'),
('CC','1002000002','Natalia',    'Cifuentes Prada',     'ncifuentes@estudiante.edu.co',   '3001001002'),
('CC','1002000003','Ricardo',    'Palomino Useche',     'rpalomino@estudiante.edu.co',    '3001001003'),
('CC','1002000004','Paola',      'Acosta Barrera',      'pacosta@estudiante.edu.co',      '3001001004'),
('CC','1002000005','Cristian',   'Bohórquez Leal',      'cbohorquez@estudiante.edu.co',   '3001001005'),
('CC','1002000006','Luisa',      'Serrano Palacios',    'lserrano@estudiante.edu.co',     '3001001006'),
('CC','1002000007','Esteban',    'Amaya Contreras',     'eamaya@estudiante.edu.co',       '3001001007'),
('CC','1002000008','Juliana',    'Becerra Pinzón',      'jbecerra@estudiante.edu.co',     '3001001008'),
('CC','1002000009','Héctor',     'Fuentes Alvarado',    'hfuentes@estudiante.edu.co',     '3001001009'),
('CC','1002000010','Marcela',    'Iglesias Buitrago',   'miglesias@estudiante.edu.co',    '3001001010'),
-- ING-IND
('CC','1002001001','Omar',       'Castellanos Vega',    'ocastellanos@estudiante.edu.co', '3001002001'),
('CC','1002001002','Patricia',   'Naranjo Correa',      'pnaranjo@estudiante.edu.co',     '3001002002'),
('CC','1002001003','Germán',     'Suárez Triana',       'gsuarez@estudiante.edu.co',      '3001002003'),
('CC','1002001004','Claudia',    'Rangel Mendoza',      'crangel@estudiante.edu.co',      '3001002004'),
('CC','1002001005','Iván',       'Portilla Sandoval',   'iportillb@estudiante.edu.co',    '3001002005'),
('CC','1002001006','Andrea',     'Solano Villamizar',   'asolanob@estudiante.edu.co',     '3001002006'),
('CC','1002001007','Rodrigo',    'Pineda Ballén',       'rpineda@estudiante.edu.co',      '3001002007'),
('CC','1002001008','Carolina',   'Hurtado Jaimes',      'churtado@estudiante.edu.co',     '3001002008'),
('CC','1002001009','Álvaro',     'Quintana Flórez',     'aquintana@estudiante.edu.co',    '3001002009'),
('CC','1002001010','Tatiana',    'Villegas Moncayo',    'tvillegas@estudiante.edu.co',    '3001002010'),
-- ADM-EMP
('CC','1002002001','Mauricio',   'Arias Bedoya',        'marias@estudiante.edu.co',       '3001003001'),
('CC','1002002002','Xiomara',    'Peláez Giraldo',      'xpelaez@estudiante.edu.co',      '3001003002'),
('CC','1002002003','Fernando',   'Ochoa Restrepo',      'fochoa@estudiante.edu.co',       '3001003003'),
('CC','1002002004','Stephanie',  'Correa Holguín',      'scorrea@estudiante.edu.co',      '3001003004'),
('CC','1002002005','Jhon',       'Medina Acevedo',      'jmedina@estudiante.edu.co',      '3001003005'),
('CC','1002002006','Lina',       'Tobón Cardona',       'ltobon@estudiante.edu.co',       '3001003006'),
('CC','1002002007','Andrés',     'Urrego Zapata',       'aurrego@estudiante.edu.co',      '3001003007'),
('CC','1002002008','Melissa',    'Zuluaga Jaramillo',   'mzuluaga@estudiante.edu.co',     '3001003008'),
('CC','1002002009','Gustavo',    'Londoño Vélez',       'glondono@estudiante.edu.co',     '3001003009'),
('CC','1002002010','Adriana',    'Sepúlveda Muñoz',     'asepulveda@estudiante.edu.co',   '3001003010'),
-- CON-PUB
('CC','1002003001','Harold',     'Ballesteros Díaz',    'hballesteros@estudiante.edu.co', '3001004001'),
('CC','1002003002','Yesenia',    'Carrillo Ávila',      'ycarrillo@estudiante.edu.co',    '3001004002'),
('CC','1002003003','Camilo',     'Sánchez Toro',        'csanchezt@estudiante.edu.co',    '3001004003'),
('CC','1002003004','Leidy',      'Bernal Pardo',        'lbernal@estudiante.edu.co',      '3001004004'),
('CC','1002003005','Julio',      'Arbeláez Figueroa',   'jarbelaez@estudiante.edu.co',    '3001004005'),
('CC','1002003006','Angélica',   'Varón Castro',        'avaron@estudiante.edu.co',       '3001004006'),
('CC','1002003007','Wilmer',     'Garzón Pulido',       'wgarzon@estudiante.edu.co',      '3001004007'),
('CC','1002003008','Bibiana',    'Moreno Salamanca',    'bmoreno@estudiante.edu.co',      '3001004008'),
('CC','1002003009','Édgar',      'Ríos Chaparro',       'erios@estudiante.edu.co',        '3001004009'),
('CC','1002003010','Sonia',      'Delgado Riveros',     'sdelgado@estudiante.edu.co',     '3001004010'),
-- DER
('CC','1002004001','Hernán',     'Rincón Agudelo',      'hrincon@estudiante.edu.co',      '3001005001'),
('CC','1002004002','Lorena',     'Parra Camacho',       'lparra@estudiante.edu.co',       '3001005002'),
('CC','1002004003','Álvaro',     'Nieto Fonseca',       'anieto@estudiante.edu.co',       '3001005003'),
('CC','1002004004','Gloria',     'Trujillo Bonilla',    'gtrujillo@estudiante.edu.co',    '3001005004'),
('CC','1002004005','Mauricio',   'Alarcón Vargas',      'malarcon@estudiante.edu.co',     '3001005005'),
('CC','1002004006','Pilar',      'Cuervo Méndez',       'pcuervo@estudiante.edu.co',      '3001005006'),
('CC','1002004007','Leonardo',   'Mahecha Quiroga',     'lmahecha@estudiante.edu.co',     '3001005007'),
('CC','1002004008','Diana',      'Téllez Rojas',        'dtellez@estudiante.edu.co',      '3001005008'),
('CC','1002004009','Fabián',     'Useche Cortés',       'fuseche@estudiante.edu.co',      '3001005009'),
('CC','1002004010','Nohora',     'Pinzón Galindo',      'npinzon@estudiante.edu.co',      '3001005010'),
-- PSI
('CC','1002005001','Sergio',     'Muñoz Espinosa',      'smunoz@estudiante.edu.co',       '3001006001'),
('CC','1002005002','Milena',     'Cardozo Buitrago',    'mcardozo@estudiante.edu.co',     '3001006002'),
('CC','1002005003','Jhonatan',   'Poveda Roa',          'jpoveda@estudiante.edu.co',      '3001006003'),
('CC','1002005004','Leidy',      'Sanabria Torres',     'lsanabria@estudiante.edu.co',    '3001006004'),
('CC','1002005005','Andrés',     'Chaparro Flórez',     'achaparro@estudiante.edu.co',    '3001006005'),
('CC','1002005006','Sandra',     'Olaya Cárdenas',      'solaya@estudiante.edu.co',       '3001006006'),
('CC','1002005007','Tomás',      'Herrera Pedraza',     'therrera@estudiante.edu.co',     '3001006007'),
('CC','1002005008','Yuri',       'Bautista Díaz',       'ybautista@estudiante.edu.co',    '3001006008'),
('CC','1002005009','Eduardo',    'Castellanos Prieto',  'ecastellanos@estudiante.edu.co', '3001006009'),
('CC','1002005010','Paola',      'Flórez Montiel',      'pflorez@estudiante.edu.co',      '3001006010'),
-- MED
('CC','1002006001','Catalina',   'Vásquez Guerrero',    'cvasquez@estudiante.edu.co',     '3001007001'),
('CC','1002006002','Ernesto',    'Peñuela Barragán',    'epenuelas@estudiante.edu.co',    '3001007002'),
('CC','1002006003','Margarita',  'Sandoval Reyes',      'msandoval@estudiante.edu.co',    '3001007003'),
('CC','1002006004','Germán',     'Lozada Ruiz',         'glozada@estudiante.edu.co',      '3001007004'),
('CC','1002006005','Estefanía',  'Molina Hoyos',        'emolina@estudiante.edu.co',      '3001007005'),
('CC','1002006006','Wilson',     'Prado Gamboa',        'wprado@estudiante.edu.co',       '3001007006'),
('CC','1002006007','Liliana',    'Rojas Sabogal',       'lrojas@estudiante.edu.co',       '3001007007'),
('CC','1002006008','Nicolás',    'Ariza Porras',        'nariza@estudiante.edu.co',       '3001007008'),
('CC','1002006009','Yamile',     'Fonseca Blanco',      'yfonseca@estudiante.edu.co',     '3001007009'),
('CC','1002006010','Sebastián',  'Téllez Wilches',      'stellez@estudiante.edu.co',      '3001007010'),
-- ENF
('CC','1002007001','Alejandra',  'Ceballos Hurtado',    'aceballos@estudiante.edu.co',    '3001008001'),
('CC','1002007002','Jorge',      'Navarrete Uribe',     'jnavarrete@estudiante.edu.co',   '3001008002'),
('CC','1002007003','Nubia',      'Alvarado Pinto',      'nalvarado@estudiante.edu.co',    '3001008003'),
('CC','1002007004','William',    'Salazar Vergara',     'wsalazar@estudiante.edu.co',     '3001008004'),
('CC','1002007005','Bibiana',    'Ramos Guerrero',      'bramos@estudiante.edu.co',       '3001008005'),
('CC','1002007006','Oswaldo',    'Suescún Lara',        'osuescun@estudiante.edu.co',     '3001008006'),
('CC','1002007007','Cindy',      'Bermúdez Acero',      'cbermudez@estudiante.edu.co',    '3001008007'),
('CC','1002007008','Camilo',     'Montes Parra',        'cmontes@estudiante.edu.co',      '3001008008'),
('CC','1002007009','Adriana',    'Guzmán Peña',         'aguzman@estudiante.edu.co',      '3001008009'),
('CC','1002007010','Jonathan',   'Caro Pineda',         'jcaro@estudiante.edu.co',        '3001008010'),
-- ARQ
('CC','1002008001','Sebastián',  'Barreto Amaya',       'sbarreto@estudiante.edu.co',     '3001009001'),
('CC','1002008002','Viviana',    'Ortega Duque',        'vortega@estudiante.edu.co',      '3001009002'),
('CC','1002008003','David',      'Restrepo Cano',       'drestrepo@estudiante.edu.co',    '3001009003'),
('CC','1002008004','Katherine',  'Mejía Zapata',        'kmejia@estudiante.edu.co',       '3001009004'),
('CC','1002008005','Julián',     'Caicedo Ríos',        'jcaicedo@estudiante.edu.co',     '3001009005'),
('CC','1002008006','Tatiana',    'Bernal Forero',       'tbernal@estudiante.edu.co',      '3001009006'),
('CC','1002008007','Andrés',     'Moreno Velandia',     'amorenov@estudiante.edu.co',     '3001009007'),
('CC','1002008008','Lina',       'Prada Medina',        'lprada@estudiante.edu.co',       '3001009008'),
('CC','1002008009','Daniel',     'Vargas Caballero',    'dvargasc@estudiante.edu.co',     '3001009009'),
('CC','1002008010','Ingrid',     'Orozco Estrada',      'iorozco@estudiante.edu.co',      '3001009010'),
-- COM-SOC
('CC','1002009001','Felipe',     'Salcedo Rondón',      'fsalcedo@estudiante.edu.co',     '3001010001'),
('CC','1002009002','Ángela',     'Bedoya Mosquera',     'abedoya@estudiante.edu.co',      '3001010002'),
('CC','1002009003','Mauricio',   'Vergara Llano',       'mvergara@estudiante.edu.co',     '3001010003'),
('CC','1002009004','Nathalia',   'Ospina Muñoz',        'nospina@estudiante.edu.co',      '3001010004'),
('CC','1002009005','Carlos',     'Henao Agudelo',       'chenao@estudiante.edu.co',       '3001010005'),
('CC','1002009006','Marcela',    'Ríos Londoño',        'mriosb@estudiante.edu.co',       '3001010006'),
('CC','1002009007','Jhon',       'Parra Cardona',       'jparrac@estudiante.edu.co',      '3001010007'),
('CC','1002009008','Sandra',     'Acosta Soto',         'sacosta@estudiante.edu.co',      '3001010008'),
('CC','1002009009','Hernán',     'Giraldo Vélez',       'hgiraldo@estudiante.edu.co',     '3001010009'),
('CC','1002009010','Paola',      'Montaño Díaz',        'pmontano@estudiante.edu.co',     '3001010010'),
-- EDU-INF
('CC','1002010001','Luz',        'Marina Rueda',        'lrueda@estudiante.edu.co',       '3001011001'),
('CC','1002010002','Elkin',      'Pulido Gómez',        'epulido@estudiante.edu.co',      '3001011002'),
('CC','1002010003','Yolanda',    'Cifuentes Mora',      'ycifuentes@estudiante.edu.co',   '3001011003'),
('CC','1002010004','Javier',     'Toro Gallego',        'jtoro@estudiante.edu.co',        '3001011004'),
('CC','1002010005','Gloria',     'Ávila Zamora',        'gavila@estudiante.edu.co',       '3001011005'),
('CC','1002010006','Rodrigo',    'Gutiérrez Ramos',     'rgutierrezb@estudiante.edu.co',  '3001011006'),
('CC','1002010007','Martha',     'Soto Guevara',        'msoto@estudiante.edu.co',        '3001011007'),
('CC','1002010008','Félix',      'Baquero Nieto',       'fbaquero@estudiante.edu.co',     '3001011008'),
('CC','1002010009','Ingrid',     'Díaz Melo',           'idiaz@estudiante.edu.co',        '3001011009'),
('CC','1002010010','Andrés',     'Castillo Prado',      'acastillo@estudiante.edu.co',    '3001011010'),
-- NEG-INT
('CC','1002011001','Melissa',    'Sarmiento Peña',      'msarmiento@estudiante.edu.co',   '3001012001'),
('CC','1002011002','Jorge',      'Cabrera Fajardo',     'jcabrera@estudiante.edu.co',     '3001012002'),
('CC','1002011003','Diana',      'Muñoz Galindo',       'dmunoz@estudiante.edu.co',       '3001012003'),
('CC','1002011004','Santiago',   'Guerrero Pinto',      'sguerrero@estudiante.edu.co',    '3001012004'),
('CC','1002011005','Vanessa',    'Cárdenas Bohórquez',  'vcardenas@estudiante.edu.co',    '3001012005'),
('CC','1002011006','Ricardo',    'Mora Arévalo',        'rmorab@estudiante.edu.co',       '3001012006'),
('CC','1002011007','Camila',     'Pérez Holguín',       'cperez@estudiante.edu.co',       '3001012007'),
('CC','1002011008','Andrés',     'Neira Vásquez',       'aneira@estudiante.edu.co',       '3001012008'),
('CC','1002011009','Juliana',    'Barón Quintero',      'jbaron@estudiante.edu.co',       '3001012009'),
('CC','1002011010','Wilson',     'Forero Sánchez',      'wforero@estudiante.edu.co',      '3001012010'),
-- TEC-SIS extra
('CC','1002012001','Kevin',      'Medina Salazar',      'kmedina@estudiante.edu.co',      '3001013001'),
('CC','1002012002','Laura',      'Vergara Triana',      'lvergarab@estudiante.edu.co',    '3001013002'),
('CC','1002012003','Darío',      'Bernal Casas',        'dbernal@estudiante.edu.co',      '3001013003'),
('CC','1002012004','Natalia',    'Hurtado Prieto',      'nhurtado@estudiante.edu.co',     '3001013004'),
('CC','1002012005','Cristóbal',  'Arango Ochoa',        'carangob@estudiante.edu.co',     '3001013005'),
('CC','1002012006','Johanna',    'Páez Riveros',        'jpaez@estudiante.edu.co',        '3001013006'),
('CC','1002012008','Fabio',      'Leal Romero',         'fleal@estudiante.edu.co',        '3001013008'),
('CC','1002012009','Adriana',    'Pinto Castellanos',   'apintob@estudiante.edu.co',      '3001013009'),
('CC','1002012010','Tomás',      'Suárez Niño',         'tsuarez@estudiante.edu.co',      '3001013010'),
-- TEC-ADM
('CC','1002013001','Yesid',      'Cano Bermúdez',       'ycanob@estudiante.edu.co',       '3001014001'),
('CC','1002013002','Luisa',      'Varón Aguilar',       'lvaron@estudiante.edu.co',       '3001014002'),
('CC','1002013003','Óscar',      'Reyes Morales',       'oreyes@estudiante.edu.co',       '3001014003'),
('CC','1002013004','Claudia',    'Ríos Obando',         'criosb@estudiante.edu.co',       '3001014004'),
('CC','1002013005','Edwin',      'Solano Rueda',        'esolano@estudiante.edu.co',      '3001014005'),
('CC','1002013006','Paola',      'Cadena Flórez',       'pcadena@estudiante.edu.co',      '3001014006'),
('CC','1002013007','Javier',     'Ospina Rincón',       'jospinabc@estudiante.edu.co',    '3001014007'),
('CC','1002013008','Bibiana',    'Herrera Acosta',      'bherrera@estudiante.edu.co',     '3001014008'),
('CC','1002013009','Carlos',     'Pedraza Clavijo',     'cpedrazab@estudiante.edu.co',    '3001014009'),
('CC','1002013010','Angela',     'Guzmán Torres',       'aguzmanb@estudiante.edu.co',     '3001014010'),
-- TEC-CON
('CC','1002014001','Fredy',      'Alarcón Useche',      'falarcon@estudiante.edu.co',     '3001015001'),
('CC','1002014002','Esperanza',  'Morales Pinzón',      'emorales@estudiante.edu.co',     '3001015002'),
('CC','1002014003','Jesús',      'Montoya Bernal',      'jmontoya@estudiante.edu.co',     '3001015003'),
('CC','1002014004','Silvia',     'Castaño Díaz',        'scastanob@estudiante.edu.co',    '3001015004'),
('CC','1002014005','Ramiro',     'Gómez Londoño',       'rgomez@estudiante.edu.co',       '3001015005'),
('CC','1002014006','Yolanda',    'Pabón Serrano',       'ypabon@estudiante.edu.co',       '3001015006'),
('CC','1002014007','Hernando',   'Acosta Guerrero',     'hacosta@estudiante.edu.co',      '3001015007'),
('CC','1002014008','Patricia',   'Rojas Ávila',         'projasb@estudiante.edu.co',      '3001015008'),
('CC','1002014009','Álvaro',     'Nieto Salcedo',       'anietob@estudiante.edu.co',      '3001015009'),
('CC','1002014010','Constanza',  'Duque Marín',         'cduque@estudiante.edu.co',       '3001015010'),
-- ESP-GER extra
('CC','1002015001','Rodrigo',    'Arbeláez Dávila',     'rarbelaez@estudiante.edu.co',    '3001016001'),
('CC','1002015002','Claudia',    'Sánchez Wilches',     'csanchezb@estudiante.edu.co',    '3001016002'),
('CC','1002015003','Álvaro',     'Peña Guerrero',       'apenab@estudiante.edu.co',       '3001016003'),
('CC','1002015004','Mónica',     'Florián Cárdenas',    'mflorian@estudiante.edu.co',     '3001016004'),
('CC','1002015005','Ernesto',    'Vargas Quintero',     'evargasb@estudiante.edu.co',     '3001016005'),
('CC','1002015006','Ximena',     'Mahecha Prado',       'xmahecha@estudiante.edu.co',     '3001016006'),
('CC','1002015007','Fabián',     'Castro Betancourt',   'fcastrob@estudiante.edu.co',     '3001016007'),
('CC','1002015008','Adriana',    'Lozano Amaya',        'alozanob@estudiante.edu.co',     '3001016008'),
('CC','1002015009','Camilo',     'Guzmán Bermúdez',     'cguzman@estudiante.edu.co',      '3001016009'),
('CC','1002015010','Stefania',   'Caro Medina',         'scarob@estudiante.edu.co',       '3001016010'),
-- ESP-FIN
('CC','1002016001','Mauricio',   'Prado Villegas',      'mpradb@estudiante.edu.co',       '3001017001'),
('CC','1002016002','Lorena',     'Duarte Cifuentes',    'lduarte@estudiante.edu.co',      '3001017002'),
('CC','1002016003','Gabriel',    'Téllez Barón',        'gtellez@estudiante.edu.co',      '3001017003'),
('CC','1002016004','Liliana',    'Ospina Castaño',      'lospinad@estudiante.edu.co',     '3001017004'),
('CC','1002016005','Fernando',   'Rincón Sabogal',      'frincon@estudiante.edu.co',      '3001017005'),
('CC','1002016006','Carolina',   'Vega Acevedo',        'cvega@estudiante.edu.co',        '3001017006'),
('CC','1002016007','Héctor',     'Bedoya Restrepo',     'hbedoya@estudiante.edu.co',      '3001017007'),
('CC','1002016008','Andrea',     'Flórez Ríos',         'aflorezb@estudiante.edu.co',     '3001017008'),
('CC','1002016009','Julián',     'Ríos Barreto',        'jriosb@estudiante.edu.co',       '3001017009'),
('CC','1002016010','Sandra',     'Molina Gutiérrez',    'smolinab@estudiante.edu.co',     '3001017010'),
-- ESP-DER
('CC','1002017001','Édgar',      'Bernal Páez',         'ebernal@estudiante.edu.co',      '3001018001'),
('CC','1002017002','Pilar',      'Moreno Fonseca',      'pmorenob@estudiante.edu.co',     '3001018002'),
('CC','1002017003','William',    'Suárez Herrera',      'wsuarez@estudiante.edu.co',      '3001018003'),
('CC','1002017004','Ángela',     'Nieto Bonilla',       'anietob2@estudiante.edu.co',     '3001018004'),
('CC','1002017005','Iván',       'Cárdenas Pérez',      'icardenas@estudiante.edu.co',    '3001018005'),
('CC','1002017006','Natalia',    'Arango Salcedo',      'narangob@estudiante.edu.co',     '3001018006'),
('CC','1002017007','Oswaldo',    'Vergara Pineda',      'overgara@estudiante.edu.co',     '3001018007'),
('CC','1002017008','Diana',      'Pulido Montoya',      'dpulido@estudiante.edu.co',      '3001018008'),
('CC','1002017009','Rodrigo',    'Guevara Salinas',     'rguevara@estudiante.edu.co',     '3001018009'),
('CC','1002017010','Leidy',      'Chaparro Useche',     'lchaparro@estudiante.edu.co',    '3001018010'),
-- ESP-TIC
('CC','1002018001','Cristian',   'Pabón Acosta',        'cpabon@estudiante.edu.co',       '3001019001'),
('CC','1002018002','Vanessa',    'Forero Rueda',        'vforero@estudiante.edu.co',      '3001019002'),
('CC','1002018003','Sergio',     'Muñoz Barragán',      'smunozb@estudiante.edu.co',      '3001019003'),
('CC','1002018004','Johanna',    'Roa Pinzón',          'jroab@estudiante.edu.co',        '3001019004'),
('CC','1002018005','Kevin',      'Alarcón Herrera',     'kalarcon@estudiante.edu.co',     '3001019005'),
('CC','1002018006','Melissa',    'Castro Giraldo',      'mcastrob@estudiante.edu.co',     '3001019006'),
('CC','1002018007','Darío',      'Pedraza Varón',       'dpedraza@estudiante.edu.co',     '3001019007'),
('CC','1002018008','Adriana',    'Londoño Triana',      'alondono@estudiante.edu.co',     '3001019008'),
('CC','1002018009','Edwin',      'Sarmiento Mora',      'esarmiento@estudiante.edu.co',   '3001019009'),
('CC','1002018010','Paola',      'Vásquez Cano',        'pvasquez@estudiante.edu.co',     '3001019010'),
-- MAS-ADM extra
('CC','1002019001','Gustavo',    'Hurtado Arbeláez',    'ghurtado@estudiante.edu.co',     '3001020001'),
('CC','1002019002','Claudia',    'Espinosa Holguín',    'cespinosa@estudiante.edu.co',    '3001020002'),
('CC','1002019003','Hernán',     'Tobón Castaño',       'htobon@estudiante.edu.co',       '3001020003'),
('CC','1002019004','Mónica',     'Zapata Restrepo',     'mzapata@estudiante.edu.co',      '3001020004'),
('CC','1002019005','Leonardo',   'Acevedo Giraldo',     'lacevedo@estudiante.edu.co',     '3001020005'),
('CC','1002019006','Patricia',   'Wilches Flórez',      'pwilches@estudiante.edu.co',     '3001020006'),
('CC','1002019007','Germán',     'Ríos Betancourt',     'griosb@estudiante.edu.co',       '3001020007'),
('CC','1002019008','Ximena',     'Caicedo Bermúdez',    'xcaicedo@estudiante.edu.co',     '3001020008'),
('CC','1002019009','Fabián',     'Lozano Guerrero',     'flozano@estudiante.edu.co',      '3001020009'),
('CC','1002019010','Carolina',   'Medina Sabogal',      'cmedinabc@estudiante.edu.co',    '3001020010'),
-- MAS-ING
('CC','1002020001','Álvaro',     'Gaviria Montoya',     'agaviria@estudiante.edu.co',     '3001021001'),
('CC','1002020002','Stefania',   'Bonilla Duque',       'sbonilla@estudiante.edu.co',     '3001021002'),
('CC','1002020003','Harold',     'Pineda Caro',         'hpineda@estudiante.edu.co',      '3001021003'),
('CC','1002020004','Lina',       'Guerrero Páez',       'lguerrero@estudiante.edu.co',    '3001021004'),
('CC','1002020005','Julio',      'Amaya Vergara',       'jamayab@estudiante.edu.co',      '3001021005'),
('CC','1002020006','Yesenia',    'Rodríguez Pabón',     'yrodriguez@estudiante.edu.co',   '3001021006'),
('CC','1002020007','Camilo',     'Fajardo Rincón',      'cfajardo@estudiante.edu.co',     '3001021007'),
('CC','1002020008','Bibiana',    'Ariza Soto',          'barizab@estudiante.edu.co',      '3001021008'),
('CC','1002020009','Tomás',      'Cuervo Salcedo',      'tcuervo@estudiante.edu.co',      '3001021009'),
('CC','1002020010','Sandra',     'Mahecha Villegas',    'smahecha@estudiante.edu.co',     '3001021010'),
-- MAS-DER
('CC','1002021001','Rodrigo',    'Espinosa Barreto',    'respinosa@estudiante.edu.co',    '3001022001'),
('CC','1002021002','Gloria',     'Navarrete Prado',     'gnavarrete@estudiante.edu.co',   '3001022002'),
('CC','1002021003','Wilson',     'Peláez Nieto',        'wpelaez@estudiante.edu.co',      '3001022003'),
('CC','1002021004','Diana',      'Cardozo Useche',      'dcardozo@estudiante.edu.co',     '3001022004'),
('CC','1002021005','Fernando',   'Sánchez Guzmán',      'fsanchezb@estudiante.edu.co',    '3001022005'),
('CC','1002021006','Yolanda',    'Vásquez Herrera',     'yvasquez@estudiante.edu.co',     '3001022006'),
('CC','1002021007','Ernesto',    'Roa Florián',         'eroa@estudiante.edu.co',         '3001022007'),
('CC','1002021008','Pilar',      'Bernal Agudelo',      'pbernal@estudiante.edu.co',      '3001022008'),
('CC','1002021009','Mauricio',   'Delgado Camacho',     'mdelgado@estudiante.edu.co',     '3001022009'),
('CC','1002021010','Marcela',    'Téllez Bedoya',       'mtellez@estudiante.edu.co',      '3001022010');


-- ============================================================
-- USUARIOS DE PRUEBA (SUPERVISOR y ASISTENTE)
-- Contraseñas: Supervisor2026* y Asistente2026*
-- ============================================================
INSERT INTO persona (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC', '1111111111', 'Carlos',  'Mendoza Herrera',  'supervisor@unicaribe.edu.co', '3009998877'),
    ('CC', '2222222222', 'María',   'López Restrepo',   'asistente@unicaribe.edu.co',  '3009997766');

INSERT INTO usuario (id_persona, id_rol, username, password)
SELECT p.id_persona, r.id_rol,
       'supervisor',
       'scrypt:32768:8:1$NjEHlvuzcn2kQCxB$bcd31cc8a6059fe7301ff78bc9e5fbc82e6daf0a0972a890e20b66123ed14c6183e930ecc9afa0e6f97c4d9369875cd1e14c54c45d447aeefa849ebb675ded35'
FROM persona p JOIN rol r ON r.nombre = 'SUPERVISOR'
WHERE p.email = 'supervisor@unicaribe.edu.co';

INSERT INTO usuario (id_persona, id_rol, username, password)
SELECT p.id_persona, r.id_rol,
       'asistente',
       'scrypt:32768:8:1$Q9HwDzIPjhKmqADz$af71c3275ce3e143d85eb034f00568312f5ac1deded2a577a8cf90070186a4ff5463be6a2a94d894919f966c2fa02907ba29aa86d1df0815b3f8eebf4db6bab2'
FROM persona p JOIN rol r ON r.nombre = 'ASISTENTE'
WHERE p.email = 'asistente@unicaribe.edu.co';


-- ============================================================
-- PLANES DE ESTUDIO FALTANTES
-- ============================================================

-- ARQ — Arquitectura (10 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ARQ' cod_p,'ARQ101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'ARQ','ARQ102',1,3 UNION ALL SELECT 'ARQ','MAT101',1,3 UNION ALL
 SELECT 'ARQ','HUM101',1,2 UNION ALL SELECT 'ARQ','COM101',1,2 UNION ALL
 SELECT 'ARQ','ARQ201',2,4 UNION ALL SELECT 'ARQ','FIS101',2,3 UNION ALL
 SELECT 'ARQ','MAT102',2,3 UNION ALL SELECT 'ARQ','ING-E01',2,2 UNION ALL
 SELECT 'ARQ','ARQ202',3,4 UNION ALL SELECT 'ARQ','FIS102',3,3 UNION ALL
 SELECT 'ARQ','HUM102',3,2 UNION ALL SELECT 'ARQ','ING-E02',3,2 UNION ALL
 SELECT 'ARQ','ARQ301',4,3 UNION ALL SELECT 'ARQ','ARQ302',4,3 UNION ALL
 SELECT 'ARQ','MAT203',4,3 UNION ALL SELECT 'ARQ','ECO101',4,2 UNION ALL
 SELECT 'ARQ','ARQ401',5,3 UNION ALL SELECT 'ARQ','INV101',5,3 UNION ALL
 SELECT 'ARQ','ETI101',5,2 UNION ALL SELECT 'ARQ','ING-E03',5,2 UNION ALL
 SELECT 'ARQ','ADM101',6,3 UNION ALL SELECT 'ARQ','FIN101',6,3 UNION ALL
 SELECT 'ARQ','EST101',6,3 UNION ALL SELECT 'ARQ','ING-E04',7,2 UNION ALL
 SELECT 'ARQ','ADM202',7,3 UNION ALL SELECT 'ARQ','INV201',7,3 UNION ALL
 SELECT 'ARQ','EMP101',8,3 UNION ALL SELECT 'ARQ','ADM401',8,3 UNION ALL
 SELECT 'ARQ','TRA101',9,6 UNION ALL SELECT 'ARQ','TRA102',10,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- COM-SOC — Comunicación Social (8 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'COM-SOC' cod_p,'COM101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'COM-SOC','COM102',1,3 UNION ALL SELECT 'COM-SOC','HUM101',1,2 UNION ALL
 SELECT 'COM-SOC','ING-E01',1,2 UNION ALL SELECT 'COM-SOC','ECO101',1,2 UNION ALL
 SELECT 'COM-SOC','COM201',2,3 UNION ALL SELECT 'COM-SOC','COM202',2,3 UNION ALL
 SELECT 'COM-SOC','HUM102',2,2 UNION ALL SELECT 'COM-SOC','ING-E02',2,2 UNION ALL
 SELECT 'COM-SOC','COM301',3,3 UNION ALL SELECT 'COM-SOC','MKT101',3,3 UNION ALL
 SELECT 'COM-SOC','INV101',3,3 UNION ALL SELECT 'COM-SOC','ETI101',3,2 UNION ALL
 SELECT 'COM-SOC','MKT201',4,3 UNION ALL SELECT 'COM-SOC','ADM101',4,3 UNION ALL
 SELECT 'COM-SOC','EST101',4,3 UNION ALL SELECT 'COM-SOC','ING-E03',4,2 UNION ALL
 SELECT 'COM-SOC','MKT301',5,3 UNION ALL SELECT 'COM-SOC','ADM202',5,3 UNION ALL
 SELECT 'COM-SOC','INV201',5,3 UNION ALL SELECT 'COM-SOC','ING-E04',6,2 UNION ALL
 SELECT 'COM-SOC','EMP101',6,3 UNION ALL SELECT 'COM-SOC','FIN101',6,2 UNION ALL
 SELECT 'COM-SOC','ADM401',7,3 UNION ALL SELECT 'COM-SOC','TRA101',7,3 UNION ALL
 SELECT 'COM-SOC','TRA102',8,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ENF — Enfermería (8 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ENF' cod_p,'ENF101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'ENF','ENF102',1,3 UNION ALL SELECT 'ENF','BIO101',1,3 UNION ALL
 SELECT 'ENF','COM101',1,2 UNION ALL SELECT 'ENF','HUM101',1,2 UNION ALL
 SELECT 'ENF','ENF201',2,4 UNION ALL SELECT 'ENF','MED101',2,3 UNION ALL
 SELECT 'ENF','QUI101',2,3 UNION ALL SELECT 'ENF','ING-E01',2,2 UNION ALL
 SELECT 'ENF','ENF202',3,4 UNION ALL SELECT 'ENF','MED201',3,3 UNION ALL
 SELECT 'ENF','HUM102',3,2 UNION ALL SELECT 'ENF','ENF301',4,4 UNION ALL
 SELECT 'ENF','MED301',4,3 UNION ALL SELECT 'ENF','MED302',4,3 UNION ALL
 SELECT 'ENF','ETI101',4,2 UNION ALL SELECT 'ENF','ENF302',5,4 UNION ALL
 SELECT 'ENF','MED401',5,3 UNION ALL SELECT 'ENF','INV101',5,2 UNION ALL
 SELECT 'ENF','MED402',6,3 UNION ALL SELECT 'ENF','EST101',6,3 UNION ALL
 SELECT 'ENF','INV201',6,3 UNION ALL SELECT 'ENF','TRA101',7,6 UNION ALL
 SELECT 'ENF','TRA102',8,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- MED — Medicina (12 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'MED' cod_p,'MED101' cod_a,1 sem,4 cred UNION ALL
 SELECT 'MED','BIO101',1,3 UNION ALL SELECT 'MED','QUI101',1,3 UNION ALL
 SELECT 'MED','COM101',1,2 UNION ALL SELECT 'MED','HUM101',1,2 UNION ALL
 SELECT 'MED','MED102',2,4 UNION ALL SELECT 'MED','MED201',2,4 UNION ALL
 SELECT 'MED','ING-E01',2,2 UNION ALL SELECT 'MED','MED202',3,4 UNION ALL
 SELECT 'MED','HUM102',3,2 UNION ALL SELECT 'MED','INV101',3,2 UNION ALL
 SELECT 'MED','MED301',4,4 UNION ALL SELECT 'MED','MED302',4,4 UNION ALL
 SELECT 'MED','ETI101',4,2 UNION ALL SELECT 'MED','MED401',5,4 UNION ALL
 SELECT 'MED','EST101',5,3 UNION ALL SELECT 'MED','MED402',6,4 UNION ALL
 SELECT 'MED','INV201',6,2 UNION ALL SELECT 'MED','MED501',7,4 UNION ALL
 SELECT 'MED','MED502',7,4 UNION ALL SELECT 'MED','MED601',8,4 UNION ALL
 SELECT 'MED','MED602',8,4 UNION ALL SELECT 'MED','TRA101',9,6 UNION ALL
 SELECT 'MED','TRA102',10,6 UNION ALL
 -- Semestres 11 y 12: internado rotatorio
 -- Se usan ING-E02/03/04 y EMP101 porque no están en semestres anteriores
 SELECT 'MED','ING-E02',11,2 UNION ALL
 SELECT 'MED','ING-E03',11,2 UNION ALL
 SELECT 'MED','ING-E04',12,2 UNION ALL
 SELECT 'MED','EMP101', 12,3) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- EDU-INF — Licenciatura Educación Infantil (8 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'EDU-INF' cod_p,'EDU101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'EDU-INF','EDU102',1,3 UNION ALL SELECT 'EDU-INF','COM101',1,2 UNION ALL
 SELECT 'EDU-INF','HUM101',1,2 UNION ALL SELECT 'EDU-INF','PSI101',1,3 UNION ALL
 SELECT 'EDU-INF','EDU201',2,3 UNION ALL SELECT 'EDU-INF','PSI102',2,3 UNION ALL
 SELECT 'EDU-INF','ING-E01',2,2 UNION ALL SELECT 'EDU-INF','HUM102',2,2 UNION ALL
 SELECT 'EDU-INF','EDU202',3,3 UNION ALL SELECT 'EDU-INF','PSI201',3,3 UNION ALL
 SELECT 'EDU-INF','INV101',3,3 UNION ALL SELECT 'EDU-INF','ETI101',3,2 UNION ALL
 SELECT 'EDU-INF','EDU301',4,4 UNION ALL SELECT 'EDU-INF','MAT203',4,3 UNION ALL
 SELECT 'EDU-INF','ING-E02',4,2 UNION ALL SELECT 'EDU-INF','EDU302',5,4 UNION ALL
 SELECT 'EDU-INF','EST101',5,3 UNION ALL SELECT 'EDU-INF','INV201',5,3 UNION ALL
 SELECT 'EDU-INF','ADM101',6,3 UNION ALL SELECT 'EDU-INF','ING-E03',6,2 UNION ALL
 SELECT 'EDU-INF','EMP101',6,3 UNION ALL SELECT 'EDU-INF','TRA101',7,6 UNION ALL
 SELECT 'EDU-INF','TRA102',8,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- NEG-INT — Negocios Internacionales (8 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'NEG-INT' cod_p,'ADM101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'NEG-INT','ECO101',1,3 UNION ALL SELECT 'NEG-INT','COM101',1,2 UNION ALL
 SELECT 'NEG-INT','HUM101',1,2 UNION ALL SELECT 'NEG-INT','ING-E01',1,3 UNION ALL
 SELECT 'NEG-INT','NEG101',2,3 UNION ALL SELECT 'NEG-INT','ECO102',2,3 UNION ALL
 SELECT 'NEG-INT','MKT101',2,3 UNION ALL SELECT 'NEG-INT','ING-E02',2,3 UNION ALL
 SELECT 'NEG-INT','NEG201',3,3 UNION ALL SELECT 'NEG-INT','FIN101',3,3 UNION ALL
 SELECT 'NEG-INT','DER101',3,2 UNION ALL SELECT 'NEG-INT','HUM102',3,2 UNION ALL
 SELECT 'NEG-INT','NEG301',4,3 UNION ALL SELECT 'NEG-INT','FIN201',4,3 UNION ALL
 SELECT 'NEG-INT','MKT201',4,3 UNION ALL SELECT 'NEG-INT','ING-E03',4,3 UNION ALL
 SELECT 'NEG-INT','ADM202',5,3 UNION ALL SELECT 'NEG-INT','FIN202',5,3 UNION ALL
 SELECT 'NEG-INT','MKT301',5,3 UNION ALL SELECT 'NEG-INT','ETI101',5,2 UNION ALL
 SELECT 'NEG-INT','FIN301',6,3 UNION ALL SELECT 'NEG-INT','INV101',6,3 UNION ALL
 SELECT 'NEG-INT','ING-E04',6,3 UNION ALL SELECT 'NEG-INT','ADM401',7,3 UNION ALL
 SELECT 'NEG-INT','INV201',7,3 UNION ALL SELECT 'NEG-INT','EMP101',7,3 UNION ALL
 SELECT 'NEG-INT','TRA101',8,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- TEC-ADM — Tecnología en Gestión Empresarial (6 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'TEC-ADM' cod_p,'ADM101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'TEC-ADM','ECO101',1,3 UNION ALL SELECT 'TEC-ADM','COM101',1,2 UNION ALL
 SELECT 'TEC-ADM','HUM101',1,2 UNION ALL SELECT 'TEC-ADM','ADM102',2,3 UNION ALL
 SELECT 'TEC-ADM','MKT101',2,3 UNION ALL SELECT 'TEC-ADM','CON101',2,3 UNION ALL
 SELECT 'TEC-ADM','ING-E01',2,2 UNION ALL SELECT 'TEC-ADM','ADM201',3,3 UNION ALL
 SELECT 'TEC-ADM','FIN101',3,3 UNION ALL SELECT 'TEC-ADM','HUM102',3,2 UNION ALL
 SELECT 'TEC-ADM','ADM202',4,3 UNION ALL SELECT 'TEC-ADM','FIN201',4,3 UNION ALL
 SELECT 'TEC-ADM','MKT201',4,3 UNION ALL SELECT 'TEC-ADM','ETI101',4,2 UNION ALL
 SELECT 'TEC-ADM','ADM401',5,3 UNION ALL SELECT 'TEC-ADM','INV101',5,3 UNION ALL
 SELECT 'TEC-ADM','EMP101',5,3 UNION ALL SELECT 'TEC-ADM','TRA101',6,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- TEC-CON — Tecnología en Contabilidad (6 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'TEC-CON' cod_p,'CON101' cod_a,1 sem,3 cred UNION ALL
 SELECT 'TEC-CON','ECO101',1,3 UNION ALL SELECT 'TEC-CON','MAT101',1,3 UNION ALL
 SELECT 'TEC-CON','COM101',1,2 UNION ALL SELECT 'TEC-CON','CON102',2,3 UNION ALL
 SELECT 'TEC-CON','FIN101',2,3 UNION ALL SELECT 'TEC-CON','DER101',2,2 UNION ALL
 SELECT 'TEC-CON','HUM101',2,2 UNION ALL SELECT 'TEC-CON','CON201',3,3 UNION ALL
 SELECT 'TEC-CON','TRI101',3,3 UNION ALL SELECT 'TEC-CON','FIN201',3,3 UNION ALL
 SELECT 'TEC-CON','HUM102',3,2 UNION ALL SELECT 'TEC-CON','CON301',4,3 UNION ALL
 SELECT 'TEC-CON','TRI201',4,3 UNION ALL SELECT 'TEC-CON','ETI101',4,2 UNION ALL
 SELECT 'TEC-CON','FIN202',5,3 UNION ALL SELECT 'TEC-CON','INV101',5,3 UNION ALL
 SELECT 'TEC-CON','EMP101',5,3 UNION ALL SELECT 'TEC-CON','TRA101',6,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ESP-FIN — Especialización Finanzas (3 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ESP-FIN' cod_p,'FIN202' cod_a,1 sem,4 cred UNION ALL
 SELECT 'ESP-FIN','FIN301',1,4 UNION ALL SELECT 'ESP-FIN','INV101',1,4 UNION ALL
 SELECT 'ESP-FIN','FIN401',2,4 UNION ALL SELECT 'ESP-FIN','ADM202',2,4 UNION ALL
 SELECT 'ESP-FIN','EST101',2,4 UNION ALL SELECT 'ESP-FIN','TRA101',3,6 UNION ALL
 SELECT 'ESP-FIN','INV201',3,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ESP-DER — Especialización Derecho Comercial (3 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ESP-DER' cod_p,'DER401' cod_a,1 sem,4 cred UNION ALL
 SELECT 'ESP-DER','DER501',1,4 UNION ALL SELECT 'ESP-DER','INV101',1,4 UNION ALL
 SELECT 'ESP-DER','DER502',2,4 UNION ALL SELECT 'ESP-DER','ADM202',2,4 UNION ALL
 SELECT 'ESP-DER','FIN101',2,4 UNION ALL SELECT 'ESP-DER','TRA101',3,6 UNION ALL
 SELECT 'ESP-DER','INV201',3,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- ESP-TIC — Especialización Seguridad Informática (3 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'ESP-TIC' cod_p,'SEG101' cod_a,1 sem,4 cred UNION ALL
 SELECT 'ESP-TIC','SEG201',1,4 UNION ALL SELECT 'ESP-TIC','RED101',1,4 UNION ALL
 SELECT 'ESP-TIC','SEG301',2,4 UNION ALL SELECT 'ESP-TIC','RED201',2,4 UNION ALL
 SELECT 'ESP-TIC','INV101',2,4 UNION ALL SELECT 'ESP-TIC','TRA101',3,6 UNION ALL
 SELECT 'ESP-TIC','INV201',3,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- MAS-ING — Maestría Ingeniería de Software (4 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'MAS-ING' cod_p,'ING301' cod_a,1 sem,4 cred UNION ALL
 SELECT 'MAS-ING','ING401',1,4 UNION ALL SELECT 'MAS-ING','PRG402',1,4 UNION ALL
 SELECT 'MAS-ING','BDD202',2,4 UNION ALL SELECT 'MAS-ING','SOP301',2,4 UNION ALL
 SELECT 'MAS-ING','ING201',2,4 UNION ALL SELECT 'MAS-ING','INV201',3,4 UNION ALL
 SELECT 'MAS-ING','SEG201',3,4 UNION ALL SELECT 'MAS-ING','EMP101',3,4 UNION ALL
 SELECT 'MAS-ING','TRA101',4,6 UNION ALL SELECT 'MAS-ING','TRA102',4,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;

-- MAS-DER — Maestría Derecho Empresarial (4 semestres)
INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
SELECT p.id_programa, a.id_asignatura, t.sem, t.cred
FROM programa_academico p, asignatura a,
(SELECT 'MAS-DER' cod_p,'DER401' cod_a,1 sem,4 cred UNION ALL
 SELECT 'MAS-DER','DER402',1,4 UNION ALL SELECT 'MAS-DER','FIN101',1,4 UNION ALL
 SELECT 'MAS-DER','DER501',2,4 UNION ALL SELECT 'MAS-DER','ADM202',2,4 UNION ALL
 SELECT 'MAS-DER','INV101',2,4 UNION ALL SELECT 'MAS-DER','DER502',3,4 UNION ALL
 SELECT 'MAS-DER','FIN201',3,4 UNION ALL SELECT 'MAS-DER','INV201',3,4 UNION ALL
 SELECT 'MAS-DER','TRA101',4,6 UNION ALL SELECT 'MAS-DER','TRA102',4,6) t
WHERE p.codigo = t.cod_p AND a.codigo = t.cod_a;


-- ============================================================
-- USUARIO ADMINISTRADOR
-- Contraseña: Admin2026*
-- Hash generado con werkzeug.security.generate_password_hash('Admin2026*')
-- Si regeneras el hash con generar_admin.py, actualiza este INSERT.
-- ============================================================
INSERT IGNORE INTO persona (tipo_doc, num_doc, nombres, apellidos, email, telefono)
VALUES ('CC', '0000000000', 'Administrador', 'Sistema', 'admin@unicaribe.edu.co', '3001234567');

INSERT IGNORE INTO usuario (id_persona, id_rol, username, password)
SELECT
    p.id_persona,
    r.id_rol,
    'admin',
    'scrypt:32768:8:1$uBvvaDV3gEn6rdpv$db5521a59afa5fdfe6da166104ef10251d94ef8fc82f4567c1e0c182143268fa78f3b685fa910f4c1e0c7ae80d61b7ee30d6082a8dd289ff875c4ad90c274c88'
FROM persona p
JOIN rol r ON r.nombre = 'ADMINISTRADOR'
WHERE p.email = 'admin@unicaribe.edu.co';
