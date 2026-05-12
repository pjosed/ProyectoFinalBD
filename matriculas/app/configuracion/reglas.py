from flask import render_template, request, redirect, url_for, flash
from app.configuracion import configuracion_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


@configuracion_bp.route('/reglas')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def reglas_lista():
    reglas = ejecutar_consulta(
        """SELECT rc.id_regla, pa.nombre AS nom_periodo, 
                  pr.nombre AS nom_programa, pr.codigo AS cod_programa,
                  rc.valor_global, rc.valor_credito
           FROM regla_cobro rc
           JOIN periodo_academico pa ON rc.id_periodo  = pa.id_periodo
           JOIN programa_academico pr ON rc.id_programa = pr.id_programa
           ORDER BY pa.nombre, pr.nombre""",
        fetch=True
    )
    return render_template('configuracion/reglas_lista.html', reglas=reglas or [])


@configuracion_bp.route('/reglas/nueva', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def regla_nueva():
    periodos  = ejecutar_consulta("SELECT id_periodo, nombre FROM periodo_academico ORDER BY nombre", fetch=True)
    programas = ejecutar_consulta("SELECT id_programa, nombre FROM programa_academico WHERE activo=1 ORDER BY nombre", fetch=True)
    if request.method == 'POST':
        id_periodo   = request.form.get('id_periodo')
        id_programa  = request.form.get('id_programa')
        valor_global  = request.form.get('valor_global')
        valor_credito = request.form.get('valor_credito')
        ejecutar_consulta(
            "INSERT INTO regla_cobro (id_periodo, id_programa, valor_global, valor_credito) VALUES (%s,%s,%s,%s)",
            (id_periodo, id_programa, valor_global, valor_credito)
        )
        flash('Regla de cobro creada.', 'success')
        return redirect(url_for('configuracion.reglas_lista'))
    return render_template('configuracion/regla_form.html', regla=None,
                           periodos=periodos or [], programas=programas or [])


@configuracion_bp.route('/reglas/<int:id_regla>/editar', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def regla_editar(id_regla):
    regla    = ejecutar_uno("SELECT * FROM regla_cobro WHERE id_regla=%s", (id_regla,))
    periodos  = ejecutar_consulta("SELECT id_periodo, nombre FROM periodo_academico ORDER BY nombre", fetch=True)
    programas = ejecutar_consulta("SELECT id_programa, nombre FROM programa_academico WHERE activo=1 ORDER BY nombre", fetch=True)
    if not regla:
        flash('Regla no encontrada.', 'danger')
        return redirect(url_for('configuracion.reglas_lista'))
    if request.method == 'POST':
        valor_global  = request.form.get('valor_global')
        valor_credito = request.form.get('valor_credito')
        ejecutar_consulta(
            "UPDATE regla_cobro SET valor_global=%s, valor_credito=%s WHERE id_regla=%s",
            (valor_global, valor_credito, id_regla)
        )
        flash('Regla actualizada.', 'success')
        return redirect(url_for('configuracion.reglas_lista'))
    return render_template('configuracion/regla_form.html', regla=regla,
                           periodos=periodos or [], programas=programas or [])
