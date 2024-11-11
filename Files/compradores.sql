-- Compradores
--
-- DETALLES: se quitaron los campos
-- fk_menu_favorito y fk_local_favorito

CREATE TABLE IF NOT EXISTS compradores (
    fk_usuario INT PRIMARY KEY,
    direccion VARCHAR(128) NOT NULL,
    detalle_direccion VARCHAR(255),
    ciudad VARCHAR(32) NOT NULL,
    provincia VARCHAR(32) NOT NULL,
    codigo_postal CHAR(8) NOT NULL,
    pais VARCHAR(32) NOT NULL,
    nro_tarjeta CHAR(16),
    cvv CHAR(3),
    vencimiento DATE,
    saldo DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (fk_usuario) REFERENCES usuarios(id)
);

-- TRIGGER before_insert_compradores
-- Previene que se inserte un comprador 
-- si el usuario no es un comprador

DELIMITER //

CREATE TRIGGER before_insert_compradores
BEFORE INSERT ON compradores
FOR EACH ROW
BEGIN
    DECLARE tipo_usuario INT;
    -- Obtener el tipo de usuario del fk_usuario
    SELECT fk_tipo INTO tipo_usuario FROM usuarios WHERE id = NEW.fk_usuario;
    -- Verificar si el tipo de usuario es 'comrpador' (asumiendo que el id del tipo 'comprador' es 3)
    IF tipo_usuario != 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no es un comprador';
    END IF;
END //

DELIMITER ;

INSERT INTO compradores (fk_usuario, direccion, ciudad, provincia, codigo_postal, pais, detalle_direccion, nro_tarjeta, cvv, vencimiento)
VALUES 
(3, 'Calle Falsa 123', 'Ciudad de Springfield', 'Springfield', '1234', 'EEUU', 'Casa de Homero', '1234567890123456', '123', '2023-12-31');