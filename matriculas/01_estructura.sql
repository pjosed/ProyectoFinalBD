-- ============================================================
-- 01_estructura.sql — ESTRUCTURA COMPLETA DE LA BASE DE DATOS

-- ── Crea/limpia la base de datos ────────────────────────────
DROP DATABASE IF EXISTS matriculas_uni;
CREATE DATABASE matriculas_uni
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE matriculas_uni;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- MÓDULO 1: AUTENTICACIÓN Y ROLES
-- Tablas: rol, persona, usuario

CREATE TABLE rol (
    id_rol      INT         NOT NULL AUTO_INCREMENT,
    nombre      ENUM('ADMINISTRADOR','SUPERVISOR','ASISTENTE') NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    CONSTRAINT pk_rol PRIMARY KEY (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE persona (
    id_persona      INT          NOT NULL AUTO_INCREMENT,
    tipo_doc        VARCHAR(20)  NOT NULL DEFAULT 'CC',
    num_doc         VARCHAR(30)  NOT NULL UNIQUE,
    nombres         VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE usuario (
    id_usuario  INT          NOT NULL AUTO_INCREMENT,
    id_persona  INT          NOT NULL,
    id_rol      INT          NOT NULL,
    username    VARCHAR(60)  NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    fech_crea   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo      TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_usuario     PRIMARY KEY (id_usuario),
    CONSTRAINT fk_usr_persona FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    CONSTRAINT fk_usr_rol     FOREIGN KEY (id_rol)     REFERENCES rol(id_rol),
    CONSTRAINT uq_usr_persona UNIQUE (id_persona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- MÓDULO 2: OFERTA ACADÉMICA
-- Tablas: programa_academico, asignatura, plan_estudio

-- Nombre según E-R: programa_academico
-- Columna semestres según E-R: num_sem
CREATE TABLE programa_academico (
    id_programa INT          NOT NULL AUTO_INCREMENT,
    codigo      VARCHAR(20)  NOT NULL UNIQUE,
    nombre      VARCHAR(150) NOT NULL,
    num_sem     TINYINT      NOT NULL DEFAULT 9,
    activo      TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_programa PRIMARY KEY (id_programa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE asignatura (
    id_asignatura INT          NOT NULL AUTO_INCREMENT,
    codigo        VARCHAR(20)  NOT NULL UNIQUE,
    nombre        VARCHAR(150) NOT NULL,
    activo        TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE plan_estudio (
    id_plan       INT     NOT NULL AUTO_INCREMENT,
    id_programa   INT     NOT NULL,
    id_asignatura INT     NOT NULL,
    semestre      TINYINT NOT NULL,
    creditos      TINYINT NOT NULL,
    CONSTRAINT pk_plan           PRIMARY KEY (id_plan),
    CONSTRAINT fk_plan_prog      FOREIGN KEY (id_programa)   REFERENCES programa_academico(id_programa),
    CONSTRAINT fk_plan_asig      FOREIGN KEY (id_asignatura) REFERENCES asignatura(id_asignatura),
    CONSTRAINT uq_plan_prog_asig UNIQUE (id_programa, id_asignatura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- MÓDULO 3: PERIODOS Y REGLAS DE COBRO
-- Tablas: periodo_academico, regla_cobro, codigo_detalle

CREATE TABLE periodo_academico (
    id_periodo  INT         NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(50) NOT NULL UNIQUE,
    fecha_inicio DATE        NOT NULL,
    fecha_fin    DATE        NOT NULL,
    activo       TINYINT(1)  NOT NULL DEFAULT 0,
    CONSTRAINT pk_periodo PRIMARY KEY (id_periodo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE regla_cobro (
    id_regla        INT           NOT NULL AUTO_INCREMENT,
    id_periodo      INT           NOT NULL,
    id_programa     INT           NOT NULL,
    modalidad_cobro ENUM('GLOBAL','POR_CREDITOS') NOT NULL,
    valor_global    DECIMAL(12,2) DEFAULT NULL,
    valor_credito   DECIMAL(12,2) DEFAULT NULL,
    CONSTRAINT pk_regla          PRIMARY KEY (id_regla),
    CONSTRAINT fk_regla_periodo  FOREIGN KEY (id_periodo)  REFERENCES periodo_academico(id_periodo),
    CONSTRAINT fk_regla_programa FOREIGN KEY (id_programa) REFERENCES programa_academico(id_programa),
    CONSTRAINT uq_regla_per_prog UNIQUE (id_periodo, id_programa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE codigo_detalle (
    id_codigo   INT         NOT NULL AUTO_INCREMENT,
    grupo       ENUM('COBRO','PAGO') NOT NULL,
    codigo      VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(200) NOT NULL,
    CONSTRAINT pk_codigo PRIMARY KEY (id_codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- MÓDULO 4: ESTUDIANTES Y MATRÍCULAS
-- Tablas: estudiante, volante_matricula, volante_asignatura

CREATE TABLE estudiante (
    id_estudiante INT          NOT NULL AUTO_INCREMENT,
    tipo_doc      VARCHAR(5)   NOT NULL DEFAULT 'CC',
    num_doc       VARCHAR(20)  NOT NULL UNIQUE,
    nombres       VARCHAR(100) NOT NULL,
    apellidos     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    telefono      VARCHAR(20),
    activo        BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- id_estu, id_per, id_prog, modalidad, val_tot, fecha_gen 
-- id_cuenta agregado para join con cuenta_corriente

CREATE TABLE volante_matricula (
    id_volante  INT           NOT NULL AUTO_INCREMENT,
    id_estu     INT           NOT NULL,
    id_per      INT           NOT NULL,
    id_prog     INT           NOT NULL,
    id_usuario  INT           NOT NULL,
    semestre    TINYINT       NOT NULL,
    modalidad   ENUM('Global','Creditos') NOT NULL,
    val_tot     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fecha_gen   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cuenta   INT           DEFAULT NULL,
    CONSTRAINT pk_volante      PRIMARY KEY (id_volante),
    CONSTRAINT fk_vol_estu     FOREIGN KEY (id_estu)    REFERENCES estudiante(id_estudiante),
    CONSTRAINT fk_vol_per      FOREIGN KEY (id_per)     REFERENCES periodo_academico(id_periodo),
    CONSTRAINT fk_vol_prog     FOREIGN KEY (id_prog)    REFERENCES programa_academico(id_programa),
    CONSTRAINT fk_vol_usuario  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE volante_asignatura (
    id_vol_asig   INT NOT NULL AUTO_INCREMENT,
    id_volante    INT NOT NULL,
    id_asig       INT NOT NULL,
    CONSTRAINT pk_vol_asig    PRIMARY KEY (id_vol_asig),
    CONSTRAINT fk_va_volante  FOREIGN KEY (id_volante) REFERENCES volante_matricula(id_volante) ON DELETE CASCADE,
    CONSTRAINT fk_va_asig     FOREIGN KEY (id_asig)    REFERENCES asignatura(id_asignatura),
    CONSTRAINT uq_va          UNIQUE (id_volante, id_asig)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- MÓDULO 5: CUENTA CORRIENTE Y MOVIMIENTOS
-- Tablas: cuenta_corriente, movimiento_cuenta, pago


CREATE TABLE cuenta_corriente (
    id_cuenta     INT      NOT NULL AUTO_INCREMENT,
    id_estudiante INT      NOT NULL,
    id_periodo    INT      NOT NULL,
    fecha_cre     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cuenta      PRIMARY KEY (id_cuenta),
    CONSTRAINT fk_cc_est      FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),
    CONSTRAINT fk_cc_per      FOREIGN KEY (id_periodo)    REFERENCES periodo_academico(id_periodo),
    CONSTRAINT uq_cc_est_per  UNIQUE (id_estudiante, id_periodo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Agrega FK de volante_matricula a cuenta_corriente (después de crear la tabla)
ALTER TABLE volante_matricula
    ADD CONSTRAINT fk_vol_cuenta FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta);


CREATE TABLE movimiento_cuenta (
    id_movimiento INT           NOT NULL AUTO_INCREMENT,
    id_cuenta     INT           NOT NULL,
    id_codigo     INT           NOT NULL,
    descrip       VARCHAR(255)  NOT NULL,
    monto         DECIMAL(12,2) NOT NULL,
    fecha         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario    INT           NOT NULL,
    CONSTRAINT pk_movimiento      PRIMARY KEY (id_movimiento),
    CONSTRAINT fk_mov_cuenta      FOREIGN KEY (id_cuenta)  REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_mov_codigo      FOREIGN KEY (id_codigo)  REFERENCES codigo_detalle(id_codigo),
    CONSTRAINT fk_mov_usuario     FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE pago (
    id_pago   INT           NOT NULL AUTO_INCREMENT,
    id_cuenta INT           NOT NULL,
    id_usuario INT          NOT NULL,
    medio     VARCHAR(50)   NOT NULL,
    ref       VARCHAR(100)  DEFAULT NULL,
    monto     DECIMAL(12,2) NOT NULL,
    fecha     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_pago       PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_cuenta   FOREIGN KEY (id_cuenta)  REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_pago_usuario  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- MÓDULO 6 (EXTENSIÓN): SIMULACIÓN PSE
-- Tablas: banco_pse, pago_pse

CREATE TABLE banco_pse (
    id_banco INT          NOT NULL AUTO_INCREMENT,
    codigo   VARCHAR(10)  NOT NULL UNIQUE,
    nombre   VARCHAR(100) NOT NULL,
    activo   TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT pk_banco_pse PRIMARY KEY (id_banco)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE pago_pse (
    id_pse             INT           NOT NULL AUTO_INCREMENT,
    id_cuenta          INT           NOT NULL,
    id_banco           INT           NOT NULL,
    id_pago            INT           DEFAULT NULL,
    valor              DECIMAL(12,2) NOT NULL,
    referencia         VARCHAR(50)   NOT NULL UNIQUE,
    estado             ENUM('PENDIENTE','APROBADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
    usuario_banco      VARCHAR(60)   DEFAULT NULL,
    fecha_transaccion  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_confirmacion DATETIME      DEFAULT NULL,
    CONSTRAINT pk_pago_pse   PRIMARY KEY (id_pse),
    CONSTRAINT fk_pse_cuenta FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_pse_banco  FOREIGN KEY (id_banco)  REFERENCES banco_pse(id_banco),
    CONSTRAINT fk_pse_pago   FOREIGN KEY (id_pago)   REFERENCES pago(id_pago)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- MÓDULO 7 (EXTENSIÓN): DESCUENTOS Y BECAS
-- Tablas: tipo_descuento, descuento_aplicado

CREATE TABLE tipo_descuento (
    id_tipo     INT           NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100)  NOT NULL,
    descripcion VARCHAR(255),
    porcentaje  DECIMAL(5,2)  NOT NULL,
    activo      TINYINT(1)    NOT NULL DEFAULT 1,
    CONSTRAINT pk_tipo_descuento PRIMARY KEY (id_tipo),
    CONSTRAINT chk_porcentaje    CHECK (porcentaje IN (10, 20, 25, 50, 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE descuento_aplicado (
    id_descuento     INT           NOT NULL AUTO_INCREMENT,
    id_cuenta        INT           NOT NULL,
    id_tipo          INT           NOT NULL,
    id_pago          INT           NOT NULL,
    id_usuario       INT           NOT NULL,
    porcentaje       DECIMAL(5,2)  NOT NULL,
    valor_descuento  DECIMAL(12,2) NOT NULL,
    observacion      VARCHAR(255),
    fech_pub DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_descuento    PRIMARY KEY (id_descuento),
    CONSTRAINT fk_desc_cuenta  FOREIGN KEY (id_cuenta)  REFERENCES cuenta_corriente(id_cuenta),
    CONSTRAINT fk_desc_tipo    FOREIGN KEY (id_tipo)    REFERENCES tipo_descuento(id_tipo),
    CONSTRAINT fk_desc_pago    FOREIGN KEY (id_pago)    REFERENCES pago(id_pago),
    CONSTRAINT fk_desc_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
