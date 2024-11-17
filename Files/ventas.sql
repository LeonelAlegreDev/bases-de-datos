-- Tabla ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_comprador INT NOT NULL,
    fk_local INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    metodo_pago ENUM('EFECTIVO', 'DEBITO', 'CREDITO') NOT NULL, -- PONGO UN ENUM ACÁ PARA NO HACER OTRA TABLA
    estado_venta ENUM('PENDIENTE', 'PAGADO', 'CANCELADO') NOT NULL DEFAULT 'PENDIENTE', 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fk_comprador) REFERENCES compradores(fk_usuario),
    FOREIGN KEY (fk_local) REFERENCES locales(id)
);

INSERT INTO ventas (fk_comprador, fk_local, metodo_pago, estado_venta)
VALUES
(3, 1, 'EFECTIVO', 'PAGADO');
