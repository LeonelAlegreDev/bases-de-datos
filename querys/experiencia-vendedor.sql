-- Inicia una transacción para asegurar que todas las operaciones sean atómicas.
START TRANSACTION;

-- 1. Crear un usuario vendedor.
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('vendedor', 'vendedorVega', 'vendedor5@email.com', '14345', '86654321', '+54 11 12546578', 2);

-- Obtener el ID del último usuario insertado.
SET @last_user_id = LAST_INSERT_ID();

-- 2. Insertar en la tabla de vendedores.
INSERT INTO vendedores (fk_usuario, cuit, cbu) 
VALUES (@last_user_id, '20866543211', '7534567890123566789012');

-- 3. Crear un local asociado al vendedor.
INSERT INTO locales (fk_usuario, nombre, direccion, provincia, ciudad, pais, tel_local, codigo_postal)
VALUES
(@last_user_id, 'Local Larrea', 'Larrea 466', 'Buenos Aires', 'CABA', 'Argentina', '0987654321', '4321');

-- Obtener el ID del último local insertado.
SET @last_local_id = LAST_INSERT_ID();

-- 4. Crear menús para el local.
INSERT INTO menus (fk_local, nombre)
VALUES
(@last_local_id, 'Menu 10'), (@last_local_id, 'Menu 20');

-- Obtener los IDs de los menús creados.
SET @menu1_id = LAST_INSERT_ID();
SET @menu2_id = @menu1_id + 1;

-- 5. Agregar productos a los menús.
INSERT INTO productos (fk_menu, tipo_producto, descripcion, precio, stock)
VALUES 
(@menu1_id, 'comida', 'Hamburguesa', 200.00, 10),
(@menu1_id, 'comida', 'Pizza', 300.00, 5),
(@menu1_id, 'bebida', 'Coca Cola', 100.00, 20),
(@menu2_id, 'bebida', 'Sprite', 100.00, 20),
(@menu2_id, 'bebida', 'Agua', 50.00, 20),
(@menu2_id, 'postre', 'Torta', 200.00, 10);

-- 6. Crear un carrito para un comprador.
-- 6. 1 Crear un usuario comprador.
INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('Comprador 100', 'Apellido Falso', 'comprador33@email.com', '123456', '20302020', '+54 11 12345678', 3);

SET @comprador_id = LAST_INSERT_ID();

INSERT INTO compradores (fk_usuario, direccion, ciudad, provincia, codigo_postal, pais, detalle_direccion, nro_tarjeta, cvv, vencimiento)
VALUES 
(@comprador_id, 'Av. Corrientes 1300', 'CABA', 'Buenos Aires', '1234', 'Argentina', 'Planta Baja - PB', '1234567890123456', '123', '2023-12-31');

INSERT INTO carritos (fk_comprador, fk_local, metodo_pago)
VALUES (@comprador_id, @last_local_id, 'EFECTIVO');

-- Obtener el ID del carrito creado.
SET @last_cart_id = LAST_INSERT_ID();

-- 7. Agregar productos al carrito.
-- Nota: `monto` debería calcularse dinámicamente con triggers.
INSERT INTO carrito_detalles (fk_carrito, fk_producto, cantidad, monto)
VALUES 
(@last_cart_id, 1, 2, 400.00), -- 2 Hamburguesas (2 * 200.00)
(@last_cart_id, 3, 1, 100.00); -- 1 Coca Cola (1 * 100.00)


-- 8. Crear una entrega asociada al pedido.
UPDATE entregas
SET estado = 'LISTO A DESPACHAR'
WHERE fk_venta = 1;

-- 9. Actualizar la entrega como despachada y asignarla a un repartidor.
UPDATE entregas
SET fk_repartidor = 4, geo_coord = '[-34.6037, -58.3816]', estado = 'DESPACHADO'
WHERE id = 1;

-- 10. Finalizar la entrega.
UPDATE entregas
SET estado = 'ENTREGADO'
WHERE id = 1;