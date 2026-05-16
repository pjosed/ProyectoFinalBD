from flask import render_template, request, redirect, url_for, flash
from app.configuracion import configuracion_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@configuracion_bp.route('/codigos')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def codigos_lista():
    codigos = ejecutar_consulta(
        "SELECT * FROM codigo_detalle ORDER BY grupo, codigo",
        fetch=True
    )
    return render_template('configuracion/codigos_lista.html', codigos=codigos or [])


@configuracion_bp.route('/codigos/nuevo', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR')
def codigo_nuevo():
    if request.method == 'POST':
        grupo       = request.form.get('grupo')
        codigo      = request.form.get('codigo', '').strip().upper()
        descripcion = request.form.get('descripcion', '').strip()
        if not grupo or not codigo or not descripcion:
            flash('Todos los campos son obligatorios.', 'warning')
            return render_template('configuracion/codigo_form.html', codigo=None, grupos=['COBRO', 'PAGO'])
        ejecutar_consulta(
            "INSERT INTO codigo_detalle (grupo, codigo, descripcion) VALUES (%s, %s, %s)",
            (grupo, codigo, descripcion)
        )
        flash('Código creado correctamente.', 'success')
        return redirect(url_for('configuracion.codigos_lista'))
    return render_template('configuracion/codigo_form.html',
                           codigo=None,
                           grupos=['COBRO', 'PAGO'])


@configuracion_bp.route('/codigos/<int:id_codigo>/editar', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR')
def codigo_editar(id_codigo):
    codigo = ejecutar_uno("SELECT * FROM codigo_detalle WHERE id_codigo=%s", (id_codigo,))
    if not codigo:
        flash('Código no encontrado.', 'danger')
        return redirect(url_for('configuracion.codigos_lista'))
    if request.method == 'POST':
        grupo       = request.form.get('grupo', '').strip()
        cod         = request.form.get('codigo', '').strip().upper()
        descripcion = request.form.get('descripcion', '').strip()
        if not grupo or not cod or not descripcion:
            flash('Todos los campos son obligatorios.', 'warning')
            return render_template('configuracion/codigo_form.html',
                                   codigo=codigo, codigo_obj=codigo, grupos=['COBRO', 'PAGO'])
        ejecutar_consulta(
            "UPDATE codigo_detalle SET grupo=%s, codigo=%s, descripcion=%s WHERE id_codigo=%s",
            (grupo, cod, descripcion, id_codigo)
        )
        flash('Código actualizado correctamente.', 'success')
        return redirect(url_for('configuracion.codigos_lista'))
    return render_template('configuracion/codigo_form.html',
                           codigo=codigo,
                           codigo_obj=codigo,
                           grupos=['COBRO', 'PAGO'])