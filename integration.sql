-- Tabla Ventas
CREATE TABLE Ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    monto FLOAT NOT NULL,
    fk_vendedor FLOAT NOT NULL,
    metodo_pago ENUM('EFECTIVO', 'DEBITO', 'CREDITO') NOT NULL, -- PONGO UN ENUM ACÁ PARA NO HACER OTRA TABLA
    fk_comprador INT NOT NULL,
    estado_venta ENUM('PENDIENTE', 'PAGADO', 'CANCELADO') NOT NULL, 
    FOREIGN KEY (fk_vendedor) REFERENCES User(id),
    FOREIGN KEY (fk_comprador) REFERENCES User(id)
);

INSERT INTO Ventas (monto, fk_vendedor, metodo_pago, fk_comprador, estado_venta) VALUES
(500.00, 2, 'CREDITO', 3, 'PAGADO'),
(750.50, 2, 'DEBITO', 3, 'PENDIENTE'),
(300.00, 2, 'EFECTIVO', 3, 'CANCELADO'),
(1200.00, 2, 'CREDITO', 3, 'PAGADO'),
(450.75, 2, 'DEBITO', 3, 'PENDIENTE');



-- Tabla Entrega
CREATE TABLE Entrega (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_direccion_local VARCHAR(255) NOT NULL,
    fk_direccion_comprador VARCHAR(255) NOT NULL,
    FOREIGN KEY (fk_direccion_local) REFERENCES locales(direccion),  
    FOREIGN KEY (fk_direccion_comprador) REFERENCES compradores(direccion) 
);


INSERT INTO Entrega (fk_direccion_local, fk_direccion_comprador) VALUES
('Av. Corrientes 1234', 'Calle Falsa 123'), 
('Av. Santa Fe 4567', 'Av. Belgrano 1500'), 
('Calle Florida 876', 'Av. Rivadavia 10200'), 
('Av. Pueyrredón 2500', 'Calle San Martín 555'), 
('Calle Lavalle 1200', 'Av. Callao 3500');




-- Tabla Detalle Pedido
CREATE TABLE DetallePedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedidos INT NOT NULL,
    fk_producto INT NOT NULL,
    cantidad INT NOT NULL,
    fk_menu INT NOT NULL,
    FOREIGN KEY (fk_pedidos) REFERENCES Ventas(id),
    FOREIGN KEY (fk_producto) REFERENCES productos(id),
    FOREIGN KEY (fk_menu) REFERENCES menus(id)
);

INSERT INTO DetallePedido (fk_pedidos, fk_producto, cantidad, fk_menu) VALUES
(1, 1, 2, 1),
(1, 2, 1, 1),
(2, 3, 3, 1),
(2, 4, 2, 1),
(3, 5, 1, 1),
(3, 6, 4, 2),
(4, 7, 2, 2),
(4, 8, 3, 2),
(5, 9, 1, 2),
(5, 10, 5, 2);
