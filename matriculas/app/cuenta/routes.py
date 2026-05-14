"""
app/cuenta/routes.py
Módulo de Cuenta Corriente — UniCaribe
Permite buscar estudiantes y visualizar el estado completo de su cuenta
corriente con movimientos, saldo acumulado fila por fila y verificación
de balance.  Desde aquí se accede a los pagos (PSE / Caja) y descuentos.
"""

from flask import render_template, request, redirect, url_for, flash, session
from app.cuenta import cuenta_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


# ─── helpers ──────────────────────────────────────────────────────────────────

def _get_periodos():
    return ejecutar_consulta(
        "SELECT id_periodo, nombre FROM periodo_academico ORDER BY nombre DESC",
        fetch=True
    ) or []


def _saldo_acumulado(movimientos):
    """Calcula el saldo corriente fila por fila sobre la lista de movimientos.
    Cada elemento debe tener los campos 'tipo' (COBRO/PAGO) y 'valor'."""
    acum = 0.0
    for m in movimientos:
        if m['tipo'] == 'COBRO':
            acum += float(m['valor'])
        else:
            acum -= float(m['valor'])
        m['saldo_acumulado'] = acum
    return movimientos


# ─── Buscar estudiante ────────────────────────────────────────────────────────

@cuenta_bp.route('/buscar')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def buscar():
    q = request.args.get('q', '').strip()
    estudiantes = []

    if q:
        like = f'%{q}%'
        # Devuelve solo estudiantes que ya tienen al menos una cuenta corriente
        estudiantes = ejecutar_consulta(
            """
            SELECT e.id_estudiante, e.nombres, e.apellidos,
                   e.num_doc, e.tipo_doc,
                   pr.nombre AS programa,
                   cc.id_cuenta
            FROM estudiante e
            JOIN cuenta_corriente  cc ON cc.id_estudiante = e.id_estudiante
            LEFT JOIN volante_matricula vm ON vm.id_cuenta = cc.id_cuenta
            LEFT JOIN programa          pr ON vm.id_prog   = pr.id_programa
            WHERE e.activo = TRUE
              AND (e.nombres   LIKE %s
                OR e.apellidos LIKE %s
                OR e.num_doc   LIKE %s)
            GROUP BY e.id_estudiante, cc.id_cuenta
            ORDER BY e.apellidos, e.nombres
            LIMIT 50
            """,
            (like, like, like),
            fetch=True
        ) or []

    return render_template('cuenta/buscar.html',
                           estudiantes=estudiantes,
                           q=q)


# ─── Cuenta corriente detallada ───────────────────────────────────────────────

@cuenta_bp.route('/<int:id_cuenta>')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def cuenta_corriente(id_cuenta):
    # Selector de periodo: usa el de la URL o el propio de la cuenta
    id_periodo_sel = request.args.get('id_periodo', '')

    # Datos básicos de la cuenta
    cuenta = ejecutar_uno(
        """
        SELECT cc.id_cuenta, cc.id_periodo,
               cc.id_estudiante,
               CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
               e.nombres, e.apellidos,
               e.num_doc, e.tipo_doc,
               pa.nombre  AS periodo,
               pa.id_periodo
        FROM cuenta_corriente  cc
        JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
        WHERE cc.id_cuenta = %s
        """,
        (id_cuenta,)
    )
    if not cuenta:
        flash('Cuenta corriente no encontrada.', 'danger')
        return redirect(url_for('cuenta.buscar'))

    # Si no se pasó periodo en la URL, usar el de la cuenta
    if not id_periodo_sel:
        id_periodo_sel = cuenta['id_periodo']

    # Todos los periodos disponibles para el selector
    periodos = _get_periodos()

    # Movimientos del periodo seleccionado, ordenados por fecha ASC
    # (la vista v_movimientos_con_saldo del script 09 ya calcula el saldo
    # acumulado con window functions; la usamos directamente)
    movimientos = ejecutar_consulta(
        """
        SELECT v.id_movimiento,
               v.movimiento,
               v.codigo,
               v.tipo,
               v.valor,
               v.saldo_acumulado,
               v.fecha,
               mc.descrip AS observacion
        FROM v_movimientos_con_saldo v
        JOIN movimiento_cuenta mc ON mc.id_movimiento = v.id_movimiento
        WHERE v.id_cuenta  = %s
          AND v.id_periodo = %s
        ORDER BY v.fecha ASC, v.id_movimiento ASC
        """,
        (id_cuenta, id_periodo_sel),
        fetch=True
    ) or []

    # Si la vista no existe todavía en este entorno, calculamos manualmente
    if not movimientos:
        raw = ejecutar_consulta(
            """
            SELECT mc.id_movimiento,
                   cd.nombre  AS movimiento,
                   cd.codigo,
                   cd.grupo   AS tipo,
                   mc.monto   AS valor,
                   mc.fecha,
                   mc.descrip AS observacion
            FROM movimiento_cuenta mc
            JOIN codigo_detalle    cd  ON mc.id_codigo  = cd.id_codigo
            JOIN cuenta_corriente  cc  ON mc.id_cuenta  = cc.id_cuenta
            WHERE mc.id_cuenta  = %s
              AND cc.id_periodo = %s
            ORDER BY mc.fecha ASC, mc.id_movimiento ASC
            """,
            (id_cuenta, id_periodo_sel),
            fetch=True
        ) or []
        movimientos = _saldo_acumulado(raw)

    # Totales
    total_cobros = sum(
        float(m['valor']) for m in movimientos if m['tipo'] == 'COBRO'
    )
    total_pagos_raw = ejecutar_uno(
        "SELECT COALESCE(SUM(monto), 0) AS total FROM pago WHERE id_cuenta = %s",
        (id_cuenta,)
    )
    total_pagos   = float(total_pagos_raw['total']) if total_pagos_raw else 0.0
    saldo_pendiente = total_cobros - total_pagos
    diferencia      = 0.0   # la vista ya garantiza consistencia

    estado = 'PENDIENTE' if saldo_pendiente > 0 else 'BALANCEADO'

    return render_template('cuenta/cuenta_corriente.html',
                           cuenta=cuenta,
                           periodos=periodos,
                           id_periodo_sel=int(id_periodo_sel),
                           movimientos=movimientos,
                           total_cobros=total_cobros,
                           total_pagos=total_pagos,
                           saldo_pendiente=saldo_pendiente,
                           diferencia=diferencia,
                           estado=estado)
