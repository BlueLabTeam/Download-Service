
-- Crear usuario administrador (Contraseña: adminadmin)
DELETE FROM Usuario WHERE cedula='12345678';
DELETE FROM Nucleo_Familiar WHERE id_nucleo=1;
DELETE FROM Rol WHERE id_rol=1;

INSERT INTO Rol (id_rol, nombre_rol) VALUES (1, 'Administrador');
INSERT INTO Nucleo_Familiar (id_nucleo, direccion, nombre_nucleo) 
VALUES (1, 'Administración Central', 'Núcleo Administrador');

INSERT INTO Usuario (
    nombre_completo, cedula, contrasena, direccion, estado, 
    fecha_nacimiento, email, id_nucleo, id_rol
) VALUES (
    'Administrador del Sistema', '12345678',
    '$2y$10$SvXY9vqFav9wCncj9qh05.Qn247a/XqVpxbwUaCQWND//wSwdV07q',
    'Oficina Principal', 'aceptado', '1990-01-01',
    'admin@gestcoop.com', 1, 1
);

-- Insertar algunas viviendas de ejemplo
INSERT INTO Viviendas (numero_vivienda, direccion, id_tipo, estado, metros_cuadrados) VALUES
('A-101', 'Bloque A, Planta Baja', 1, 'disponible', 35.50),
('A-102', 'Bloque A, Planta Baja', 2, 'disponible', 55.00),
('A-201', 'Bloque A, Primer Piso', 2, 'disponible', 55.00),
('A-202', 'Bloque A, Primer Piso', 3, 'disponible', 75.00),
('B-101', 'Bloque B, Planta Baja', 2, 'disponible', 58.00),
('B-102', 'Bloque B, Planta Baja', 3, 'disponible', 78.00),
('B-201', 'Bloque B, Primer Piso', 1, 'disponible', 38.00),
('B-202', 'Bloque B, Primer Piso', 2, 'disponible', 56.00);