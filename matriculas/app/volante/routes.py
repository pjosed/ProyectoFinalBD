"""
Módulo Volante de Matrícula — UniCaribe
Vista imprimible del volante con búsqueda de estudiante.
"""

from datetime import date
from flask import render_template, request, redirect, url_for, flash
from app.volante import volante_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno


def _get_periodos():
    return ejecutar_consulta(
        "SELECT id_periodo, nombre FROM periodo_academico ORDER BY nombre DESC",
        fetch=True
    ) or []


def _datos_volante(id_cuenta, id_periodo):
    base = ejecutar_uno(
        """
        SELECT cc.id_cuenta, cc.id_estudiante, cc.id_periodo,
               CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
               e.nombres, e.apellidos, e.num_doc, e.tipo_doc,
               e.email, e.telefono,
               pa.nombre AS periodo, pa.fecha_inicio, pa.fecha_fin,
               vm.semestre,
               vm.val_tot,
               pr.id_programa, pr.nombre AS programa, pr.codigo AS codigo_programa,
               rc.modalidad_cobro, rc.valor_global, rc.valor_credito
        FROM cuenta_corriente  cc
        JOIN estudiante        e   ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico pa  ON cc.id_periodo    = pa.id_periodo
        LEFT JOIN volante_matricula  vm ON vm.id_cuenta  = cc.id_cuenta
        LEFT JOIN programa_academico pr ON vm.id_prog    = pr.id_programa
        LEFT JOIN regla_cobro        rc ON rc.id_periodo  = pa.id_periodo
                                       AND rc.id_programa = pr.id_programa
        WHERE cc.id_cuenta = %s AND cc.id_periodo = %s
        LIMIT 1
        """,
        (id_cuenta, id_periodo)
    )
    if not base:
        return None, []

    asignaturas = []
    if base.get('modalidad_cobro') == 'POR_CREDITOS':
        id_volante_row = ejecutar_uno(
            "SELECT id_volante FROM volante_matricula WHERE id_cuenta = %s LIMIT 1",
            (id_cuenta,)
        )
        if id_volante_row:
            asignaturas = ejecutar_consulta(
                """SELECT a.codigo, a.nombre, pe.creditos
                   FROM volante_asignatura va
                   JOIN asignatura   a  ON va.id_asig      = a.id_asignatura
                   JOIN plan_estudio pe ON pe.id_asignatura = a.id_asignatura
                                      AND pe.id_programa   = %s
                   WHERE va.id_volante = %s""",
                (base['id_programa'], id_volante_row['id_volante']),
                fetch=True
            ) or []

    valor_credito  = float(base.get('valor_credito') or 0)
    total_creditos = sum(int(a['creditos']) for a in asignaturas)
    base['total_creditos'] = total_creditos
    base['valor_credito']  = valor_credito

    cobros_row = ejecutar_uno(
        """SELECT COALESCE(SUM(mc.monto), 0) AS total
           FROM movimiento_cuenta mc
           JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
           WHERE mc.id_cuenta = %s AND cd.grupo = 'COBRO'""",
        (id_cuenta,)
    )
    pagos_row = ejecutar_uno(
        "SELECT COALESCE(SUM(monto), 0) AS total FROM pago WHERE id_cuenta = %s",
        (id_cuenta,)
    )
    desc_row = ejecutar_uno(
        "SELECT COALESCE(SUM(valor_descuento), 0) AS total FROM descuento_aplicado WHERE id_cuenta = %s",
        (id_cuenta,)
    )

    base['total_cobros']     = float(cobros_row['total']) if cobros_row else 0.0
    base['total_pagos']      = float(pagos_row['total'])  if pagos_row  else 0.0
    base['total_descuentos'] = float(desc_row['total'])   if desc_row   else 0.0
    base['saldo_pendiente']  = base['total_cobros'] - base['total_pagos']
    base['estado']           = 'PENDIENTE' if base['saldo_pendiente'] > 0 else 'BALANCEADO'

    return base, asignaturas


@volante_bp.route('/buscar')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def buscar():
    q = request.args.get('q', '').strip()
    estudiantes = []
    if q:
        like = f'%{q}%'
        # Solo muestra estudiantes que tienen volante generado (con programa asignado)
        estudiantes = ejecutar_consulta(
            """
            SELECT e.id_estudiante, e.nombres, e.apellidos,
                   e.num_doc, e.tipo_doc,
                   MAX(pr.nombre) AS programa,
                   cc.id_cuenta,
                   pa.nombre AS periodo
            FROM estudiante e
            JOIN cuenta_corriente cc ON cc.id_estudiante = e.id_estudiante
            JOIN periodo_academico pa ON pa.id_periodo = cc.id_periodo
            JOIN (
                SELECT vm1.id_cuenta, vm1.id_prog
                FROM volante_matricula vm1
                INNER JOIN (
                    SELECT id_cuenta, MAX(id_volante) AS max_vol
                    FROM volante_matricula
                    GROUP BY id_cuenta
                ) vm2 ON vm1.id_cuenta = vm2.id_cuenta AND vm1.id_volante = vm2.max_vol
            ) vm ON vm.id_cuenta = cc.id_cuenta
            JOIN programa_academico pr ON vm.id_prog = pr.id_programa
            WHERE e.activo = TRUE
              AND (e.nombres LIKE %s OR e.apellidos LIKE %s OR e.num_doc LIKE %s)
            GROUP BY e.id_estudiante, e.nombres, e.apellidos, e.num_doc, e.tipo_doc, cc.id_cuenta, pa.nombre
            ORDER BY e.apellidos, e.nombres
            LIMIT 50
            """,
            (like, like, like), fetch=True
        ) or []
    return render_template('volante/buscar.html', estudiantes=estudiantes, q=q)


@volante_bp.route('/<int:id_cuenta>')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def volante(id_cuenta):
    id_periodo = request.args.get('id_periodo', '')
    cuenta_row = ejecutar_uno(
        "SELECT id_periodo FROM cuenta_corriente WHERE id_cuenta = %s", (id_cuenta,)
    )
    if not cuenta_row:
        flash('Cuenta corriente no encontrada.', 'danger')
        return redirect(url_for('volante.buscar'))
    if not id_periodo:
        id_periodo = cuenta_row['id_periodo']

    datos, asignaturas = _datos_volante(id_cuenta, id_periodo)
    if not datos:
        flash('No se pudo cargar la información del volante.', 'warning')
        return redirect(url_for('volante.buscar'))

    descuentos = ejecutar_consulta(
        """SELECT da.porcentaje, da.valor_descuento, td.nombre AS nombre_tipo
           FROM descuento_aplicado da
           JOIN tipo_descuento td ON da.id_tipo = td.id_tipo
           WHERE da.id_cuenta = %s ORDER BY da.fech_pub""",
        (id_cuenta,), fetch=True
    ) or []

    pagos = ejecutar_consulta(
        """SELECT pg.id_pago, pg.medio, pg.ref, pg.monto, pg.fecha
           FROM pago pg WHERE pg.id_cuenta = %s ORDER BY pg.fecha ASC""",
        (id_cuenta,), fetch=True
    ) or []

    return render_template('volante/volante.html',
                           datos=datos,
                           asignaturas=asignaturas,
                           descuentos=descuentos,
                           pagos=pagos,
                           periodos=_get_periodos(),
                           hoy=date.today().strftime('%d/%m/%Y'))