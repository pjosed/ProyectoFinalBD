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

    # Tus compañeros registran sus blueprints aquí:
    # from app.programas import programas_bp
    # app.register_blueprint(programas_bp, url_prefix="/programas")

    return app
