--
-- TABLA menus
-- 
-- CAMPOS: fk_local, nombre,

CREATE TABLE menus (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_local INT NOT NULL,
    nombre VARCHAR(128) NOT NULL,
    FOREIGN KEY (fk_local) REFERENCES locales(id)
);

INSERT INTO menus (fk_local, nombre)
VALUES
(1, 'Menu 1'), (1, 'Menu 2'),
(2, 'Menu 1'), (2, 'Menu 2');
