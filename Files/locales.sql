-- TABLA locales
--
-- DETALLES: se añadieron los campos fk_usuario,
-- direccion, provincia, ciudad, pais, tel_local y
-- codigo_postal

CREATE TABLE locales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_usuario INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    provincia VARCHAR(64) NOT NULL,
    ciudad VARCHAR(64) NOT NULL,
    pais VARCHAR(64) NOT NULL,
    tel_local VARCHAR(32) NOT NULL,
    codigo_postal CHAR(8),
    calificacion DECIMAL(2, 1) DEFAULT 0,
    FOREIGN KEY (fk_usuario) REFERENCES usuarios(id)
);

DELIMITER //

-- TRIGGER before_insert_locales    
-- Previene que se inserte un local si el
-- usuario no es un vendedor
CREATE TRIGGER before_insert_locales
BEFORE INSERT ON locales
FOR EACH ROW
BEGIN
    DECLARE tipo_usuario INT;
    -- Obtener el tipo de usuario del fk_usuario
    SELECT fk_tipo INTO tipo_usuario FROM usuarios WHERE id = NEW.fk_usuario;
    -- Verificar si el tipo de usuario es 'vendedor' (asumiendo que el id del tipo 'vendedor' es 2)
    IF tipo_usuario != 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no es un vendedor';
    END IF;
END //

-- TRIGGER before_update_locales
-- Previene que se actualice un local si el
-- usuario no es un vendedor
CREATE TRIGGER before_update_locales
BEFORE UPDATE ON locales
FOR EACH ROW
BEGIN
    DECLARE tipo_usuario INT;
    -- Obtener el tipo de usuario del fk_usuario
    SELECT fk_tipo INTO tipo_usuario FROM usuarios WHERE id = NEW.fk_usuario;
    -- Verificar si el tipo de usuario es 'vendedor' (asumiendo que el id del tipo 'vendedor' es 2)
    IF tipo_usuario != 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no es un vendedor';
    END IF;
END //

DELIMITER ;

INSERT INTO locales (fk_usuario, nombre, direccion, provincia, ciudad, pais, tel_local, codigo_postal)
VALUES
(2, 'Local 1', 'Calle 123', 'Buenos Aires', 'CABA', 'Argentina', '1234567890', '1234'),
(2, 'Local 2', 'Calle 456', 'Buenos Aires', 'CABA', 'Argentina', '0987654321', '4321');