from flask import render_template, request, redirect, url_for, flash
from app.estudiantes import estudiantes_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@estudiantes_bp.route('/')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def lista_estudiantes():
    """Muestra la lista de todos los estudiantes activos."""
    sql = "SELECT * FROM estudiante WHERE activo = 1 ORDER BY apellidos ASC"
    estudiantes = ejecutar_consulta(sql, fetch=True)
    return render_template('estudiantes/lista.html', estudiantes=estudiantes)


@estudiantes_bp.route('/crear', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def crear_estudiante():
    """Muestra el formulario y procesa la creación de un estudiante."""
    if request.method == 'POST':
        tipo_doc  = request.form.get('tipo_doc')
        num_doc   = request.form.get('num_doc')
        nombres   = request.form.get('nombres')
        apellidos = request.form.get('apellidos')
        email     = request.form.get('email')
        telefono  = request.form.get('telefono')

        try:
            sql = """
                INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono, activo)
                VALUES (%s, %s, %s, %s, %s, %s, 1)
            """
            ejecutar_consulta(sql, (tipo_doc, num_doc, nombres, apellidos, email, telefono))
            flash('Estudiante registrado exitosamente.', 'success')
            return redirect(url_for('estudiantes.lista_estudiantes'))
        except Exception as e:
            flash(f'Error al registrar estudiante (¿quizás documento o email duplicado?): {str(e)}', 'danger')

    return render_template('estudiantes/crear.html')


@estudiantes_bp.route('/editar/<int:id_estudiante>', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def editar_estudiante(id_estudiante):
    """Muestra el formulario y procesa la edición de un estudiante."""
    sql_buscar = "SELECT * FROM estudiante WHERE id_estudiante = %s"
    estudiante = ejecutar_uno(sql_buscar, (id_estudiante,))

    if not estudiante:
        flash('Estudiante no encontrado.', 'danger')
        return redirect(url_for('estudiantes.lista_estudiantes'))

    if request.method == 'POST':
        tipo_doc  = request.form.get('tipo_doc')
        num_doc   = request.form.get('num_doc')
        nombres   = request.form.get('nombres')
        apellidos = request.form.get('apellidos')
        email     = request.form.get('email')
        telefono  = request.form.get('telefono')

        try:
            sql_update = """
                UPDATE estudiante
                SET tipo_doc=%s, num_doc=%s, nombres=%s, apellidos=%s, email=%s, telefono=%s
                WHERE id_estudiante=%s
            """
            ejecutar_consulta(sql_update, (tipo_doc, num_doc, nombres, apellidos, email, telefono, id_estudiante))
            flash('Estudiante actualizado exitosamente.', 'success')
            return redirect(url_for('estudiantes.lista_estudiantes'))
        except Exception as e:
            flash(f'Error al actualizar: {str(e)}', 'danger')

    return render_template('estudiantes/editar.html', estudiante=estudiante)


@estudiantes_bp.route('/eliminar/<int:id_estudiante>', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def eliminar_estudiante(id_estudiante):
    """'Elimina' un estudiante marcándolo como inactivo para no romper las FKs."""
    try:
        sql_delete = "UPDATE estudiante SET activo = 0 WHERE id_estudiante = %s"
        ejecutar_consulta(sql_delete, (id_estudiante,))
        flash('Estudiante eliminado (inactivado) correctamente.', 'success')
    except Exception as e:
        flash(f'Error al eliminar: {str(e)}', 'danger')

    return redirect(url_for('estudiantes.lista_estudiantes'))