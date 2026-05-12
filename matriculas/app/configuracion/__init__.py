from flask import Blueprint

configuracion_bp = Blueprint('configuracion', __name__)

from app.configuracion import programas, planes, codigos, reglas
