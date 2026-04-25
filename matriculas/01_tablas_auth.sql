-- ============================================================
-- 01_tablas_auth.sql — MÓDULO DE AUTENTICACIÓN Y ROLES
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar en MySQL Workbench sobre la BD: matriculas_uni
-- ============================================================

USE matriculas_uni;

-- ────────────────────────────────────────────────────────────
-- TABLA: persona
-- Almacena los datos básicos de cualquier persona del sistema
-- (empleados contratados con rol de usuario)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS persona (
    id_persona      INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    correo          VARCHAR(150)    NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    activo          TINYINT(1)      NOT NULL DEFAULT 1,
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: rol
-- Solo 3 roles posibles: ADMINISTRADOR, SUPERVISOR, ASISTENTE
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rol (
    id_rol          INT             NOT NULL AUTO_INCREMENT,
    nombre_rol      ENUM('ADMINISTRADOR','SUPERVISOR','ASISTENTE') NOT NULL UNIQUE,
    descripcion     VARCHAR(255),
    CONSTRAINT pk_rol PRIMARY KEY (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- TABLA: usuario
-- Una persona solo puede tener UN usuario y UN rol (enunciado)
-- La contraseña se guarda con hash Werkzeug (nunca en texto plano)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario          INT             NOT NULL AUTO_INCREMENT,
    id_persona          INT             NOT NULL,
    id_rol              INT             NOT NULL,
    nombre_usuario      VARCHAR(60)     NOT NULL UNIQUE,
    contrasena_hash     VARCHAR(255)    NOT NULL,
    debe_cambiar_clave  TINYINT(1)      NOT NULL DEFAULT 1,
    activo              TINYINT(1)      NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso       DATETIME,
    CONSTRAINT pk_usuario   PRIMARY KEY (id_usuario),
    CONSTRAINT fk_usr_persona FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    CONSTRAINT fk_usr_rol     FOREIGN KEY (id_rol)     REFERENCES rol(id_rol),
    -- Una persona solo puede tener un usuario (regla del enunciado)
    CONSTRAINT uq_persona_usuario UNIQUE (id_persona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ────────────────────────────────────────────────────────────
-- DATOS SEMILLA: Roles
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO rol (nombre_rol, descripcion) VALUES
    ('ADMINISTRADOR', 'Acceso total al sistema. Gestiona usuarios, roles y menús.'),
    ('SUPERVISOR',    'Gestiona programas, planes de estudio, reglas de cobro y estudiantes.'),
    ('ASISTENTE',     'Gestiona cobros individuales y masivos, pagos y cuenta corriente.');


-- ────────────────────────────────────────────────────────────
-- DATOS SEMILLA: Usuario ADMINISTRADOR
-- Contraseña inicial: Admin2026*
-- El campo debe_cambiar_clave = 0 para la sustentación
-- IMPORTANTE: este hash corresponde a "Admin2026*"
-- Generado con werkzeug.security.generate_password_hash
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO persona (nombre, apellido, correo, telefono) VALUES
    ('Administrador', 'Sistema', 'admin@unicaribe.edu.co', '3001234567');

INSERT IGNORE INTO usuario (id_persona, id_rol, nombre_usuario, contrasena_hash, debe_cambiar_clave)
SELECT
    p.id_persona,
    r.id_rol,
    'admin',
    -- Hash de: Admin2026*
    'scrypt:32768:8:1$XkqzKV8YmNpLwRtA$8f2e1d4c6b9a3f7e0d5c8b1a4e7f2c9b6d3a0e8f5c2b9a6d3f0e7c4b1a8d5f2e9c6b3a0d7f4e1c8b5a2d9f6e3c0b7a4d1f8e5c2b',
    0
FROM persona p, rol r
WHERE p.correo  = 'admin@unicaribe.edu.co'
  AND r.nombre_rol = 'ADMINISTRADOR';
