"""
app/admin/routes.py
Menú dinámico según rol. Cada rol ve solo las opciones que le corresponden.
"""

from flask import render_template, session
from app.admin import admin_bp
from app.auth.routes import login_requerido

#INFO IMPORTANTE: para correr el programa se necesita modificar todas las líneas que empiecen por configuracion. y cambiarlas a admin. en el diccionario MENUS_POR_ROL, ya que el blueprint de configuracion no está terminado y no se pueden usar esas rutas aún. Se deben cambiar temporalmente a admin.placeholder para poder probar la app sin errores. Luego, cuando el blueprint de configuración esté listo, se cambian nuevamente a configuracion.nombre_de_la_ruta.

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
                {"label": "Programas Académicos", "url": "configuracion.programas_lista", "icono": "bi-book"},
                {"label": "Plan de Estudio",      "url": "configuracion.planes_lista",    "icono": "bi-journal-text"},
                {"label": "Códigos de Detalle",   "url": "configuracion.codigos_lista",   "icono": "bi-tags"},
                {"label": "Reglas de Cobro",      "url": "configuracion.reglas_lista",    "icono": "bi-cash-coin"},
            ],
        },
        {
            "seccion": "Estudiantes",
            "icono": "bi-mortarboard",
            "opciones": [
                {"label": "Gestionar Estudiantes", "url": "estudiantes.lista_estudiantes", "icono": "bi-person-lines-fill"},
                {"label": "Generar Cobros",        "url": "volantes.lista_volantes", "icono": "bi-receipt"},
                {"label": "Cuenta Corriente",      "url": "cuentas.lista_cuentas", "icono": "bi-wallet2"},
            ],
        },
        {
            "seccion": "Reportes",
            "icono": "bi-bar-chart",
            "opciones": [
                {"label": "Ingreso Esperado",   "url": "reportes.ingreso_esperado", "icono": "bi-graph-up"},
                {"label": "Pendientes de Pago", "url": "reportes.pendientes",       "icono": "bi-exclamation-circle"},
                {"label": "Ingreso Real",       "url": "reportes.ingreso_real",     "icono": "bi-cash-stack"},
                {"label": "Créditos",           "url": "reportes.creditos",         "icono": "bi-credit-card"},
            ],
        },
    ],
    "SUPERVISOR": [
        {
            "seccion": "Configuración",
            "icono": "bi-gear",
            "opciones": [
                {"label": "Programas Académicos", "url": "configuracion.programas_lista", "icono": "bi-book"},
                {"label": "Plan de Estudio",      "url": "configuracion.planes_lista",    "icono": "bi-journal-text"},
                {"label": "Reglas de Cobro",      "url": "configuracion.reglas_lista",    "icono": "bi-cash-coin"},
                {"label": "Códigos de Detalle",   "url": "configuracion.codigos_lista",   "icono": "bi-tags"},
            ],
        },
        {
            "seccion": "Estudiantes",
            "icono": "bi-mortarboard",
            "opciones": [
                {"label": "Gestionar Estudiantes", "url": "estudiantes.lista_estudiantes", "icono": "bi-person-lines-fill"},
            ],
        },
    ],
    "ASISTENTE": [
        {
            "seccion": "Cobros",
            "icono": "bi-receipt",
            "opciones": [
                {"label": "Generar Cobro Individual", "url": "volantes.volante_nuevo", "icono": "bi-person-check"},
                {"label": "Generación Masiva",        "url": "volantes.volante_masivo", "icono": "bi-people-fill"},
                {"label": "Cuenta Corriente",         "url": "cuentas.lista_cuentas", "icono": "bi-wallet2"},
                {"label": "Simular Pago",             "url": "cuentas.lista_cuentas", "icono": "bi-credit-card-2-front"},
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
