from flask import Blueprint

descuentos_bp = Blueprint('descuentos', __name__, template_folder='../templates/descuentos')

from app.descuentos import routes  # noqa: F401
