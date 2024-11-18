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
