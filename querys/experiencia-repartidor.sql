-- Experiencia del Repartidor
-- 1. El usuario crea una cuenta de repartidor en la plataforma.
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Repartidor 1', 'Apellido Falso', 'repartidor15@email.com', '123456', '20000010', '+54 11 12345678', 4);

SET @repartidor_id = LAST_INSERT_ID();

INSERT INTO repartidores (fk_usuario, tipo_vehiculo, patente, cbu)
VALUES 
(@repartidor_id, 'motocicleta', 'A100FKD', '1234567890123456789012');

-- 2. El vendedor carga la información de su negocio y sus productos.
-- 2.1 Creacion del usuario
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Vendedor 100', 'Apellido Falso', 'vendedor100@email.com', '123456', '20000099', '+54 11 12345678', 2);

SET @vendedor_id = LAST_INSERT_ID();

INSERT INTO vendedores (fk_usuario, cuit, cbu) 
VALUES 
(@vendedor_id, '20333333339', '1234567890123456789012');

-- 2.2 Creacion de la tienda
INSERT INTO locales (fk_usuario, nombre, direccion, provincia, ciudad, pais, tel_local, codigo_postal)
VALUES
(@vendedor_id, 'Sushi King', 'Av. Santa fe 2031', 'Buenos Aires', 'CABA', 'Argentina', '1234567890', '1234');

SET @local_id = LAST_INSERT_ID();

INSERT INTO menus (fk_local, nombre)
VALUES
(1, 'Sushi fresco');

SET @menu_id = LAST_INSERT_ID();

-- 3. El vendedor pública sus productos como disponible·
INSERT INTO productos (fk_menu, tipo_producto, descripcion, precio, stock)
VALUES 
(@menu_id, 'comida', 'Sushi de salmon', 200.00, 10),
(@menu_id, 'comida', 'Sushi de atun', 300.00, 5),
(@menu_id, 'bebida', 'Coca Cola', 100.00, 20),
(@menu_id, 'bebida', 'Fanta', 100.00, 20),
(@menu_id, 'postre', 'Helado', 150.00, 10);


-- 4. Un cliente realiza un pedido y el vendedor es notificado con la orden de compra.
-- 4.1 Creacion del usuario comprador
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Comprador 100', 'Apellido Falso', 'comprador100@email.com', '123456', '20002020', '+54 11 12345678', 3);

SET @comprador_id = LAST_INSERT_ID();

INSERT INTO compradores (fk_usuario, direccion, ciudad, provincia, codigo_postal, pais, detalle_direccion, nro_tarjeta, cvv, vencimiento)
VALUES 
(@comprador_id, 'Av. Corrientes 1300', 'CABA', 'Buenos Aires', '1234', 'Argentina', 'Planta Baja - PB', '1234567890123456', '123', '2023-12-31');

-- 4.2 Creacion del carrito y agregado de productos
INSERT INTO carritos (fk_comprador, fk_local, metodo_pago)
VALUES (@comprador_id, @local_id, 'DEBITO');

SET @carrito_id = LAST_INSERT_ID();

INSERT INTO carrito_detalles (fk_carrito, fk_producto, cantidad)
VALUES (@carrito_id, 1, 2),
       (@carrito_id, 2, 1),
       (@carrito_id, 3, 3);

UPDATE carritos
SET estado = 'CONFIRMADO'
WHERE id = 1;

-- 5. El vendedor realiza los productos del pedido y lo marca como listo a retirar.
-- 5.1 Obtener el ID del pedido PENDIENTE del local
SELECT e.*
FROM entregas e
JOIN ventas v ON e.fk_venta = v.id
WHERE e.estado = 'PENDIENTE' AND v.fk_local = @local_id;

-- 5.2 Marcar el pedido como LISTO A DESPACHAR
SET @entrega_id = (SELECT e.id FROM entregas e JOIN ventas v ON e.fk_venta = v.id WHERE e.estado = 'PENDIENTE' AND v.fk_local = @local_id LIMIT 1);

UPDATE entregas
SET estado = 'LISTO A DESPACHAR'
WHERE id = @entrega_id;

-- 6. El vendedor recibe al repartidor y confirma el despacho del producto.
-- 6.1 Creacion del repartidor
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Repartidor 1', 'Apellido Falso', 'repartidor1@email.com', '123456', '20001234', '+54 11 12345678', 4); 

SET @repartidor_id = LAST_INSERT_ID();

INSERT INTO repartidores (fk_usuario, tipo_vehiculo, patente, cbu)
VALUES 
(@repartidor_id, 'motocicleta', 'ABC323', '1234567890123456789012');

-- 6.2 El repartidor toma el pedido
UPDATE entregas 
SET fk_repartidor = @repartidor_id
WHERE id = @entrega_id;

-- 6.3 El repartidor marca el pedidor como ENTREGADO
UPDATE entregas
SET estado = 'ENTREGADO'
WHERE id = @entrega_id;

-- 7. El vendedor realiza seguimiento del envío hasta que se concreta la entrega.
-- 8. El vendedor accede a las métricas de la plataforma.