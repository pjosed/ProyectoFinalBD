from flask import Blueprint

cuenta_bp = Blueprint('cuenta', __name__, template_folder='../templates/cuenta')

from app.cuenta import routes  # noqa: F401
