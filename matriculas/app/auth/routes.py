"""
app/auth/routes.py
Módulo de autenticación: login, logout, cambio de clave y decoradores de acceso.
"""

from functools import wraps
from flask import render_template, request, redirect, url_for, session, flash
from werkzeug.security import check_password_hash, generate_password_hash
from app.auth import auth_bp
from config.database import ejecutar_uno, ejecutar_consulta


# ─────────────────────────────────────────────────────────────────────────────
# DECORADORES DE CONTROL DE ACCESO
# ─────────────────────────────────────────────────────────────────────────────

def login_requerido(f):
    """Redirige al login si el usuario no tiene sesión activa."""
    @wraps(f)
    def decorador(*args, **kwargs):
        if "usuario_id" not in session:
            flash("Debes iniciar sesión para continuar.", "warning")
            return redirect(url_for("auth.login"))
        return f(*args, **kwargs)
    return decorador


def rol_requerido(*roles_permitidos):
    """
    Verifica que el usuario tenga uno de los roles indicados.
    Uso: @rol_requerido("ADMINISTRADOR", "SUPERVISOR")
    """
    def decorador(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if "usuario_id" not in session:
                flash("Debes iniciar sesión.", "warning")
                return redirect(url_for("auth.login"))
            if session.get("rol") not in roles_permitidos:
                flash("No tienes permisos para acceder a esta sección.", "danger")
                return redirect(url_for("auth.dashboard"))
            return f(*args, **kwargs)
        return wrapper
    return decorador


# ─────────────────────────────────────────────────────────────────────────────
# LOGIN
# ─────────────────────────────────────────────────────────────────────────────

@auth_bp.route("/", methods=["GET", "POST"])
@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if "usuario_id" in session:
        return redirect(url_for("auth.dashboard"))

    if request.method == "POST":
        nombre_usuario = request.form.get("nombre_usuario", "").strip()
        contrasena     = request.form.get("contrasena", "")

        if not nombre_usuario or not contrasena:
            flash("Ingresa usuario y contraseña.", "warning")
            return render_template("auth/login.html")

        usuario = ejecutar_uno(
            """
            SELECT u.id_usuario, u.nombre_usuario, u.contrasena_hash,
                   u.activo, u.debe_cambiar_clave,
                   r.nombre_rol, p.nombre, p.apellido
            FROM   usuario u
            JOIN   rol     r ON u.id_rol     = r.id_rol
            JOIN   persona p ON u.id_persona = p.id_persona
            WHERE  u.nombre_usuario = %s
            """,
            (nombre_usuario,),
        )

        # Mismo mensaje para usuario no encontrado o clave incorrecta
        if not usuario or not check_password_hash(usuario["contrasena_hash"], contrasena):
            flash("Usuario o contraseña incorrectos.", "danger")
            return render_template("auth/login.html")

        if not usuario["activo"]:
            flash("Tu cuenta está inactiva. Contacta al administrador.", "warning")
            return render_template("auth/login.html")

        # Registrar último acceso
        ejecutar_consulta(
            "UPDATE usuario SET ultimo_acceso = NOW() WHERE id_usuario = %s",
            (usuario["id_usuario"],)
        )

        # Guardar sesión
        session["usuario_id"]         = usuario["id_usuario"]
        session["nombre_usuario"]     = usuario["nombre_usuario"]
        session["rol"]                = usuario["nombre_rol"]
        session["nombre"]             = f"{usuario['nombre']} {usuario['apellido']}"
        session["debe_cambiar_clave"] = bool(usuario["debe_cambiar_clave"])

        # Primer login: forzar cambio de contraseña
        if usuario["debe_cambiar_clave"]:
            flash("Por seguridad, debes cambiar tu contraseña antes de continuar.", "warning")
            return redirect(url_for("auth.cambiar_clave"))

        flash(f"Bienvenido, {session['nombre']}.", "success")
        return redirect(url_for("auth.dashboard"))

    return render_template("auth/login.html")


# ─────────────────────────────────────────────────────────────────────────────
# CAMBIO DE CONTRASEÑA (forzado en primer login)
# ─────────────────────────────────────────────────────────────────────────────

@auth_bp.route("/cambiar-clave", methods=["GET", "POST"])
@login_requerido
def cambiar_clave():
    if request.method == "POST":
        nueva        = request.form.get("nueva_contrasena", "")
        confirmacion = request.form.get("confirmar_contrasena", "")

        if len(nueva) < 8:
            flash("La contraseña debe tener al menos 8 caracteres.", "warning")
            return render_template("auth/cambiar_clave.html")

        if nueva != confirmacion:
            flash("Las contraseñas no coinciden.", "warning")
            return render_template("auth/cambiar_clave.html")

        nuevo_hash = generate_password_hash(nueva)
        ejecutar_consulta(
            """UPDATE usuario
               SET contrasena_hash    = %s,
                   debe_cambiar_clave = 0
               WHERE id_usuario = %s""",
            (nuevo_hash, session["usuario_id"])
        )
        session["debe_cambiar_clave"] = False
        flash("Contraseña actualizada correctamente. ¡Bienvenido!", "success")
        return redirect(url_for("auth.dashboard"))

    return render_template("auth/cambiar_clave.html")


# ─────────────────────────────────────────────────────────────────────────────
# LOGOUT
# ─────────────────────────────────────────────────────────────────────────────

@auth_bp.route("/logout")
def logout():
    session.clear()
    flash("Sesión cerrada correctamente.", "info")
    return redirect(url_for("auth.login"))


# ─────────────────────────────────────────────────────────────────────────────
# DASHBOARD — redirige según rol
# ─────────────────────────────────────────────────────────────────────────────

@auth_bp.route("/dashboard")
@login_requerido
def dashboard():
    return redirect(url_for("admin.menu"))
