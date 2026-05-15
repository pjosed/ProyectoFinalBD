from flask import render_template, request, redirect, url_for, flash, session
from app.cuentas import cuentas_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


# ─── Lista de cuentas corrientes ─────────────────────────────────────────────

@cuentas_bp.route('/')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def lista_cuentas():
    id_periodo = request.args.get('id_periodo', '')
    q          = request.args.get('q', '').strip()

    sql = """
        SELECT cc.id_cuenta, cc.fecha_cre,
               e.id_estudiante, e.nombres, e.apellidos, e.num_doc,
               pa.nombre AS nom_periodo,
               COALESCE((SELECT SUM(mc.monto)
                         FROM movimiento_cuenta mc
                         JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                         WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0) AS total_cobros,
               COALESCE((SELECT SUM(pg.monto)
                         FROM pago pg
                         WHERE pg.id_cuenta = cc.id_cuenta), 0) AS total_pagos,
               COALESCE((SELECT SUM(mc.monto)
                         FROM movimiento_cuenta mc
                         JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                         WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0) -
               COALESCE((SELECT SUM(pg.monto)
                         FROM pago pg
                         WHERE pg.id_cuenta = cc.id_cuenta), 0) AS saldo
        FROM cuenta_corriente cc
        JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
        WHERE 1=1
    """
    params = []
    if id_periodo:
        sql += " AND cc.id_periodo = %s"
        params.append(id_periodo)
    if q:
        like = f'%{q}%'
        sql += " AND (e.num_doc LIKE %s OR e.nombres LIKE %s OR e.apellidos LIKE %s)"
        params.extend([like, like, like])
    sql += " ORDER BY pa.nombre DESC, e.apellidos"

    cuentas = ejecutar_consulta(sql, params, fetch=True) or []
    periodos = ejecutar_consulta(
        "SELECT id_periodo, nombre FROM periodo_academico ORDER BY nombre DESC",
        fetch=True
    )
    return render_template('cuentas/lista.html',
                           cuentas=cuentas,
                           periodos=periodos or [],
                           filtro_periodo=id_periodo,
                           filtro_q=q)


# ─── Detalle de cuenta corriente ─────────────────────────────────────────────

@cuentas_bp.route('/<int:id_cuenta>/detalle')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def detalle_cuenta(id_cuenta):
    cuenta = ejecutar_uno(
        """SELECT cc.id_cuenta, cc.fecha_cre,
                  e.nombres, e.apellidos, e.num_doc, e.tipo_doc,
                  pa.nombre AS nom_periodo
           FROM cuenta_corriente cc
           JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
           JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
           WHERE cc.id_cuenta = %s""",
        (id_cuenta,)
    )
    if not cuenta:
        flash('Cuenta corriente no encontrada.', 'danger')
        return redirect(url_for('cuentas.lista_cuentas'))

    movimientos = ejecutar_consulta(
        """SELECT mc.id_movimiento, mc.monto, mc.descrip,
                  mc.fecha, cd.grupo,
                  cd.codigo AS cod_concepto, cd.descripcion AS nom_concepto
           FROM movimiento_cuenta mc
           JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
           WHERE mc.id_cuenta = %s
           ORDER BY mc.fecha ASC""",
        (id_cuenta,), fetch=True
    ) or []

    pagos = ejecutar_consulta(
        """SELECT pg.id_pago, pg.monto, pg.medio, pg.ref, pg.fecha
           FROM pago pg
           WHERE pg.id_cuenta = %s
           ORDER BY pg.fecha ASC""",
        (id_cuenta,), fetch=True
    ) or []

    # Códigos de cobro adicional (excluye PMAT que se genera automáticamente)
    codigos_cobro = ejecutar_consulta(
        """SELECT id_codigo, codigo, descripcion
           FROM codigo_detalle
           WHERE grupo = 'COBRO' AND codigo != 'PMAT'
           ORDER BY codigo""",
        fetch=True
    ) or []

    total_cobros = sum(float(m['monto']) for m in movimientos if m['grupo'] == 'COBRO')
    total_pagos  = sum(float(p['monto']) for p in pagos)
    saldo        = total_cobros - total_pagos

    return render_template('cuentas/detalle.html',
                           cuenta=cuenta,
                           movimientos=movimientos,
                           pagos=pagos,
                           codigos_cobro=codigos_cobro,
                           total_cobros=total_cobros,
                           total_pagos=total_pagos,
                           saldo=saldo)


# ─── Agregar cobro adicional ──────────────────────────────────────────────────

@cuentas_bp.route('/<int:id_cuenta>/agregar-cobro', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def agregar_cobro(id_cuenta):
    id_codigo = request.form.get('id_codigo')
    monto     = request.form.get('monto', '').strip()
    descrip   = request.form.get('descrip', '').strip()
    id_usuario = session['usuario_id']

    if not id_codigo or not monto:
        flash('Debe seleccionar un concepto e ingresar el monto.', 'warning')
        return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))

    try:
        monto = float(monto)
        if monto <= 0:
            raise ValueError
    except ValueError:
        flash('El monto debe ser un número mayor a cero.', 'warning')
        return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))

    # Obtener descripción del código si no se ingresó una
    if not descrip:
        cod = ejecutar_uno(
            "SELECT descripcion FROM codigo_detalle WHERE id_codigo = %s",
            (id_codigo,)
        )
        descrip = cod['descripcion'] if cod else 'Cobro adicional'

    ejecutar_consulta(
        """INSERT INTO movimiento_cuenta (id_cuenta, id_codigo, descrip, monto, fecha, id_usuario)
           VALUES (%s, %s, %s, %s, NOW(), %s)""",
        (id_cuenta, id_codigo, descrip, monto, id_usuario)
    )
    flash('Cobro adicional registrado correctamente.', 'success')
    return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))