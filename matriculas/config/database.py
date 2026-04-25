"""
config/database.py
Gestiona la conexión a MySQL usando mysql-connector-python.
Usa variables de entorno del archivo .env para las credenciales.
"""

import os
import mysql.connector
from mysql.connector import Error


def get_connection():
    """
    Abre y retorna una conexión a la base de datos MySQL.
    Lanza una excepción si no puede conectar.
    """
    try:
        conexion = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=int(os.getenv("DB_PORT", 3306)),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            database=os.getenv("DB_NAME", "matriculas_uni"),
            charset="utf8mb4",
            use_unicode=True,
        )
        return conexion
    except Error as e:
        raise ConnectionError(f"Error al conectar con MySQL: {e}")


def ejecutar_consulta(sql, params=None, fetch=False):
    """
    Ejecuta una consulta SQL.

    Args:
        sql    : Cadena SQL con placeholders %s
        params : Tupla o lista de parámetros (opcional)
        fetch  : True → retorna todas las filas; False → retorna lastrowid

    Returns:
        Lista de dicts si fetch=True, o el id del último registro insertado.
    """
    conexion = None
    cursor = None
    try:
        conexion = get_connection()
        cursor = conexion.cursor(dictionary=True)
        cursor.execute(sql, params or ())

        if fetch:
            return cursor.fetchall()
        else:
            conexion.commit()
            return cursor.lastrowid

    except Error as e:
        if conexion:
            conexion.rollback()
        raise RuntimeError(f"Error ejecutando consulta: {e}")
    finally:
        if cursor:
            cursor.close()
        if conexion and conexion.is_connected():
            conexion.close()


def ejecutar_uno(sql, params=None):
    """
    Ejecuta una consulta y retorna solo la primera fila como dict.
    Útil para buscar un registro específico por ID o campo único.
    """
    resultados = ejecutar_consulta(sql, params, fetch=True)
    return resultados[0] if resultados else None
