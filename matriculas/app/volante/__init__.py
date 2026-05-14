from flask import Blueprint

volante_bp = Blueprint('volante', __name__, template_folder='../templates/volante')

from app.volante import routes  # noqa: F401
