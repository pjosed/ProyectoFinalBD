from flask import Blueprint

volantes_bp = Blueprint('volantes', __name__, template_folder='../templates/volantes')

from app.volantes import routes  # noqa: F401
