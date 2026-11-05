-- =====================================================
-- PROYECTO: FashionStore – Tienda de Ropa
-- ARCHIVO: database/schema.sql
-- DESCRIPCIÓN: Definición del esquema DDL en 3FN
-- =====================================================

USE local_xampp_d;

-- Desactivar temporalmente revisión de llaves foráneas para evitar problemas al regenerar
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS detalle_ventas;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS inventario;
DROP TABLE IF EXISTS prendas;
DROP TABLE IF EXISTS colores;
DROP TABLE IF EXISTS tallas;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS proveedores;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------
-- Tabla: roles
-- -----------------------------------------------------
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: usuarios (Administradores, Vendedores)
-- -----------------------------------------------------
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rol_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_roles FOREIGN KEY (rol_id) REFERENCES roles (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: proveedores
-- -----------------------------------------------------
CREATE TABLE proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nit VARCHAR(20) NOT NULL UNIQUE,
    razon_social VARCHAR(150) NOT NULL,
    contacto_nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(120) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO'
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: categorias
-- -----------------------------------------------------
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    descripcion TEXT NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: tallas
-- -----------------------------------------------------
CREATE TABLE tallas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE, -- Ej: XS, S, M, L, XL, 38, 40
    descripcion VARCHAR(50) NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: colores
-- -----------------------------------------------------
CREATE TABLE colores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    codigo_hex VARCHAR(7) NULL -- Ej: #FFFFFF, #000000
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: prendas
-- -----------------------------------------------------
CREATE TABLE prendas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_referencia VARCHAR(30) NOT NULL UNIQUE,
    categoria_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    estado ENUM('ACTIVO', 'DESCONTINUADO') DEFAULT 'ACTIVO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prendas_categorias FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prendas_proveedores FOREIGN KEY (proveedor_id) REFERENCES proveedores (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: inventario (Variantes de Prenda x Talla x Color)
-- -----------------------------------------------------
CREATE TABLE inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prenda_id INT NOT NULL,
    talla_id INT NOT NULL,
    color_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 5, -- Nivel base para alerta de reposición
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_prenda_talla_color UNIQUE (prenda_id, talla_id, color_id),
    CONSTRAINT fk_inv_prenda FOREIGN KEY (prenda_id) REFERENCES prendas (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_inv_talla FOREIGN KEY (talla_id) REFERENCES tallas (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_inv_color FOREIGN KEY (color_id) REFERENCES colores (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: clientes
-- -----------------------------------------------------
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(120) NULL,
    direccion VARCHAR(200) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: ventas
-- -----------------------------------------------------
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_factura VARCHAR(30) NOT NULL UNIQUE,
    cliente_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('EFECTIVO', 'TARJETA', 'TRANSFERENCIA') NOT NULL DEFAULT 'EFECTIVO',
    estado ENUM('COMPLETADA', 'ANULADA') DEFAULT 'COMPLETADA',
    CONSTRAINT fk_ventas_clientes FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: detalle_ventas
-- -----------------------------------------------------
CREATE TABLE detalle_ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    inventario_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detalle_ventas FOREIGN KEY (venta_id) REFERENCES ventas (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_inventario FOREIGN KEY (inventario_id) REFERENCES inventario (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;