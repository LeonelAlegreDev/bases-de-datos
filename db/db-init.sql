---
--- TABLA tipos_usuario
---
CREATE TABLE tipos_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(32) NOT NULL UNIQUE
);

INSERT INTO tipos_usuario (nombre) 
VALUES ('admin'), ('vendedor'), ('comprador'), ('repartidor');

---
--- TABLA usuarios
---
CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(32) NOT NULL,
    apellido VARCHAR(32) NOT NULL,
    email VARCHAR(64) NOT NULL,
    password VARCHAR(255) NOT NULL,
    dni CHAR(8) NOT NULL UNIQUE,
    tel VARCHAR(32) NOT NULL UNIQUE,
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

INSERT INTO usuarios (nombre, apellido, email, password, dni, tel, fk_tipo)
VALUES ('admin', 'admin1', 'apellido1', 'admin@email.com', '+54 11 12345678', '12345678', 1);

--- 
--- TABLA vendedores
--- 
--- campos: fk_usuario, cuit, cbu,

CREATE TABLE IF NOT EXISTS vendedores (
    fk_usuario INT PRIMARY KEY,
    cuit CHAR(11) NOT NULL UNIQUE,
    cbu CHAR(22) NOT NULL UNIQUE,

    FOREIGN KEY (fk_usuario) REFERENCES usuarios(id)
);