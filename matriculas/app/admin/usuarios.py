"""
app/admin/usuarios.py
CRUD de usuarios adaptado al modelo de Alan.
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
            f"Sistema de Matrículas — UniCaribe"
        )
        mail.send(msg)
        return True
    except Exception:
        return False


@admin_bp.route("/usuarios")
@rol_requerido("ADMINISTRADOR")
def usuarios_lista():
    usuarios = ejecutar_consulta(
        """
        SELECT u.id_usuario, u.username AS nombre_usuario, u.activo,
               u.fecha_creacion,
               r.nombre AS nombre_rol,
               p.nombres AS nombre, p.apellidos AS apellido, p.email AS correo
        FROM   usuario u
        JOIN   rol     r ON u.id_rol     = r.id_rol
        JOIN   persona p ON u.id_persona = p.id_persona
        ORDER  BY u.fecha_creacion DESC
        """,
        fetch=True,
    )
    return render_template("admin/usuarios_lista.html", usuarios=usuarios)


@admin_bp.route("/usuarios/nuevo", methods=["GET", "POST"])
@rol_requerido("ADMINISTRADOR")
def usuario_nuevo():
    roles = ejecutar_consulta(
        "SELECT id_rol, nombre FROM rol ORDER BY nombre",
        fetch=True
    )

    personas_sin_usuario = ejecutar_consulta(
        """
        SELECT p.id_persona, p.nombres AS nombre, p.apellidos AS apellido, p.email AS correo
        FROM   persona p
        LEFT JOIN usuario u ON u.id_persona = p.id_persona
        WHERE  u.id_usuario IS NULL
          AND  p.activo = 1
        ORDER  BY p.apellidos, p.nombres
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
            nombres   = request.form.get("nombre", "").strip()
            apellidos = request.form.get("apellido", "").strip()
            correo    = request.form.get("correo", "").strip().lower()
            telefono  = request.form.get("telefono", "").strip()
            num_doc   = request.form.get("num_doc", "").strip()

            if not nombres or not apellidos or not correo or not num_doc:
                flash("Nombre, apellido, correo y número de documento son obligatorios.", "warning")
                return render_template("admin/usuario_form.html",
                                    roles=roles, personas=personas_sin_usuario)

            existente = ejecutar_uno(
                "SELECT id_persona FROM persona WHERE email = %s", (correo,)
            )
            if existente:
                flash("Ya existe una persona con ese correo.", "danger")
                return render_template("admin/usuario_form.html",
                                       roles=roles, personas=personas_sin_usuario)

            id_persona = ejecutar_consulta(
            "INSERT INTO persona (tipo_doc, num_doc, nombres, apellidos, email, telefono) VALUES (%s,%s,%s,%s,%s,%s)",
            ('CC', num_doc, nombres, apellidos, correo, telefono or None),
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
            "SELECT id_usuario FROM usuario WHERE username = %s", (nombre_usuario,)
        ):
            flash(f"El nombre de usuario '{nombre_usuario}' ya está en uso.", "danger")
            return render_template("admin/usuario_form.html",
                                   roles=roles, personas=personas_sin_usuario)

        contrasena = _generar_contrasena()
        hash_pwd   = generate_password_hash(contrasena)

        ejecutar_consulta(
            """INSERT INTO usuario
               (id_persona, id_rol, username, password_hash)
               VALUES (%s, %s, %s, %s)""",
            (id_persona, int(id_rol), nombre_usuario, hash_pwd),
        )

        persona = ejecutar_uno(
            "SELECT nombres, email FROM persona WHERE id_persona = %s", (id_persona,)
        )
        correo_ok = _enviar_contrasena(
            persona["email"], persona["nombres"], nombre_usuario, contrasena
        )

        if correo_ok:
            flash(f"Usuario '{nombre_usuario}' creado y contraseña enviada a {persona['email']}.", "success")
        else:
            flash(
                f"Usuario '{nombre_usuario}' creado. "
                f"Contraseña temporal: {contrasena}",
                "warning",
            )

        return redirect(url_for("admin.usuarios_lista"))

    return render_template("admin/usuario_form.html",
                           roles=roles, personas=personas_sin_usuario)


@admin_bp.route("/usuarios/<int:id_usuario>/toggle", methods=["POST"])
@rol_requerido("ADMINISTRADOR")
def usuario_toggle(id_usuario):
    if id_usuario == session["usuario_id"]:
        flash("No puedes desactivar tu propia cuenta.", "warning")
        return redirect(url_for("admin.usuarios_lista"))

    usuario = ejecutar_uno(
        "SELECT activo, username FROM usuario WHERE id_usuario = %s", (id_usuario,)
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
    flash(f"Usuario '{usuario['username']}' {estado_texto}.", "success")
    return redirect(url_for("admin.usuarios_lista"))


@admin_bp.route("/usuarios/<int:id_usuario>/reenviar-clave", methods=["POST"])
@rol_requerido("ADMINISTRADOR")
def usuario_reenviar_clave(id_usuario):
    datos = ejecutar_uno(
        """
        SELECT u.username, p.nombres, p.email
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
        "UPDATE usuario SET password_hash = %s WHERE id_usuario = %s",
        (hash_pwd, id_usuario),
    )

    correo_ok = _enviar_contrasena(
        datos["email"], datos["nombres"], datos["username"], contrasena
    )

    if correo_ok:
        flash(f"Nueva contraseña enviada a {datos['email']}.", "success")
    else:
        flash(f"No se pudo enviar el correo. Contraseña temporal: {contrasena}", "warning")

    return redirect(url_for("admin.usuarios_lista"))