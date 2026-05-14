from flask import render_template, request, redirect, url_for, flash
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
        SELECT cc.id_cuenta, cc.fecha_creacion,
               e.id_estudiante, e.nombres, e.apellidos, e.num_doc,
               pa.nombre AS nom_periodo,
               cc.total_cobros,
               cc.total_pagos,
               cc.saldo_pendiente AS saldo
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
        """SELECT cc.id_cuenta, cc.fecha_creacion,
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
        """SELECT mc.id_movimiento, mc.valor AS monto, mc.descripcion AS descrip,
                  mc.fecha, mc.tipo,
                  cd.codigo AS cod_concepto, cd.grupo, cd.nombre AS nom_concepto
           FROM movimiento_cuenta mc
           JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
           WHERE mc.id_cuenta = %s
           ORDER BY mc.fecha ASC""",
        (id_cuenta,), fetch=True
    ) or []

    pagos = ejecutar_consulta(
        """SELECT pg.id_pago, pg.valor AS monto, pg.metodo_pago AS medio,
                  pg.fecha_pago AS fecha, pg.observacion AS ref
           FROM pago pg
           WHERE pg.id_cuenta = %s
           ORDER BY pg.fecha_pago ASC""",
        (id_cuenta,), fetch=True
    ) or []

    total_cobros = sum(float(m['monto']) for m in movimientos if m['tipo'] == 'COBRO')
    total_pagos  = sum(float(p['monto']) for p in pagos)
    saldo        = total_cobros - total_pagos

    return render_template('cuentas/detalle.html',
                           cuenta=cuenta,
                           movimientos=movimientos,
                           pagos=pagos,
                           total_cobros=total_cobros,
                           total_pagos=total_pagos,
                           saldo=saldo)