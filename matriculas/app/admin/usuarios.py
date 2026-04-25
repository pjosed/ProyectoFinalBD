"""
app/admin/usuarios.py
CRUD de usuarios: listar, crear, activar/desactivar, reenviar contraseña.
"""

import secrets
import string
from flask import render_template, request, redirect, url_for, session, flash
from werkzeug.security import generate_password_hash
from flask_mail import Message
from app.admin import admin_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno
from app import mail
from app.admin import admin_bp

# ─────────────────────────────────────────────────────────────────────────────
# UTILIDADES
# ─────────────────────────────────────────────────────────────────────────────

def _generar_contrasena(largo=10):
    caracteres = string.ascii_letters + string.digits + "!@#$"
    while True:
        pwd = "".join(secrets.choice(caracteres) for _ in range(largo))
        if (any(c.isupper() for c in pwd) and
            any(c.islower() for c in pwd) and
            any(c.isdigit() for c in pwd)):
            return pwd


def _enviar_contrasena(correo, nombre, nombre_usuario, contrasena):
    try:
        msg = Message(
            subject="Acceso al Sistema de Matrículas — UniCaribe",
            recipients=[correo],
        )
        msg.body = (
            f"Hola {nombre},\n\n"
            f"Tu cuenta ha sido creada en el Sistema de Matrículas UniCaribe.\n\n"
            f"  Usuario:     {nombre_usuario}\n"
            f"  Contraseña:  {contrasena}\n\n"
            f"Al ingresar por primera vez deberás cambiar tu contraseña.\n\n"
            f"Sistema de Matrículas — UniCaribe"
        )
        mail.send(msg)
        return True
    except Exception:
        return False


# ─────────────────────────────────────────────────────────────────────────────
# LISTAR USUARIOS
# ─────────────────────────────────────────────────────────────────────────────

@admin_bp.route("/usuarios")
@rol_requerido("ADMINISTRADOR")
def usuarios_lista():
    usuarios = ejecutar_consulta(
        """
        SELECT u.id_usuario, u.nombre_usuario, u.activo,
               u.fecha_creacion, u.ultimo_acceso, u.debe_cambiar_clave,
               r.nombre_rol,
               p.nombre, p.apellido, p.correo
        FROM   usuario u
        JOIN   rol     r ON u.id_rol     = r.id_rol
        JOIN   persona p ON u.id_persona = p.id_persona
        ORDER  BY u.fecha_creacion DESC
        """,
        fetch=True,
    )
    return render_template("admin/usuarios_lista.html", usuarios=usuarios)


# ─────────────────────────────────────────────────────────────────────────────
# CREAR USUARIO
# ─────────────────────────────────────────────────────────────────────────────

@admin_bp.route("/usuarios/nuevo", methods=["GET", "POST"])
@rol_requerido("ADMINISTRADOR")
def usuario_nuevo():
    roles = ejecutar_consulta(
        "SELECT id_rol, nombre_rol FROM rol ORDER BY nombre_rol",
        fetch=True
    )

    personas_sin_usuario = ejecutar_consulta(
        """
        SELECT p.id_persona, p.nombre, p.apellido, p.correo
        FROM   persona p
        LEFT JOIN usuario u ON u.id_persona = p.id_persona
        WHERE  u.id_usuario IS NULL
          AND  p.activo = 1
        ORDER  BY p.apellido, p.nombre
        """,
        fetch=True,
    )

    if request.method == "POST":
        accion = request.form.get("accion")

        if accion == "existente":
            id_persona = request.form.get("id_persona")
            if not id_persona:
                flash("Selecciona una persona.", "warning")
                return render_template("admin/usuario_form.html",
                                       roles=roles, personas=personas_sin_usuario)
            id_persona = int(id_persona)

        elif accion == "nueva":
            nombre   = request.form.get("nombre", "").strip()
            apellido = request.form.get("apellido", "").strip()
            correo   = request.form.get("correo", "").strip().lower()
            telefono = request.form.get("telefono", "").strip()

            if not nombre or not apellido or not correo:
                flash("Nombre, apellido y correo son obligatorios.", "warning")
                return render_template("admin/usuario_form.html",
                                       roles=roles, personas=personas_sin_usuario)

            existente = ejecutar_uno(
                "SELECT id_persona FROM persona WHERE correo = %s", (correo,)
            )
            if existente:
                flash("Ya existe una persona con ese correo.", "danger")
                return render_template("admin/usuario_form.html",
                                       roles=roles, personas=personas_sin_usuario)

            id_persona = ejecutar_consulta(
                "INSERT INTO persona (nombre, apellido, correo, telefono) VALUES (%s,%s,%s,%s)",
                (nombre, apellido, correo, telefono or None),
            )
        else:
            flash("Acción no válida.", "danger")
            return render_template("admin/usuario_form.html",
                                   roles=roles, personas=personas_sin_usuario)

        nombre_usuario = request.form.get("nombre_usuario", "").strip().lower()
        id_rol         = request.form.get("id_rol")

        if not nombre_usuario or not id_rol:
            flash("El nombre de usuario y el rol son obligatorios.", "warning")
            return render_template("admin/usuario_form.html",
                                   roles=roles, personas=personas_sin_usuario)

        if ejecutar_uno(
            "SELECT id_usuario FROM usuario WHERE nombre_usuario = %s", (nombre_usuario,)
        ):
            flash(f"El nombre de usuario '{nombre_usuario}' ya está en uso.", "danger")
            return render_template("admin/usuario_form.html",
                                   roles=roles, personas=personas_sin_usuario)

        contrasena = _generar_contrasena()
        hash_pwd   = generate_password_hash(contrasena)

        ejecutar_consulta(
            """INSERT INTO usuario
               (id_persona, id_rol, nombre_usuario, contrasena_hash, debe_cambiar_clave)
               VALUES (%s, %s, %s, %s, 1)""",
            (id_persona, int(id_rol), nombre_usuario, hash_pwd),
        )

        persona = ejecutar_uno(
            "SELECT nombre, correo FROM persona WHERE id_persona = %s", (id_persona,)
        )
        correo_ok = _enviar_contrasena(
            persona["correo"], persona["nombre"], nombre_usuario, contrasena
        )

        if correo_ok:
            flash(f"Usuario '{nombre_usuario}' creado y contraseña enviada a {persona['correo']}.", "success")
        else:
            flash(
                f"Usuario '{nombre_usuario}' creado. "
                f"No se pudo enviar el correo — contraseña temporal: {contrasena}",
                "warning",
            )

        return redirect(url_for("admin.usuarios_lista"))

    return render_template("admin/usuario_form.html",
                           roles=roles, personas=personas_sin_usuario)


# ─────────────────────────────────────────────────────────────────────────────
# ACTIVAR / DESACTIVAR
# ─────────────────────────────────────────────────────────────────────────────

@admin_bp.route("/usuarios/<int:id_usuario>/toggle", methods=["POST"])
@rol_requerido("ADMINISTRADOR")
def usuario_toggle(id_usuario):
    if id_usuario == session["usuario_id"]:
        flash("No puedes desactivar tu propia cuenta.", "warning")
        return redirect(url_for("admin.usuarios_lista"))

    usuario = ejecutar_uno(
        "SELECT activo, nombre_usuario FROM usuario WHERE id_usuario = %s", (id_usuario,)
    )
    if not usuario:
        flash("Usuario no encontrado.", "danger")
        return redirect(url_for("admin.usuarios_lista"))

    nuevo_estado = 0 if usuario["activo"] else 1
    ejecutar_consulta(
        "UPDATE usuario SET activo = %s WHERE id_usuario = %s",
        (nuevo_estado, id_usuario),
    )
    estado_texto = "activado" if nuevo_estado else "desactivado"
    flash(f"Usuario '{usuario['nombre_usuario']}' {estado_texto}.", "success")
    return redirect(url_for("admin.usuarios_lista"))


# ─────────────────────────────────────────────────────────────────────────────
# REENVIAR CONTRASEÑA
# ─────────────────────────────────────────────────────────────────────────────

@admin_bp.route("/usuarios/<int:id_usuario>/reenviar-clave", methods=["POST"])
@rol_requerido("ADMINISTRADOR")
def usuario_reenviar_clave(id_usuario):
    datos = ejecutar_uno(
        """
        SELECT u.nombre_usuario, p.nombre, p.correo
        FROM   usuario u
        JOIN   persona p ON u.id_persona = p.id_persona
        WHERE  u.id_usuario = %s
        """,
        (id_usuario,),
    )
    if not datos:
        flash("Usuario no encontrado.", "danger")
        return redirect(url_for("admin.usuarios_lista"))

    contrasena = _generar_contrasena()
    hash_pwd   = generate_password_hash(contrasena)

    ejecutar_consulta(
        "UPDATE usuario SET contrasena_hash = %s, debe_cambiar_clave = 1 WHERE id_usuario = %s",
        (hash_pwd, id_usuario),
    )

    correo_ok = _enviar_contrasena(
        datos["correo"], datos["nombre"], datos["nombre_usuario"], contrasena
    )

    if correo_ok:
        flash(f"Nueva contraseña enviada a {datos['correo']}.", "success")
    else:
        flash(f"No se pudo enviar el correo. Contraseña temporal: {contrasena}", "warning")

    return redirect(url_for("admin.usuarios_lista"))