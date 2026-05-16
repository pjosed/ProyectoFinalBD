"""
app/descuentos/routes.py
Módulo de Descuentos y Becas — UniCaribe
"""

from flask import render_template, request, redirect, url_for, flash, session
from datetime import datetime
from app.descuentos import descuentos_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno, get_connection
from mysql.connector import Error


def _get_periodos_con_saldo(id_estudiante):
    return ejecutar_consulta(
        """
        SELECT cc.id_cuenta,
               cc.id_periodo,
               pa.nombre AS nom_periodo,
               pa.fecha_inicio,
               pa.fecha_fin,
               COALESCE(
                   (SELECT SUM(mc.monto)
                    FROM movimiento_cuenta mc
                    JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                    WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0
               ) -
               COALESCE(
                   (SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta), 0
               ) AS saldo
        FROM cuenta_corriente cc
        JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo
        WHERE cc.id_estudiante = %s
        ORDER BY pa.nombre DESC
        """,
        (id_estudiante,),
        fetch=True
    ) or []


def _get_descuentos_aplicados(id_cuenta):
    return ejecutar_consulta(
        """
        SELECT da.id_descuento, da.porcentaje, da.valor_descuento,
               da.observacion, da.fech_pub,
               td.nombre AS nombre_tipo,
               pa.nombre AS nom_periodo
        FROM descuento_aplicado da
        JOIN tipo_descuento    td ON da.id_tipo   = td.id_tipo
        JOIN cuenta_corriente  cc ON da.id_cuenta = cc.id_cuenta
        JOIN periodo_academico pa ON cc.id_periodo = pa.id_periodo
        WHERE da.id_cuenta = %s
        ORDER BY da.fech_pub DESC
        """,
        (id_cuenta,),
        fetch=True
    ) or []


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
                   MAX(pr.nombre) AS programa
            FROM estudiante e
            JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante
            LEFT JOIN (
                SELECT vm1.id_cuenta, vm1.id_prog
                FROM volante_matricula vm1
                INNER JOIN (
                    SELECT id_cuenta, MAX(id_volante) AS max_vol
                    FROM volante_matricula
                    GROUP BY id_cuenta
                ) vm2 ON vm1.id_cuenta = vm2.id_cuenta AND vm1.id_volante = vm2.max_vol
            ) vm ON vm.id_cuenta = cc.id_cuenta
            LEFT JOIN programa_academico pr ON vm.id_prog = pr.id_programa
            WHERE e.activo = TRUE
              AND (e.nombres   LIKE %s
                OR e.apellidos LIKE %s
                OR e.num_doc   LIKE %s)
            GROUP BY e.id_estudiante, e.nombres, e.apellidos, e.num_doc, e.tipo_doc, cc.id_cuenta
            ORDER BY e.apellidos, e.nombres
            LIMIT 50
            """,
            (like, like, like),
            fetch=True
        ) or []

    return render_template('descuentos/buscar.html',
                           estudiantes=estudiantes,
                           q=q)


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

    descuentos_aplicados = []
    if periodos:
        descuentos_aplicados = _get_descuentos_aplicados(periodos[0]['id_cuenta'])

    return render_template('descuentos/formulario.html',
                           estudiante=estudiante,
                           periodos=periodos,
                           tipos_descuento=tipos_descuento,
                           descuentos_aplicados=descuentos_aplicados)


@descuentos_bp.route('/aplicar/<int:id_estudiante>', methods=['POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def aplicar(id_estudiante):
    id_periodo  = request.form.get('id_periodo',  '').strip()
    id_tipo     = request.form.get('id_tipo',     '').strip()
    observacion = request.form.get('observacion', '').strip() or None

    try:
        porcentaje = float(request.form.get('porcentaje', 0))
    except ValueError:
        porcentaje = 0

    if not id_periodo:
        flash('Debes seleccionar un periodo.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    if not id_tipo:
        flash('Debes seleccionar un tipo de beca.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    if porcentaje not in (10, 20, 25, 50, 100):
        flash('El porcentaje de descuento no es válido.', 'warning')
        return redirect(url_for('descuentos.formulario', id_estudiante=id_estudiante))

    cuenta = ejecutar_uno(
        """
        SELECT cc.id_cuenta,
               COALESCE(
                   (SELECT SUM(mc.monto)
                    FROM movimiento_cuenta mc
                    JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
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

    conexion = None
    cursor   = None
    try:
        conexion = get_connection()
        conexion.autocommit = False
        cursor = conexion.cursor(dictionary=True)
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

    cuenta = ejecutar_uno(
        """
        SELECT cc.id_cuenta,
               CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
               e.id_estudiante,
               pa.nombre AS periodo,
               COALESCE(
                   (SELECT SUM(mc.monto)
                    FROM movimiento_cuenta mc
                    JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                    WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'), 0
               ) AS total_cobros,
               COALESCE(
                   (SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta), 0
               ) AS total_pagos,
               COALESCE(
                   (SELECT SUM(da.valor_descuento) FROM descuento_aplicado da
                    WHERE da.id_cuenta = cc.id_cuenta), 0
               ) AS total_descuentos
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