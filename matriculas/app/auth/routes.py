"""
app/auth/routes.py
Módulo de autenticación adaptado al modelo de Alan.
"""

from functools import wraps
from flask import render_template, request, redirect, url_for, session, flash
from werkzeug.security import check_password_hash, generate_password_hash
from app.auth import auth_bp
from config.database import ejecutar_uno, ejecutar_consulta


def login_requerido(f):
    @wraps(f)
    def decorador(*args, **kwargs):
        if "usuario_id" not in session:
            flash("Debes iniciar sesión para continuar.", "warning")
            return redirect(url_for("auth.login"))
        return f(*args, **kwargs)
    return decorador


def rol_requerido(*roles_permitidos):
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
            SELECT u.id_usuario, u.username, u.password_hash,
                   u.activo, r.nombre AS nombre_rol,
                   p.nombres, p.apellidos
            FROM   usuario u
            JOIN   rol     r ON u.id_rol     = r.id_rol
            JOIN   persona p ON u.id_persona = p.id_persona
            WHERE  u.username = %s
            """,
            (nombre_usuario,),
        )

        if not usuario or not check_password_hash(usuario["password_hash"], contrasena):
            flash("Usuario o contraseña incorrectos.", "danger")
            return render_template("auth/login.html")

        if not usuario["activo"]:
            flash("Tu cuenta está inactiva. Contacta al administrador.", "warning")
            return render_template("auth/login.html")

        session["usuario_id"]     = usuario["id_usuario"]
        session["nombre_usuario"] = usuario["username"]
        session["rol"]            = usuario["nombre_rol"]
        session["nombre"]         = f"{usuario['nombres']} {usuario['apellidos']}"

        flash(f"Bienvenido, {session['nombre']}.", "success")
        return redirect(url_for("auth.dashboard"))

    return render_template("auth/login.html")


@auth_bp.route("/logout")
def logout():
    session.clear()
    flash("Sesión cerrada correctamente.", "info")
    return redirect(url_for("auth.login"))


@auth_bp.route("/dashboard")
@login_requerido
def dashboard():
    return redirect(url_for("admin.menu"))