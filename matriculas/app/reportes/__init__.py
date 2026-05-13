from flask import Blueprint

reportes_bp = Blueprint('reportes', __name__, template_folder='../templates/reportes')

from app.reportes import routes  # noqa: F401
