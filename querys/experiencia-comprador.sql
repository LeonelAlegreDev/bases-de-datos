-- EXPERIENCIA DEL COMPRADOR
-- 1. El usuario crea una cuenta de comprador en la plataforma

-- 1.1 Insertar un nuevo usuario
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Comprador 1', 'Apellido Falso', 'comprador1@email.com', '123456', '20000000', '+54 11 12345678', 3);

-- 1.2 Obtener el ID del usuario recién insertado
SET @comprador_id = LAST_INSERT_ID();

-- 1.3 Insertar un nuevo Comprador con el ID del usuario recién insertado
INSERT INTO compradores (fk_usuario, direccion, ciudad, provincia, codigo_postal, pais, detalle_direccion, nro_tarjeta, cvv, vencimiento)
VALUES 
(@comprador_id, 'Av. Corrientes 2050', 'CABA', 'Buenos Aires', '1234', 'Argentina', '3 B', '1234567890123456', '123', '2023-12-31');

-- 2. El comprador agrega productos al carrito.
-- 2.1 Crea un nuevo Usuario tipo Vendedor en la plataforma
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Vendedor 1', 'Apellido Falso', 'vendedor1@email.com', '123456', '20000001', '+54 11 12345678', 2);

-- 2.2 Obtener el ID del usuario recién insertado
SET @vendedor_id = LAST_INSERT_ID();

-- 2.3 Insertar un nuevo Vendedor con el ID del usuario recién insertado
INSERT INTO vendedores (fk_usuario, cuit, cbu) 
VALUES (@vendedor_id, '20323232323', '1234567890123456789012');

-- 2.4 Insertar un nuevo local
INSERT INTO locales (fk_usuario, nombre, direccion, provincia, ciudad, pais, tel_local, codigo_postal)
VALUES
(@vendedor_id, 'Big Pizzas', 'Av. Rivadavia 1800', 'Buenos Aires', 'CABA', 'Argentina', '1234567890', '1234');

-- 2.4.1 Obtiene el ID del local recién insertado
SET @local_id = LAST_INSERT_ID();

-- 2.5 Insertar un nuevo Menu 
INSERT INTO menus (fk_local, nombre)
VALUES
(1, 'Pizzas al Horno');

-- 2.6 Obtiene el ID del menu recién insertado
SET @last_menu_id = LAST_INSERT_ID();

-- 2.6 Insertar nuevos productos al menu
INSERT INTO productos (fk_menu, tipo_producto, descripcion, precio, stock)
VALUES 
(@last_menu_id, 'comida', 'Pizza de Muzarella', 200.00, 10),
(@last_menu_id, 'comida', 'Pizza con Jamon', 300.00, 5),
(@last_menu_id, 'bebida', 'Coca Cola', 100.00, 20),
(@last_menu_id, 'bebida', 'Fanta', 100.00, 20),
(@last_menu_id, 'postre', 'Helado', 150.00, 10);

-- 2.8 El comprador crea un carrito
INSERT INTO carritos (fk_comprador, fk_local, metodo_pago)
VALUES (@comprador_id, @local_id, 'DEBITO');

-- 2.9 Obtiene el ID del carrito recién insertado
SET @carrito_id = LAST_INSERT_ID();

-- 2.9 El comprador agrega productos al carrito
INSERT INTO carrito_detalles (fk_carrito, fk_producto, cantidad)
VALUES (@carrito_id, 1, 2),
       (@carrito_id, 2, 1),
       (@carrito_id, 3, 3);

-- 3 y 4. El comprador confirma la compra
UPDATE carritos
SET estado = 'CONFIRMADO'
WHERE id = 1;

-- 5 Orden de entrega generada automáticamente sin repartidor asignado

-- 6 El comprador recibe la orden de entrega
SELECT e.*
FROM entregas e
JOIN ventas v ON e.fk_venta = v.id
WHERE v.fk_comprador = @comprador_id;

-- 7 El repartidor lee la lista entregas pendientes
SELECT * FROM entregas WHERE estado = 'PENDIENTE';

-- 8 El repartidor acepta el pedido y se dirige a la localización del vendedor.
-- 8.1 crea un usuario tipo repartidor
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Repartidor 1', 'Apellido Falso', 'repartidor1@email.com', '123456', '20000002', '+54 11 12345678', 4); 

-- 8.2 Obtiene el ID del usuario recién insertado
SET @repartidor_id = LAST_INSERT_ID();

-- 8.3 Insertar un nuevo Repartidor con el ID del usuario recién insertado
INSERT INTO repartidores (fk_usuario, tipo_vehiculo, patente, cbu)
VALUES 
(@repartidor_id, 'motocicleta', 'ABC123', '1234567890123456789012');

-- 8.4 Obtiene el ID de la entrega pendiente
SET @entrega_id = (SELECT id FROM entregas WHERE estado = 'PENDIENTE' LIMIT 1);

-- 8.5 Actualiza la entrega con el repartidor asignado
UPDATE entregas 
SET fk_repartidor = @repartidor_id
WHERE id = @entrega_id;

-- 9 El reparatidor recoge el paquete y lo entrega en el domicilio del comprador.
UPDATE entregas
SET estado = 'DESPACHADO'
WHERE id = @entrega_id;

-- 10 El comprador confirma el recibo del paquete y se cierra la orden de compra.
-- 10.1 Cambia el estado de la entrega a 'ENTREGADO'
UPDATE entregas
SET estado = 'ENTREGADO'
WHERE id = @entrega_id;

-- 10.2 El usuario obtiene el detalle de su venta
