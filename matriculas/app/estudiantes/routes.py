from flask import render_template, request, redirect, url_for, flash, session
from app.estudiantes import estudiantes_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@estudiantes_bp.route('/')
@login_requerido
def lista_estudiantes():
    estudiantes = ejecutar_consulta(
        """SELECT id_estudiante, tipo_doc, num_doc, nombres, apellidos, email, telefono, activo
           FROM estudiante WHERE activo = 1 ORDER BY apellidos, nombres""",
        fetch=True
    )
    return render_template('estudiantes/lista.html', estudiantes=estudiantes or [])


@estudiantes_bp.route('/nuevo', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def crear_estudiante():
    if request.method == 'POST':
        tipo_doc  = request.form.get('tipo_doc', 'CC')
        num_doc   = request.form.get('num_doc', '').strip()
        nombres   = request.form.get('nombres', '').strip()
        apellidos = request.form.get('apellidos', '').strip()
        email     = request.form.get('email', '').strip()
        telefono  = request.form.get('telefono', '').strip()

        if not num_doc or not nombres or not apellidos or not email:
            flash('Todos los campos obligatorios deben completarse.', 'warning')
            return render_template('estudiantes/crear.html')

        ejecutar_consulta(
            """INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono)
               VALUES (%s, %s, %s, %s, %s, %s)""",
            (tipo_doc, num_doc, nombres, apellidos, email, telefono or None)
        )
        flash(f'Estudiante {nombres} {apellidos} registrado correctamente.', 'success')
        return redirect(url_for('estudiantes.lista_estudiantes'))

    return render_template('estudiantes/crear.html')


@estudiantes_bp.route('/<int:id_estudiante>/editar', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def editar_estudiante(id_estudiante):
    estudiante = ejecutar_uno(
        "SELECT * FROM estudiante WHERE id_estudiante = %s", (id_estudiante,)
    )
    if not estudiante:
        flash('Estudiante no encontrado.', 'danger')
        return redirect(url_for('estudiantes.lista_estudiantes'))

    if request.method == 'POST':
        nombres   = request.form.get('nombres', '').strip()
        apellidos = request.form.get('apellidos', '').strip()
        email     = request.form.get('email', '').strip()
        telefono  = request.form.get('telefono', '').strip()

        ejecutar_consulta(
            """UPDATE estudiante SET nombres=%s, apellidos=%s, email=%s, telefono=%s
               WHERE id_estudiante=%s""",
            (nombres, apellidos, email, telefono or None, id_estudiante)
        )
        flash('Estudiante actualizado correctamente.', 'success')
        return redirect(url_for('estudiantes.lista_estudiantes'))

    return render_template('estudiantes/editar.html', estudiante=estudiante)


@estudiantes_bp.route('/<int:id_estudiante>/eliminar', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR')
def eliminar_estudiante(id_estudiante):
    ejecutar_consulta(
        "UPDATE estudiante SET activo = 0 WHERE id_estudiante = %s", (id_estudiante,)
    )
    flash('Estudiante desactivado correctamente.', 'info')
    return redirect(url_for('estudiantes.lista_estudiantes'))
