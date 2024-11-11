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


