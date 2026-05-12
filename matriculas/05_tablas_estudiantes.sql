USE matriculas_uni;

-- -----------------------------------------------------
-- 1. Tabla: estudiante (Independiente)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    tipo_doc VARCHAR(5) NOT NULL,
    num_doc VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE
);

-- -----------------------------------------------------
-- 2. Tabla Débil: volante_matricula
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS volante_matricula (
    id_volante INT AUTO_INCREMENT PRIMARY KEY,
    id_estu INT NOT NULL,
    id_per INT NOT NULL,
    id_prog INT NOT NULL,
    semestre INT NOT NULL,
    modalidad ENUM('Global', 'Creditos') NOT NULL,
    val_tot DECIMAL(12, 2) NOT NULL,
    fecha_gen DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_estu) REFERENCES estudiante(id_estudiante),
    FOREIGN KEY (id_per) REFERENCES periodo_academico(id_periodo),
    FOREIGN KEY (id_prog) REFERENCES programa(id_programa),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- -----------------------------------------------------
-- 3. Tabla Débil: volante_asignatura
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS volante_asignatura (
    id_vol_asig INT AUTO_INCREMENT PRIMARY KEY,
    id_volante INT NOT NULL,
    id_asig INT NOT NULL,
    FOREIGN KEY (id_volante) REFERENCES volante_matricula(id_volante) ON DELETE CASCADE,
    FOREIGN KEY (id_asig) REFERENCES asignatura(id_asignatura)
);

-- -----------------------------------------------------
-- 4. Tabla Débil: cuenta_corriente
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS cuenta_corriente (
    id_cuenta INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_periodo INT NOT NULL,
    fecha_cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),
    FOREIGN KEY (id_periodo) REFERENCES periodo_academico(id_periodo),
    UNIQUE (id_estudiante, id_periodo) 
);

-- -----------------------------------------------------
-- 5. Tabla Débil: movimiento_cuenta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS movimiento_cuenta (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_cuenta INT NOT NULL,
    monto DECIMAL(12, 2) NOT NULL,
    descrip VARCHAR(255) NOT NULL,
    id_codigo INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    FOREIGN KEY (id_codigo) REFERENCES codigo_detalle(id_codigo),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- -----------------------------------------------------
-- 6. Tabla Débil: pago
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_cuenta INT NOT NULL,
    medio VARCHAR(50) NOT NULL, 
    ref VARCHAR(100),
    monto DECIMAL(12, 2) NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_cuenta) REFERENCES cuenta_corriente(id_cuenta),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
