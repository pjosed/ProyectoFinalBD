-- ============================================================
-- 04_migracion_er.sql — AJUSTE AL MODELO ENTIDAD-RELACIÓN
-- Sistema de Matrículas — UniCaribe
-- IST7111 Bases de Datos 2026-10
-- Ejecutar UNA sola vez sobre la BD existente
-- ============================================================

USE matriculas_uni;

-- ── PROGRAMA ─────────────────────────────────────────────────
ALTER TABLE programa
    RENAME COLUMN total_semestres TO num_sem;
ALTER TABLE programa
    DROP COLUMN modalidad,
    DROP COLUMN nivel,
    DROP COLUMN total_creditos,
    DROP COLUMN fecha_creacion;

-- ── PLAN_ESTUDIO ──────────────────────────────────────────────
-- Agregar creditos y copiar desde asignatura ANTES de quitarlos
ALTER TABLE plan_estudio
    ADD COLUMN creditos INT NOT NULL DEFAULT 0;
UPDATE plan_estudio pe
JOIN   asignatura   a  ON pe.id_asignatura = a.id_asignatura
SET    pe.creditos = a.creditos;

-- ── ASIGNATURA ────────────────────────────────────────────────
ALTER TABLE asignatura
    DROP COLUMN creditos;

-- ── PERIODO_ACADEMICO ─────────────────────────────────────────
ALTER TABLE periodo_academico
    DROP COLUMN codigo;

-- ── REGLA_COBRO ───────────────────────────────────────────────
ALTER TABLE regla_cobro
    RENAME COLUMN valor_por_credito TO valor_credito;
ALTER TABLE regla_cobro
    DROP COLUMN modalidad_cobro,
    DROP COLUMN activo;

-- ── CODIGO_DETALLE ────────────────────────────────────────────
ALTER TABLE codigo_detalle
    DROP COLUMN nombre,
    DROP COLUMN activo;

-- ── USUARIO ───────────────────────────────────────────────────
ALTER TABLE usuario
    RENAME COLUMN password_hash TO password;
ALTER TABLE usuario
    RENAME COLUMN fecha_creacion TO fech_crea;
ALTER TABLE usuario
    DROP COLUMN debe_cambiar_clave,
    DROP COLUMN ultimo_acceso;
