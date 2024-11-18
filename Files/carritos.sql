-- tabla: carritos
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
INSERT INTO carritos (fk_comprador, fk_local, metodo_pago)
VALUES (3, 1, 'DEBITO');

INSERT INTO carrito_detalles (fk_carrito, fk_producto, cantidad)
VALUES (1, 1, 2),
       (1, 2, 1),
       (1, 3, 3);

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

UPDATE carritos
SET estado = 'CONFIRMADO'
WHERE id = 1;
