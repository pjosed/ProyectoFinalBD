-- ============================================================
-- 04_historial_cobros.sql — DATOS HISTÓRICOS DE COBROS
-- Sistema de Matrículas — UniCaribe
-- Periodos: 2025-1 y 2025-2
-- ============================================================


USE matriculas_uni;

-- ============================================================
-- ESTUDIANTES HISTÓRICOS PROPIOS (1003001001-1003001016)
-- ============================================================
INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC','1003001001','Alejandro',  'Pedraza Niño',       'apedraza@hist.unicaribe.edu.co',    '3201110001'),
    ('CC','1003001002','Natalia',    'Cifuentes Prada',    'ncifuentes@hist.unicaribe.edu.co',  '3201110002'),
    ('CC','1003001003','Ricardo',    'Palomino Useche',    'rpalomino@hist.unicaribe.edu.co',   '3201110003'),
    ('CC','1003001004','Paola',      'Acosta Barrera',     'pacosta@hist.unicaribe.edu.co',     '3201110004'),
    ('CC','1003001005','Cristian',   'Bohórquez Leal',     'cbohorquez@hist.unicaribe.edu.co',  '3201110005'),
    ('CC','1003001006','Luisa',      'Serrano Palacios',   'lserrano@hist.unicaribe.edu.co',    '3201110006'),
    ('CC','1003001007','Esteban',    'Amaya Contreras',    'eamaya@hist.unicaribe.edu.co',      '3201110007'),
    ('CC','1003001008','Juliana',    'Becerra Pinzón',     'jbecerra@hist.unicaribe.edu.co',    '3201110008'),
    ('CC','1003001009','Héctor',     'Fuentes Alvarado',   'hfuentes@hist.unicaribe.edu.co',    '3201110009'),
    ('CC','1003001010','Marcela',    'Iglesias Buitrago',  'miglesias@hist.unicaribe.edu.co',   '3201110010'),
    ('CC','1003001011','Omar',       'Castellanos Vega',   'ocastellanos@hist.unicaribe.edu.co','3201110011'),
    ('CC','1003001012','Patricia',   'Naranjo Correa',     'pnaranjo@hist.unicaribe.edu.co',    '3201110012'),
    ('CC','1003001013','Germán',     'Suárez Triana',      'gsuarez@hist.unicaribe.edu.co',     '3201110013'),
    ('CC','1003001014','Claudia',    'Rangel Mendoza',     'crangel@hist.unicaribe.edu.co',     '3201110014'),
    ('CC','1003001015','Iván',       'Portilla Sandoval',  'iportilla@hist.unicaribe.edu.co',   '3201110015'),
    ('CC','1003001016','Andrea',     'Solano Villamizar',  'asolano@hist.unicaribe.edu.co',     '3201110016');


-- ============================================================
-- PERIODO 2025-1 — Estudiantes históricos propios (8)
-- ============================================================
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-01-25 08:00:00'
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-1'
WHERE e.num_doc IN (
    '1003001001','1003001002','1003001003','1003001004',
    '1003001005','1003001006','1003001007','1003001008'
);

INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global', rc.valor_global, '2025-01-25 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico  pa   ON pa.nombre = '2025-1'
JOIN usuario            u    ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1003001001' num_doc, 'ADM-EMP' cod_prog, 1 semestre UNION ALL
    SELECT '1003001002', 'CON-PUB', 1 UNION ALL
    SELECT '1003001003', 'DER',     1 UNION ALL
    SELECT '1003001004', 'PSI',     2 UNION ALL
    SELECT '1003001005', 'ADM-EMP', 3 UNION ALL
    SELECT '1003001006', 'CON-PUB', 2 UNION ALL
    SELECT '1003001007', 'DER',     2 UNION ALL
    SELECT '1003001008', 'PSI',     1
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT cc.id_cuenta, cd.id_codigo, CONCAT('Matrícula semestre ', vm.semestre, ' — 2025-1'),
    vm.val_tot, '2025-01-25 10:00:00', u.id_usuario
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN codigo_detalle cd ON cd.codigo = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN ('1003001001','1003001002','1003001003','1003001004',
                    '1003001005','1003001006','1003001007','1003001008');

INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT cc.id_cuenta, u.id_usuario, 'PSE', CONCAT('PSE-2025-1-', e.num_doc), vm.val_tot, '2025-02-05 14:00:00'
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN ('1003001001','1003001002','1003001003','1003001004',
                    '1003001005','1003001006','1003001007','1003001008');

INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT p.id_cuenta, cd.id_codigo, 'Pago recibido — PSE', p.monto, p.fecha, p.id_usuario
FROM pago p
JOIN codigo_detalle cd ON cd.codigo = 'MPAG' AND cd.grupo = 'PAGO'
JOIN cuenta_corriente cc ON cc.id_cuenta = p.id_cuenta
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN ('1003001001','1003001002','1003001003','1003001004',
                    '1003001005','1003001006','1003001007','1003001008');


-- ============================================================
-- PERIODO 2025-2 — Estudiantes históricos propios (8)
-- ============================================================
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-07-20 08:00:00'
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
WHERE e.num_doc IN (
    '1003001009','1003001010','1003001011','1003001012',
    '1003001013','1003001014','1003001015','1003001016'
);

INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global', rc.valor_global, '2025-07-20 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1003001009' num_doc, 'ADM-EMP' cod_prog, 2 semestre UNION ALL
    SELECT '1003001010', 'CON-PUB', 1 UNION ALL
    SELECT '1003001011', 'DER',     3 UNION ALL
    SELECT '1003001012', 'PSI',     2 UNION ALL
    SELECT '1003001013', 'ADM-EMP', 4 UNION ALL
    SELECT '1003001014', 'CON-PUB', 3
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Creditos', rc.valor_credito * t.creditos, '2025-07-20 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1003001015' num_doc, 'ING-SIS' cod_prog, 2 semestre, 15 creditos UNION ALL
    SELECT '1003001016', 'ING-SIS', 3, 16
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT cc.id_cuenta, cd.id_codigo, CONCAT('Matrícula semestre ', vm.semestre, ' — 2025-2'),
    vm.val_tot, '2025-07-20 10:00:00', u.id_usuario
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN codigo_detalle cd ON cd.codigo = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN ('1003001009','1003001010','1003001011','1003001012',
                    '1003001013','1003001014','1003001015','1003001016');

INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT cc.id_cuenta, u.id_usuario, 'CAJA', CONCAT('CAJA-2025-2-', e.num_doc), vm.val_tot, '2025-08-01 11:00:00'
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN ('1003001009','1003001010','1003001011','1003001012','1003001013');

INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT p.id_cuenta, cd.id_codigo, 'Pago recibido — Caja', p.monto, p.fecha, p.id_usuario
FROM pago p
JOIN codigo_detalle cd ON cd.codigo = 'MPAG' AND cd.grupo = 'PAGO'
JOIN cuenta_corriente cc ON cc.id_cuenta = p.id_cuenta
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN ('1003001009','1003001010','1003001011','1003001012','1003001013');

INSERT INTO volante_asignatura (id_volante, id_asig)
SELECT vm.id_volante, pe.id_asignatura
FROM volante_matricula vm
JOIN estudiante e ON e.id_estudiante = vm.id_estu
JOIN plan_estudio pe ON pe.id_programa = vm.id_prog AND pe.semestre = vm.semestre
WHERE e.num_doc IN ('1003001015','1003001016') AND vm.modalidad = 'Creditos';


-- ============================================================
-- PERIODO 2025-1 — Estudiantes adicionales del semilla (110)
-- Programas GLOBAL: ADM-EMP, CON-PUB, DER, PSI, MED, ENF, ARQ,
--                   COM-SOC, EDU-INF, NEG-INT, TEC-ADM, TEC-CON,
--                   ESP-GER, ESP-FIN, ESP-DER, ESP-TIC, MAS-ADM,
--                   MAS-ING, MAS-DER
-- Programas CREDITOS: ING-SIS, ING-IND, TEC-SIS
-- ============================================================

-- Cuentas corrientes 2025-1 para los 220 estudiantes adicionales
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-01-26 08:00:00'
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-1'
WHERE e.num_doc LIKE '1002%';

-- Volantes 2025-1 — modalidad GLOBAL (solo programas GLOBAL)
-- ING-SIS, ING-IND y TEC-SIS son POR_CREDITOS — van en sección aparte
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global', rc.valor_global, '2025-01-26 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-1'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1002002001' num_doc,'ADM-EMP' cod_prog,1 semestre UNION ALL SELECT '1002002002','ADM-EMP',2 UNION ALL
    SELECT '1002002003','ADM-EMP',3 UNION ALL SELECT '1002002004','ADM-EMP',4 UNION ALL
    SELECT '1002002005','ADM-EMP',5 UNION ALL SELECT '1002002006','ADM-EMP',6 UNION ALL
    SELECT '1002002007','ADM-EMP',7 UNION ALL SELECT '1002002008','ADM-EMP',8 UNION ALL
    SELECT '1002002009','ADM-EMP',1 UNION ALL SELECT '1002002010','ADM-EMP',2 UNION ALL
    SELECT '1002003001','CON-PUB',1 UNION ALL SELECT '1002003002','CON-PUB',2 UNION ALL
    SELECT '1002003003','CON-PUB',3 UNION ALL SELECT '1002003004','CON-PUB',4 UNION ALL
    SELECT '1002003005','CON-PUB',5 UNION ALL SELECT '1002003006','CON-PUB',6 UNION ALL
    SELECT '1002003007','CON-PUB',7 UNION ALL SELECT '1002003008','CON-PUB',8 UNION ALL
    SELECT '1002003009','CON-PUB',1 UNION ALL SELECT '1002003010','CON-PUB',2 UNION ALL
    SELECT '1002004001','DER',1 UNION ALL SELECT '1002004002','DER',2 UNION ALL
    SELECT '1002004003','DER',3 UNION ALL SELECT '1002004004','DER',4 UNION ALL
    SELECT '1002004005','DER',5 UNION ALL SELECT '1002004006','DER',6 UNION ALL
    SELECT '1002004007','DER',7 UNION ALL SELECT '1002004008','DER',8 UNION ALL
    SELECT '1002004009','DER',9 UNION ALL SELECT '1002004010','DER',10 UNION ALL
    SELECT '1002005001','PSI',1 UNION ALL SELECT '1002005002','PSI',2 UNION ALL
    SELECT '1002005003','PSI',3 UNION ALL SELECT '1002005004','PSI',4 UNION ALL
    SELECT '1002005005','PSI',5 UNION ALL SELECT '1002005006','PSI',6 UNION ALL
    SELECT '1002005007','PSI',7 UNION ALL SELECT '1002005008','PSI',8 UNION ALL
    SELECT '1002005009','PSI',9 UNION ALL SELECT '1002005010','PSI',1 UNION ALL
    SELECT '1002006001','MED',1 UNION ALL SELECT '1002006002','MED',2 UNION ALL
    SELECT '1002006003','MED',3 UNION ALL SELECT '1002006004','MED',4 UNION ALL
    SELECT '1002006005','MED',5 UNION ALL SELECT '1002006006','MED',6 UNION ALL
    SELECT '1002006007','MED',7 UNION ALL SELECT '1002006008','MED',8 UNION ALL
    SELECT '1002006009','MED',9 UNION ALL SELECT '1002006010','MED',10 UNION ALL
    SELECT '1002007001','ENF',1 UNION ALL SELECT '1002007002','ENF',2 UNION ALL
    SELECT '1002007003','ENF',3 UNION ALL SELECT '1002007004','ENF',4 UNION ALL
    SELECT '1002007005','ENF',5 UNION ALL SELECT '1002007006','ENF',6 UNION ALL
    SELECT '1002007007','ENF',7 UNION ALL SELECT '1002007008','ENF',8 UNION ALL
    SELECT '1002007009','ENF',1 UNION ALL SELECT '1002007010','ENF',2 UNION ALL
    SELECT '1002008001','ARQ',1 UNION ALL SELECT '1002008002','ARQ',2 UNION ALL
    SELECT '1002008003','ARQ',3 UNION ALL SELECT '1002008004','ARQ',4 UNION ALL
    SELECT '1002008005','ARQ',5 UNION ALL SELECT '1002008006','ARQ',6 UNION ALL
    SELECT '1002008007','ARQ',7 UNION ALL SELECT '1002008008','ARQ',8 UNION ALL
    SELECT '1002008009','ARQ',9 UNION ALL SELECT '1002008010','ARQ',10 UNION ALL
    SELECT '1002009001','COM-SOC',1 UNION ALL SELECT '1002009002','COM-SOC',2 UNION ALL
    SELECT '1002009003','COM-SOC',3 UNION ALL SELECT '1002009004','COM-SOC',4 UNION ALL
    SELECT '1002009005','COM-SOC',5 UNION ALL SELECT '1002009006','COM-SOC',6 UNION ALL
    SELECT '1002009007','COM-SOC',7 UNION ALL SELECT '1002009008','COM-SOC',8 UNION ALL
    SELECT '1002009009','COM-SOC',1 UNION ALL SELECT '1002009010','COM-SOC',2 UNION ALL
    SELECT '1002010001','EDU-INF',1 UNION ALL SELECT '1002010002','EDU-INF',2 UNION ALL
    SELECT '1002010003','EDU-INF',3 UNION ALL SELECT '1002010004','EDU-INF',4 UNION ALL
    SELECT '1002010005','EDU-INF',5 UNION ALL SELECT '1002010006','EDU-INF',6 UNION ALL
    SELECT '1002010007','EDU-INF',7 UNION ALL SELECT '1002010008','EDU-INF',8 UNION ALL
    SELECT '1002010009','EDU-INF',1 UNION ALL SELECT '1002010010','EDU-INF',2 UNION ALL
    SELECT '1002011001','NEG-INT',1 UNION ALL SELECT '1002011002','NEG-INT',2 UNION ALL
    SELECT '1002011003','NEG-INT',3 UNION ALL SELECT '1002011004','NEG-INT',4 UNION ALL
    SELECT '1002011005','NEG-INT',5 UNION ALL SELECT '1002011006','NEG-INT',6 UNION ALL
    SELECT '1002011007','NEG-INT',7 UNION ALL SELECT '1002011008','NEG-INT',8 UNION ALL
    SELECT '1002011009','NEG-INT',1 UNION ALL SELECT '1002011010','NEG-INT',2 UNION ALL
    SELECT '1002013001' num_doc,'TEC-ADM' cod_prog,1 semestre UNION ALL SELECT '1002013002','TEC-ADM',2 UNION ALL
    SELECT '1002013003','TEC-ADM',3 UNION ALL SELECT '1002013004','TEC-ADM',4 UNION ALL
    SELECT '1002013005','TEC-ADM',5 UNION ALL SELECT '1002013006','TEC-ADM',6 UNION ALL
    SELECT '1002013007','TEC-ADM',1 UNION ALL SELECT '1002013008','TEC-ADM',2 UNION ALL
    SELECT '1002013009','TEC-ADM',3 UNION ALL SELECT '1002013010','TEC-ADM',4 UNION ALL
    SELECT '1002014001','TEC-CON',1 UNION ALL SELECT '1002014002','TEC-CON',2 UNION ALL
    SELECT '1002014003','TEC-CON',3 UNION ALL SELECT '1002014004','TEC-CON',4 UNION ALL
    SELECT '1002014005','TEC-CON',5 UNION ALL SELECT '1002014006','TEC-CON',6 UNION ALL
    SELECT '1002014007','TEC-CON',1 UNION ALL SELECT '1002014008','TEC-CON',2 UNION ALL
    SELECT '1002014009','TEC-CON',3 UNION ALL SELECT '1002014010','TEC-CON',4 UNION ALL
    SELECT '1002015001','ESP-GER',1 UNION ALL SELECT '1002015002','ESP-GER',2 UNION ALL
    SELECT '1002015003','ESP-GER',3 UNION ALL SELECT '1002015004','ESP-GER',1 UNION ALL
    SELECT '1002015005','ESP-GER',2 UNION ALL SELECT '1002015006','ESP-GER',3 UNION ALL
    SELECT '1002015007','ESP-GER',1 UNION ALL SELECT '1002015008','ESP-GER',2 UNION ALL
    SELECT '1002015009','ESP-GER',3 UNION ALL SELECT '1002015010','ESP-GER',1 UNION ALL
    SELECT '1002016001','ESP-FIN',1 UNION ALL SELECT '1002016002','ESP-FIN',2 UNION ALL
    SELECT '1002016003','ESP-FIN',3 UNION ALL SELECT '1002016004','ESP-FIN',1 UNION ALL
    SELECT '1002016005','ESP-FIN',2 UNION ALL SELECT '1002016006','ESP-FIN',3 UNION ALL
    SELECT '1002016007','ESP-FIN',1 UNION ALL SELECT '1002016008','ESP-FIN',2 UNION ALL
    SELECT '1002016009','ESP-FIN',3 UNION ALL SELECT '1002016010','ESP-FIN',1 UNION ALL
    SELECT '1002017001','ESP-DER',1 UNION ALL SELECT '1002017002','ESP-DER',2 UNION ALL
    SELECT '1002017003','ESP-DER',3 UNION ALL SELECT '1002017004','ESP-DER',1 UNION ALL
    SELECT '1002017005','ESP-DER',2 UNION ALL SELECT '1002017006','ESP-DER',3 UNION ALL
    SELECT '1002017007','ESP-DER',1 UNION ALL SELECT '1002017008','ESP-DER',2 UNION ALL
    SELECT '1002017009','ESP-DER',3 UNION ALL SELECT '1002017010','ESP-DER',1 UNION ALL
    SELECT '1002018001','ESP-TIC',1 UNION ALL SELECT '1002018002','ESP-TIC',2 UNION ALL
    SELECT '1002018003','ESP-TIC',3 UNION ALL SELECT '1002018004','ESP-TIC',1 UNION ALL
    SELECT '1002018005','ESP-TIC',2 UNION ALL SELECT '1002018006','ESP-TIC',3 UNION ALL
    SELECT '1002018007','ESP-TIC',1 UNION ALL SELECT '1002018008','ESP-TIC',2 UNION ALL
    SELECT '1002018009','ESP-TIC',3 UNION ALL SELECT '1002018010','ESP-TIC',1 UNION ALL
    SELECT '1002019001','MAS-ADM',1 UNION ALL SELECT '1002019002','MAS-ADM',2 UNION ALL
    SELECT '1002019003','MAS-ADM',3 UNION ALL SELECT '1002019004','MAS-ADM',4 UNION ALL
    SELECT '1002019005','MAS-ADM',1 UNION ALL SELECT '1002019006','MAS-ADM',2 UNION ALL
    SELECT '1002019007','MAS-ADM',3 UNION ALL SELECT '1002019008','MAS-ADM',4 UNION ALL
    SELECT '1002019009','MAS-ADM',1 UNION ALL SELECT '1002019010','MAS-ADM',2 UNION ALL
    SELECT '1002020001','MAS-ING',1 UNION ALL SELECT '1002020002','MAS-ING',2 UNION ALL
    SELECT '1002020003','MAS-ING',3 UNION ALL SELECT '1002020004','MAS-ING',4 UNION ALL
    SELECT '1002020005','MAS-ING',1 UNION ALL SELECT '1002020006','MAS-ING',2 UNION ALL
    SELECT '1002020007','MAS-ING',3 UNION ALL SELECT '1002020008','MAS-ING',4 UNION ALL
    SELECT '1002020009','MAS-ING',1 UNION ALL SELECT '1002020010','MAS-ING',2 UNION ALL
    SELECT '1002021001','MAS-DER',1 UNION ALL SELECT '1002021002','MAS-DER',2 UNION ALL
    SELECT '1002021003','MAS-DER',3 UNION ALL SELECT '1002021004','MAS-DER',4 UNION ALL
    SELECT '1002021005','MAS-DER',1 UNION ALL SELECT '1002021006','MAS-DER',2 UNION ALL
    SELECT '1002021007','MAS-DER',3 UNION ALL SELECT '1002021008','MAS-DER',4 UNION ALL
    SELECT '1002021009','MAS-DER',1 UNION ALL SELECT '1002021010','MAS-DER',2
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

-- Volantes 2025-1 — modalidad CREDITOS (ING-SIS, ING-IND, TEC-SIS)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Creditos', rc.valor_credito * t.creditos, '2025-01-26 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-1'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1002000001' num_doc,'ING-SIS' cod_prog,1 semestre,14 creditos UNION ALL
    SELECT '1002000002','ING-SIS',2,15 UNION ALL SELECT '1002000003','ING-SIS',3,16 UNION ALL
    SELECT '1002000004','ING-SIS',4,15 UNION ALL SELECT '1002000005','ING-SIS',5,14 UNION ALL
    SELECT '1002000006','ING-SIS',6,15 UNION ALL SELECT '1002000007','ING-SIS',7,14 UNION ALL
    SELECT '1002000008','ING-SIS',8,15 UNION ALL SELECT '1002000009','ING-SIS',9,12 UNION ALL
    SELECT '1002000010','ING-SIS',1,14 UNION ALL
    SELECT '1002001001','ING-IND',1,13 UNION ALL SELECT '1002001002','ING-IND',2,14 UNION ALL
    SELECT '1002001003','ING-IND',3,15 UNION ALL SELECT '1002001004','ING-IND',4,14 UNION ALL
    SELECT '1002001005','ING-IND',5,13 UNION ALL SELECT '1002001006','ING-IND',6,14 UNION ALL
    SELECT '1002001007','ING-IND',7,13 UNION ALL SELECT '1002001008','ING-IND',8,14 UNION ALL
    SELECT '1002001009','ING-IND',9,12 UNION ALL SELECT '1002001010','ING-IND',1,13 UNION ALL
    SELECT '1002012001','TEC-SIS',1,11 UNION ALL SELECT '1002012002','TEC-SIS',2,12 UNION ALL
    SELECT '1002012003','TEC-SIS',3,13 UNION ALL SELECT '1002012004','TEC-SIS',4,12 UNION ALL
    SELECT '1002012005','TEC-SIS',5,11 UNION ALL SELECT '1002012006','TEC-SIS',6,10 UNION ALL
    SELECT '1002012008','TEC-SIS',1,11 UNION ALL SELECT '1002012009','TEC-SIS',2,12 UNION ALL
    SELECT '1002012010','TEC-SIS',3,13
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

-- Cobros 2025-1 para los 220 estudiantes adicionales
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT cc.id_cuenta, cd.id_codigo,
    CONCAT('Matrícula semestre ', vm.semestre, ' — 2025-1'),
    vm.val_tot, '2025-01-26 10:00:00', u.id_usuario
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN codigo_detalle cd ON cd.codigo = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc LIKE '1002%';

-- Pagos 2025-1: los primeros 5 de cada grupo pagan, los últimos 5 quedan pendientes
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT cc.id_cuenta, u.id_usuario, 'PSE', CONCAT('PSE-2025-1-', e.num_doc), vm.val_tot, '2025-02-10 14:00:00'
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1002000001','1002000002','1002000003','1002000004','1002000005',
    '1002001001','1002001002','1002001003','1002001004','1002001005',
    '1002002001','1002002002','1002002003','1002002004','1002002005',
    '1002003001','1002003002','1002003003','1002003004','1002003005',
    '1002004001','1002004002','1002004003','1002004004','1002004005',
    '1002005001','1002005002','1002005003','1002005004','1002005005',
    '1002006001','1002006002','1002006003','1002006004','1002006005',
    '1002007001','1002007002','1002007003','1002007004','1002007005',
    '1002008001','1002008002','1002008003','1002008004','1002008005',
    '1002009001','1002009002','1002009003','1002009004','1002009005',
    '1002010001','1002010002','1002010003','1002010004','1002010005',
    '1002011001','1002011002','1002011003','1002011004','1002011005',
    '1002012001','1002012002','1002012003','1002012004','1002012005',
    '1002013001','1002013002','1002013003','1002013004','1002013005',
    '1002014001','1002014002','1002014003','1002014004','1002014005',
    '1002015001','1002015002','1002015003','1002015004','1002015005',
    '1002016001','1002016002','1002016003','1002016004','1002016005',
    '1002017001','1002017002','1002017003','1002017004','1002017005',
    '1002018001','1002018002','1002018003','1002018004','1002018005',
    '1002019001','1002019002','1002019003','1002019004','1002019005',
    '1002020001','1002020002','1002020003','1002020004','1002020005',
    '1002021001','1002021002','1002021003','1002021004','1002021005'
);

INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT p.id_cuenta, cd.id_codigo, 'Pago recibido — PSE', p.monto, p.fecha, p.id_usuario
FROM pago p
JOIN codigo_detalle cd ON cd.codigo = 'MPAG' AND cd.grupo = 'PAGO'
JOIN cuenta_corriente cc ON cc.id_cuenta = p.id_cuenta
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-1'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc LIKE '1002%';


-- ============================================================
-- PERIODO 2025-2 — Estudiantes adicionales (110 estudiantes)
-- Solo la mitad de los programas para variar
-- ============================================================
INSERT INTO cuenta_corriente (id_estudiante, id_periodo, fecha_cre)
SELECT e.id_estudiante, pa.id_periodo, '2025-07-21 08:00:00'
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
WHERE e.num_doc IN (
    '1002000001','1002000002','1002000003','1002000004','1002000005',
    '1002001001','1002001002','1002001003','1002001004','1002001005',
    '1002002001','1002002002','1002002003','1002002004','1002002005',
    '1002003001','1002003002','1002003003','1002003004','1002003005',
    '1002004001','1002004002','1002004003','1002004004','1002004005',
    '1002005001','1002005002','1002005003','1002005004','1002005005',
    '1002006001','1002006002','1002006003','1002006004','1002006005',
    '1002007001','1002007002','1002007003','1002007004','1002007005',
    '1002008001','1002008002','1002008003','1002008004','1002008005',
    '1002009001','1002009002','1002009003','1002009004','1002009005',
    '1002012001','1002012002','1002012003','1002012004','1002012005',
    '1002015001','1002015002','1002015003','1002016001','1002016002',
    '1002017001','1002017002','1002017003','1002019001','1002019002',
    '1002020001','1002020002','1002021001','1002021002','1002021003'
);

-- Volantes 2025-2 — modalidad GLOBAL (solo programas GLOBAL)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Global', rc.valor_global, '2025-07-21 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1002002001' num_doc,'ADM-EMP' cod_prog,2 semestre UNION ALL SELECT '1002002002','ADM-EMP',3 UNION ALL
    SELECT '1002002003','ADM-EMP',4 UNION ALL SELECT '1002002004','ADM-EMP',5 UNION ALL SELECT '1002002005','ADM-EMP',6 UNION ALL
    SELECT '1002003001','CON-PUB',2 UNION ALL SELECT '1002003002','CON-PUB',3 UNION ALL
    SELECT '1002003003','CON-PUB',4 UNION ALL SELECT '1002003004','CON-PUB',5 UNION ALL SELECT '1002003005','CON-PUB',6 UNION ALL
    SELECT '1002004001','DER',2 UNION ALL SELECT '1002004002','DER',3 UNION ALL
    SELECT '1002004003','DER',4 UNION ALL SELECT '1002004004','DER',5 UNION ALL SELECT '1002004005','DER',6 UNION ALL
    SELECT '1002005001','PSI',2 UNION ALL SELECT '1002005002','PSI',3 UNION ALL
    SELECT '1002005003','PSI',4 UNION ALL SELECT '1002005004','PSI',5 UNION ALL SELECT '1002005005','PSI',6 UNION ALL
    SELECT '1002006001','MED',2 UNION ALL SELECT '1002006002','MED',3 UNION ALL
    SELECT '1002006003','MED',4 UNION ALL SELECT '1002006004','MED',5 UNION ALL SELECT '1002006005','MED',6 UNION ALL
    SELECT '1002007001','ENF',2 UNION ALL SELECT '1002007002','ENF',3 UNION ALL
    SELECT '1002007003','ENF',4 UNION ALL SELECT '1002007004','ENF',5 UNION ALL SELECT '1002007005','ENF',6 UNION ALL
    SELECT '1002008001','ARQ',2 UNION ALL SELECT '1002008002','ARQ',3 UNION ALL
    SELECT '1002008003','ARQ',4 UNION ALL SELECT '1002008004','ARQ',5 UNION ALL SELECT '1002008005','ARQ',6 UNION ALL
    SELECT '1002009001','COM-SOC',2 UNION ALL SELECT '1002009002','COM-SOC',3 UNION ALL
    SELECT '1002009003','COM-SOC',4 UNION ALL SELECT '1002009004','COM-SOC',5 UNION ALL SELECT '1002009005','COM-SOC',6 UNION ALL
    SELECT '1002015001','ESP-GER',1 UNION ALL SELECT '1002015002','ESP-GER',2 UNION ALL SELECT '1002015003','ESP-GER',3 UNION ALL
    SELECT '1002016001','ESP-FIN',1 UNION ALL SELECT '1002016002','ESP-FIN',2 UNION ALL
    SELECT '1002017001','ESP-DER',1 UNION ALL SELECT '1002017002','ESP-DER',2 UNION ALL SELECT '1002017003','ESP-DER',3 UNION ALL
    SELECT '1002019001','MAS-ADM',2 UNION ALL SELECT '1002019002','MAS-ADM',3 UNION ALL
    SELECT '1002020001','MAS-ING',2 UNION ALL SELECT '1002020002','MAS-ING',3 UNION ALL
    SELECT '1002021001','MAS-DER',2 UNION ALL SELECT '1002021002','MAS-DER',3 UNION ALL SELECT '1002021003','MAS-DER',4
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

-- Volantes 2025-2 — modalidad CREDITOS (ING-SIS, ING-IND, TEC-SIS)
INSERT INTO volante_matricula (id_estu, id_per, id_prog, id_usuario, semestre, modalidad, val_tot, fecha_gen, id_cuenta)
SELECT e.id_estudiante, pa.id_periodo, prog.id_programa,
    u.id_usuario, t.semestre, 'Creditos', rc.valor_credito * t.creditos, '2025-07-21 09:00:00', cc.id_cuenta
FROM estudiante e
JOIN periodo_academico pa ON pa.nombre = '2025-2'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN (
    SELECT '1002000001' num_doc,'ING-SIS' cod_prog,2 semestre,15 creditos UNION ALL
    SELECT '1002000002','ING-SIS',3,16 UNION ALL SELECT '1002000003','ING-SIS',4,15 UNION ALL
    SELECT '1002000004','ING-SIS',5,14 UNION ALL SELECT '1002000005','ING-SIS',6,15 UNION ALL
    SELECT '1002001001','ING-IND',2,14 UNION ALL SELECT '1002001002','ING-IND',3,15 UNION ALL
    SELECT '1002001003','ING-IND',4,14 UNION ALL SELECT '1002001004','ING-IND',5,13 UNION ALL
    SELECT '1002001005','ING-IND',6,14 UNION ALL
    SELECT '1002012001','TEC-SIS',2,12 UNION ALL SELECT '1002012002','TEC-SIS',3,13 UNION ALL
    SELECT '1002012003','TEC-SIS',4,12 UNION ALL SELECT '1002012004','TEC-SIS',5,11 UNION ALL
    SELECT '1002012005','TEC-SIS',6,10
) t ON e.num_doc = t.num_doc
JOIN programa_academico prog ON prog.codigo = t.cod_prog
JOIN regla_cobro rc ON rc.id_periodo = pa.id_periodo AND rc.id_programa = prog.id_programa
JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante AND cc.id_periodo = pa.id_periodo;

-- Cobros 2025-2 para los estudiantes adicionales
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT cc.id_cuenta, cd.id_codigo,
    CONCAT('Matrícula semestre ', vm.semestre, ' — 2025-2'),
    vm.val_tot, '2025-07-21 10:00:00', u.id_usuario
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN codigo_detalle cd ON cd.codigo = 'PMAT' AND cd.grupo = 'COBRO'
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1002000001','1002000002','1002000003','1002000004','1002000005',
    '1002001001','1002001002','1002001003','1002001004','1002001005',
    '1002002001','1002002002','1002002003','1002002004','1002002005',
    '1002003001','1002003002','1002003003','1002003004','1002003005',
    '1002004001','1002004002','1002004003','1002004004','1002004005',
    '1002005001','1002005002','1002005003','1002005004','1002005005',
    '1002006001','1002006002','1002006003','1002006004','1002006005',
    '1002007001','1002007002','1002007003','1002007004','1002007005',
    '1002008001','1002008002','1002008003','1002008004','1002008005',
    '1002009001','1002009002','1002009003','1002009004','1002009005',
    '1002012001','1002012002','1002012003','1002012004','1002012005',
    '1002015001','1002015002','1002015003','1002016001','1002016002',
    '1002017001','1002017002','1002017003','1002019001','1002019002',
    '1002020001','1002020002','1002021001','1002021002','1002021003'
);

-- Pagos 2025-2: los primeros 3 de cada grupo pagan, el resto queda pendiente
INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT cc.id_cuenta, u.id_usuario, 'CAJA', CONCAT('CAJA-2025-2-', e.num_doc), vm.val_tot, '2025-08-05 11:00:00'
FROM cuenta_corriente cc
JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
JOIN usuario u ON u.id_usuario = (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1)
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1002000001','1002000002','1002000003',
    '1002001001','1002001002','1002001003',
    '1002002001','1002002002','1002002003',
    '1002003001','1002003002','1002003003',
    '1002004001','1002004002','1002004003',
    '1002005001','1002005002','1002005003',
    '1002006001','1002006002','1002006003',
    '1002007001','1002007002','1002007003',
    '1002008001','1002008002','1002008003',
    '1002009001','1002009002','1002009003',
    '1002012001','1002012002','1002012003',
    '1002015001','1002016001','1002017001',
    '1002019001','1002020001','1002021001'
);

INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT p.id_cuenta, cd.id_codigo, 'Pago recibido — Caja', p.monto, p.fecha, p.id_usuario
FROM pago p
JOIN codigo_detalle cd ON cd.codigo = 'MPAG' AND cd.grupo = 'PAGO'
JOIN cuenta_corriente cc ON cc.id_cuenta = p.id_cuenta
JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo AND pa.nombre = '2025-2'
JOIN estudiante e ON e.id_estudiante = cc.id_estudiante
WHERE e.num_doc IN (
    '1002000001','1002000002','1002000003',
    '1002001001','1002001002','1002001003',
    '1002002001','1002002002','1002002003',
    '1002003001','1002003002','1002003003',
    '1002004001','1002004002','1002004003',
    '1002005001','1002005002','1002005003',
    '1002006001','1002006002','1002006003',
    '1002007001','1002007002','1002007003',
    '1002008001','1002008002','1002008003',
    '1002009001','1002009002','1002009003',
    '1002012001','1002012002','1002012003',
    '1002015001','1002016001','1002017001',
    '1002019001','1002020001','1002021001'
);

-- ============================================================
-- ASIGNATURAS DE VOLANTES POR CRÉDITOS
-- (ING-SIS y TEC-SIS son POR_CREDITOS — insertar asignaturas)
-- ============================================================
INSERT INTO volante_asignatura (id_volante, id_asig)
SELECT vm.id_volante, pe.id_asignatura
FROM volante_matricula vm
JOIN estudiante e ON e.id_estudiante = vm.id_estu
JOIN plan_estudio pe ON pe.id_programa = vm.id_prog AND pe.semestre = vm.semestre
WHERE vm.modalidad = 'Creditos'
  AND e.num_doc LIKE '1002%';


-- ============================================================
-- VERIFICACIÓN FINAL
-- Se usan subconsultas en lugar de LEFT JOIN con pago para evitar
-- multiplicar filas cuando una cuenta tiene múltiples pagos.
-- ============================================================
SELECT
    pa.nombre                                           AS periodo,
    prog.nombre                                         AS programa,
    COUNT(vm.id_volante)                                AS volantes,
    SUM(vm.val_tot)                                     AS ingreso_esperado,
    SUM(CASE
        WHEN EXISTS (
            SELECT 1 FROM pago p WHERE p.id_cuenta = vm.id_cuenta
        ) THEN vm.val_tot ELSE 0
    END)                                                AS ingreso_pagado,
    COUNT(CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM pago p WHERE p.id_cuenta = vm.id_cuenta
        ) THEN 1
    END)                                                AS pendientes
FROM volante_matricula vm
JOIN periodo_academico  pa   ON pa.id_periodo   = vm.id_per
JOIN programa_academico prog ON prog.id_programa = vm.id_prog
GROUP BY pa.nombre, prog.nombre
ORDER BY pa.nombre DESC, prog.nombre;


-- ============================================================
-- CRÉDITOS FINANCIEROS (ICETEX U OTRA ENTIDAD)
-- Código CRED — 5 estudiantes con crédito financiero
-- Periodos: 2025-1 y 2025-2
-- ============================================================
-- Estudiantes usados (ya tienen cuenta corriente):
--   1003001001 — Pedraza Niño     → ADM-EMP 2025-1  cobro $3.500.000
--   1003001002 — Cifuentes Prada  → CON-PUB 2025-1  cobro $3.400.000
--   1003001003 — Palomino Useche  → DER     2025-1  cobro $4.200.000
--   1003001009 — Castellanos Vega → ADM-EMP 2025-2  cobro $3.600.000
--   1003001010 — Naranjo Correa   → CON-PUB 2025-2  cobro $3.500.000
-- El crédito cubre el 70% del valor total de matrícula.
-- El resto ($) queda pendiente como saldo.
-- ============================================================

INSERT INTO pago (id_cuenta, id_usuario, medio, ref, monto, fecha)
SELECT
    cc.id_cuenta,
    (SELECT MIN(id_usuario) FROM usuario WHERE activo = 1),
    'CREDITO',
    CONCAT('ICETEX-', pa.nombre, '-', e.num_doc),
    ROUND(vm.val_tot * 0.70, 0),
    CASE pa.nombre
        WHEN '2025-1' THEN '2025-02-15 09:00:00'
        ELSE               '2025-08-10 09:00:00'
    END
FROM estudiante e
JOIN cuenta_corriente   cc  ON cc.id_estudiante = e.id_estudiante
JOIN periodo_academico  pa  ON pa.id_periodo    = cc.id_periodo
JOIN volante_matricula  vm  ON vm.id_cuenta     = cc.id_cuenta
WHERE e.num_doc IN (
    '1003001001','1003001002','1003001003',
    '1003001009','1003001010'
);

-- Movimiento CRED en cuenta corriente
INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
SELECT
    p.id_cuenta,
    cd.id_codigo,
    CONCAT('Crédito ICETEX — ', pa.nombre),
    p.monto,
    p.fecha,
    p.id_usuario
FROM pago p
JOIN cuenta_corriente  cc  ON cc.id_cuenta  = p.id_cuenta
JOIN periodo_academico pa  ON pa.id_periodo = cc.id_periodo
JOIN codigo_detalle    cd  ON cd.codigo = 'CRED' AND cd.grupo = 'PAGO'
JOIN estudiante        e   ON e.id_estudiante = cc.id_estudiante
WHERE p.medio = 'CREDITO'
  AND e.num_doc IN (
      '1003001001','1003001002','1003001003',
      '1003001009','1003001010'
  );
