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
('admin', 'admin1', 'admin@email.com', '123456', '00000000', '+54 11 12345678', 1),
('vendedor', 'vendedor1', 'vendedor1@email.com', '123456', '00000001', '+54 11 12345678', 2),
('comprador', 'comprador1', 'comprador1@email.com', '123456', '00000002', '+54 11 12345678', 3),
('repartidor', 'repartidor1', 'repartidor1@email.com', '123456', '00000003', '+54 11 12345678', 4),
('repartidor', 'repartidor2', 'repartidor2@email.com', '123456', '00000004', '+54 11 12345678', 4);