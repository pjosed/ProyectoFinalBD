# Sistema de Matrículas — UniCaribe
## IST7111 Bases de Datos · 2026-10 · NRC 2076


## Herramientas utilizadas

| Componente | Tecnología |
|---|---|
| Motor de base de datos | MySQL 8.0+ |
| Backend | Python 3.x + Flask |
| Driver de conexión | mysql-connector-python |
| Frontend | Bootstrap 5 + Jinja2 |
| Autenticación | Werkzeug (scrypt) |

---

## Estructura del proyecto

```
ProyectoFinalBD/
└── matriculas/
    ├── 01_estructura.sql        # Tablas, constraints, vistas y stored procedures
    ├── 02_datos_semilla.sql     # Datos base: roles, programas, estudiantes, usuarios
    ├── 03_vistas_sp.sql         # Vistas y stored procedures (incluido en 01)
    ├── 04_historial_cobros.sql  # Datos históricos de cobros, pagos y créditos
    ├── run.py                   # Punto de entrada de la aplicación
    ├── requirements.txt         # Dependencias Python
    ├── .env                     # Variables de entorno (configurar antes de correr)
    ├── generar_admin.py         # Utilidad para regenerar hash del administrador
    ├── config/
    │   └── database.py          # Gestión de conexión MySQL
    └── app/
        ├── __init__.py          # App factory y registro de blueprints
        ├── auth/                # Login, logout, decoradores de seguridad
        ├── admin/               # Menú dinámico y gestión de usuarios
        ├── configuracion/       # Programas, planes de estudio, reglas, códigos
        ├── estudiantes/         # CRUD de estudiantes
        ├── volantes/            # Generación de cobros individual y masiva
        ├── cuentas/             # Lista y detalle de cuentas corrientes
        ├── cuenta/              # Vista detallada con movimientos y saldo
        ├── pagos/               # Simulación PSE y pago por caja
        ├── descuentos/          # Aplicación de becas y descuentos
        ├── reportes/            # 5 reportes de gestión
        └── volante/             # Vista imprimible del volante de matrícula
```

---

## Instalación paso a paso

### 1. Requisitos previos
- Python 3.10 o superior
- MySQL 8.0 o superior
- MySQL Workbench 

### 2. Clonar o descomprimir el proyecto
```bash
# Si llegó como ZIP, descomprimir y entrar a la carpeta:
cd ProyectoFinalBD/matriculas
```

### 3. Crear entorno virtual e instalar dependencias
```bash
python -m venv venv

# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

### 4. Configurar variables de entorno
Editar el archivo `.env` con las credenciales reales de MySQL:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=tu_contraseña_aqui
DB_NAME=matriculas_uni
SECRET_KEY=cualquier_clave_secreta_larga

MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=correo@gmail.com
MAIL_PASSWORD=contraseña_correo
MAIL_DEFAULT_SENDER=correo@gmail.com
```

> El correo es opcional. Si no se configura, al crear usuarios la contraseña
> temporal aparece en un mensaje flash en pantalla en lugar de enviarse por email.

### 5. Ejecutar los scripts SQL en MySQL Workbench
Correr en este orden exacto:
```
1. 01_estructura.sql    → Crea la base de datos y todas las tablas
2. 02_datos_semilla.sql → Inserta datos base y usuario administrador
3. 03_vistas_sp.sql     → Crea vistas y stored procedures
4. 04_historial_cobros.sql → Inserta datos históricos de prueba
```

### 6. Correr la aplicación
```bash
python run.py
```
Abrir en el navegador: **http://localhost:5000**

---

## Usuarios de prueba

| Usuario | Contraseña | Rol |
|---|---|---|
| `admin` | `Admin2026*` | ADMINISTRADOR |
| `supervisor` | `Supervisor2026*` | SUPERVISOR |
| `asistente` | `Asistente2026*` | ASISTENTE |

---

## Notas técnicas
- Las contraseñas se almacenan con hash `scrypt` (werkzeug)
- El usuario administrador se incluye en `02_datos_semilla.sql` con hash pregenerado. Para regenerar el hash ejecutar `generar_admin.py`
- La conexión a MySQL se gestiona por petición (abre y cierra en cada consulta)