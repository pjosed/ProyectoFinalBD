from flask import Blueprint

cuentas_bp = Blueprint('cuentas', __name__, template_folder='../templates/cuentas')

from app.cuentas import routes  # noqa: F401
