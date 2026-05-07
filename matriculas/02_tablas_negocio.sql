-- ============================================================
-- 02_tablas_negocio.sql — MÓDULO DE PROGRAMAS, PLANES Y COBROS
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Responsable: Danilo Vergel
-- Ejecutar DESPUÉS de 01_tablas_auth.sql
-- ============================================================

USE matriculas_uni;

-- ────────────────────────────────────────────────────────────
-- TABLA: programa
-- Programas académicos ofertados por la institución
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS programa (
    id_programa         INT             NOT NULL AUTO_INCREMENT,
    codigo              VARCHAR(20)     NOT NULL UNIQUE,
    nombre              VARCHAR(150)    NOT NULL,
    modalidad           ENUM('PRESENCIAL','VIRTUAL','MIXTA') NOT NULL,
    nivel               ENUM('TECNICO','TECNOLOGO','PREGRADO','POSGRADO') NOT NULL,
    total_semestres     INT             NOT NULL,
    total_creditos      INT             NOT NULL,
    activo              TINYINT(1)      NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_programa PRIMARY KEY (id_programa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: asignatura
-- Catálogo de materias disponibles en la institución
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS asignatura (
    id_asignatura       INT             NOT NULL AUTO_INCREMENT,
    codigo              VARCHAR(20)     NOT NULL UNIQUE,
    nombre              VARCHAR(150)    NOT NULL,
    creditos            INT             NOT NULL,
    activo              TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: plan_estudio
-- Relaciona cada asignatura con el programa y semestre
-- en que se dicta. Una asignatura solo aparece una vez
-- por programa.
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS plan_estudio (
    id_plan             INT             NOT NULL AUTO_INCREMENT,
    id_programa         INT             NOT NULL,
    id_asignatura       INT             NOT NULL,
    semestre            INT             NOT NULL,
    CONSTRAINT pk_plan          PRIMARY KEY (id_plan),
    CONSTRAINT fk_plan_prog     FOREIGN KEY (id_programa)   REFERENCES programa(id_programa),
    CONSTRAINT fk_plan_asig     FOREIGN KEY (id_asignatura) REFERENCES asignatura(id_asignatura),
    -- Una asignatura no puede repetirse dentro del mismo programa
    CONSTRAINT uq_plan_prog_asig UNIQUE (id_programa, id_asignatura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: periodo_academico
-- Semestres o periodos en los que se cobra matrícula
-- Solo debe haber un periodo con activo = 1 a la vez
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS periodo_academico (
    id_periodo          INT             NOT NULL AUTO_INCREMENT,
    codigo              VARCHAR(20)     NOT NULL UNIQUE,
    nombre              VARCHAR(100)    NOT NULL,
    fecha_inicio        DATE            NOT NULL,
    fecha_fin           DATE            NOT NULL,
    activo              TINYINT(1)      NOT NULL DEFAULT 0,
    CONSTRAINT pk_periodo PRIMARY KEY (id_periodo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: regla_cobro
-- Define cuánto se cobra por (periodo × programa).
-- modalidad_cobro = GLOBAL  → se usa valor_global (tarifa fija)
-- modalidad_cobro = POR_CREDITOS → se usa valor_por_credito
-- Solo puede existir UNA regla activa por periodo+programa.
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS regla_cobro (
    id_regla            INT             NOT NULL AUTO_INCREMENT,
    id_periodo          INT             NOT NULL,
    id_programa         INT             NOT NULL,
    modalidad_cobro     ENUM('GLOBAL','POR_CREDITOS') NOT NULL,
    valor_global        DECIMAL(12,2)   DEFAULT NULL,
    valor_por_credito   DECIMAL(12,2)   DEFAULT NULL,
    activo              TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_regla         PRIMARY KEY (id_regla),
    CONSTRAINT fk_regla_periodo FOREIGN KEY (id_periodo)  REFERENCES periodo_academico(id_periodo),
    CONSTRAINT fk_regla_prog    FOREIGN KEY (id_programa) REFERENCES programa(id_programa),
    -- Una sola regla por combinación periodo + programa
    CONSTRAINT uq_regla_periodo_prog UNIQUE (id_periodo, id_programa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: codigo_detalle
-- Catálogo de conceptos de cobro (grupo COBRO) y de abono
-- (grupo PAGO). Los descuentos/becas van en grupo PAGO
-- con código que empiece por DESC (requerimiento del profesor).
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS codigo_detalle (
    id_codigo           INT             NOT NULL AUTO_INCREMENT,
    grupo               ENUM('COBRO','PAGO')    NOT NULL,
    codigo              VARCHAR(20)     NOT NULL UNIQUE,
    nombre              VARCHAR(150)    NOT NULL,
    descripcion         VARCHAR(255),
    activo              TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_codigo PRIMARY KEY (id_codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
