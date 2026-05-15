from flask import render_template, request, redirect, url_for, flash, session, jsonify
from datetime import datetime
from app.volantes import volantes_bp
from app.auth.routes import login_requerido, rol_requerido
from config.database import ejecutar_consulta, ejecutar_uno, get_connection
from mysql.connector import Error


# ─── Lista de volantes ──────────────────────────────────────────────────────

@volantes_bp.route('/')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'SUPERVISOR', 'ASISTENTE')
def lista_volantes():
    id_periodo  = request.args.get('id_periodo', '')
    id_programa = request.args.get('id_programa', '')

    sql = """
        SELECT vm.id_volante, vm.fecha_gen, vm.val_tot, vm.semestre, vm.modalidad,
               e.nombres, e.apellidos, e.num_doc,
               pa.nombre AS nom_periodo,
               p.nombre  AS nom_programa, p.codigo AS cod_programa
        FROM volante_matricula vm
        JOIN cuenta_corriente  cc ON vm.id_cuenta = cc.id_cuenta
        JOIN estudiante        e  ON cc.id_estudiante = e.id_estudiante
        JOIN periodo_academico pa ON cc.id_periodo    = pa.id_periodo
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
    sql += " ORDER BY cc.fecha_cre DESC"

    volantes  = ejecutar_consulta(sql, params, fetch=True)
    periodos  = ejecutar_consulta(
        "SELECT id_periodo, nombre FROM periodo_academico ORDER BY nombre DESC",
        fetch=True
    )
    programas = ejecutar_consulta(
        "SELECT id_programa, nombre, codigo FROM programa_academico WHERE activo=1 ORDER BY nombre",
        fetch=True
    )
    return render_template('volantes/lista.html',
                           volantes=volantes or [],
                           periodos=periodos or [],
                           programas=programas or [],
                           filtro_periodo=id_periodo,
                           filtro_programa=id_programa)


# ─── AJAX: semestres disponibles para un programa ───────────────────────────

@volantes_bp.route('/ajax/semestres', methods=['POST'])
@login_requerido
def ajax_semestres():
    id_programa = request.form.get('id_programa')
    if not id_programa:
        return jsonify([])
    semestres = ejecutar_consulta(
        "SELECT DISTINCT semestre FROM plan_estudio WHERE id_programa=%s ORDER BY semestre",
        (id_programa,), fetch=True
    )
    return jsonify([s['semestre'] for s in (semestres or [])])


# ─── AJAX: asignaturas de un semestre/programa ──────────────────────────────

@volantes_bp.route('/ajax/asignaturas', methods=['POST'])
@login_requerido
def ajax_asignaturas():
    id_programa = request.form.get('id_programa')
    semestre    = request.form.get('semestre')
    if not id_programa or not semestre:
        return jsonify([])
    asignaturas = ejecutar_consulta(
        """SELECT a.id_asignatura, a.codigo, a.nombre, pe.creditos
           FROM plan_estudio pe
           JOIN asignatura   a ON pe.id_asignatura = a.id_asignatura
           WHERE pe.id_programa=%s AND pe.semestre=%s
           ORDER BY a.nombre""",
        (id_programa, semestre), fetch=True
    )
    return jsonify(asignaturas or [])


# ─── AJAX: calcular valor según regla de cobro ──────────────────────────────

@volantes_bp.route('/ajax/valor', methods=['POST'])
@login_requerido
def ajax_valor():
    id_periodo  = request.form.get('id_periodo')
    id_programa = request.form.get('id_programa')
    ids_asig    = request.form.getlist('asignaturas[]')

    regla = ejecutar_uno(
        """SELECT modalidad_cobro, valor_global, valor_credito
           FROM regla_cobro
           WHERE id_periodo=%s AND id_programa=%s""",
        (id_periodo, id_programa)
    )
    if not regla:
        return jsonify({'error': 'Sin regla de cobro para este periodo y programa'}), 404

    if regla['modalidad_cobro'] == 'GLOBAL':
        return jsonify({
            'modalidad': 'GLOBAL',
            'valor': float(regla['valor_global']),
            'creditos': 0
        })
    else:
        vpc = float(regla['valor_credito'])
        if not ids_asig:
            return jsonify({'modalidad': 'POR_CREDITOS', 'valor': 0, 'creditos': 0, 'valor_credito': vpc})
        placeholders = ','.join(['%s'] * len(ids_asig))
        tot = ejecutar_uno(
            f"SELECT SUM(pe.creditos) AS total FROM plan_estudio pe WHERE pe.id_asignatura IN ({placeholders})",
            ids_asig
        )
        creditos = int(tot['total'] or 0) if tot else 0
        valor    = creditos * vpc
        return jsonify({'modalidad': 'POR_CREDITOS', 'valor': valor, 'creditos': creditos, 'valor_credito': vpc})


# ─── AJAX: buscar estudiante ─────────────────────────────────────────────────

@volantes_bp.route('/ajax/buscar_estudiante')
@login_requerido
def ajax_buscar_estudiante():
    q = request.args.get('q', '').strip()
    if len(q) < 2:
        return jsonify([])
    like = f'%{q}%'
    estudiantes = ejecutar_consulta(
        """SELECT id_estudiante, num_doc, nombres, apellidos
           FROM estudiante
           WHERE activo=1 AND (num_doc LIKE %s OR nombres LIKE %s OR apellidos LIKE %s)
           ORDER BY apellidos LIMIT 15""",
        (like, like, like), fetch=True
    )
    return jsonify(estudiantes or [])


# ─── Nuevo volante ───────────────────────────────────────────────────────────

@volantes_bp.route('/nuevo', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def volante_nuevo():
    periodos  = ejecutar_consulta(
        "SELECT id_periodo, nombre FROM periodo_academico WHERE activo=1 ORDER BY nombre DESC",
        fetch=True
    )
    programas = ejecutar_consulta(
        "SELECT id_programa, nombre, codigo FROM programa_academico WHERE activo=1 ORDER BY nombre",
        fetch=True
    )
    cod_cobro = ejecutar_uno(
        "SELECT id_codigo FROM codigo_detalle WHERE codigo='PMAT' AND grupo='COBRO'"
    )

    if request.method == 'POST':
        id_estu  = request.form.get('id_estudiante', '').strip()
        id_per   = request.form.get('id_periodo', '').strip()
        id_prog  = request.form.get('id_programa', '').strip()
        semestre = request.form.get('semestre', '').strip()
        ids_asig = request.form.getlist('asignaturas')

        if not all([id_estu, id_per, id_prog, semestre]):
            flash('Todos los campos obligatorios deben completarse.', 'warning')
            return render_template('volantes/nuevo.html',
                                   periodos=periodos or [], programas=programas or [])

        regla = ejecutar_uno(
            """SELECT modalidad_cobro, valor_global, valor_credito
               FROM regla_cobro
               WHERE id_periodo=%s AND id_programa=%s""",
            (id_per, id_prog)
        )
        if not regla:
            flash('No existe regla de cobro activa para este periodo y programa.', 'danger')
            return render_template('volantes/nuevo.html',
                                   periodos=periodos or [], programas=programas or [])

        if regla['modalidad_cobro'] == 'GLOBAL':
            val_tot   = regla['valor_global']
            modalidad = 'Global'
        else:
            if not ids_asig:
                flash('Debes seleccionar al menos una asignatura.', 'warning')
                return render_template('volantes/nuevo.html',
                                       periodos=periodos or [], programas=programas or [])
            placeholders = ','.join(['%s'] * len(ids_asig))
            tot = ejecutar_uno(
                f"SELECT SUM(pe.creditos) AS total FROM plan_estudio pe WHERE pe.id_asignatura IN ({placeholders})",
                ids_asig
            )
            creditos  = int(tot['total'] or 0) if tot else 0
            val_tot   = creditos * float(regla['valor_credito'])
            modalidad = 'Creditos'

        id_usuario = session['usuario_id']
        id_codigo  = cod_cobro['id_codigo'] if cod_cobro else None
        ahora      = datetime.now()

        conexion = None
        cursor   = None
        try:
            conexion = get_connection()
            conexion.autocommit = False
            cursor = conexion.cursor(dictionary=True)

            # 1. volante_matricula
            cursor.execute(
                """INSERT INTO volante_matricula
                   (id_estu, id_per, id_prog, semestre, modalidad, val_tot, fecha_gen, id_usuario)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
                (id_estu, id_per, id_prog, semestre, modalidad, val_tot, ahora, id_usuario)
            )
            id_volante = cursor.lastrowid

            # 2. volante_asignatura (solo POR_CREDITOS)
            if modalidad == 'Creditos':
                for id_a in ids_asig:
                    cursor.execute(
                        "INSERT INTO volante_asignatura (id_volante, id_asig) VALUES (%s,%s)",
                        (id_volante, id_a)
                    )

            # 3. cuenta_corriente (crea si no existe, luego obtiene id)
            cursor.execute(
                "INSERT IGNORE INTO cuenta_corriente (id_estudiante, id_periodo) VALUES (%s,%s)",
                (id_estu, id_per)
            )
            cursor.execute(
                "SELECT id_cuenta FROM cuenta_corriente WHERE id_estudiante=%s AND id_periodo=%s",
                (id_estu, id_per)
            )
            id_cuenta = cursor.fetchone()['id_cuenta']

            # 4. Actualizar id_cuenta en volante_matricula
            cursor.execute(
                "UPDATE volante_matricula SET id_cuenta = %s WHERE id_volante = %s",
                (id_cuenta, id_volante)
            )

            # 5. movimiento_cuenta
            cursor.execute(
                """INSERT INTO movimiento_cuenta
                   (id_cuenta, monto, descrip, id_codigo, fecha, id_usuario)
                   VALUES (%s,%s,%s,%s,%s,%s)""",
                (id_cuenta, val_tot,
                 f"Matrícula semestre {semestre}",
                 id_codigo, ahora, id_usuario)
            )

            conexion.commit()
            flash('Volante generado correctamente.', 'success')
            return redirect(url_for('volantes.detalle_volante', id_volante=id_volante))

        except Error as e:
            if conexion:
                conexion.rollback()
            flash(f'Error al generar el volante: {e}', 'danger')
            return render_template('volantes/nuevo.html',
                                   periodos=periodos or [], programas=programas or [])
        finally:
            if cursor:
                cursor.close()
            if conexion and conexion.is_connected():
                conexion.close()

    return render_template('volantes/nuevo.html',
                           periodos=periodos or [], programas=programas or [])


# ─── Detalle de volante ──────────────────────────────────────────────────────

@volantes_bp.route('/<int:id_volante>/detalle')
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def detalle_volante(id_volante):
    volante = ejecutar_uno(
        """SELECT vm.*, e.nombres, e.apellidos, e.num_doc, e.tipo_doc,
                  pa.nombre AS nom_periodo,
                  p.nombre  AS nom_programa, p.codigo AS cod_programa
           FROM volante_matricula vm
           JOIN estudiante        e  ON vm.id_estu = e.id_estudiante
           JOIN periodo_academico pa ON vm.id_per  = pa.id_periodo
           JOIN programa_academico p  ON vm.id_prog = p.id_programa
           WHERE vm.id_volante = %s""",
        (id_volante,)
    )
    if not volante:
        flash('Volante no encontrado.', 'danger')
        return redirect(url_for('volantes.lista_volantes'))

    asignaturas = ejecutar_consulta(
        """SELECT a.codigo, a.nombre, pe.creditos
           FROM volante_asignatura va
           JOIN asignatura          a ON va.id_asig = a.id_asignatura
           JOIN plan_estudio        pe ON pe.id_asignatura = a.id_asignatura
                                      AND pe.id_programa = %s
           WHERE va.id_volante = %s""",
        (volante['id_prog'], id_volante), fetch=True
    )

    cuenta = ejecutar_uno(
        "SELECT id_cuenta FROM cuenta_corriente WHERE id_estudiante=%s AND id_periodo=%s",
        (volante['id_estu'], volante['id_per'])
    )
    movimientos = []
    if cuenta:
        movimientos = ejecutar_consulta(
            """SELECT mc.monto, mc.descrip, mc.fecha, cd.codigo AS cod_concepto, cd.grupo
               FROM movimiento_cuenta mc
               JOIN codigo_detalle    cd ON mc.id_codigo = cd.id_codigo
               WHERE mc.id_cuenta = %s ORDER BY mc.fecha DESC""",
            (cuenta['id_cuenta'],), fetch=True
        )

    return render_template('volantes/detalle.html',
                           volante=volante,
                           asignaturas=asignaturas or [],
                           movimientos=movimientos or [])


# ─── AJAX: estudiantes sin volante para periodo+programa ─────────────────────

@volantes_bp.route('/ajax/estudiantes', methods=['POST'])
@login_requerido
def ajax_estudiantes():
    id_periodo  = request.form.get('id_periodo')
    id_programa = request.form.get('id_programa')
    if not id_periodo or not id_programa:
        return jsonify([])
    estudiantes = ejecutar_consulta(
        """SELECT e.id_estudiante, e.num_doc, e.nombres, e.apellidos
           FROM estudiante e
           WHERE e.activo = 1
             AND e.id_estudiante NOT IN (
                 SELECT vm.id_estu FROM volante_matricula vm
                 WHERE vm.id_per = %s AND vm.id_prog = %s
             )
           ORDER BY e.apellidos""",
        (id_periodo, id_programa), fetch=True
    )
    return jsonify(estudiantes or [])


# ─── Cobro masivo ────────────────────────────────────────────────────────────

@volantes_bp.route('/masivo', methods=['GET', 'POST'])
@login_requerido
@rol_requerido('ADMINISTRADOR', 'ASISTENTE')
def volante_masivo():
    periodos  = ejecutar_consulta(
        "SELECT id_periodo, nombre FROM periodo_academico WHERE activo=1 ORDER BY nombre DESC",
        fetch=True
    )
    programas = ejecutar_consulta(
        "SELECT id_programa, nombre, codigo FROM programa_academico WHERE activo=1 ORDER BY nombre",
        fetch=True
    )
    cod_cobro = ejecutar_uno(
        "SELECT id_codigo FROM codigo_detalle WHERE codigo='PMAT' AND grupo='COBRO'"
    )

    if request.method == 'POST':
        id_per          = request.form.get('id_periodo', '').strip()
        id_prog         = request.form.get('id_programa', '').strip()
        semestre        = request.form.get('semestre', '').strip()
        ids_asig        = request.form.getlist('asignaturas')
        ids_estudiantes = request.form.getlist('ids_estudiantes')

        if not all([id_per, id_prog, semestre]):
            flash('Periodo, programa y semestre son obligatorios.', 'warning')
            return render_template('volantes/masivo.html',
                                   periodos=periodos or [], programas=programas or [])
        if not ids_estudiantes:
            flash('Debes seleccionar al menos un estudiante.', 'warning')
            return render_template('volantes/masivo.html',
                                   periodos=periodos or [], programas=programas or [])

        regla = ejecutar_uno(
            """SELECT modalidad_cobro, valor_global, valor_credito
               FROM regla_cobro WHERE id_periodo=%s AND id_programa=%s""",
            (id_per, id_prog)
        )
        if not regla:
            flash('No existe regla de cobro activa para este periodo y programa.', 'danger')
            return render_template('volantes/masivo.html',
                                   periodos=periodos or [], programas=programas or [])

        if regla['modalidad_cobro'] == 'GLOBAL':
            val_tot   = regla['valor_global']
            modalidad = 'Global'
        else:
            if not ids_asig:
                flash('Debes seleccionar al menos una asignatura.', 'warning')
                return render_template('volantes/masivo.html',
                                       periodos=periodos or [], programas=programas or [])
            placeholders = ','.join(['%s'] * len(ids_asig))
            tot = ejecutar_uno(
                f"SELECT SUM(pe.creditos) AS total FROM plan_estudio pe WHERE pe.id_asignatura IN ({placeholders})",
                ids_asig
            )
            creditos  = int(tot['total'] or 0) if tot else 0
            val_tot   = creditos * float(regla['valor_credito'])
            modalidad = 'Creditos'

        id_usuario = session['usuario_id']
        id_codigo  = cod_cobro['id_codigo'] if cod_cobro else None
        ahora      = datetime.now()
        generados  = 0
        conexion   = None
        cursor     = None
        try:
            conexion = get_connection()
            conexion.autocommit = False
            cursor = conexion.cursor(dictionary=True)

            for id_estu in ids_estudiantes:
                cursor.execute(
                    """INSERT INTO volante_matricula
                       (id_estu, id_per, id_prog, semestre, modalidad, val_tot, fecha_gen, id_usuario)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
                    (id_estu, id_per, id_prog, semestre, modalidad, val_tot, ahora, id_usuario)
                )
                id_volante = cursor.lastrowid

                if modalidad == 'Creditos':
                    for id_a in ids_asig:
                        cursor.execute(
                            "INSERT INTO volante_asignatura (id_volante, id_asig) VALUES (%s,%s)",
                            (id_volante, id_a)
                        )

                cursor.execute(
                    "INSERT IGNORE INTO cuenta_corriente (id_estudiante, id_periodo) VALUES (%s,%s)",
                    (id_estu, id_per)
                )
                cursor.execute(
                    "SELECT id_cuenta FROM cuenta_corriente WHERE id_estudiante=%s AND id_periodo=%s",
                    (id_estu, id_per)
                )
                id_cuenta = cursor.fetchone()['id_cuenta']

                # Actualizar id_cuenta en volante_matricula
                cursor.execute(
                    "UPDATE volante_matricula SET id_cuenta = %s WHERE id_volante = %s",
                    (id_cuenta, id_volante)
                )

                cursor.execute(
                    """INSERT INTO movimiento_cuenta
                       (id_cuenta, monto, descrip, id_codigo, fecha, id_usuario)
                       VALUES (%s,%s,%s,%s,%s,%s)""",
                    (id_cuenta, val_tot, f"Matrícula semestre {semestre}", id_codigo, ahora, id_usuario)
                )
                generados += 1

            conexion.commit()
            flash(f'Se generaron {generados} volante(s) correctamente.', 'success')
            return redirect(url_for('volantes.lista_volantes'))

        except Error as e:
            if conexion:
                conexion.rollback()
            flash(f'Error al generar los volantes: {e}', 'danger')
            return render_template('volantes/masivo.html',
                                   periodos=periodos or [], programas=programas or [])
        finally:
            if cursor:
                cursor.close()
            if conexion and conexion.is_connected():
                conexion.close()

    return render_template('volantes/masivo.html',
                           periodos=periodos or [], programas=programas or [])