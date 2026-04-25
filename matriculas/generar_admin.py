"""
generar_admin.py
Genera el hash real de la contraseña del ADMINISTRADOR
y muestra el INSERT SQL listo para pegar en Workbench.

Ejecutar UNA sola vez:
    python generar_admin.py
"""

from werkzeug.security import generate_password_hash

CONTRASENA = "Admin2026*"
hash_generado = generate_password_hash(CONTRASENA)

print("=" * 65)
print("  HASH GENERADO PARA EL USUARIO ADMINISTRADOR")
print("=" * 65)
print(f"\nContraseña:  {CONTRASENA}")
print(f"Hash:        {hash_generado}")
print()
print("─" * 65)
print("  COPIA Y EJECUTA ESTE SQL EN MYSQL WORKBENCH:")
print("─" * 65)
print(f"""
USE matriculas_uni;

-- 1. Roles
INSERT IGNORE INTO rol (nombre_rol, descripcion) VALUES
    ('ADMINISTRADOR', 'Acceso total al sistema. Gestiona usuarios, roles y menús.'),
    ('SUPERVISOR',    'Gestiona programas, planes de estudio y reglas de cobro.'),
    ('ASISTENTE',     'Gestiona cobros, pagos y cuenta corriente.');

-- 2. Persona del administrador
INSERT IGNORE INTO persona (nombre, apellido, correo, telefono) VALUES
    ('Administrador', 'Sistema', 'admin@unicaribe.edu.co', '3001234567');

-- 3. Usuario administrador (contraseña: {CONTRASENA})
INSERT IGNORE INTO usuario
    (id_persona, id_rol, nombre_usuario, contrasena_hash, debe_cambiar_clave)
SELECT
    p.id_persona,
    r.id_rol,
    'admin',
    '{hash_generado}',
    0
FROM persona p
JOIN rol r ON r.nombre_rol = 'ADMINISTRADOR'
WHERE p.correo = 'admin@unicaribe.edu.co';

-- Verificar
SELECT u.nombre_usuario, r.nombre_rol, p.nombre, p.apellido, u.activo
FROM   usuario u
JOIN   rol     r ON u.id_rol     = r.id_rol
JOIN   persona p ON u.id_persona = p.id_persona;
""")
print("=" * 65)
