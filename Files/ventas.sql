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

INSERT INTO ventas (fk_comprador, fk_local, metodo_pago, estado, total)
VALUES
(3, 1, 'EFECTIVO', 'PAGADO');

CREATE TABLE entregas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_venta INT NOT NULL,
    fk_repartidor INT DEFAULT NULL,
    entrega_estimada TIMESTAMP,
    estado ENUM('PENDIENTE', 'EN PREPARACION', 'LISTO A DESPACHAR', 'DESPACHADO', 'ENTREGADO', 'CANCELADO') DEFAULT 'PENDIENTE',
    geo_coord VARCHAR(255) NOT NULL,
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
    INSERT INTO entregas (fk_venta, entrega_estimada, estado, geo_coord)
    VALUES (NEW.id, CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, entrega_estado, '(-34.603722, -58.381592)');
END //

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
