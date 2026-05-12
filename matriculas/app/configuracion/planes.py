from flask import render_template, request, redirect, url_for, flash
from app.configuracion import configuracion_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@configuracion_bp.route('/planes')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def planes_lista():
    programas = ejecutar_consulta(
        """SELECT p.id_programa, p.codigo, p.nombre,
          COUNT(pe.id_plan) AS num_asignaturas
   FROM programa_academico p
   LEFT JOIN plan_estudio pe ON p.id_programa = pe.id_programa
   WHERE p.activo = 1
   GROUP BY p.id_programa, p.codigo, p.nombre
   ORDER BY p.nombre""",
        fetch=True
    )
    return render_template('configuracion/planes_lista.html', programas=programas or [])


@configuracion_bp.route('/planes/<int:id_programa>')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def plan_detalle(id_programa):
    programa = ejecutar_uno(
        "SELECT * FROM programa_academico WHERE id_programa = %s", (id_programa,)
    )
    asignaturas = ejecutar_consulta(
        """SELECT pe.id_plan, a.codigo, a.nombre, pe.semestre, pe.creditos
           FROM plan_estudio pe
           JOIN asignatura a ON pe.id_asignatura = a.id_asignatura
           WHERE pe.id_programa = %s
           ORDER BY pe.semestre, a.nombre""",
        (id_programa,), fetch=True
    )
    return render_template('configuracion/plan_detalle.html',
                           programa=programa, asignaturas=asignaturas or [])
