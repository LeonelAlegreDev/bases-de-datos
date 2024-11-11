-- TABLA tipos_vehiculos
--
-- DETALLES: la tabla tipos_vehiculos no se encuentra
-- en el diagrama 

CREATE TABLE IF NOT EXISTS tipos_vehiculos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tipos_vehiculos (nombre) 
VALUES ('auto'), ('motocicleta'), ('camioneta'), ('bicicleta');

-- TABLA repartidores
--
-- DETALLES: se añadieron los campos 
-- tipo_vehiculo y cbu

CREATE TABLE repartidores (
    fk_usuario INT PRIMARY KEY,
    tipo_vehiculo VARCHAR(50) NOT NULL,
    patente CHAR(7),
    cbu CHAR(22),
    FOREIGN KEY (fk_usuario) REFERENCES usuarios(id),
    FOREIGN KEY (tipo_vehiculo) REFERENCES tipos_vehiculos(nombre)
);


-- TRIGGER before_insert_repartidores
-- Previene que se inserte un repartidor si el 
-- usuario no es un repartidor.
-- Previene que matricula sea NULL si el 
-- tipo de vehiculo no es bicicleta
DELIMITER //

CREATE TRIGGER before_insert_repartidores
BEFORE INSERT ON repartidores
FOR EACH ROW
BEGIN
    DECLARE tipo_usuario INT;
    -- Obtener el tipo de usuario del fk_usuario
    SELECT fk_tipo INTO tipo_usuario FROM usuarios WHERE id = NEW.fk_usuario;
    -- Verificar si el tipo de usuario es 'repartidor' (asumiendo que el id del tipo 'repartidor' es 4)
    IF tipo_usuario != 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no es un repartidor';
    END IF;

    -- Verificar si el tipo de vehiculo es 'bicicleta'
    IF NEW.tipo_vehiculo != 'bicicleta' AND NEW.patente IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La patente no puede ser NULL a menos que el tipo de vehiculo sea bicicleta';
    END IF;
END //


-- TRIGGER before_update_repartidores
-- Previene que matricula sea NULL si el
-- tipo de vehiculo no es bicicleta al 
-- actualizar un repartidor
CREATE TRIGGER before_update_repartidores
BEFORE UPDATE ON repartidores
FOR EACH ROW
BEGIN
    -- Verificar si el tipo de vehiculo es 'bicicleta'
    IF NEW.tipo_vehiculo != 'bicicleta' AND NEW.patente IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La patente no puede ser NULL a menos que el tipo de vehiculo sea bicicleta';
    END IF;
END //

DELIMITER ;

-- Inserta dos repartidores creados en el archivo usuarios.sql
INSERT INTO repartidores (fk_usuario, tipo_vehiculo, patente, cbu)
VALUES 
(4, 'motocicleta', 'ABC123', '1234567890123456789012'),
(5, 'bicicleta', NULL, '1234567890123456789012');