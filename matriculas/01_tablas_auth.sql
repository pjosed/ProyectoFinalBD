-- ============================================================
-- 01_tablas_auth.sql — MÓDULO DE AUTENTICACIÓN Y ROLES
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar en MySQL Workbench sobre la BD: matriculas_uni
-- ============================================================

USE matriculas_uni;

-- Eliminar tablas en orden inverso a las FK para recrearlas limpias
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS persona;
DROP TABLE IF EXISTS rol;


-- ────────────────────────────────────────────────────────────
-- TABLA: persona
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS persona (
    id_persona      INT             NOT NULL AUTO_INCREMENT,
    tipo_doc        VARCHAR(20)     NOT NULL DEFAULT 'CC',
    num_doc         VARCHAR(30)     NOT NULL UNIQUE,
    nombres         VARCHAR(100)    NOT NULL,
    apellidos       VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    activo          TINYINT(1)      NOT NULL DEFAULT 1,
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: rol
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rol (
    id_rol      INT         NOT NULL AUTO_INCREMENT,
    nombre      ENUM('ADMINISTRADOR','SUPERVISOR','ASISTENTE') NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    CONSTRAINT pk_rol PRIMARY KEY (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: usuario
-- La contraseña se guarda con hash Werkzeug (nunca en texto plano)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario          INT             NOT NULL AUTO_INCREMENT,
    id_persona          INT             NOT NULL,
    id_rol              INT             NOT NULL,
    username            VARCHAR(60)     NOT NULL UNIQUE,
    password_hash       VARCHAR(255)    NOT NULL,
    debe_cambiar_clave  TINYINT(1)      NOT NULL DEFAULT 1,
    activo              TINYINT(1)      NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso       DATETIME,
    CONSTRAINT pk_usuario         PRIMARY KEY (id_usuario),
    CONSTRAINT fk_usr_persona     FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    CONSTRAINT fk_usr_rol         FOREIGN KEY (id_rol)     REFERENCES rol(id_rol),
    CONSTRAINT uq_persona_usuario UNIQUE (id_persona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- DATOS SEMILLA: Roles
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO rol (nombre, descripcion) VALUES
    ('ADMINISTRADOR', 'Acceso total al sistema. Gestiona usuarios, roles y menús.'),
    ('SUPERVISOR',    'Gestiona programas, planes de estudio, reglas de cobro y estudiantes.'),
    ('ASISTENTE',     'Gestiona cobros individuales y masivos, pagos y cuenta corriente.');


-- ────────────────────────────────────────────────────────────
-- NOTA: El usuario ADMINISTRADOR se crea ejecutando:
--   python generar_admin.py
-- desde la carpeta matriculas/ en la terminal.
-- Ese script genera el hash real y muestra el INSERT listo.
-- ────────────────────────────────────────────────────────────
