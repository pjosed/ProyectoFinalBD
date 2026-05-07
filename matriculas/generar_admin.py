"""
generar_admin.py
Genera el hash real de la contraseña del ADMINISTRADOR
y muestra el INSERT SQL listo para pegar en Workbench.

Ejecutar UNA sola vez desde la carpeta matriculas/:
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

-- 1. Persona del administrador
INSERT IGNORE INTO persona (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES
    ('CC', '0000000000', 'Administrador', 'Sistema', 'admin@unicaribe.edu.co', '3001234567');

-- 2. Usuario administrador (contraseña: {CONTRASENA})
INSERT IGNORE INTO usuario (id_persona, id_rol, username, password_hash, debe_cambiar_clave)
SELECT
    p.id_persona,
    r.id_rol,
    'admin',
    '{hash_generado}',
    0
FROM persona p
JOIN rol r ON r.nombre = 'ADMINISTRADOR'
WHERE p.email = 'admin@unicaribe.edu.co';

-- Verificar
SELECT u.username, r.nombre AS rol, p.nombres, p.apellidos, u.activo
FROM   usuario u
JOIN   rol     r ON u.id_rol     = r.id_rol
JOIN   persona p ON u.id_persona = p.id_persona;
""")
print("=" * 65)
