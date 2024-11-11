-- 
-- TABLA vendedores
--
-- DETALLES: Se añadieron los campos cuit y cbu,
-- y se quito el campo comisiones

CREATE TABLE IF NOT EXISTS vendedores (
    fk_usuario INT PRIMARY KEY,
    cuit CHAR(11) NOT NULL UNIQUE,
    cbu CHAR(22) NOT NULL UNIQUE,
    ganancias DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (fk_usuario) REFERENCES usuarios(id)
);

-- TRIGGER before_insert_vendedores
-- Previene que se inserte un vendedor 
-- si el usuario no es un vendedor

DELIMITER //

CREATE TRIGGER before_insert_vendedores
BEFORE INSERT ON vendedores
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

-- Crea el vendedor creado en el archivo usuarios.sql
INSERT INTO vendedores (fk_usuario, cuit, cbu) 
VALUES (2, '20323232323', '1234567890123456789012');