"""
app/admin/routes.py
Menú dinámico según rol. Cada rol ve solo las opciones que le corresponden.
"""

from flask import render_template, session
from app.admin import admin_bp
from app.auth.routes import login_requerido

MENUS_POR_ROL = {
    "ADMINISTRADOR": [
        {
            "seccion": "Seguridad",
            "icono": "bi-shield-lock",
            "opciones": [
                {"label": "Gestionar Usuarios", "url": "admin.usuarios_lista", "icono": "bi-people"},
                {"label": "Gestionar Roles", "url": "admin.placeholder", "icono": "bi-person-badge"},
            ],
        },
        {
            "seccion": "Configuración",
            "icono": "bi-gear",
            "opciones": [
                {"label": "Programas Académicos", "url": "admin.placeholder", "icono": "bi-book"},
                {"label": "Códigos de Detalle",   "url": "admin.placeholder", "icono": "bi-tags"},
                {"label": "Reglas de Cobro",      "url": "admin.placeholder", "icono": "bi-cash-coin"},
            ],
        },
        {
            "seccion": "Estudiantes",
            "icono": "bi-mortarboard",
            "opciones": [
                {"label": "Gestionar Estudiantes", "url": "admin.placeholder", "icono": "bi-person-lines-fill"},
                {"label": "Generar Cobros",        "url": "admin.placeholder", "icono": "bi-receipt"},
                {"label": "Cuenta Corriente",      "url": "admin.placeholder", "icono": "bi-wallet2"},
            ],
        },
        {
            "seccion": "Reportes",
            "icono": "bi-bar-chart",
            "opciones": [
                {"label": "Ingreso Esperado",   "url": "admin.placeholder", "icono": "bi-graph-up"},
                {"label": "Pendientes de Pago", "url": "admin.placeholder", "icono": "bi-exclamation-circle"},
                {"label": "Ingreso Real",       "url": "admin.placeholder", "icono": "bi-cash-stack"},
                {"label": "Créditos",           "url": "admin.placeholder", "icono": "bi-credit-card"},
            ],
        },
    ],
    "SUPERVISOR": [
        {
            "seccion": "Configuración",
            "icono": "bi-gear",
            "opciones": [
                {"label": "Programas Académicos", "url": "admin.placeholder", "icono": "bi-book"},
                {"label": "Plan de Estudio",      "url": "admin.placeholder", "icono": "bi-journal-text"},
                {"label": "Reglas de Cobro",      "url": "admin.placeholder", "icono": "bi-cash-coin"},
                {"label": "Códigos de Detalle",   "url": "admin.placeholder", "icono": "bi-tags"},
            ],
        },
        {
            "seccion": "Estudiantes",
            "icono": "bi-mortarboard",
            "opciones": [
                {"label": "Gestionar Estudiantes", "url": "admin.placeholder", "icono": "bi-person-lines-fill"},
            ],
        },
    ],
    "ASISTENTE": [
        {
            "seccion": "Cobros",
            "icono": "bi-receipt",
            "opciones": [
                {"label": "Generar Cobro Individual", "url": "admin.placeholder", "icono": "bi-person-check"},
                {"label": "Generación Masiva",        "url": "admin.placeholder", "icono": "bi-people-fill"},
                {"label": "Cuenta Corriente",         "url": "admin.placeholder", "icono": "bi-wallet2"},
                {"label": "Simular Pago",             "url": "admin.placeholder", "icono": "bi-credit-card-2-front"},
            ],
        },
    ],
}


@admin_bp.route("/placeholder")
@login_requerido
def placeholder():
    return render_template("admin/placeholder.html")

@admin_bp.route("/menu")
@login_requerido
def menu():
    return render_template("admin/menu.html")
