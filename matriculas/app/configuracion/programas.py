from flask import render_template, request, redirect, url_for, flash
from app.configuracion import configuracion_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@configuracion_bp.route('/programas')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def programas_lista():
    programas = ejecutar_consulta(
        "SELECT id_programa, codigo, nombre, num_sem, activo FROM programa_academico ORDER BY nombre",
        fetch=True
    )
    return render_template('configuracion/programas_lista.html', programas=programas or [])


@configuracion_bp.route('/programas/nuevo', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def programa_nuevo():
    if request.method == 'POST':
        codigo       = request.form.get('codigo', '').strip().upper()
        nombre       = request.form.get('nombre', '').strip()
        num_sem = request.form.get('num_sem', 9)
        if not codigo or not nombre:
            flash('Código y nombre son obligatorios.', 'warning')
            return render_template('configuracion/programa_form.html', programa=None)
        ejecutar_consulta(
            "INSERT INTO programa_academico (codigo, nombre, num_sem) VALUES (%s, %s, %s)",
            (codigo, nombre, num_sem)
        )
        flash('Programa creado correctamente.', 'success')
        return redirect(url_for('configuracion.programas_lista'))
    return render_template('configuracion/programa_form.html', programa=None)


@configuracion_bp.route('/programas/<int:id_programa>/editar', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def programa_editar(id_programa):
    programa = ejecutar_uno(
        "SELECT * FROM programa_academico WHERE id_programa = %s", (id_programa,)
    )
    if not programa:
        flash('Programa no encontrado.', 'danger')
        return redirect(url_for('configuracion.programas_lista'))
    if request.method == 'POST':
        nombre        = request.form.get('nombre', '').strip()
        num_sem = request.form.get('num_sem', programa['num_sem'])
        ejecutar_consulta(
            "UPDATE programa_academico SET nombre=%s, num_sem=%s WHERE id_programa=%s",
            (nombre, num_sem, id_programa)
        )
        flash('Programa actualizado.', 'success')
        return redirect(url_for('configuracion.programas_lista'))
    return render_template('configuracion/programa_form.html', programa=programa)


@configuracion_bp.route('/programas/<int:id_programa>/toggle', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR')
def programa_toggle(id_programa):
    ejecutar_consulta(
        "UPDATE programa_academico SET activo = NOT activo WHERE id_programa = %s",
        (id_programa,)
    )
    flash('Estado del programa actualizado.', 'info')
    return redirect(url_for('configuracion.programas_lista'))
