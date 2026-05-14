import os
from flask import Flask, session
from flask_mail import Mail
from dotenv import load_dotenv

load_dotenv()

mail = Mail()


def create_app():
    app = Flask(__name__)

    app.secret_key = os.getenv("SECRET_KEY", "clave_desarrollo_insegura")
    app.config["ENV"] = os.getenv("FLASK_ENV", "development")

    app.config["MAIL_SERVER"]         = os.getenv("MAIL_SERVER", "smtp.gmail.com")
    app.config["MAIL_PORT"]           = int(os.getenv("MAIL_PORT", 587))
    app.config["MAIL_USE_TLS"]        = os.getenv("MAIL_USE_TLS", "True") == "True"
    app.config["MAIL_USERNAME"]       = os.getenv("MAIL_USERNAME")
    app.config["MAIL_PASSWORD"]       = os.getenv("MAIL_PASSWORD")
    app.config["MAIL_DEFAULT_SENDER"] = os.getenv("MAIL_DEFAULT_SENDER")

    mail.init_app(app)

    # ── Context processor: inyecta 'secciones' en todos los templates ──────
    from app.admin.routes import MENUS_POR_ROL

    @app.context_processor
    def inyectar_menu():
        rol = session.get("rol", "")
        return {"secciones": MENUS_POR_ROL.get(rol, [])}

    # ── Blueprints ──────────────────────────────────────────────────────────
    from app.auth import auth_bp
    app.register_blueprint(auth_bp)

    from app.admin import admin_bp
    app.register_blueprint(admin_bp, url_prefix="/admin")

    from app.configuracion import configuracion_bp
    app.register_blueprint(configuracion_bp, url_prefix="/configuracion")

    # Blueprint de Estudiantes
    from app.estudiantes import estudiantes_bp
    app.register_blueprint(estudiantes_bp, url_prefix="/estudiantes")

    # Blueprint de Volantes
    from app.volantes import volantes_bp
    app.register_blueprint(volantes_bp, url_prefix="/volantes")

    # Blueprint de Cuentas Corrientes
    from app.cuentas import cuentas_bp
    app.register_blueprint(cuentas_bp, url_prefix="/cuentas")

    # Blueprint de Pagos
    from app.pagos import pagos_bp
    app.register_blueprint(pagos_bp, url_prefix="/pagos")

    # Blueprint de Reportes
    from app.reportes import reportes_bp
    app.register_blueprint(reportes_bp, url_prefix="/reportes")


    # Blueprint de Descuentos y Becas
    from app.descuentos import descuentos_bp
    app.register_blueprint(descuentos_bp, url_prefix="/descuentos")
 
    # Blueprint de Cuenta Corriente (vista detallada por estudiante)
    from app.cuenta import cuenta_bp
    app.register_blueprint(cuenta_bp, url_prefix="/cuenta")
 
    # Blueprint de Volante de Matrícula (vista imprimible)
    from app.volante import volante_bp
    app.register_blueprint(volante_bp, url_prefix="/volante")
    return app
