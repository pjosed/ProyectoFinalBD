from flask import render_template, request
from app.reportes import reportes_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta


def _get_periodos():
    """Solo periodos que tienen al menos un volante o cuenta corriente generada."""
    return ejecutar_consulta(
        """
        SELECT DISTINCT pa.id_periodo, pa.nombre
        FROM periodo_academico pa
        WHERE EXISTS (
            SELECT 1 FROM volante_matricula vm WHERE vm.id_per = pa.id_periodo
        ) OR EXISTS (
            SELECT 1 FROM cuenta_corriente cc WHERE cc.id_periodo = pa.id_periodo
        )
        ORDER BY pa.nombre DESC
        """,
        fetch=True
    ) or []


# ─── Reporte 1: Listado de Estudiantes ───────────────────────────────────────

@reportes_bp.route('/listado-estudiantes')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def listado_estudiantes():
    id_periodo  = request.args.get('id_periodo', '')
    id_programa = request.args.get('id_programa', '')

    sql = """
        SELECT e.nombres, e.apellidos, e.num_doc,
               pa.nombre AS nom_periodo,
               p.nombre  AS nom_programa, p.codigo AS cod_programa,
               vm.semestre, vm.modalidad, vm.val_tot
        FROM volante_matricula  vm
        JOIN estudiante         e  ON vm.id_estu = e.id_estudiante
        JOIN periodo_academico  pa ON vm.id_per  = pa.id_periodo
        JOIN programa_academico p  ON vm.id_prog = p.id_programa
        WHERE 1=1
    """
    params = []
    if id_periodo:
        sql += " AND vm.id_per = %s"
        params.append(id_periodo)
    if id_programa:
        sql += " AND vm.id_prog = %s"
        params.append(id_programa)
    sql += " ORDER BY pa.nombre DESC, e.apellidos"

    filas      = ejecutar_consulta(sql, params, fetch=True) or []
    gran_total = sum(float(f['val_tot']) for f in filas)
    programas  = ejecutar_consulta(
        "SELECT id_programa, nombre FROM programa_academico WHERE activo=1 ORDER BY nombre",
        fetch=True
    ) or []

    return render_template('reportes/listado_estudiantes.html',
                           filas=filas,
                           gran_total=gran_total,
                           periodos=_get_periodos(),
                           programas=programas,
                           filtro_periodo=id_periodo,
                           filtro_programa=id_programa)


# ─── Reporte 2: Ingreso Esperado ─────────────────────────────────────────────

@reportes_bp.route('/ingreso-esperado')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def ingreso_esperado():
    id_periodo = request.args.get('id_periodo', '')

    sql = """
        SELECT p.nombre  AS nom_programa, p.codigo AS cod_programa,
               pa.nombre AS nom_periodo,
               COUNT(vm.id_volante) AS num_volantes,
               SUM(vm.val_tot)      AS total_esperado
        FROM volante_matricula vm
        JOIN programa_academico p  ON vm.id_prog = p.id_programa
        JOIN periodo_academico  pa ON vm.id_per  = pa.id_periodo
        WHERE 1=1
    """
    params = []
    if id_periodo:
        sql += " AND vm.id_per = %s"
        params.append(id_periodo)
    sql += " GROUP BY p.id_programa, pa.id_periodo ORDER BY pa.nombre DESC, p.nombre"

    filas      = ejecutar_consulta(sql, params, fetch=True) or []
    gran_total = sum(float(f['total_esperado']) for f in filas)

    return render_template('reportes/ingreso_esperado.html',
                           filas=filas,
                           gran_total=gran_total,
                           periodos=_get_periodos(),
                           filtro_periodo=id_periodo)


# ─── Reporte 3: Pendientes de Pago ───────────────────────────────────────────

@reportes_bp.route('/pendientes')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def pendientes():
    id_periodo  = request.args.get('id_periodo', '')
    id_programa = request.args.get('id_programa', '')

    sql = """
        SELECT e.nombres, e.apellidos, e.num_doc, e.tipo_doc,
               pa.nombre AS nom_periodo,
               p.nombre  AS nom_programa,
               cc.id_cuenta,
               COALESCE((
                   SELECT SUM(mc.monto)
                   FROM movimiento_cuenta mc
                   JOIN codigo_detalle cd ON mc.id_codigo = cd.id_codigo
                   WHERE mc.id_cuenta = cc.id_cuenta AND cd.grupo = 'COBRO'
               ), 0) AS total_cobros,
               COALESCE((
                   SELECT SUM(pg.monto) FROM pago pg WHERE pg.id_cuenta = cc.id_cuenta
               ), 0) AS total_pagos
        FROM cuenta_corriente  cc
        JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
        LEFT JOIN volante_matricula  vm ON vm.id_estu = cc.id_estudiante
                                       AND vm.id_per  = cc.id_periodo
        LEFT JOIN programa_academico p  ON vm.id_prog  = p.id_programa
        WHERE 1=1
    """
    params = []
    if id_periodo:
        sql += " AND cc.id_periodo = %s"
        params.append(id_periodo)
    if id_programa:
        sql += " AND vm.id_prog = %s"
        params.append(id_programa)
    sql += " HAVING (total_cobros - total_pagos) > 0 ORDER BY pa.nombre DESC, e.apellidos"

    filas = ejecutar_consulta(sql, params, fetch=True) or []
    for f in filas:
        f['saldo'] = float(f['total_cobros']) - float(f['total_pagos'])
    total_pendiente = sum(f['saldo'] for f in filas)
    programas = ejecutar_consulta(
        "SELECT id_programa, nombre FROM programa_academico WHERE activo=1 ORDER BY nombre",
        fetch=True
    ) or []

    return render_template('reportes/pendientes.html',
                           filas=filas,
                           total_pendiente=total_pendiente,
                           periodos=_get_periodos(),
                           programas=programas,
                           filtro_periodo=id_periodo,
                           filtro_programa=id_programa)


# ─── Reporte 4: Ingreso Real ──────────────────────────────────────────────────

@reportes_bp.route('/ingreso-real')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def ingreso_real():
    id_periodo = request.args.get('id_periodo', '')

    sql = """
        SELECT pa.nombre  AS nom_periodo,
               pg.medio,
               COUNT(pg.id_pago) AS num_pagos,
               SUM(pg.monto)     AS total_recibido
        FROM pago pg
        JOIN cuenta_corriente  cc ON pg.id_cuenta  = cc.id_cuenta
        JOIN periodo_academico pa ON cc.id_periodo  = pa.id_periodo
        WHERE 1=1
    """
    params = []
    if id_periodo:
        sql += " AND cc.id_periodo = %s"
        params.append(id_periodo)
    sql += " GROUP BY pa.id_periodo, pg.medio ORDER BY pa.nombre DESC, pg.medio"

    filas      = ejecutar_consulta(sql, params, fetch=True) or []
    gran_total = sum(float(f['total_recibido']) for f in filas)

    return render_template('reportes/ingreso_real.html',
                           filas=filas,
                           gran_total=gran_total,
                           periodos=_get_periodos(),
                           filtro_periodo=id_periodo)


# ─── Reporte 5: Crédito Financiero ───────────────────────────────────────────
# Muestra estudiantes que tienen el código CRED (crédito ICETEX u otra entidad)
# registrado en su cuenta corriente, con el valor del crédito y su totalización.
# Esto representa la cartera o cuentas por cobrar a entidades financieras.

@reportes_bp.route('/creditos')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR')
def creditos():
    id_periodo = request.args.get('id_periodo', '')

    sql = """
        SELECT e.nombres, e.apellidos, e.num_doc,
               pa.nombre                          AS nom_periodo,
               COALESCE(MAX(prog.nombre), '—')    AS nom_programa,
               SUM(mc.monto)                      AS valor_credito,
               cc.id_cuenta
        FROM movimiento_cuenta  mc
        JOIN codigo_detalle     cd  ON mc.id_codigo     = cd.id_codigo
        JOIN cuenta_corriente   cc  ON mc.id_cuenta     = cc.id_cuenta
        JOIN estudiante         e   ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico  pa  ON cc.id_periodo    = pa.id_periodo
        -- Obtener el programa del último volante de la cuenta (puede no existir)
        LEFT JOIN (
            SELECT vm1.id_cuenta, vm1.id_prog
            FROM volante_matricula vm1
            INNER JOIN (
                SELECT id_cuenta, MAX(id_volante) AS max_vol
                FROM volante_matricula
                GROUP BY id_cuenta
            ) vm2 ON vm1.id_cuenta = vm2.id_cuenta
                  AND vm1.id_volante = vm2.max_vol
        ) vm  ON vm.id_cuenta  = cc.id_cuenta
        LEFT JOIN programa_academico prog ON vm.id_prog = prog.id_programa
        WHERE cd.codigo = 'CRED'
          AND cd.grupo  = 'PAGO'
    """
    params = []
    if id_periodo:
        sql += " AND cc.id_periodo = %s"
        params.append(id_periodo)
    sql += """
        GROUP BY e.id_estudiante, cc.id_cuenta,
                 pa.id_periodo, pa.nombre,
                 e.nombres, e.apellidos, e.num_doc
        ORDER BY pa.nombre DESC, e.apellidos
    """

    filas       = ejecutar_consulta(sql, params, fetch=True) or []
    total_valor = sum(float(f['valor_credito']) for f in filas)

    return render_template('reportes/creditos.html',
                           filas=filas,
                           total_valor=total_valor,
                           periodos=_get_periodos(),
                           filtro_periodo=id_periodo)