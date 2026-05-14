"""
app/descuentos/routes.py
Módulo de Descuentos y Becas — UniCaribe
Permite buscar estudiantes, aplicar descuentos sobre su cuenta corriente
y consultar el resultado de los descuentos aplicados en un periodo.
"""

from flask import render_template, request, redirect, url_for, flash, session
from datetime import datetime
from app.descuentos import descuentos_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno, get_connection
from mysql.connector import Error


# ─── helpers ──────────────────────────────────────────────────────────────────

def _get_periodos_con_saldo(id_estudiante):
    """Devuelve los periodos que tienen cuenta corriente para el estudiante,
    junto con el saldo pendiente de cada uno."""
    return ejecutar_consulta(
        """
        SELECT cc.id_cuenta,
               cc.id_periodo,
               pa.nombre                                      AS nom_periodo,
               pa.fecha_inicio,
               pa.fecha_fin,
               COALESCE(
                   (SELECT SUM(mc.monto)
                    FROM movimiento_cuenta mc
                    JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
                    WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0
               ) -
               COALESCE(
                   (SELECT SUM(pg.monto)
                    FROM pago pg
                    WHERE pg.id_cuenta = cc.id_cuenta), 0
               )                                              AS saldo
        FROM cuenta_corriente  cc
        JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo
        WHERE cc.id_estudiante = %s
        ORDER BY pa.nombre DESC
        """,
        (id_estudiante,),
        fetch=True
    ) or []


def _get_descuentos_aplicados(id_cuenta):
    """Devuelve todos los descuentos ya aplicados a una cuenta corriente."""
    return ejecutar_consulta(
        """
        SELECT da.id_descuento, da.porcentaje, da.valor_descuento,
               da.observacion, da.fecha_aplicacion,
               td.nombre  AS nombre_tipo,
               pa.nombre  AS nom_periodo
        FROM descuento_aplicado da
        JOIN tipo_descuento      td ON da.id_tipo    = td.id_tipo
        JOIN cuenta_corriente    cc ON da.id_cuenta  = cc.id_cuenta
        JOIN periodo_academico   pa ON cc.id_periodo = pa.id_periodo
        WHERE da.id_cuenta = %s
        ORDER BY da.fecha_aplicacion DESC
        """,
        (id_cuenta,),
        fetch=True
    ) or []


# ─── Buscar estudiante ────────────────────────────────────────────────────────

@descuentos_bp.route('/buscar')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def buscar():
    q = request.args.get('q', '').strip()
    estudiantes = []

    if q:
        like = f'%{q}%'
        estudiantes = ejecutar_consulta(
            """
            SELECT e.id_estudiante, e.nombres, e.apellidos,
                   e.num_doc, e.tipo_doc,
                   pr.nombre AS programa
            FROM estudiante e
            LEFT JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante
            LEFT JOIN volante_matricula vm ON vm.id_cuenta    = cc.id_cuenta
            LEFT JOIN programa_academico          pr ON vm.id_prog      = pr.id_programa
            WHERE e.activo = TRUE
              AND (e.nombres   LIKE %s
                OR e.apellidos LIKE %s
                OR e.num_doc   LIKE %s)
            GROUP BY e.id_estudiante, pr.nombre
            ORDER BY e.apellidos, e.nombres
            LIMIT 50
            """,
            (like, like, like),
            fetch=True
        ) or []

    return render_template('descuentos/buscar.html',
                           estudiantes=estudiantes,
                           q=q)


# ─── Formulario de descuento ──────────────────────────────────────────────────

@descuentos_bp.route('/formulario/<int:id_estudiante>', methods=['GET'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def formulario(id_estudiante):
    estudiante = ejecutar_uno(
        """
        SELECT id_estudiante, nombres, apellidos, num_doc, tipo_doc
        FROM estudiante
        WHERE id_estudiante = %s AND activo = TRUE
        """,
        (id_estudiante,)
    )
    if not estudiante:
        flash('Estudiante no encontrado.', 'danger')
        return redirect(url_for('descuentos.buscar'))

    periodos        = _get_periodos_con_saldo(id_estudiante)
    tipos_descuento = ejecutar_consulta(
        "SELECT id_tipo, nombre, porcentaje FROM tipo_descuento WHERE activo = 1 ORDER BY nombre",
        fetch=True
    ) or []

    # Panel lateral: descuentos de la primera cuenta disponible
    descuentos_aplicados = []
    if periodos:
        descuentos_aplicados = _get_descuentos_aplicados(periodos[0]['id_cuenta'])

    return render_template('descuentos/formulario.html',
                           estudiante=estudiante,
                           periodos=periodos,
                           tipos_descuento=tipos_descuento,
                           descuentos_aplicados=descuentos_aplicados)


# ─── Aplicar descuento ────────────────────────────────────────────────────────

@descuentos_bp.route('/aplicar/<int:id_estudiante>', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def aplicar(id_estudiante):
    id_periodo   = request.form.get('id_periodo',  '').strip()
    id_tipo      = request.form.get('id_tipo',     '').strip()
    observacion  = request.form.get('observacion', '').strip() or None

    try:
        porcentaje = float(request.form.get('porcentaje', 0))
    except ValueError:
        porcentaje = 0

    # ── Validaciones básicas ──────────────────────────────────────────────────
    if not id_periodo:
        flash('Debes seleccionar un periodo.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    if not id_tipo:
        flash('Debes seleccionar un tipo de beca.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    if porcentaje not in (10, 20, 25, 50, 100):
        flash('El porcentaje de descuento no es válido.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    # ── Obtener la cuenta corriente del estudiante en ese periodo ─────────────
    cuenta = ejecutar_uno(
        """
        SELECT cc.id_cuenta,
               COALESCE(
                   (SELECT SUM(mc.monto)
                    FROM movimiento_cuenta mc
                    JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
                    WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0
               ) -
               COALESCE(
                   (SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta), 0
               ) AS saldo
        FROM cuenta_corriente cc
        WHERE cc.id_estudiante = %s AND cc.id_periodo = %s
        """,
        (id_estudiante, id_periodo)
    )

    if not cuenta:
        flash('No existe cuenta corriente para ese estudiante en el periodo seleccionado.', 'danger')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    saldo = float(cuenta['saldo'])
    if saldo <= 0:
        flash('Esta cuenta no tiene saldo pendiente; no se puede aplicar un descuento.', 'info')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    valor_descuento = round(saldo * porcentaje / 100, 2)

    # ── Insertar en BD via stored procedure o INSERT directo ──────────────────
    # El SP sp_aplicar_descuento (script 08) requiere:
    #   p_id_estudiante, p_id_periodo, p_id_tipo, p_porcentaje, p_observacion, p_id_usuario
    conexion = None
    cursor   = None
    try:
        conexion = get_connection()
        conexion.autocommit = False
        cursor = conexion.cursor(dictionary=True)

        # Llamada al stored procedure definido en 08_Descuentos&Becas.sql
        cursor.callproc('sp_aplicar_descuento', [
            id_estudiante,
            id_periodo,
            int(id_tipo),
            porcentaje,
            observacion,
            session['usuario_id']
        ])
        conexion.commit()

        flash('Descuento aplicado correctamente.', 'success')
        return redirect(url_for('descuentos.resultado',
                                id_estudiante=id_estudiante,
                                id_periodo=id_periodo))

    except Error as e:
        if conexion:
            conexion.rollback()
        flash(f'Error al aplicar el descuento: {e}', 'danger')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))
    finally:
        if cursor:
            cursor.close()
        if conexion and conexion.is_connected():
            conexion.close()


# ─── Resultado ────────────────────────────────────────────────────────────────

@descuentos_bp.route('/resultado/<int:id_estudiante>')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def resultado(id_estudiante):
    id_periodo = request.args.get('id_periodo', '')

    estudiante = ejecutar_uno(
        "SELECT id_estudiante, nombres, apellidos, num_doc FROM estudiante WHERE id_estudiante = %s",
        (id_estudiante,)
    )
    if not estudiante:
        flash('Estudiante no encontrado.', 'danger')
        return redirect(url_for('descuentos.buscar'))

    # Resumen financiero de la cuenta en ese periodo
    cuenta = ejecutar_uno(
        """
        SELECT cc.id_cuenta,
               CONCAT(e.nombres, ' ', e.apellidos)            AS estudiante,
               e.id_estudiante,
               pa.nombre                                       AS periodo,
               COALESCE(
                   (SELECT SUM(mc.monto)
                    FROM movimiento_cuenta mc
                    JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
                    WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0
               )                                               AS total_cobros,
               COALESCE(
                   (SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta), 0
               )                                               AS total_pagos,
               COALESCE(
                   (SELECT SUM(da.valor_descuento)
                    FROM descuento_aplicado da
                    WHERE da.id_cuenta = cc.id_cuenta), 0
               )                                               AS total_descuentos
        FROM cuenta_corriente  cc
        JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
        WHERE cc.id_estudiante = %s AND cc.id_periodo = %s
        """,
        (id_estudiante, id_periodo)
    )

    if not cuenta:
        flash('No se encontró la cuenta corriente para ese periodo.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    cuenta['saldo_pendiente'] = (
        float(cuenta['total_cobros'])
        - float(cuenta['total_pagos'])
        - float(cuenta['total_descuentos'])
    )
    cuenta['estado'] = 'PENDIENTE' if cuenta['saldo_pendiente'] > 0 else 'BALANCEADO'

    descuentos = _get_descuentos_aplicados(cuenta['id_cuenta'])

    return render_template('descuentos/descuentos_resultado.html',
                           cuenta=cuenta,
                           descuentos=descuentos)
