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
('admin', 'admin1', 'admin@email.com', '123456', '00000000', '+54 11 12345678', 1);
-- ('vendedor', 'vendedor1', 'vendedor1@email.com', '123456', '00000001', '+54 11 12345678', 2),
-- ('comprador', 'comprador1', 'comprador1@email.com', '123456', '00000002', '+54 11 12345678', 3),
-- ('repartidor', 'repartidor1', 'repartidor1@email.com', '123456', '00000003', '+54 11 12345678', 4),
-- ('repartidor', 'repartidor2', 'repartidor2@email.com', '123456', '00000004', '+54 11 12345678', 4);

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
-- INSERT INTO vendedores (fk_usuario, cuit, cbu) 
-- VALUES (2, '20323232323', '1234567890123456789012');

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

-- INSERT INTO compradores (fk_usuario, direccion, ciudad, provincia, codigo_postal, pais, detalle_direccion, nro_tarjeta, cvv, vencimiento)
-- VALUES 
-- (3, 'Calle Falsa 123', 'Ciudad de Springfield', 'Springfield', '1234', 'EEUU', 'Casa de Homero', '1234567890123456', '123', '2023-12-31');

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

-- INSERT INTO repartidores (fk_usuario, tipo_vehiculo, patente, cbu)
-- VALUES 
-- (4, 'motocicleta', 'ABC123', '1234567890123456789012'),
-- (5, 'bicicleta', NULL, '1234567890123456789012');

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

-- INSERT INTO locales (fk_usuario, nombre, direccion, provincia, ciudad, pais, tel_local, codigo_postal)
-- VALUES
-- (2, 'Local 1', 'Calle 123', 'Buenos Aires', 'CABA', 'Argentina', '1234567890', '1234'),
-- (2, 'Local 2', 'Calle 456', 'Buenos Aires', 'CABA', 'Argentina', '0987654321', '4321');

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

-- INSERT INTO menus (fk_local, nombre)
-- VALUES
-- (1, 'Menu 1'), (1, 'Menu 2'),
-- (2, 'Menu 1'), (2, 'Menu 2');

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

-- INSERT INTO productos (fk_menu, tipo_producto, descripcion, precio, stock)
-- VALUES 
-- (1, 'comida', 'Hamburguesa', 200.00, 10),
-- (1, 'comida', 'Pizza', 300.00, 5),
-- (1, 'bebida', 'Coca Cola', 100.00, 20),
-- (1, 'bebida', 'Fanta', 100.00, 20),
-- (1, 'postre', 'Helado', 150.00, 10),
-- (2, 'comida', 'Milanesa', 250.00, 10),
-- (2, 'comida', 'Empanadas', 150.00, 10),
-- (2, 'bebida', 'Sprite', 100.00, 20),
-- (2, 'bebida', 'Agua', 50.00, 20),
-- (2, 'postre', 'Torta', 200.00, 10);

-- Tabla ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_comprador INT NOT NULL,
    fk_local INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    metodo_pago ENUM('EFECTIVO', 'DEBITO', 'CREDITO') NOT NULL, -- PONGO UN ENUM ACÁ PARA NO HACER OTRA TABLA
    estado ENUM('PENDIENTE', 'PAGADO', 'CANCELADO') NOT NULL DEFAULT 'PENDIENTE', 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fk_comprador) REFERENCES compradores(fk_usuario),
    FOREIGN KEY (fk_local) REFERENCES locales(id)
);

-- tabla entregas
CREATE TABLE entregas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_venta INT NOT NULL,
    fk_repartidor INT DEFAULT NULL,
    entrega_estimada TIMESTAMP,
    estado ENUM('PENDIENTE', 'EN PREPARACION', 'LISTO A DESPACHAR', 'DESPACHADO', 'ENTREGADO', 'CANCELADO') DEFAULT 'PENDIENTE',
    geo_coord VARCHAR(255),
    FOREIGN KEY (fk_venta) REFERENCES ventas(id),
    FOREIGN KEY (fk_repartidor) REFERENCES repartidores(fk_usuario)
);

DELIMITER //

CREATE TRIGGER after_ventas_insert
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    DECLARE entrega_estado ENUM('PENDIENTE', 'EN PREPARACION', 'LISTO A DESPACHAR', 'DESPACHADO', 'ENTREGADO', 'CANCELADO');
    IF NEW.estado = 'CANCELADO' THEN
        SET entrega_estado = 'CANCELADO';
    ELSE
        SET entrega_estado = 'PENDIENTE';
    END IF;
    INSERT INTO entregas (fk_venta, entrega_estimada, estado)
    VALUES (NEW.id, CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, entrega_estado);
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_ventas_update
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    DECLARE entrega_estado ENUM('PENDIENTE', 'EN PREPARACION', 'LISTO A DESPACHAR', 'DESPACHADO', 'ENTREGADO', 'CANCELADO');
    IF NEW.estado = 'CANCELADO' THEN
        SET entrega_estado = 'CANCELADO';
    ELSE
        SET entrega_estado = 'PENDIENTE';
    END IF;
    UPDATE entregas
    SET estado = entrega_estado
    WHERE fk_venta = NEW.id;
END //

DELIMITER ;

-- Tabla detalles
CREATE TABLE detalles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_venta INT NOT NULL,
    fk_producto INT NOT NULL,
    cantidad INT NOT NULL,
    monto DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (fk_venta) REFERENCES ventas(id),
    FOREIGN KEY (fk_producto) REFERENCES productos(id)
);

DELIMITER //

-- TRIGGER before_insert_detalles
CREATE TRIGGER before_insert_detalles
BEFORE INSERT ON detalles
FOR EACH ROW
BEGIN
    -- Previene que se inserte un detalle si la cantidad 
    -- supera el stock disponible
    DECLARE stock_disponible INT;
    DECLARE precio_producto DECIMAL(10,2);

    -- Obtener el stock disponible del producto
    SELECT stock INTO stock_disponible FROM productos WHERE id = NEW.fk_producto;
    -- Verificar si la cantidad es menor o igual al stock disponible
    IF NEW.cantidad > stock_disponible THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay stock suficiente para el producto';
    END IF;

    -- Obtener el precio del producto
    SELECT precio INTO precio_producto FROM productos WHERE id = NEW.fk_producto;
    -- Calcular el valor de la venta
    SET NEW.monto = NEW.cantidad * precio_producto;
END //

DELIMITER ;

DELIMITER //
-- TRIGGER before_update_detalles
CREATE TRIGGER before_update_detalles
BEFORE UPDATE ON detalles
FOR EACH ROW
BEGIN
    -- Previene que se inserte un detalle si la cantidad 
    -- supera el stock disponible
    DECLARE stock_disponible INT;
    DECLARE precio_producto DECIMAL(10,2);

    -- Obtener el stock disponible del producto
    SELECT stock INTO stock_disponible FROM productos WHERE id = NEW.fk_producto;
    -- Verificar si la cantidad es menor o igual al stock disponible
    IF NEW.cantidad > stock_disponible THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay stock suficiente para el producto';
    END IF;


    -- Obtener el precio del producto
    SELECT precio INTO precio_producto FROM productos WHERE id = NEW.fk_producto;
    -- Calcular el valor de la venta
    SET NEW.monto = NEW.cantidad * precio_producto;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_insert_detalles
AFTER INSERT ON detalles
FOR EACH ROW
BEGIN
    -- Actualizar el total en la tabla ventas
    UPDATE ventas
    SET total = total + NEW.monto
    WHERE id = NEW.fk_venta;

    -- Actualizar el stock del producto
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.fk_producto;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_update_detalles
AFTER UPDATE ON detalles
FOR EACH ROW
BEGIN
    DECLARE old_monto DECIMAL(10,2);
    -- Obtener el valor de venta anterior
    SELECT monto INTO old_monto FROM detalles WHERE id = OLD.id;
    -- Actualizar el total en la tabla ventas
    UPDATE ventas
    SET total = total - old_monto + NEW.monto
    WHERE id = NEW.fk_venta;
END //

DELIMITER ;

CREATE TABLE carritos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_comprador INT NOT NULL,
    fk_local INT NOT NULL,
    estado ENUM('PENDIENTE', 'CONFIRMADO', 'CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
    metodo_pago ENUM('EFECTIVO', 'DEBITO', 'CREDITO') DEFAULT 'EFECTIVO',
    FOREIGN KEY (fk_comprador) REFERENCES compradores(fk_usuario),
    FOREIGN KEY (fk_local) REFERENCES locales(id)
);

CREATE TABLE carrito_detalles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_carrito INT NOT NULL,
    fk_producto INT NOT NULL,
    cantidad INT NOT NULL,
    monto DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (fk_carrito) REFERENCES carritos(id),
    FOREIGN KEY (fk_producto) REFERENCES productos(id)
);

DELIMITER //

CREATE TRIGGER after_update_carritos
AFTER UPDATE ON carritos
FOR EACH ROW
BEGIN
    DECLARE last_inserted_id INT;
    DECLARE estado_venta VARCHAR(20);

    -- Verificar si el estado del carrito es 'CONFIRMADO'
    IF NEW.estado = 'CONFIRMADO' THEN
        -- Determinar el estado de la venta basado en el método de pago
        IF NEW.metodo_pago = 'debito' OR NEW.metodo_pago = 'credito' THEN
            SET estado_venta = 'PAGADO';
        ELSE
            SET estado_venta = 'PENDIENTE';
        END IF;

        -- Insertar una nueva venta
        INSERT INTO ventas (fk_comprador, fk_local, metodo_pago, estado)
        VALUES (NEW.fk_comprador, NEW.fk_local, NEW.metodo_pago, estado_venta);
        
        -- Obtener el id de la venta recién creada
        SET last_inserted_id = LAST_INSERT_ID();
        
        -- Insertar los detalles del carrito en la tabla detalles
        INSERT INTO detalles (fk_venta, fk_producto, cantidad, monto)
        SELECT last_inserted_id, fk_producto, cantidad, monto
        FROM carrito_detalles
        WHERE fk_carrito = NEW.id;
        
        -- Actualizar el total de la venta
        UPDATE ventas
        SET total = (SELECT SUM(monto) FROM detalles WHERE fk_venta = last_inserted_id)
        WHERE id = last_inserted_id;
    END IF;
END //

DELIMITER ;

-- INSERT INTO carritos (fk_comprador, fk_local, metodo_pago)
-- VALUES (3, 1, 'DEBITO');

-- INSERT INTO carrito_detalles (fk_carrito, fk_producto, cantidad)
-- VALUES (1, 1, 2),
--        (1, 2, 1),
--        (1, 3, 3);

-- UPDATE carritos
-- SET estado = 'CONFIRMADO'
-- WHERE id = 1;
