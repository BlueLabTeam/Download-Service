CREATE DATABASE IF NOT EXISTS proyecto2025 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE proyecto2025;
-- ==========================================
-- USUARIOS Y ROLES
-- ==========================================
CREATE TABLE IF NOT EXISTS Rol (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(50) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Nucleo_Familiar (
    id_nucleo INT PRIMARY KEY AUTO_INCREMENT,
    direccion VARCHAR(100),
    nombre_nucleo VARCHAR(50)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre_completo VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    direccion VARCHAR(100),
    estado ENUM(
        'pendiente',
        'enviado',
        'aceptado',
        'rechazado'
    ) NOT NULL DEFAULT 'pendiente',
    fecha_ingreso DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_nacimiento DATE,
    email VARCHAR(100) UNIQUE,
    id_nucleo INT,
    id_rol INT,
    FOREIGN KEY (id_nucleo) REFERENCES Nucleo_Familiar (id_nucleo),
    FOREIGN KEY (id_rol) REFERENCES Rol (id_rol)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Telefonos (
    id_telefono INT PRIMARY KEY AUTO_INCREMENT,
    entidad_tipo ENUM('usuario', 'proveedor') NOT NULL,
    entidad_id INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    tipo ENUM('movil', 'fijo', 'trabajo') DEFAULT 'movil',
    INDEX idx_entidad (entidad_tipo, entidad_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- PROVEEDORES Y MATERIALES
-- ==========================================
CREATE TABLE IF NOT EXISTS Proveedores (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proveedor VARCHAR(100),
    direccion VARCHAR(100),
    descripcion TEXT,
    email VARCHAR(100)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Materiales (
    id_material INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    caracteristicas TEXT,
    cantidad_disponible INT NOT NULL DEFAULT 0
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Proveedor_Material (
    id_proveedor INT,
    id_material INT,
    PRIMARY KEY (id_proveedor, id_material),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores (id_proveedor),
    FOREIGN KEY (id_material) REFERENCES Materiales (id_material)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- HERRAMIENTAS
-- ==========================================
CREATE TABLE IF NOT EXISTS Herramientas (
    id_herramienta INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    estado VARCHAR(20)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Herramienta_Responsable (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    id_herramienta INT,
    fecha DATE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario),
    FOREIGN KEY (id_herramienta) REFERENCES Herramientas (id_herramienta)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- TIPOS DE VIVIENDA
-- ==========================================
CREATE TABLE IF NOT EXISTS Tipo_Vivienda (
    id_tipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    habitaciones INT NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT IGNORE INTO
    Tipo_Vivienda (
        nombre,
        descripcion,
        habitaciones
    )
VALUES (
        'Mono-ambiente',
        'Vivienda de 1 habitacion con cocina y banio integrado',
        1
    ),
    (
        '2 Dormitorios',
        'Vivienda de 2 dormitorios, sala, cocina y banio',
        2
    ),
    (
        '3 Dormitorios',
        'Vivienda de 3 dormitorios, sala, cocina y 2 banios',
        3
    );
-- ==========================================
-- ETAPAS DE CONSTRUCCION
-- ==========================================
CREATE TABLE IF NOT EXISTS Etapas (
    id_etapa INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    fechas VARCHAR(100),
    estado VARCHAR(20)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- VIVIENDAS
-- ==========================================
CREATE TABLE IF NOT EXISTS Viviendas (
    id_vivienda INT PRIMARY KEY AUTO_INCREMENT,
    numero_vivienda VARCHAR(20) UNIQUE NOT NULL,
    direccion VARCHAR(200),
    id_tipo INT NOT NULL,
    id_etapa INT,
    estado ENUM(
        'disponible',
        'ocupada',
        'mantenimiento'
    ) DEFAULT 'disponible',
    fecha_construccion DATE,
    metros_cuadrados DECIMAL(10, 2),
    observaciones TEXT,
    FOREIGN KEY (id_tipo) REFERENCES Tipo_Vivienda (id_tipo),
    FOREIGN KEY (id_etapa) REFERENCES Etapas (id_etapa)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- ASIGNACIONES DE VIVIENDA
-- ==========================================
CREATE TABLE IF NOT EXISTS Asignacion_Vivienda (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_vivienda INT NOT NULL,
    id_usuario INT,
    id_nucleo INT,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    activa BOOLEAN DEFAULT TRUE,
    observaciones TEXT,
    FOREIGN KEY (id_vivienda) REFERENCES Viviendas (id_vivienda),
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_nucleo) REFERENCES Nucleo_Familiar (id_nucleo) ON DELETE CASCADE,
    CONSTRAINT chk_asignacion CHECK (
        (
            id_usuario IS NOT NULL
            AND id_nucleo IS NULL
        )
        OR (
            id_usuario IS NULL
            AND id_nucleo IS NOT NULL
        )
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- NOTIFICACIONES
-- ==========================================
CREATE TABLE IF NOT EXISTS notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo ENUM(
        'info',
        'importante',
        'urgente',
        'exito'
    ) DEFAULT 'info',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha_creacion)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS usuario_notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_notificacion INT NOT NULL,
    leida TINYINT(1) DEFAULT 0,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_lectura DATETIME NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_notificacion) REFERENCES notificaciones (id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_notification (id_usuario, id_notificacion),
    INDEX idx_usuario_leida (id_usuario, leida),
    INDEX idx_notificacion (id_notificacion)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- TAREAS
-- ==========================================
CREATE TABLE IF NOT EXISTS Tareas (
    id_tarea INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    prioridad ENUM('baja', 'media', 'alta') DEFAULT 'media',
    estado ENUM(
        'pendiente',
        'en_progreso',
        'completada',
        'cancelada'
    ) DEFAULT 'pendiente',
    tipo_asignacion ENUM('usuario', 'nucleo') DEFAULT 'usuario',
    id_creador INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_creador) REFERENCES Usuario (id_usuario),
    INDEX idx_estado (estado),
    INDEX idx_fechas (fecha_inicio, fecha_fin)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Tarea_Usuario (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_tarea INT NOT NULL,
    id_usuario INT NOT NULL,
    progreso INT DEFAULT 0,
    estado_usuario ENUM(
        'pendiente',
        'en_progreso',
        'completada'
    ) DEFAULT 'pendiente',
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_completada DATETIME NULL,
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    UNIQUE KEY unique_tarea_usuario (id_tarea, id_usuario),
    INDEX idx_usuario (id_usuario),
    INDEX idx_estado (estado_usuario)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Tarea_Nucleo (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_tarea INT NOT NULL,
    id_nucleo INT NOT NULL,
    progreso INT DEFAULT 0,
    estado_nucleo ENUM(
        'pendiente',
        'en_progreso',
        'completada'
    ) DEFAULT 'pendiente',
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_completada DATETIME NULL,
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea) ON DELETE CASCADE,
    FOREIGN KEY (id_nucleo) REFERENCES Nucleo_Familiar (id_nucleo) ON DELETE CASCADE,
    UNIQUE KEY unique_tarea_nucleo (id_tarea, id_nucleo),
    INDEX idx_nucleo (id_nucleo),
    INDEX idx_estado (estado_nucleo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Tarea_Avances (
    id_avance INT PRIMARY KEY AUTO_INCREMENT,
    id_tarea INT NOT NULL,
    id_usuario INT NOT NULL,
    comentario TEXT NOT NULL,
    progreso_reportado INT DEFAULT 0,
    archivo VARCHAR(200) NULL,
    fecha_avance DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario),
    INDEX idx_tarea (id_tarea),
    INDEX idx_fecha (fecha_avance)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Tarea_Material (
    id_tarea INT NOT NULL,
    id_material INT NOT NULL,
    cantidad_requerida INT NOT NULL DEFAULT 1,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_tarea, id_material),
    FOREIGN KEY (id_tarea) REFERENCES Tareas (id_tarea) ON DELETE CASCADE,
    FOREIGN KEY (id_material) REFERENCES Materiales (id_material) ON DELETE CASCADE,
    INDEX idx_tarea (id_tarea),
    INDEX idx_material (id_material)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- SOLICITUDES DE MATERIALES
-- ==========================================
CREATE TABLE IF NOT EXISTS Solicitud_Material (
    id_solicitud INT PRIMARY KEY AUTO_INCREMENT,
    id_material INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    id_usuario INT NOT NULL,
    descripcion TEXT,
    estado ENUM(
        'pendiente',
        'aprobada',
        'rechazada',
        'entregada'
    ) DEFAULT 'pendiente',
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta DATETIME NULL,
    FOREIGN KEY (id_material) REFERENCES Materiales (id_material),
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_solicitud)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- REGISTRO DE HORAS
-- ==========================================
CREATE TABLE IF NOT EXISTS Registro_Horas (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME NOT NULL,
    hora_salida TIME NULL,
    total_horas DECIMAL(5, 2) DEFAULT 0.00,
    descripcion TEXT,
    estado ENUM(
        'pendiente',
        'aprobado',
        'rechazado'
    ) DEFAULT 'pendiente',
    observaciones TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    INDEX idx_usuario_fecha (id_usuario, fecha),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha),
    CONSTRAINT chk_entrada_salida CHECK (
        hora_salida IS NULL
        OR hora_salida > hora_entrada
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- TABLA PARA PRIMER PAGO DE REGISTRO
-- ==========================================
CREATE TABLE IF NOT EXISTS pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    comprobante_archivo VARCHAR(255) NOT NULL,
    monto DECIMAL(10, 2) DEFAULT 5000.00 COMMENT 'Monto del primer pago',
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_validacion ENUM(
        'pendiente',
        'aprobado',
        'rechazado'
    ) DEFAULT 'pendiente',
    fecha_validacion TIMESTAMP NULL,
    observaciones TEXT,
    tipo_pago ENUM(
        'primer_pago',
        'cuota_mensual'
    ) DEFAULT 'primer_pago',
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    INDEX idx_usuario (id_usuario),
    INDEX idx_estado (estado_validacion),
    INDEX idx_fecha (fecha_pago)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- SISTEMA DE CUOTAS MENSUALES
-- ==========================================
CREATE TABLE IF NOT EXISTS Config_Cuotas (
    id_config INT PRIMARY KEY AUTO_INCREMENT,
    id_tipo INT NOT NULL,
    monto_mensual DECIMAL(10, 2) NOT NULL,
    fecha_vigencia_desde DATE NOT NULL,
    fecha_vigencia_hasta DATE NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_tipo) REFERENCES Tipo_Vivienda (id_tipo),
    INDEX idx_tipo_activo (id_tipo, activo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT IGNORE INTO
    Config_Cuotas (
        id_tipo,
        monto_mensual,
        fecha_vigencia_desde,
        activo
    )
VALUES (
        1,
        5000.00,
        '2025-01-01',
        TRUE
    ),
    (
        2,
        7500.00,
        '2025-01-01',
        TRUE
    ),
    (
        3,
        10000.00,
        '2025-01-01',
        TRUE
    );

CREATE TABLE IF NOT EXISTS Cuotas_Mensuales (
    id_cuota INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_vivienda INT NULL COMMENT 'NULL = Usuario sin vivienda asignada',
    mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    monto_pendiente_anterior DECIMAL(10, 2) DEFAULT 0.00,
    estado ENUM(
        'pendiente',
        'pagada',
        'vencida',
        'exonerada'
    ) DEFAULT 'pendiente',
    fecha_vencimiento DATE NOT NULL,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    horas_requeridas DECIMAL(5, 2) DEFAULT 84.00,
    horas_cumplidas DECIMAL(5, 2) DEFAULT 0.00,
    horas_validadas BOOLEAN DEFAULT FALSE,
    pendiente_asignacion TINYINT(1) DEFAULT 0 COMMENT 'Indica si esta esperando asignacion de vivienda',
    observaciones TEXT,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_vivienda) REFERENCES Viviendas (id_vivienda),
    UNIQUE KEY unique_usuario_mes_anio (id_usuario, mes, anio),
    INDEX idx_usuario_estado (id_usuario, estado),
    INDEX idx_fecha_vencimiento (fecha_vencimiento),
    INDEX idx_pendiente_asignacion (pendiente_asignacion)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Pagos_Cuotas (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_cuota INT NOT NULL,
    id_usuario INT NOT NULL,
    monto_pagado DECIMAL(10, 2) NOT NULL,
    metodo_pago ENUM('transferencia') DEFAULT 'transferencia',
    comprobante_archivo VARCHAR(200) NOT NULL,
    numero_comprobante VARCHAR(50),
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado_validacion ENUM(
        'pendiente',
        'aprobado',
        'rechazado'
    ) DEFAULT 'pendiente',
    observaciones_validacion TEXT,
    fecha_validacion DATETIME NULL,
    incluye_deuda_horas TINYINT(1) DEFAULT 0,
    monto_deuda_horas DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (id_cuota) REFERENCES Cuotas_Mensuales (id_cuota) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario),
    INDEX idx_cuota (id_cuota),
    INDEX idx_estado (estado_validacion),
    INDEX idx_fecha_pago (fecha_pago)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- JUSTIFICACIONES DE HORAS
-- ==========================================
CREATE TABLE IF NOT EXISTS Justificaciones_Horas (
    id_justificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INT NOT NULL,
    horas_justificadas DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    motivo TEXT NOT NULL,
    archivo_adjunto VARCHAR(500) NULL,
    monto_descontado DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    id_admin INT NOT NULL,
    fecha_justificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('aprobada', 'rechazada') DEFAULT 'aprobada',
    observaciones TEXT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_admin) REFERENCES Usuario (id_usuario),
    INDEX idx_usuario_periodo (id_usuario, mes, anio),
    INDEX idx_fecha (fecha_justificacion DESC)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- SOLICITUDES GENERALES
-- ==========================================
CREATE TABLE IF NOT EXISTS Solicitudes (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo_solicitud ENUM(
        'horas',
        'pago',
        'vivienda',
        'general',
        'otro'
    ) DEFAULT 'general',
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    archivo_adjunto VARCHAR(500) NULL,
    estado ENUM(
        'pendiente',
        'en_revision',
        'resuelta',
        'rechazada'
    ) DEFAULT 'pendiente',
    prioridad ENUM('baja', 'media', 'alta') DEFAULT 'media',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    INDEX idx_usuario (id_usuario),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_creacion DESC)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Respuestas_Solicitudes (
    id_respuesta INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud INT NOT NULL,
    id_usuario INT NOT NULL,
    es_admin BOOLEAN DEFAULT FALSE,
    mensaje TEXT NOT NULL,
    archivo_adjunto VARCHAR(500) NULL,
    fecha_respuesta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_solicitud) REFERENCES Solicitudes (id_solicitud) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    INDEX idx_solicitud (id_solicitud),
    INDEX idx_fecha (fecha_respuesta DESC)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- SOLICITUDES PARA UNIRSE A NUCLEOS
-- ==========================================
CREATE TABLE IF NOT EXISTS Solicitudes_Nucleo (
    id_solicitud_nucleo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_nucleo INT NOT NULL,
    mensaje TEXT NULL,
    estado ENUM(
        'pendiente',
        'aprobada',
        'rechazada'
    ) DEFAULT 'pendiente',
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta DATETIME NULL,
    id_admin_respuesta INT NULL,
    observaciones_admin TEXT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_nucleo) REFERENCES Nucleo_Familiar (id_nucleo) ON DELETE CASCADE,
    FOREIGN KEY (id_admin_respuesta) REFERENCES Usuario (id_usuario),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_solicitud DESC),
    INDEX idx_nucleo (id_nucleo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ==========================================
-- VISTAS
-- ==========================================
CREATE OR REPLACE VIEW Vista_Cuotas_Con_Justificaciones AS
SELECT
    cm.id_cuota,
    cm.id_usuario,
    u.nombre_completo,
    u.email,
    cm.id_vivienda,
    CASE
        WHEN cm.id_vivienda IS NULL THEN 'SIN ASIGNAR'
        ELSE v.numero_vivienda
    END as numero_vivienda,
    CASE
        WHEN cm.id_vivienda IS NULL THEN 'Sin vivienda'
        ELSE tv.nombre
    END as tipo_vivienda,
    COALESCE(tv.habitaciones, 0) as habitaciones,
    cm.mes,
    cm.anio,
    cm.monto as monto_base,
    cm.monto_pendiente_anterior,
    cm.horas_requeridas,
    cm.horas_cumplidas,
    cm.pendiente_asignacion,
    GREATEST(
        0,
        cm.horas_requeridas - cm.horas_cumplidas
    ) as horas_faltantes_base,
    COALESCE(SUM(jh.horas_justificadas), 0) as horas_justificadas,
    COALESCE(SUM(jh.monto_descontado), 0) as monto_justificado,
    GREATEST(
        0,
        cm.horas_requeridas - cm.horas_cumplidas - COALESCE(SUM(jh.horas_justificadas), 0)
    ) as horas_faltantes_real,
    GREATEST(
        0,
        cm.horas_requeridas - cm.horas_cumplidas - COALESCE(SUM(jh.horas_justificadas), 0)
    ) * 160 as deuda_horas_pesos,
    (
        cm.monto + cm.monto_pendiente_anterior + (
            GREATEST(
                0,
                cm.horas_requeridas - cm.horas_cumplidas - COALESCE(SUM(jh.horas_justificadas), 0)
            ) * 160
        )
    ) as monto_total,
    cm.estado,
    cm.fecha_vencimiento,
    cm.horas_validadas,
    cm.observaciones,
    pc.id_pago,
    pc.monto_pagado,
    pc.fecha_pago,
    pc.comprobante_archivo,
    pc.estado_validacion as estado_pago,
    pc.observaciones_validacion,
    CASE
        WHEN cm.pendiente_asignacion = 1 THEN 'sin_vivienda'
        WHEN cm.fecha_vencimiento < CURDATE()
        AND cm.estado = 'pendiente' THEN 'vencida'
        ELSE cm.estado
    END as estado_actual
FROM
    Cuotas_Mensuales cm
    INNER JOIN Usuario u ON cm.id_usuario = u.id_usuario
    LEFT JOIN Viviendas v ON cm.id_vivienda = v.id_vivienda
    LEFT JOIN Tipo_Vivienda tv ON v.id_tipo = tv.id_tipo
    LEFT JOIN Justificaciones_Horas jh ON cm.id_usuario = jh.id_usuario
    AND cm.mes = jh.mes
    AND cm.anio = jh.anio
    AND jh.estado = 'aprobada'
    LEFT JOIN Pagos_Cuotas pc ON cm.id_cuota = pc.id_cuota
    AND pc.estado_validacion != 'rechazado'
GROUP BY
    cm.id_cuota;

CREATE OR REPLACE VIEW Vista_Solicitudes_Completa AS
SELECT
    s.id_solicitud,
    s.id_usuario,
    u.nombre_completo,
    u.email,
    u.cedula,
    s.tipo_solicitud,
    s.asunto,
    s.descripcion,
    s.archivo_adjunto,
    s.estado,
    s.prioridad,
    s.fecha_creacion,
    s.fecha_actualizacion,
    COUNT(rs.id_respuesta) as total_respuestas,
    MAX(rs.fecha_respuesta) as ultima_respuesta
FROM
    Solicitudes s
    INNER JOIN Usuario u ON s.id_usuario = u.id_usuario
    LEFT JOIN Respuestas_Solicitudes rs ON s.id_solicitud = rs.id_solicitud
GROUP BY
    s.id_solicitud
ORDER BY s.fecha_creacion DESC;

CREATE OR REPLACE VIEW Vista_Solicitudes_Nucleo AS
SELECT
    sn.id_solicitud_nucleo,
    sn.id_usuario,
    u.nombre_completo,
    u.email,
    u.cedula,
    sn.id_nucleo,
    nf.nombre_nucleo,
    nf.direccion as direccion_nucleo,
    COUNT(DISTINCT u2.id_usuario) as miembros_actuales,
    sn.mensaje,
    sn.estado,
    sn.fecha_solicitud,
    sn.fecha_respuesta,
    sn.observaciones_admin,
    admin.nombre_completo as admin_respuesta
FROM
    Solicitudes_Nucleo sn
    INNER JOIN Usuario u ON sn.id_usuario = u.id_usuario
    INNER JOIN Nucleo_Familiar nf ON sn.id_nucleo = nf.id_nucleo
    LEFT JOIN Usuario u2 ON u2.id_nucleo = nf.id_nucleo
    LEFT JOIN Usuario admin ON sn.id_admin_respuesta = admin.id_usuario
GROUP BY
    sn.id_solicitud_nucleo
ORDER BY sn.fecha_solicitud DESC;

CREATE OR REPLACE VIEW Vista_Informe_Mensual AS
SELECT
    YEAR(rh.fecha) as anio,
    MONTH(rh.fecha) as mes,
    SUM(rh.total_horas) as total_horas_trabajadas,
    COUNT(DISTINCT rh.id_usuario) as total_trabajadores,
    COALESCE(SUM(pc.monto_pagado), 0) as total_ingresado,
    COUNT(DISTINCT pc.id_pago) as total_pagos
FROM
    Registro_Horas rh
    LEFT JOIN Cuotas_Mensuales cm ON YEAR(rh.fecha) = cm.anio
    AND MONTH(rh.fecha) = cm.mes
    AND rh.id_usuario = cm.id_usuario
    LEFT JOIN Pagos_Cuotas pc ON cm.id_cuota = pc.id_cuota
    AND pc.estado_validacion = 'aprobado'
WHERE
    rh.estado = 'aprobado'
GROUP BY
    anio,
    mes
ORDER BY anio DESC, mes DESC;
-- ==========================================
-- TRIGGERS
-- ==========================================
-- ==========================================
-- TRIGGER 1: Actualizar horas de cuota al aprobar horas de trabajo
-- ==========================================
DROP TRIGGER IF EXISTS actualizar_horas_cuota;

DELIMITER $$

CREATE TRIGGER actualizar_horas_cuota
AFTER UPDATE ON Registro_Horas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'aprobado' AND OLD.estado != 'aprobado' THEN
        UPDATE Cuotas_Mensuales
        SET horas_cumplidas = (
            SELECT COALESCE(SUM(total_horas), 0)
            FROM Registro_Horas
            WHERE id_usuario = NEW.id_usuario
            AND MONTH(fecha) = MONTH(NEW.fecha)
            AND YEAR(fecha) = YEAR(NEW.fecha)
            AND estado = 'aprobado'
        )
        WHERE id_usuario = NEW.id_usuario
        AND mes = MONTH(NEW.fecha)
        AND anio = YEAR(NEW.fecha);
    END IF;
END $$

DELIMITER ;

-- ==========================================
-- TRIGGER 2: Actualizar cuota al asignar vivienda (Usuario o Núcleo)
-- ==========================================
DROP TRIGGER IF EXISTS actualizar_cuota_al_asignar_vivienda;

DELIMITER $$

CREATE TRIGGER actualizar_cuota_al_asignar_vivienda
AFTER INSERT ON Asignacion_Vivienda
FOR EACH ROW
BEGIN
    DECLARE v_id_tipo INT;
    DECLARE v_monto_vivienda DECIMAL(10, 2);

    IF NEW.activa = 1 THEN
        SELECT v.id_tipo, cc.monto_mensual
        INTO v_id_tipo, v_monto_vivienda
        FROM Viviendas v
        LEFT JOIN Config_Cuotas cc
            ON cc.id_tipo = v.id_tipo AND cc.activo = 1
        WHERE v.id_vivienda = NEW.id_vivienda
        LIMIT 1;

        -- Asignación a USUARIO
        IF NEW.id_usuario IS NOT NULL THEN
            UPDATE Cuotas_Mensuales
            SET id_vivienda = NEW.id_vivienda,
                monto = COALESCE(v_monto_vivienda, 0),
                pendiente_asignacion = 0,
                observaciones = CONCAT(
                    COALESCE(observaciones, ''),
                    IF(observaciones IS NOT NULL AND observaciones != '', '\n', ''),
                    'Vivienda asignada el ', DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i')
                )
            WHERE id_usuario = NEW.id_usuario
                AND pendiente_asignacion = 1
                AND (
                    (anio = YEAR(CURDATE()) AND mes >= MONTH(CURDATE()))
                    OR anio > YEAR(CURDATE())
                );

            INSERT INTO notificaciones (titulo, mensaje, tipo)
            VALUES (
                'Vivienda Asignada',
                'Se te ha asignado una vivienda. Tus cuotas han sido actualizadas con el monto correspondiente.',
                'exito'
            );
            INSERT INTO usuario_notificaciones (id_usuario, id_notificacion)
            VALUES (NEW.id_usuario, LAST_INSERT_ID());
        END IF;

        -- Asignación a NUCLEO
        IF NEW.id_nucleo IS NOT NULL THEN
            UPDATE Cuotas_Mensuales cm
            INNER JOIN Usuario u ON cm.id_usuario = u.id_usuario
            SET cm.id_vivienda = NEW.id_vivienda,
                cm.monto = COALESCE(v_monto_vivienda, 0),
                cm.pendiente_asignacion = 0,
                cm.observaciones = CONCAT(
                    COALESCE(cm.observaciones, ''),
                    IF(cm.observaciones IS NOT NULL AND cm.observaciones != '', '\n', ''),
                    'Vivienda asignada a núcleo el ', DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i')
                )
            WHERE u.id_nucleo = NEW.id_nucleo
                AND cm.pendiente_asignacion = 1
                AND (
                    (cm.anio = YEAR(CURDATE()) AND cm.mes >= MONTH(CURDATE()))
                    OR cm.anio > YEAR(CURDATE())
                );

            INSERT INTO notificaciones (titulo, mensaje, tipo)
            VALUES (
                'Vivienda Asignada a tu Núcleo',
                'Se ha asignado una vivienda a tu núcleo familiar. Tus cuotas han sido actualizadas.',
                'exito'
            );

            INSERT INTO usuario_notificaciones (id_usuario, id_notificacion)
            SELECT u.id_usuario, LAST_INSERT_ID()
            FROM Usuario u
            WHERE u.id_nucleo = NEW.id_nucleo;
        END IF;
    END IF;
END $$

DELIMITER ;

-- ==========================================
-- TRIGGER 3: Generar cuota automáticamente cuando un usuario es aceptado
-- ==========================================
DROP TRIGGER IF EXISTS generar_cuota_usuario_nuevo;

DELIMITER $$

CREATE TRIGGER generar_cuota_usuario_nuevo
AFTER UPDATE ON Usuario
FOR EACH ROW
BEGIN
    DECLARE v_mes_actual INT;
    DECLARE v_anio_actual INT;
    DECLARE v_id_vivienda INT;
    DECLARE v_id_tipo INT;
    DECLARE v_monto_base DECIMAL(10, 2);
    DECLARE v_fecha_vencimiento DATE;
    DECLARE v_pendiente_asignacion TINYINT(1);

    IF NEW.estado = 'aceptado' AND OLD.estado != 'aceptado' THEN
        SET v_mes_actual = MONTH(CURDATE());
        SET v_anio_actual = YEAR(CURDATE());
        SET v_fecha_vencimiento = LAST_DAY(CURDATE());

        IF NOT EXISTS (
            SELECT 1
            FROM Cuotas_Mensuales
            WHERE id_usuario = NEW.id_usuario
                AND mes = v_mes_actual
                AND anio = v_anio_actual
        ) THEN
            SELECT av.id_vivienda, v.id_tipo
            INTO v_id_vivienda, v_id_tipo
            FROM Asignacion_Vivienda av
                INNER JOIN Viviendas v ON av.id_vivienda = v.id_vivienda
            WHERE (
                av.id_usuario = NEW.id_usuario
                OR av.id_nucleo = NEW.id_nucleo
            )
                AND av.activa = 1
            LIMIT 1;

            IF v_id_vivienda IS NOT NULL THEN
                SELECT monto_mensual
                INTO v_monto_base
                FROM Config_Cuotas
                WHERE id_tipo = v_id_tipo AND activo = 1
                LIMIT 1;
                SET v_monto_base = COALESCE(v_monto_base, 0);
                SET v_pendiente_asignacion = 0;
            ELSE
                SET v_monto_base = 0;
                SET v_pendiente_asignacion = 1;
            END IF;

            INSERT INTO Cuotas_Mensuales (
                id_usuario,
                id_vivienda,
                mes,
                anio,
                monto,
                monto_pendiente_anterior,
                fecha_vencimiento,
                horas_requeridas,
                estado,
                pendiente_asignacion,
                observaciones
            ) VALUES (
                NEW.id_usuario,
                v_id_vivienda,
                v_mes_actual,
                v_anio_actual,
                v_monto_base,
                0,
                v_fecha_vencimiento,
                84.00,
                'pendiente',
                v_pendiente_asignacion,
                IF(
                    v_pendiente_asignacion = 1,
                    CONCAT(
                        'Usuario aceptado el ', DATE_FORMAT(NOW(), '%d/%m/%Y'),
                        '. Pendiente asignación de vivienda.'
                    ),
                    CONCAT(
                        'Usuario aceptado el ', DATE_FORMAT(NOW(), '%d/%m/%Y')
                    )
                )
            );

            INSERT INTO notificaciones (titulo, mensaje, tipo)
            VALUES (
                'Bienvenido al Sistema de Cuotas',
                CONCAT(
                    'Tu cuota de ', MONTHNAME(CURDATE()),
                    ' ha sido generada. ',
                    IF(
                        v_pendiente_asignacion = 1,
                        'Estás en espera de asignación de vivienda.',
                        CONCAT(
                            'Monto: ', CAST(v_monto_base AS CHAR),
                            '. Horas requeridas: 84'
                        )
                    )
                ),
                'info'
            );

            INSERT INTO usuario_notificaciones (id_usuario, id_notificacion)
            VALUES (NEW.id_usuario, LAST_INSERT_ID());
        END IF;
    END IF;
END $$

DELIMITER ;
-- ==========================================
-- PROCEDIMIENTOS ALMACENADOS
-- ==========================================
DROP PROCEDURE IF EXISTS GenerarCuotasMensuales;

DELIMITER $$

CREATE PROCEDURE GenerarCuotasMensuales(IN p_mes INT, IN p_anio INT) BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE v_id_usuario INT;
DECLARE v_id_vivienda INT;
DECLARE v_id_tipo INT;
DECLARE v_monto_base DECIMAL(10, 2);
DECLARE v_deuda_anterior DECIMAL(10, 2);
DECLARE v_fecha_vencimiento DATE;
DECLARE v_pendiente_asignacion TINYINT(1);
DECLARE v_cuotas_generadas INT DEFAULT 0;
DECLARE v_cuotas_sin_vivienda INT DEFAULT 0;
DECLARE v_cuotas_existentes INT DEFAULT 0;
DECLARE cur_usuarios CURSOR FOR
SELECT DISTINCT u.id_usuario
FROM Usuario u
WHERE u.estado = 'aceptado'
ORDER BY u.id_usuario;
DECLARE CONTINUE HANDLER FOR NOT FOUND
SET done = TRUE;
SET v_fecha_vencimiento = LAST_DAY(CONCAT(p_anio, '-', LPAD(p_mes, 2, '0'), '-01'));
OPEN cur_usuarios;
read_loop: LOOP FETCH cur_usuarios INTO v_id_usuario;
IF done THEN LEAVE read_loop;
END IF;
IF EXISTS (
    SELECT 1
    FROM Cuotas_Mensuales
    WHERE id_usuario = v_id_usuario
        AND mes = p_mes
        AND anio = p_anio
) THEN
SET v_cuotas_existentes = v_cuotas_existentes + 1;
ITERATE read_loop;
END IF;
SET v_id_vivienda = NULL;
SET v_id_tipo = NULL;
SET v_monto_base = 0;
SET v_pendiente_asignacion = 0;
SELECT av.id_vivienda,
    v.id_tipo INTO v_id_vivienda,
    v_id_tipo
FROM Asignacion_Vivienda av
    INNER JOIN Viviendas v ON av.id_vivienda = v.id_vivienda
    INNER JOIN Usuario u ON (
        av.id_usuario = u.id_usuario
        OR av.id_nucleo = u.id_nucleo
    )
WHERE u.id_usuario = v_id_usuario
    AND av.activa = 1
LIMIT 1;
IF v_id_vivienda IS NOT NULL THEN
SELECT monto_mensual INTO v_monto_base
FROM Config_Cuotas
WHERE id_tipo = v_id_tipo
    AND activo = 1
LIMIT 1;
SET v_monto_base = COALESCE(v_monto_base, 0);
ELSE
SET v_monto_base = 0;
SET v_pendiente_asignacion = 1;
SET v_cuotas_sin_vivienda = v_cuotas_sin_vivienda + 1;
END IF;
SELECT COALESCE(SUM(monto + monto_pendiente_anterior), 0) INTO v_deuda_anterior
FROM Cuotas_Mensuales
WHERE id_usuario = v_id_usuario
    AND estado != 'pagada'
    AND (
        anio < p_anio
        OR (
            anio = p_anio
            AND mes < p_mes
        )
    );
INSERT INTO Cuotas_Mensuales (
        id_usuario,
        id_vivienda,
        mes,
        anio,
        monto,
        monto_pendiente_anterior,
        fecha_vencimiento,
        horas_requeridas,
        estado,
        pendiente_asignacion,
        observaciones
    )
VALUES (
        v_id_usuario,
        v_id_vivienda,
        p_mes,
        p_anio,
        v_monto_base,
        v_deuda_anterior,
        v_fecha_vencimiento,
        84.00,
        'pendiente',
        v_pendiente_asignacion,
        IF(
            v_pendiente_asignacion = 1,
            'Pendiente: Asignar vivienda',
            NULL
        )
    );
SET v_cuotas_generadas = v_cuotas_generadas + 1;
END LOOP;
CLOSE cur_usuarios;
IF v_cuotas_sin_vivienda > 0 THEN
INSERT INTO notificaciones (titulo, mensaje, tipo)
VALUES (
        'Usuarios sin Vivienda',
        CONCAT(
            'Hay ',
            v_cuotas_sin_vivienda,
            ' usuario(s) sin vivienda. Cuotas pendientes de asignacion.'
        ),
        'urgente'
    );
INSERT INTO usuario_notificaciones (id_usuario, id_notificacion)
SELECT u.id_usuario,
    LAST_INSERT_ID()
FROM Usuario u
WHERE u.id_rol = 1;
END IF;
INSERT INTO notificaciones (titulo, mensaje, tipo)
VALUES (
        'Cuotas Generadas',
        CONCAT(
            'Mes ',
            p_mes,
            '/',
            p_anio,
            ': ',
            v_cuotas_generadas,
            ' nuevas | ',
            v_cuotas_existentes,
            ' existian | ',
            v_cuotas_sin_vivienda,
            ' sin vivienda'
        ),
        'exito'
    );
INSERT INTO usuario_notificaciones (id_usuario, id_notificacion)
SELECT u.id_usuario,
    LAST_INSERT_ID()
FROM Usuario u
WHERE u.id_rol = 1;
END $$

DELIMITER ;
-- ==========================================
-- FUNCIONES
-- ==========================================
DROP FUNCTION IF EXISTS CalcularDeudaUsuario;

DELIMITER $$

CREATE FUNCTION CalcularDeudaUsuario(p_id_usuario INT) RETURNS DECIMAL(10, 2) DETERMINISTIC READS SQL DATA BEGIN
DECLARE v_deuda DECIMAL(10, 2);
SELECT COALESCE(SUM(monto + monto_pendiente_anterior), 0) INTO v_deuda
FROM Cuotas_Mensuales
WHERE id_usuario = p_id_usuario
    AND estado != 'pagada';
RETURN v_deuda;
END $$

DELIMITER ;
-- ==========================================
-- EVENTOS AUTOMATICOS
-- ==========================================
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS GenerarCuotasAutomatico;

DELIMITER $$

CREATE EVENT GenerarCuotasAutomatico ON SCHEDULE EVERY 1 MONTH STARTS CASE
    WHEN DAY(CURDATE()) = 1 THEN CONCAT(
        DATE_FORMAT(
            DATE_ADD(LAST_DAY(CURDATE()), INTERVAL 1 DAY),
            '%Y-%m-01'
        ),
        ' 00:01:00'
    )
    ELSE CONCAT(
        DATE_FORMAT(
            DATE_ADD(LAST_DAY(CURDATE()), INTERVAL 1 DAY),
            '%Y-%m-01'
        ),
        ' 00:01:00'
    )
END

DO BEGIN
DECLARE v_mes INT;
DECLARE v_anio INT;
SET v_mes = MONTH(CURDATE());
SET v_anio = YEAR(CURDATE());
CALL GenerarCuotasMensuales(v_mes, v_anio);
END $$

DELIMITER ;
-- ==========================================
-- INDICES ADICIONALES
-- ==========================================
CREATE INDEX idx_vivienda_tipo ON Viviendas (id_tipo);

CREATE INDEX idx_vivienda_estado ON Viviendas (estado);

CREATE INDEX idx_asignacion_activa ON Asignacion_Vivienda (activa);

CREATE INDEX idx_cuota_mes_anio ON Cuotas_Mensuales (mes, anio);

CREATE INDEX idx_pago_fecha ON Pagos_Cuotas (fecha_pago);

CREATE INDEX idx_telefono_busqueda ON Telefonos (telefono);
-- ==========================================
-- GENERAR CUOTAS DEL MES ACTUAL
-- ==========================================
CALL GenerarCuotasMensuales ( MONTH(CURDATE()), YEAR(CURDATE()) );
-- ==========================================
-- MENSAJE FINAL
-- ==========================================
SELECT 'Base de datos proyecto2025 inicializada correctamente' as status;