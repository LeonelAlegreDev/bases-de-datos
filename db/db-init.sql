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
('comprador', 'comprador1', 'comprador1@email.com', '123456', '00000002', '+54 11 12345678', 3),
('repartidor', 'repartidor1', 'repartidor1@email.com', '123456', '00000003', '+54 11 12345678', 4),
('repartidor', 'repartidor2', 'repartidor2@email.com', '123456', '00000004', '+54 11 12345678', 4);

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

--
-- TABLA tipos_vehiculos
--

CREATE TABLE IF NOT EXISTS tipos_vehiculos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tipos_vehiculos (nombre) 
VALUES ('auto'), ('motocicleta'), ('camioneta'), ('bicicleta');

--
-- TABLA repartidores
--
CREATE TABLE repartidores (
    fk_usuario INT PRIMARY KEY,
    tipo_vehiculo VARCHAR(50) NOT NULL,
    patente CHAR(7),
    cbu CHAR(22),
    FOREIGN KEY (fk_usuario) REFERENCES usuarios(id),
    FOREIGN KEY (tipo_vehiculo) REFERENCES tipos_vehiculos(nombre)
);

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

INSERT INTO repartidores (fk_usuario, tipo_vehiculo, patente, cbu)
VALUES 
(4, 'motocicleta', 'ABC123', '1234567890123456789012'),
(5, 'bicicleta', NULL, '1234567890123456789012');

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

--
-- TABLA menus
-- 
-- CAMPOS: fk_local, nombre,

CREATE TABLE menus (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_local INT NOT NULL,
    nombre VARCHAR(128) NOT NULL,
    FOREIGN KEY (fk_local) REFERENCES locales(id)
);

INSERT INTO menus (fk_local, nombre)
VALUES
(1, 'Menu 1'), (1, 'Menu 2'),
(2, 'Menu 1'), (2, 'Menu 2');

-- 
-- TABLA tipos_productos
--
-- DETALLES: tipos_productos no aparece 
-- en el archivo de diseño

CREATE TABLE tipos_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tipos_productos (nombre)
VALUES ('comida'), ('bebida'), ('postre');

--
-- TABLA productos
--
-- DETALLES: se añadieron los campos, precio, stock y
-- tipo_producto
-- nombre_ingredientes se cambio a descripcion

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_menu INT NOT NULL,
    tipo_producto VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    FOREIGN KEY (fk_menu) REFERENCES menus(id),
    CONSTRAINT fk_tipo_producto FOREIGN KEY (tipo_producto) REFERENCES tipos_productos(nombre)
);

INSERT INTO productos (fk_menu, tipo_producto, descripcion, precio, stock)
VALUES 
(1, 'comida', 'Hamburguesa', 200.00, 10),
(1, 'comida', 'Pizza', 300.00, 5),
(1, 'bebida', 'Coca Cola', 100.00, 20),
(1, 'bebida', 'Fanta', 100.00, 20),
(1, 'postre', 'Helado', 150.00, 10),
(2, 'comida', 'Milanesa', 250.00, 10),
(2, 'comida', 'Empanadas', 150.00, 10),
(2, 'bebida', 'Sprite', 100.00, 20),
(2, 'bebida', 'Agua', 50.00, 20),
(2, 'postre', 'Torta', 200.00, 10);