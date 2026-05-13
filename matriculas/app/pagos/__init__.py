from flask import Blueprint

pagos_bp = Blueprint('pagos', __name__, template_folder='../templates/pagos')

from app.pagos import routes  # noqa: F401
