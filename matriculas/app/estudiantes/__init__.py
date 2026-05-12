from flask import Blueprint

estudiantes_bp = Blueprint('estudiantes', __name__)

from app.estudiantes import routes
