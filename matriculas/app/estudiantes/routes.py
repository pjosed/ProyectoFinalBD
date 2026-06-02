from flask import render_template, request, redirect, url_for, flash
from app.estudiantes import estudiantes_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


def _mensaje_duplicado(error_str):
    """
    Convierte el error 1062 de MySQL en un mensaje amigable.
    Detecta qué campo causó el duplicado leyendo el key name del error.
    """
    err = str(error_str).lower()
    if 'num_doc' in err:
        return 'Ese número de documento ya está registrado. Por favor ingrese uno diferente.'
    if 'email' in err:
        return 'Ese correo electrónico ya está registrado. Por favor ingrese uno diferente.'
    return 'Uno de los datos ingresados ya existe en el sistema. Verifique documento y correo.'


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
        tipo_doc  = (request.form.get('tipo_doc') or '').strip().upper()
        num_doc   = (request.form.get('num_doc') or '').strip()
        nombres   = (request.form.get('nombres') or '').strip()
        apellidos = (request.form.get('apellidos') or '').strip()
        email     = (request.form.get('email') or '').strip().lower()
        telefono  = (request.form.get('telefono') or '').strip() or None

        TIPOS_DOC_VALIDOS = ('CC', 'CE', 'TI', 'PA', 'RC')
        if not tipo_doc or tipo_doc not in TIPOS_DOC_VALIDOS:
            flash(f'Tipo de documento inválido. Use: {", ".join(TIPOS_DOC_VALIDOS)}.', 'warning')
            return render_template('estudiantes/crear.html')

        if not num_doc or not nombres or not apellidos or not email:
            flash('Todos los campos obligatorios deben completarse.', 'warning')
            return render_template('estudiantes/crear.html')

        try:
            sql = """
                INSERT INTO estudiante (tipo_doc, num_doc, nombres, apellidos, email, telefono, activo)
                VALUES (%s, %s, %s, %s, %s, %s, 1)
            """
            ejecutar_consulta(sql, (tipo_doc, num_doc, nombres, apellidos, email, telefono))
            flash('Estudiante registrado exitosamente.', 'success')
            return redirect(url_for('estudiantes.lista_estudiantes'))
        except Exception as e:
            if '1062' in str(e):
                flash(_mensaje_duplicado(e), 'warning')
            else:
                flash(f'Error inesperado al registrar el estudiante: {str(e)}', 'danger')

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
        tipo_doc  = (request.form.get('tipo_doc') or '').strip().upper()
        num_doc   = (request.form.get('num_doc') or '').strip()
        nombres   = (request.form.get('nombres') or '').strip()
        apellidos = (request.form.get('apellidos') or '').strip()
        email     = (request.form.get('email') or '').strip().lower()
        telefono  = (request.form.get('telefono') or '').strip() or None

        TIPOS_DOC_VALIDOS = ('CC', 'CE', 'TI', 'PA', 'RC')
        if not tipo_doc or tipo_doc not in TIPOS_DOC_VALIDOS:
            flash(f'Tipo de documento inválido. Use: {", ".join(TIPOS_DOC_VALIDOS)}.', 'warning')
            return render_template('estudiantes/editar.html', estudiante=estudiante)

        if not num_doc or not nombres or not apellidos or not email:
            flash('Todos los campos obligatorios deben completarse.', 'warning')
            return render_template('estudiantes/editar.html', estudiante=estudiante)

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
            if '1062' in str(e):
                flash(_mensaje_duplicado(e), 'warning')
            else:
                flash(f'Error inesperado al actualizar el estudiante: {str(e)}', 'danger')

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