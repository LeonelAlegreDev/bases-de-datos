--
-- TABLA tipos_usuario
--
CREATE TABLE tipos_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(32) NOT NULL UNIQUE
);

INSERT INTO tipos_usuario (nombre) 
VALUES ('admin'), ('vendedor'), ('comprador'), ('repartidor');

--
-- TABLA usuarios
--
CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(32) NOT NULL,
    apellido VARCHAR(32) NOT NULL,
    email VARCHAR(64) NOT NULL,
    password VARCHAR(255) NOT NULL,
    dni CHAR(8) NOT NULL,
    tel VARCHAR(32) NOT NULL,
    fk_tipo INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    FOREIGN KEY (fk_tipo) REFERENCES tipos_usuario(id)
);

-- Añade el campo not_archived a la tabla usuarios
-- Indica si el usuario fue eliminado o no
ALTER TABLE usuarios
ADD not_archived BOOLEAN
GENERATED ALWAYS AS (IF(deleted_at IS NULL, 1, NULL)) VIRTUAL;

-- Añade un constraint para que el email sea único 
-- entre los usuarios no archivados
ALTER TABLE usuarios
ADD CONSTRAINT UNIQUE (email, not_archived);

-- Añade un constraint para que el dni sea único
-- entre los usuarios no archivados
ALTER TABLE usuarios
ADD CONSTRAINT UNIQUE (dni, not_archived);

INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES 
('admin', 'admin1', 'admin@email.com', '123456', '00000000', '+54 11 12345678', 1),
('vendedor', 'vendedor1', 'vendedor1@email.com', '123456', '00000001', '+54 11 12345678', 2),
('comprador', 'comprador1', 'comprador1@email.com', '123456', '00000002', '+54 11 12345678', 3);

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