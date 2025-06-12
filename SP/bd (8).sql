-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-06-2025 a las 00:34:18
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_categoria` (IN `p_id` INT, IN `p_descripcion` VARCHAR(150))   BEGIN
  UPDATE categorias SET descripcion = p_descripcion WHERE id_categoria = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_categoria` (IN `p_id` INT)   BEGIN
  DELETE FROM categorias WHERE id_categoria = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_producto` (IN `p_id` INT)   BEGIN
  DELETE FROM productos WHERE id_producto = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_proveedor` (IN `p_id` INT)   BEGIN
  DELETE FROM proveedores WHERE id_proveedor = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_categorias` ()   BEGIN
  SELECT * FROM categorias;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_proveedores` ()   BEGIN
  SELECT * FROM proveedores;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login_usuario` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255))   BEGIN
IF NOT campo_no_vacio(p_email) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo no puede estar vacío.';
END IF;

IF NOT campo_no_vacio(p_password) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña no puede estar vacía.';
END IF;

IF NOT validar_correo(p_email) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Correo no válido.';
END IF;

IF NOT validar_password(p_password) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contraseña no válida.';
END IF;

IF NOT usuario_existe(p_email) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado.';
END IF;

IF NOT verificar_password(p_email, p_password) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contraseña incorrecta.';
END IF;

IF NOT validar_rol_permitido(p_email) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No tienes permiso para iniciar sesión.';
END IF;

  -- Devolver los datos y ruta de redirección usando función
SELECT 
    id_usuario, 
    nombre, 
    rol,
    obtener_redireccion_por_rol(p_email) AS redirect
FROM usuario
WHERE email = p_email
LIMIT 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_categoria_por_id` (IN `p_id` INT)   BEGIN
  SELECT * FROM categorias WHERE id_categoria = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_producto_por_id` (IN `p_id` INT)   BEGIN
  SELECT * FROM productos WHERE id_producto = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_proveedor_por_id` (IN `p_id` INT)   BEGIN
  SELECT * FROM proveedores WHERE id_proveedor = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_usuario_por_email` (IN `p_email` VARCHAR(100))   BEGIN
    -- Verifica si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo no está registrado.';
    ELSE
        -- Retorna los datos del usuario
        SELECT id_usuario, nombre, email, password, rol
        FROM usuario
        WHERE email = p_email
        LIMIT 1;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_venta_producto` (IN `p_cantidad` VARCHAR(10))   BEGIN
    IF NOT validar_cantidad(p_cantidad) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser un número entero mayor que 0 y no puede estar vacía.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_categoria` (IN `p_id_categoria` INT, IN `p_descripcion` VARCHAR(100))   BEGIN
    -- Validar que la descripción no esté vacía
    IF NOT categoria_no_vacia(p_descripcion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción no puede estar vacía.';
    END IF;

    -- Validar formato correcto
    IF NOT descripcion_categoria_valida(p_descripcion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción solo debe contener letras y espacios.';
    END IF;

    -- Actualizar categoría
    UPDATE categorias
    SET descripcion = p_descripcion
    WHERE id_categoria = p_id_categoria;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_cliente` (IN `p_id_cliente` INT, IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_direccion` VARCHAR(200), IN `p_telefono` VARCHAR(15))   BEGIN
    -- Validar campos obligatorios
    IF NOT campo_no_vacio(p_nombres) OR NOT campo_no_vacio(p_apellidos)
       OR NOT campo_no_vacio(p_direccion) OR NOT campo_no_vacio(p_telefono) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Todos los campos son obligatorios.';
    END IF;

    -- Validar letras en nombres y apellidos
    IF NOT validar_letras_espacios(p_nombres) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre solo debe contener letras y espacios.';
    END IF;

    IF NOT validar_letras_espacios(p_apellidos) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido solo debe contener letras y espacios.';
    END IF;

    -- Validar teléfono
    IF NOT validar_telefono(p_telefono) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono debe comenzar con 9 y tener 9 dígitos.';
    END IF;

    -- Actualizar registro
    UPDATE clientes
    SET nombres = p_nombres,
        apellidos = p_apellidos,
        direccion = p_direccion,
        telefono = p_telefono
    WHERE id_cliente = p_id_cliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_producto` (IN `p_id_producto` INT, IN `p_descripcion` VARCHAR(100), IN `p_precio` DECIMAL(10,2), IN `p_stock` INT, IN `p_id_categoria` INT, IN `p_id_proveedor` INT)   BEGIN
  -- Validar ID del producto
  IF p_id_producto IS NULL OR p_id_producto = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID de producto inválido.';
  END IF;

  -- Validar descripción
 IF NOT campo_no_vacio(p_descripcion) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción es obligatoria.';
  END IF;

  IF NOT descripcion_producto_validaP(p_descripcion) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción solo debe contener letras, números y espacios.';
  END IF;

  -- Validar precio
  IF NOT precio_validoP(p_precio) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que 0 y tener máximo 2 decimales.';
  END IF;
  
IF NOT stock_validoP(p_stock) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock debe ser un número entero mayor o igual a 0 y no puede estar vacío.';
END IF;


  -- Validar categoría y proveedor
  IF p_id_categoria IS NULL OR p_id_categoria = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe seleccionar una categoría.';
  END IF;

  IF p_id_proveedor IS NULL OR p_id_proveedor = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe seleccionar un proveedor.';
  END IF;

  -- Actualizar el producto
  UPDATE productos
  SET descripcion = p_descripcion,
      precio = p_precio,
      stock = p_stock,
      id_categoria = p_id_categoria,
      id_proveedor = p_id_proveedor
  WHERE id_producto = p_id_producto;

  -- Verificar que se haya actualizado algo
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ' no hubo cambios.';
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_proveedor` (IN `p_id_proveedor` INT, IN `p_razonsocial` VARCHAR(100), IN `p_direccion` VARCHAR(200), IN `p_telefono` VARCHAR(20))   BEGIN
  -- Validar ID de proveedor
  IF NOT id_valido_proveedor(p_id_proveedor) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID de proveedor inválido.';
  END IF;

  -- Validar campos obligatorios
  IF NOT proveedor_campos_obligatorios(p_razonsocial, p_direccion, p_telefono) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Todos los campos son obligatorios.';
  END IF;

  -- Validar razón social
  IF NOT razon_social_valida(p_razonsocial) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La razón social solo debe contener letras, números y espacios.';
  END IF;

  -- Validar teléfono
  IF NOT telefono_valido(p_telefono) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono debe comenzar con 9 y tener 9 dígitos.';
  END IF;

  -- Actualizar proveedor
  UPDATE proveedores
  SET 
    razonsocial = p_razonsocial,
    direccion = p_direccion,
    telefono = p_telefono
  WHERE id_proveedor = p_id_proveedor;

  -- Validar si se actualizó
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró proveedor con ese ID.';
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_agregar_producto_carrito` (IN `p_id_producto` INT, IN `p_cantidad` INT)   BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_existe INT;

    -- Validar cantidad
    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0.';
    END IF;

    -- Validar que exista producto
    SELECT COUNT(*) INTO v_existe FROM producto WHERE id_producto = p_id_producto;
    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Producto no válido.';
    END IF;

    -- Obtener precio (opcional)
    SELECT precio INTO v_precio FROM producto WHERE id_producto = p_id_producto;

    -- Insertar en tabla temporal de carrito (si tuvieras una)
    -- INSERT INTO carrito (id_usuario, id_producto, cantidad, precio_unitario)
    -- VALUES (...);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_cliente` (IN `p_id_cliente` INT)   BEGIN
  DELETE FROM clientes
  WHERE id_cliente = p_id_cliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_categoria` (IN `p_descripcion` VARCHAR(100))   BEGIN
    -- Validar que no esté vacía
    IF NOT categoria_no_vacia(p_descripcion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción no puede estar vacía.';
    END IF;

    -- Validar formato correcto
    IF NOT descripcion_categoria_valida(p_descripcion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción solo debe contener letras y espacios.';
    END IF;

    -- Insertar categoría
    INSERT INTO categorias (descripcion)
    VALUES (p_descripcion);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_cliente` (IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_direccion` VARCHAR(200), IN `p_telefono` VARCHAR(15))   BEGIN
    -- Validar campos vacíos
    IF NOT campo_no_vacio(p_nombres) OR NOT campo_no_vacio(p_apellidos)
       OR NOT campo_no_vacio(p_direccion) OR NOT campo_no_vacio(p_telefono) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Todos los campos son obligatorios.';
    END IF;

    -- Validar nombres y apellidos
    IF NOT validar_letras_espacios(p_nombres) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre solo debe contener letras y espacios.';
    END IF;

    IF NOT validar_letras_espacios(p_apellidos) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido solo debe contener letras y espacios.';
    END IF;

    -- Validar teléfono
    IF NOT validar_telefono(p_telefono) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono debe comenzar con 9 y tener 9 dígitos.';
    END IF;

    -- Inserción final
    INSERT INTO clientes (nombres, apellidos, direccion, telefono)
    VALUES (p_nombres, p_apellidos, p_direccion, p_telefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_detalle_venta` (IN `p_id_venta` INT, IN `p_id_producto` INT, IN `p_cantidad` INT)   BEGIN
    INSERT INTO detalle_ventas (id_venta, id_producto, cantidad)
    VALUES (p_id_venta, p_id_producto, p_cantidad);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_producto` (IN `p_descripcion` VARCHAR(100), IN `p_precio` DECIMAL(10,2), IN `p_stock` INT, IN `p_id_categoria` INT, IN `p_id_proveedor` INT)   BEGIN
  -- Validar campos obligatorios
  IF TRIM(p_descripcion) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción es obligatoria.';
  END IF;

  IF p_precio IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio es obligatorio.';
  END IF;

  IF p_stock IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock es obligatorio.';
  END IF;

  IF NOT id_valido_categoriaP(p_id_categoria) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe seleccionar una categoría válida.';
  END IF;

  IF NOT id_valido_proveedorP(p_id_proveedor) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe seleccionar un proveedor válido.';
  END IF;

  -- Validaciones específicas
  IF NOT descripcion_producto_validaP(p_descripcion) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción solo debe contener letras y espacios.';
  END IF;

  IF NOT precio_validoP(p_precio) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que 0 y tener máximo 2 decimales.';
  END IF;

IF NOT stock_validoP(p_stock) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock debe ser un número entero mayor o igual a 0 y no puede estar vacío.';
END IF;



  -- Insertar el producto
  INSERT INTO productos (descripcion, precio, stock, id_categoria, id_proveedor)
  VALUES (p_descripcion, p_precio, p_stock, p_id_categoria, p_id_proveedor);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_proveedor` (IN `p_razonsocial` VARCHAR(100), IN `p_direccion` VARCHAR(200), IN `p_telefono` VARCHAR(20))   BEGIN
  -- Validar campos vacíos
  IF NOT proveedor_campos_obligatorios(p_razonsocial, p_direccion, p_telefono) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Todos los campos son obligatorios.';
  END IF;

  -- Validar razón social
  IF NOT razon_social_valida(p_razonsocial) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La razón social solo debe contener letras, números y espacios.';
  END IF;

  -- Validar teléfono
  IF NOT telefono_valido(p_telefono) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono debe comenzar con 9 y tener 9 dígitos.';
  END IF;

  -- Insertar
  INSERT INTO proveedores(razonsocial, direccion, telefono)
  VALUES (p_razonsocial, p_direccion, p_telefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_venta` (IN `p_id_cliente` INT, IN `p_fecha` DATE)   BEGIN
    INSERT INTO ventas (id_cliente, fecha) VALUES (p_id_cliente, p_fecha);
    SELECT LAST_INSERT_ID() AS nueva_venta_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_clientes` ()   BEGIN
  SELECT * FROM clientes;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_detalle_venta` ()   BEGIN
    SELECT 
        dv.id_detventa,
        dv.id_venta,
        dv.id_producto,
        p.descripcion AS producto,
        dv.cantidad
    FROM detalle_ventas dv
    JOIN productos p ON dv.id_producto = p.id_producto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_productos` ()   BEGIN
    SELECT 
        p.id_producto,
        p.descripcion,
        p.precio,
        p.stock,
        p.id_categoria,
        c.descripcion AS categoria,
        p.id_proveedor,
        pr.razonsocial AS proveedor
    FROM productos p
    JOIN categorias c ON p.id_categoria = c.id_categoria
    JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_categoria` (IN `id_cat` INT)   BEGIN
  SELECT * FROM categorias WHERE id_categoria = id_cat;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_clientes_venta` ()   BEGIN
    SELECT id_cliente, CONCAT(nombres, ' ', apellidos) AS nombre_cliente FROM clientes;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_cliente_por_id` (IN `p_id_cliente` INT)   BEGIN
    SELECT * FROM clientes WHERE id_cliente = p_id_cliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_cliente_por_id_ven` (IN `_id_cliente` INT)   BEGIN
  SELECT id_cliente, nombres, apellidos
  FROM clientes
  WHERE id_cliente = _id_cliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_producto` (IN `p_id_producto` INT)   BEGIN
    SELECT id_producto, descripcion, precio, stock, id_categoria, id_proveedor
    FROM productos
    WHERE id_producto = p_id_producto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_productos_venta` ()   BEGIN
    SELECT id_producto, descripcion, precio FROM productos;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_producto_por_id` (IN `p_id_producto` INT)   BEGIN
    SELECT descripcion, precio FROM productos WHERE id_producto = p_id_producto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_producto_por_id_validado` (IN `p_id_producto` INT)   BEGIN
    DECLARE v_existe INT;

    SELECT COUNT(*) INTO v_existe
    FROM productos
    WHERE id_producto = p_id_producto;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Producto no válido.';
    END IF;

    SELECT id_producto, descripcion, precio
    FROM productos
    WHERE id_producto = p_id_producto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_proveedor` (IN `p_id_proveedor` INT)   BEGIN
    SELECT id_proveedor, razonsocial, direccion, telefono
    FROM proveedores
    WHERE id_proveedor = p_id_proveedor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_ventas` ()   BEGIN
    SELECT * FROM ventas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_venta` (IN `p_id_cliente` INT, IN `p_total` DECIMAL(10,2), IN `p_usuario` INT)   BEGIN
    DECLARE v_existe_cliente INT;
    DECLARE v_id_venta INT;

    -- Validar existencia de cliente
    SELECT COUNT(*) INTO v_existe_cliente FROM cliente WHERE id_cliente = p_id_cliente;
    IF v_existe_cliente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente no existe.';
    END IF;

    -- Insertar en tabla venta
    INSERT INTO venta (fecha, id_cliente, total, id_usuario)
    VALUES (NOW(), p_id_cliente, p_total, p_usuario);

    SET v_id_venta = LAST_INSERT_ID();

    -- Aquí se espera que los detalles de venta estén insertados por otro proceso
    -- o que se haga una llamada posterior con los detalles en bucle

    -- Retornar el ID de la venta generada (opcional)
    SELECT v_id_venta AS id_venta_generada;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validar_cliente` (IN `p_id_cliente` INT)   BEGIN
    DECLARE v_existe INT;

    SELECT COUNT(*) INTO v_existe
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente no válido.';
    END IF;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `campo_no_vacio` (`p_texto` VARCHAR(255)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    IF p_texto IS NULL OR TRIM(p_texto) = '' THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `campo_no_vacioNP` (`p_campo` VARCHAR(255)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    RETURN TRIM(p_campo) <> '';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `categoria_no_vacia` (`descripcion` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    RETURN TRIM(descripcion) <> '';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `descripcion_categoria_valida` (`descripcion` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    RETURN descripcion REGEXP '^[A-Za-zÀ-ÿ ]+$';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `descripcion_producto_validaP` (`descripcion` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN descripcion REGEXP '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9 ]+$';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `id_valido_categoriaP` (`id_categoria` INT) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN id_categoria IS NOT NULL AND id_categoria > 0;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `id_valido_proveedorP` (`id_proveedor` INT) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN id_proveedor IS NOT NULL AND id_proveedor > 0;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `obtener_redireccion_por_rol` (`p_email` VARCHAR(100)) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE v_rol VARCHAR(50);
    DECLARE v_redirect VARCHAR(100);

    -- Obtener el rol del usuario
    SELECT rol INTO v_rol
    FROM usuario
    WHERE email = p_email;

    -- Determinar redirección según el rol
    IF v_rol = 'administrador' THEN
        SET v_redirect = 'productos.html';
    ELSEIF v_rol = 'encargado' THEN
        SET v_redirect = 'ventas.php';
    ELSE
        SET v_redirect = NULL; -- Rol no válido
    END IF;

    RETURN v_redirect;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `precio_validoP` (`precio` DECIMAL(10,2)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN precio > 0 AND precio = ROUND(precio, 2);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `proveedor_campos_obligatorios` (`razon` VARCHAR(100), `direccion` VARCHAR(200), `telefono` VARCHAR(20)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN TRIM(razon) <> '' AND TRIM(direccion) <> '' AND TRIM(telefono) <> '';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `razon_social_valida` (`razon` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN razon REGEXP '^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]+$';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `stock_validoP` (`p_stock` VARCHAR(10)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  DECLARE v_stock_int INT;

  -- Quitar espacios al inicio y final
  SET p_stock = TRIM(p_stock);

  -- Validar que no esté vacío ni nulo
  IF p_stock IS NULL OR p_stock = '' THEN
    RETURN FALSE;
  END IF;

  -- Validar que sea numérico
  IF p_stock NOT REGEXP '^[0-9]+$' THEN
    RETURN FALSE;
  END IF;

  -- Convertir a entero
  SET v_stock_int = CAST(p_stock AS UNSIGNED);

  -- Validar que sea mayor o igual a 0
  IF v_stock_int < 0 THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `telefono_valido` (`telefono` VARCHAR(20)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
  RETURN telefono REGEXP '^9[0-9]{8}$';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `usuario_existe` (`p_email` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM usuario WHERE email = p_email;

    IF v_count = 0 THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_cantidad` (`p_cantidad` VARCHAR(10)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    -- Retorna 0 si está vacío o es solo espacios
    IF p_cantidad IS NULL OR TRIM(p_cantidad) = '' THEN
        RETURN 0;
    END IF;

    -- Retorna 0 si no es un número entero positivo mayor que 0
    IF p_cantidad NOT REGEXP '^[1-9][0-9]*$' THEN
        RETURN 0;
    END IF;

    RETURN 1; -- Si pasa todas las validaciones
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_correo` (`p_email` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    IF p_email IS NULL OR TRIM(p_email) = '' THEN
        RETURN FALSE;
    END IF;

    IF p_email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_letras_espacios` (`p_texto` VARCHAR(255)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    RETURN p_texto REGEXP '^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_password` (`p_pass` VARCHAR(255)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    IF p_pass IS NULL OR TRIM(p_pass) = '' THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_rol_permitido` (`p_email` VARCHAR(100)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    DECLARE v_rol VARCHAR(50);

    SELECT rol INTO v_rol FROM usuario WHERE email = p_email;

    IF v_rol NOT IN ('administrador', 'encargado') THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_telefono` (`p_telefono` VARCHAR(15)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    RETURN p_telefono REGEXP '^9[0-9]{8}$';
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verificar_password` (`p_email` VARCHAR(100), `p_password` VARCHAR(255)) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    DECLARE v_hash VARCHAR(255);

    SELECT password INTO v_hash FROM usuario WHERE email = p_email;

    IF v_hash <> SHA2(p_password, 256) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `descripcion`) VALUES
(4, 'lentejas'),
(5, 'menestras'),
(7, 'lacteos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL,
  `nombres` varchar(50) NOT NULL,
  `apellidos` varchar(50) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombres`, `apellidos`, `direccion`, `telefono`) VALUES
(8, 'luis', 'utos ceras', 'av. san carlos 2275', '96565656'),
(10, 'carlos', 'santos campos', 'Jr. salaverry 789', '923486567'),
(12, 'jose', 'paez', 'aaaaa', '923456789'),
(14, 'jose', 'chavez', 'lefwegeu', '923456789'),
(15, 'jose', 'chave', 'wrq3r', '923456789');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_ventas`
--

CREATE TABLE `detalle_ventas` (
  `id_detventa` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `detalle_ventas`
--

INSERT INTO `detalle_ventas` (`id_detventa`, `id_venta`, `id_producto`, `cantidad`) VALUES
(20, 20, 5, 2),
(21, 21, 5, 2),
(22, 22, 5, 23),
(23, 23, 5, 3),
(24, 24, 5, 2),
(25, 24, 5, 3),
(26, 27, 5, 2),
(27, 28, 5, 0),
(28, 28, 5, 2),
(29, 29, 10, 2),
(30, 29, 11, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL,
  `descripcion` varchar(50) NOT NULL,
  `precio` decimal(18,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `id_proveedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `descripcion`, `precio`, `stock`, `id_categoria`, `id_proveedor`) VALUES
(5, 'frejol castillo', 6.00, 0, 4, 7),
(10, 'wqed', 1.00, 1, 7, 9),
(11, 'w', 1.00, 2, 7, 7),
(14, 'wqw', 2.00, 0, 4, 7),
(19, 'aea', 2.00, 0, 4, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id_proveedor` int(11) NOT NULL,
  `razonsocial` varchar(50) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id_proveedor`, `razonsocial`, `direccion`, `telefono`) VALUES
(6, 'alicorp', 'av. los nogales 890', '343545345'),
(7, 'gesa', 'av. los gamonales 567', '946546542'),
(9, 'cole', 'wqrewqr', '987654321');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `rol` varchar(50) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre`, `email`, `password`, `rol`, `fecha_registro`) VALUES
(3, 'Jose Luis', 'thegrax4@gmail.com', 'c7aedd264a1940c2baf5d3f99caf40244dbda5c3e111d0d3fe2ce6939d9cfedd', 'administrador', '2025-05-29 16:39:06'),
(4, 'Jhandel Jesus', 'jhand@gmail.com', '5cd0903253075e4ddf83aaab4f83c8a8907dc14d34971763ada09450dfe37a4b', 'encargado', '2025-05-29 16:39:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id_venta` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id_venta`, `fecha`, `id_cliente`) VALUES
(17, '2025-04-08 00:43:19', 8),
(18, '2025-04-08 00:46:03', 10),
(19, '2025-04-08 00:46:46', 8),
(20, '2025-05-29 00:00:00', 10),
(21, '2025-05-29 00:00:00', 8),
(22, '2025-05-29 00:00:00', 8),
(23, '2025-05-30 00:00:00', 10),
(24, '2025-05-30 00:00:00', 8),
(27, '2025-06-05 00:00:00', 8),
(28, '2025-06-05 00:00:00', 8),
(29, '2025-06-05 00:00:00', 8);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indices de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD PRIMARY KEY (`id_detventa`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `id_categoria` (`id_categoria`),
  ADD KEY `id_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  MODIFY `id_detventa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD CONSTRAINT `detalle_ventas_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_ventas_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
