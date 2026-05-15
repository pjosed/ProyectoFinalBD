-- 02_datos_semilla.sql — DATOS COMPLETOS DE PRUEBA

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

-- Reglas 2025-1
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, t.modalidad, t.v_global, t.v_credito
FROM periodo_academico per,
     programa_academico prog,
(SELECT '2025-1' cod_per,'ING-SIS' cod_prog,'POR_CREDITOS' modalidad,NULL v_global,290000.00 v_credito UNION ALL
 SELECT '2025-1','ADM-EMP','GLOBAL',3500000.00,NULL UNION ALL
 SELECT '2025-1','CON-PUB','GLOBAL',3400000.00,NULL UNION ALL
 SELECT '2025-1','DER','GLOBAL',4100000.00,NULL UNION ALL
 SELECT '2025-1','PSI','GLOBAL',3900000.00,NULL UNION ALL
 SELECT '2025-1','MED','GLOBAL',7800000.00,NULL UNION ALL
 SELECT '2025-1','TEC-SIS','POR_CREDITOS',NULL,250000.00 UNION ALL
 SELECT '2025-1','ESP-GER','GLOBAL',6000000.00,NULL UNION ALL
 SELECT '2025-1','MAS-ADM','GLOBAL',11000000.00,NULL) t
WHERE per.nombre = t.cod_per AND prog.codigo = t.cod_prog;

-- Reglas 2025-2
INSERT INTO regla_cobro (id_periodo, id_programa, modalidad_cobro, valor_global, valor_credito)
SELECT per.id_periodo, prog.id_programa, t.modalidad, t.v_global, t.v_credito
FROM periodo_academico per,
     programa_academico prog,
(SELECT '2025-2' cod_per,'ING-SIS' cod_prog,'POR_CREDITOS' modalidad,NULL v_global,300000.00 v_credito UNION ALL
 SELECT '2025-2','ADM-EMP','GLOBAL',3600000.00,NULL UNION ALL
 SELECT '2025-2','CON-PUB','GLOBAL',3500000.00,NULL UNION ALL
 SELECT '2025-2','DER','GLOBAL',4300000.00,NULL UNION ALL
 SELECT '2025-2','PSI','GLOBAL',4000000.00,NULL UNION ALL
 SELECT '2025-2','MED','GLOBAL',8000000.00,NULL UNION ALL
 SELECT '2025-2','TEC-SIS','POR_CREDITOS',NULL,260000.00 UNION ALL
 SELECT '2025-2','ESP-GER','GLOBAL',6200000.00,NULL UNION ALL
 SELECT '2025-2','MAS-ADM','GLOBAL',11500000.00,NULL) t
WHERE per.nombre = t.cod_per AND prog.codigo = t.cod_prog;


-- ============================================================
-- ESTUDIANTES DE PRUEBA (20 estudiantes)
-- ============================================================
INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC','1001234501','Valentina', 'Torres Sánchez',   'vtorres@estudiante.edu.co',    '3101112233'),
    ('CC','1001234502','Juan',      'Ramos Díaz',       'jramos@estudiante.edu.co',     '3112223344'),
    ('CC','1001234503','Sofía',     'Castro Mejía',     'scastro@estudiante.edu.co',    '3123334455'),
    ('CC','1001234504','Miguel',    'Vargas López',     'mvargas@estudiante.edu.co',    '3134445566'),
    ('CC','1001234505','Camila',    'Herrera Ríos',     'cherrera@estudiante.edu.co',   '3145556677'),
    ('CC','1001234506','Andrés',    'Morales Peña',     'amorales@estudiante.edu.co',   '3156667788'),
    ('CC','1001234507','Isabella',  'González Ruiz',    'igonzalez@estudiante.edu.co',  '3167778899'),
    ('CC','1001234508','Sebastián', 'Martínez Flores',  'smartinez@estudiante.edu.co',  '3178889900'),
    ('CC','1001234509','Daniela',   'Jiménez Ortiz',    'djimenez@estudiante.edu.co',   '3189990011'),
    ('CC','1001234510','Mateo',     'Rodríguez Silva',  'mrodriguez@estudiante.edu.co', '3190001122'),
    ('CC','1001234511','Valeria',   'Fernández Cruz',   'vfernandez@estudiante.edu.co', '3201112233'),
    ('CC','1001234512','Santiago',  'López Bermúdez',   'slopez@estudiante.edu.co',     '3212223344'),
    ('CC','1001234513','Mariana',   'García Pardo',     'mgarcia@estudiante.edu.co',    '3223334455'),
    ('CC','1001234514','Nicolás',   'Reyes Campos',     'nreyes@estudiante.edu.co',     '3234445566'),
    ('CC','1001234515','Gabriela',  'Muñoz Serrano',    'gmunoz@estudiante.edu.co',     '3245556677'),
    ('CE','1001234516','Carlos',    'Mendoza Arbeláez', 'cmendoza@estudiante.edu.co',   '3256667788'),
    ('CC','1001234517','Laura',     'Quintero Vásquez', 'lquintero@estudiante.edu.co',  '3267778899'),
    ('CC','1001234518','David',     'Aguilar Montoya',  'daguilar@estudiante.edu.co',   '3278889900'),
    ('CC','1001234519','Sara',      'Peña Castellanos', 'spena@estudiante.edu.co',      '3289990011'),
    ('CC','1001234520','Felipe',    'Cardona Ríos',     'fcardona@estudiante.edu.co',   '3290001122');
