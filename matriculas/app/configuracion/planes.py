from flask import render_template, request, redirect, url_for, flash
from app.configuracion import configuracion_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@configuracion_bp.route('/planes')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def planes_lista():
    programas = ejecutar_consulta(
        """SELECT p.id_programa, p.codigo, p.nombre, p.num_sem, p.activo,
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
    # Asignaturas que aún NO están en el plan de este programa
    disponibles = ejecutar_consulta(
        """SELECT a.id_asignatura, a.codigo, a.nombre
           FROM asignatura a
           WHERE a.activo = 1
             AND a.id_asignatura NOT IN (
                 SELECT pe.id_asignatura
                 FROM plan_estudio pe
                 WHERE pe.id_programa = %s
             )
           ORDER BY a.codigo""",
        (id_programa,), fetch=True
    )
    return render_template('configuracion/plan_detalle.html',
                           programa=programa,
                           plan=asignaturas or [],
                           disponibles=disponibles or [])


@configuracion_bp.route('/planes/<int:id_programa>/agregar', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def plan_agregar(id_programa):
    id_asignatura = request.form.get('id_asignatura', '').strip()
    semestre      = request.form.get('semestre', '').strip()
    creditos      = request.form.get('creditos', '').strip()

    if not id_asignatura or not semestre or not creditos:
        flash('Todos los campos son obligatorios.', 'warning')
        return redirect(url_for('configuracion.plan_detalle', id_programa=id_programa))

    try:
        semestre = int(semestre)
        creditos = int(creditos)
        if semestre < 1 or creditos < 1:
            raise ValueError
    except ValueError:
        flash('Semestre y créditos deben ser números mayores a cero.', 'warning')
        return redirect(url_for('configuracion.plan_detalle', id_programa=id_programa))

    programa = ejecutar_uno(
        "SELECT num_sem FROM programa_academico WHERE id_programa = %s", (id_programa,)
    )
    if semestre > programa['num_sem']:
        flash(f'El semestre no puede superar {programa["num_sem"]} para este programa.', 'warning')
        return redirect(url_for('configuracion.plan_detalle', id_programa=id_programa))

    try:
        ejecutar_consulta(
            """INSERT INTO plan_estudio (id_programa, id_asignatura, semestre, creditos)
               VALUES (%s, %s, %s, %s)""",
            (id_programa, id_asignatura, semestre, creditos)
        )
        flash('Asignatura agregada al plan correctamente.', 'success')
    except Exception as e:
        flash(f'Error al agregar la asignatura: {e}', 'danger')

    return redirect(url_for('configuracion.plan_detalle', id_programa=id_programa))


@configuracion_bp.route('/planes/<int:id_programa>/quitar/<int:id_plan>', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def plan_quitar(id_programa, id_plan):
    ejecutar_consulta(
        "DELETE FROM plan_estudio WHERE id_plan = %s",
        (id_plan,)
    )
    flash('Asignatura quitada del plan.', 'info')
    return redirect(url_for('configuracion.plan_detalle', id_programa=id_programa))