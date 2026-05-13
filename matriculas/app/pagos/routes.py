from flask import render_template, request, redirect, url_for, flash, session
from datetime import datetime
from app.pagos import pagos_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_uno, get_connection
from mysql.connector import Error

BANCOS_PSE = ['Bancolombia', 'Davivienda', 'BBVA', 'Banco de Bogotá', 'Nequi']
MEDIOS_CAJA = ['Efectivo', 'Transferencia', 'Consignación', 'Cheque']


def _get_cuenta_con_saldo(id_cuenta):
    cuenta = ejecutar_uno(
        """SELECT cc.id_cuenta, cc.id_estudiante, cc.id_periodo,
                  e.nombres, e.apellidos, e.num_doc, e.tipo_doc,
                  pa.nombre AS nom_periodo
           FROM cuenta_corriente cc
           JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
           JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
           WHERE cc.id_cuenta = %s""",
        (id_cuenta,)
    )
    if not cuenta:
        return None
    cobros = ejecutar_uno(
        """SELECT COALESCE(SUM(mc.monto), 0) AS total
           FROM movimiento_cuenta mc
           JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
           WHERE mc.id_cuenta = %s AND cd.grupo = 'COBRO'""",
        (id_cuenta,)
    )
    pagos = ejecutar_uno(
        "SELECT COALESCE(SUM(monto), 0) AS total FROM pago WHERE id_cuenta = %s",
        (id_cuenta,)
    )
    cuenta['total_cobros'] = float(cobros['total'])
    cuenta['total_pagos']  = float(pagos['total'])
    cuenta['saldo']        = cuenta['total_cobros'] - cuenta['total_pagos']
    return cuenta


# ─── Pago por Caja ───────────────────────────────────────────────────────────

@pagos_bp.route('/<int:id_cuenta>/caja', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def pago_caja(id_cuenta):
    cuenta = _get_cuenta_con_saldo(id_cuenta)
    if not cuenta:
        flash('Cuenta corriente no encontrada.', 'danger')
        return redirect(url_for('cuentas.lista_cuentas'))

    if cuenta['saldo'] <= 0:
        flash('Esta cuenta no tiene saldo pendiente.', 'info')
        return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))

    if request.method == 'POST':
        medio = request.form.get('medio', '').strip()
        ref   = request.form.get('ref', '').strip() or None
        try:
            monto = float(request.form.get('monto', 0))
        except ValueError:
            monto = 0

        if not medio:
            flash('Seleccione un medio de pago.', 'warning')
        elif monto <= 0:
            flash('El monto debe ser mayor a cero.', 'warning')
        elif monto > cuenta['saldo']:
            flash(f'El monto no puede superar el saldo pendiente (${cuenta["saldo"]:,.0f}).', 'warning')
        else:
            conexion = None
            cursor   = None
            try:
                conexion = get_connection()
                conexion.autocommit = False
                cursor = conexion.cursor(dictionary=True)
                cursor.execute(
                    "INSERT INTO pago (id_cuenta, medio, ref, monto, fecha, id_usuario) VALUES (%s,%s,%s,%s,%s,%s)",
                    (id_cuenta, medio, ref, monto, datetime.now(), session['usuario_id'])
                )
                id_pago = cursor.lastrowid
                conexion.commit()
                return redirect(url_for('pagos.comprobante', id_pago=id_pago))
            except Error as e:
                if conexion:
                    conexion.rollback()
                flash(f'Error al registrar el pago: {e}', 'danger')
            finally:
                if cursor:
                    cursor.close()
                if conexion and conexion.is_connected():
                    conexion.close()

    return render_template('pagos/caja.html', cuenta=cuenta, medios=MEDIOS_CAJA)


# ─── PSE Paso 1: selección de banco ─────────────────────────────────────────

@pagos_bp.route('/<int:id_cuenta>/pse')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def pse_paso1(id_cuenta):
    cuenta = _get_cuenta_con_saldo(id_cuenta)
    if not cuenta:
        flash('Cuenta corriente no encontrada.', 'danger')
        return redirect(url_for('cuentas.lista_cuentas'))
    if cuenta['saldo'] <= 0:
        flash('Esta cuenta no tiene saldo pendiente.', 'info')
        return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))
    return render_template('pagos/pse_paso1.html', cuenta=cuenta, bancos=BANCOS_PSE)


# ─── PSE Paso 2: confirmación ────────────────────────────────────────────────

@pagos_bp.route('/<int:id_cuenta>/pse/confirmar', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def pse_paso2(id_cuenta):
    cuenta = _get_cuenta_con_saldo(id_cuenta)
    banco  = request.form.get('banco', '').strip()
    if not cuenta or not banco:
        return redirect(url_for('pagos.pse_paso1', id_cuenta=id_cuenta))
    return render_template('pagos/pse_paso2.html', cuenta=cuenta, banco=banco)


# ─── PSE Procesar ────────────────────────────────────────────────────────────

@pagos_bp.route('/<int:id_cuenta>/pse/procesar', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def pse_procesar(id_cuenta):
    cuenta = _get_cuenta_con_saldo(id_cuenta)
    banco  = request.form.get('banco', '').strip()
    if not cuenta or cuenta['saldo'] <= 0:
        flash('No hay saldo pendiente.', 'info')
        return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))
    if not banco:
        return redirect(url_for('pagos.pse_paso1', id_cuenta=id_cuenta))

    conexion = None
    cursor   = None
    try:
        conexion = get_connection()
        conexion.autocommit = False
        cursor = conexion.cursor(dictionary=True)
        ref_pse = f"PSE-{banco[:3].upper()}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        cursor.execute(
            "INSERT INTO pago (id_cuenta, medio, ref, monto, fecha, id_usuario) VALUES (%s,%s,%s,%s,%s,%s)",
            (id_cuenta, 'PSE', ref_pse, cuenta['saldo'], datetime.now(), session['usuario_id'])
        )
        id_pago = cursor.lastrowid
        conexion.commit()
        return redirect(url_for('pagos.comprobante', id_pago=id_pago))
    except Error as e:
        if conexion:
            conexion.rollback()
        flash(f'Error al procesar el pago PSE: {e}', 'danger')
        return redirect(url_for('cuentas.detalle_cuenta', id_cuenta=id_cuenta))
    finally:
        if cursor:
            cursor.close()
        if conexion and conexion.is_connected():
            conexion.close()


# ─── Comprobante ─────────────────────────────────────────────────────────────

@pagos_bp.route('/comprobante/<int:id_pago>')
@login_requerido
def comprobante(id_pago):
    pago = ejecutar_uno(
        """SELECT pg.id_pago, pg.medio, pg.ref, pg.monto, pg.fecha, pg.id_cuenta,
                  e.nombres, e.apellidos, e.num_doc,
                  pa.nombre AS nom_periodo
           FROM pago pg
           JOIN cuenta_corriente cc ON pg.id_cuenta    = cc.id_cuenta
           JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
           JOIN periodo_academico pa ON cc.id_periodo   = pa.id_periodo
           WHERE pg.id_pago = %s""",
        (id_pago,)
    )
    if not pago:
        flash('Comprobante no encontrado.', 'danger')
        return redirect(url_for('cuentas.lista_cuentas'))
    return render_template('pagos/comprobante.html', pago=pago)
