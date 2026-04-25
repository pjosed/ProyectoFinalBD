# Sistema de Matrículas — UniCaribe
## IST7111 Bases de Datos · 2026-10 · NRC 2076

---

## Estructura del Proyecto

```
matriculas/
├── run.py                      # Punto de entrada
├── requirements.txt            # Dependencias Python
├── .env.example                # Plantilla de variables de entorno
├── .env                        # ← TÚ LO CREAS (no subir a Git)
├── config/
│   ├── __init__.py
│   └── database.py             # Conexión a MySQL
└── app/
    ├── __init__.py             # App factory
    ├── auth/                   # Módulo login/sesiones (José Peña)
    │   ├── __init__.py
    │   └── routes.py
    ├── admin/                  # Menú dinámico y gestión de usuarios
    │   ├── __init__.py
    │   └── routes.py
    └── templates/
        ├── shared/
        │   └── base.html       # Template base con navbar + sidebar
        ├── auth/
        │   └── login.html
        └── admin/
            ├── menu.html
            ├── usuarios_lista.html
            └── roles_lista.html
```

---

## Instalación y Configuración

### 1. Crear entorno virtual e instalar dependencias
```bash
python -m venv venv
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Configurar variables de entorno
```bash
# Copia el archivo de ejemplo
cp .env.example .env

# Edita .env con tus datos reales:
# - Credenciales de MySQL
# - SECRET_KEY (genera una aleatoria)
# - Datos del correo para envío de contraseñas
```

### 3. Correr la aplicación
```bash
python run.py
```
Abre tu navegador en: http://localhost:5000

---

## Para los compañeros — Integrar tu módulo

1. Crea tu carpeta: `app/tu_modulo/`
2. Agrega `__init__.py` con tu Blueprint
3. Registra el Blueprint en `app/__init__.py`:
   ```python
   from app.tu_modulo import tu_bp
   app.register_blueprint(tu_bp, url_prefix="/tu_ruta")
   ```
4. Usa el decorador `@login_requerido` para proteger rutas
5. Usa `@rol_requerido("SUPERVISOR")` para rutas con restricción de rol

### Ejemplo de ruta protegida:
```python
from app.auth.routes import login_requerido, rol_requerido

@tu_bp.route("/programas")
@rol_requerido("ADMINISTRADOR", "SUPERVISOR")
def lista_programas():
    datos = ejecutar_consulta("SELECT * FROM programa_academico", fetch=True)
    return render_template("programas/lista.html", programas=datos)
```

### Usar la conexión a BD:
```python
from config.database import ejecutar_consulta, ejecutar_uno

# Consultar
datos = ejecutar_consulta("SELECT * FROM estudiante WHERE activo = 1", fetch=True)

# Un registro
est = ejecutar_uno("SELECT * FROM estudiante WHERE id_estudiante = %s", (id,))

# Insertar/Actualizar (retorna lastrowid)
nuevo_id = ejecutar_consulta(
    "INSERT INTO estudiante (nombre, apellido) VALUES (%s, %s)",
    ("Juan", "García")
)
```

---

## Variables de Sesión Disponibles

| Variable | Contenido |
|---|---|
| `session['usuario_id']` | ID del usuario autenticado |
| `session['nombre_usuario']` | Login del usuario |
| `session['rol']` | `ADMINISTRADOR`, `SUPERVISOR` o `ASISTENTE` |
| `session['nombre']` | Nombre completo |

En templates Jinja2: `{{ session.rol }}`, `{{ session.nombre }}`
