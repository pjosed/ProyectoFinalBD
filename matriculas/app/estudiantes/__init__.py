from flask import Blueprint


# Creamos el Blueprint para todo el módulo de estudiantes
estudiantes_bp = Blueprint(
    'estudiantes',
    __name__,
    template_folder='../templates/estudiantes'
)


# Importamos las rutas para que se registren en el blueprint
from app.estudiantes import routes