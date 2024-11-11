# Proyecto de Base de Datos para Sistema de Pedidos

Este proyecto consiste en la creación de una base de datos para un sistema de pedidos similar a PedidosYa, Rappi, Uber Eats, etc. La base de datos está diseñada para funcionar con MySQL y MariaDB.

## Descripción

La base de datos incluye tablas para gestionar usuarios, vendedores, compradores, repartidores y otros elementos necesarios para el funcionamiento de un sistema de pedidos.

## Instalación

### Requerimientos previos
* Tener instalado Docker.
* Tener instalado Docker Compose
* Tener un Sistema Operativo basado en Linux o WSL para Sistemas Operativos Windows.

### Usando Docker Compose

Para facilitar la instalación y configuración de la base de datos, se debe crear el archivo `docker-compose.yml` que ejecuta el script `db-init.sql` con los comandos de inicialización.

Para ello debe crear una copia del archivo `docker-compose.example.yml`, cambiar el nombre del archivo a `docker-compose.yml` y remplazar los valores de las variables.

> ⚠️ **Advertencia**: Es necesario generar una contraseña segura para evitar problemas de seguirad.

1. Clona este repositorio en tu máquina local.
2. Navega al directorio del proyecto.
3. Ejecuta el siguiente comando para iniciar los servicios:

```sh
docker-compose up
```

Este comando construirá las imágenes de Docker si es necesario, y luego iniciará los contenedores definidos en `docker-compose.yml`.

### Conectarse a la Base de Datos

#### Usando DBMS
En caso de estar trabajando con un DBMS se debe conectar con la base de datos 3306 (por defecto en el archivo `docker-compose.yml`) y seguir las instrucciones de configuración del DBMS para loguearse con usuario y contraseña.

Crear una base de datos, seleccionarla y ejecutar el archivo `db-init.sql`.

##### Usando la consola
Sigue los siguientes pasos para acceder al cliente de MariaDB sin un DBMS usando la consola.

> ⚠️ Para acceder a cliente de MariaDB se debe remplazar las directivas de comandos mysql por mariadb.

1. Acceder al contenedor de MySQL: Primero, necesitas acceder al contenedor de Docker que está ejecutando MariaDB. Utiliza el siguiente comando en la terminal:

```bash
docker exec -it bases-de-datos-mysql-1 bash
```

Este comando te dará acceso a la línea de comandos dentro del contenedor node-docker-mariadb-temeplate-mariadb-1.

> ⚠️ El segmento `bases-de-datos` hace referencia al nombre del directorio donde se lanza el comando `docker-compose up` por defecto.

2. Conectarse a la base de datos MariaDB: Una vez dentro del contenedor, puedes conectarte a la base de datos MariaDB utilizando el cliente de línea de comandos de MariaDB. Ejecuta el siguiente comando:

```bash
mysql -u root -p
```

3. Para ejecutar algun comando primero se debe seleccionar la base de datos:
```
use bases-de-datos
```

