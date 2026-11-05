-- =====================================================
-- PROYECTO: FashionStore – Tienda de Ropa
-- ARCHIVO: database/datos_prueba.sql
-- DESCRIPCIÓN: Datos iniciales de prueba (Seeders)
-- =====================================================

USE local_xampp_d;

-- 1. Roles
INSERT INTO roles (nombre, descripcion) VALUES
('Administrador', 'Control total de inventario, ventas y parametrización'),
('Vendedor', 'Acceso a facturación, clientes y consulta de existencias'),
('Supervisor de Almacén', 'Gestión de proveedores, ingresos y alertas de stock');

-- 2. Usuarios (Claves hasheadas tipo bcrypt para producción)
INSERT INTO usuarios (rol_id, nombre, correo, password_hash, estado) VALUES
(1, 'Daniel Camilo', 'admin@fashionstore.com', '$2y$10$w8TKnPZp9sE5V8t6H0ZkkuoOiqm5gCjZzO7k1qN7M2M2eU9q2W9Wy', 'ACTIVO'),
(2, 'Laura Gómez', 'laura.ventas@fashionstore.com', '$2y$10$w8TKnPZp9sE5V8t6H0ZkkuoOiqm5gCjZzO7k1qN7M2M2eU9q2W9Wy', 'ACTIVO'),
(2, 'Andrés Felipe Ruiz', 'andres.ventas@fashionstore.com', '$2y$10$w8TKnPZp9sE5V8t6H0ZkkuoOiqm5gCjZzO7k1qN7M2M2eU9q2W9Wy', 'ACTIVO'),
(3, 'Marta Lucía Rivas', 'almacen@fashionstore.com', '$2y$10$w8TKnPZp9sE5V8t6H0ZkkuoOiqm5gCjZzO7k1qN7M2M2eU9q2W9Wy', 'ACTIVO'),
(2, 'Carlos Julio Mendoza', 'carlos.vendedor@fashionstore.com', '$2y$10$w8TKnPZp9sE5V8t6H0ZkkuoOiqm5gCjZzO7k1qN7M2M2eU9q2W9Wy', 'INACTIVO');

-- 3. Proveedores
INSERT INTO proveedores (nit, razon_social, contacto_nombre, telefono, correo, direccion) VALUES
('900123456-1', 'Textiles de Colombia S.A.S.', 'Hernando Parra', '3114567890', 'ventas@textilescol.com', 'Calle 10 # 45-20, Medellín'),
('900654321-2', 'Confecciones del Valle Ltda.', 'Claudia Morales', '3157891234', 'cmorales@confvalle.com', 'Carrera 15 # 33-12, Cali'),
('900987654-3', 'Moda Urbana Jeans S.A.', 'Javier Salazar', '3203456781', 'jsalazar@urbanajeans.com', 'Av. 68 # 12-40, Bogotá'),
('901234567-4', 'Estilo & Calzado Mayorista', 'Rosa Martínez', '3176549870', 'pedidos@estiloclz.com', 'Calle 26 # 50-10, Bucaramanga'),
('901876543-5', 'Distribuidora Tejidos Andinos', 'Manuel Santos', '3109876543', 'msantos@tejidosandinos.com', 'Cra 7 # 19-30, Pereira');

-- 4. Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Camisas y Polos', 'Prendas superiores formales y casuales'),
('Pantalones y Jeans', 'Jeans de denim, dril y pantalones casuales'),
('Vestidos y Faldas', 'Prendas femeninas de temporada'),
('Chaquetas y Abrigos', 'Ropa exterior para clima frío o templado'),
('Accesorios', 'Cinturones, bufandas y gorros');

-- 5. Tallas
INSERT INTO tallas (codigo, descripcion) VALUES
('XS', 'Extra Pequeña'),
('S', 'Pequeña'),
('M', 'Mediana'),
('L', 'Grande'),
('XL', 'Extra Grande');

-- 6. Colores
INSERT INTO colores (nombre, codigo_hex) VALUES
('Negro Profundo', '#000000'),
('Blanco Puro', '#FFFFFF'),
('Azul Índigo', '#1A2B4C'),
('Rojo Carmín', '#990000'),
('Verde Militar', '#4B5320');

-- 7. Prendas
INSERT INTO prendas (codigo_referencia, categoria_id, proveedor_id, nombre, descripcion, precio_compra, precio_venta, estado) VALUES
('REF-CAM-001', 1, 1, 'Camisa Oxford Slim Fit', 'Camisa manga larga algodón 100%', 35000.00, 79900.00, 'ACTIVO'),
('REF-JEA-002', 2, 3, 'Jean Skinny Clásico', 'Pantalón denim stretch 5 bolsillos', 45000.00, 119900.00, 'ACTIVO'),
('REF-VES-003', 3, 2, 'Vestido Floreado de Verano', 'Vestido corto rayón con estampado floral', 40000.00, 95000.00, 'ACTIVO'),
('REF-CHA-004', 4, 1, 'Chaqueta Bomber Acolchada', 'Chaqueta impermeable con cremallera frontal', 65000.00, 149900.00, 'ACTIVO'),
('REF-POL-005', 1, 5, 'Camiseta Polo Casual', 'Piqué fino con cuello camisero', 25000.00, 59900.00, 'ACTIVO');

-- 8. Inventario (SKU generado: PRENDA-TALLA-COLOR)
-- Notar que algunos registros tienen stock_actual <= stock_minimo para disparar la alerta
INSERT INTO inventario (prenda_id, talla_id, color_id, sku, stock_actual, stock_minimo) VALUES
(1, 2, 2, 'CAM001-S-BLA', 3, 5),   -- ALERTA: Stock crítico (3 <= 5)
(1, 3, 2, 'CAM001-M-BLA', 15, 6),
(1, 4, 3, 'CAM001-L-AZU', 2, 5),   -- ALERTA: Stock crítico (2 <= 5)
(2, 2, 3, 'JEA002-S-AZU', 20, 8),
(2, 3, 3, 'JEA002-M-AZU', 4, 8),   -- ALERTA: Stock crítico (4 <= 8)
(2, 3, 1, 'JEA002-M-NEG', 1, 5),   -- ALERTA: Stock crítico (1 <= 5)
(3, 2, 4, 'VES003-S-ROJ', 8, 4),
(3, 3, 4, 'VES003-M-ROJ', 12, 4),
(4, 3, 5, 'CHA004-M-VER', 7, 5),
(4, 4, 1, 'CHA004-L-NEG', 0, 4),   -- ALERTA: Agotado total (0 <= 4)
(5, 3, 2, 'POL005-M-BLA', 18, 5);

-- 9. Clientes
INSERT INTO clientes (documento, nombre, apellido, telefono, correo, direccion) VALUES
('1014234567', 'Carolina', 'Herrera', '3123456789', 'caro.herrera@gmail.com', 'Calle 100 # 15-30, Bogotá'),
('1018987654', 'Mateo', 'Gutiérrez', '3104561234', 'mateo.gtz@hotmail.com', 'Cra 50 # 80-10, Bogotá'),
('1020456789', 'Valeria', 'Duque', '3178901234', 'valeria.duque@yahoo.com', 'Calle 45 # 28-04, Medellín'),
('1032123456', 'Santiago', 'Mora', '3009876543', 'santi.mora@gmail.com', 'Av. Pasoancho # 66-12, Cali'),
('1098765432', 'Camila', 'Osorio', '3165432198', 'cosorio@outlook.com', 'Cra 27 # 40-50, Bucaramanga');

-- 10. Ventas
INSERT INTO ventas (numero_factura, cliente_id, usuario_id, fecha_venta, subtotal, iva, total, metodo_pago, estado) VALUES
('FAC-2024-0001', 1, 2, '2024-03-01 10:30:00', 199800.00, 37962.00, 237762.00, 'TARJETA', 'COMPLETADA'),
('FAC-2024-0002', 2, 3, '2024-03-05 14:15:00', 119900.00, 22781.00, 142681.00, 'EFECTIVO', 'COMPLETADA'),
('FAC-2024-0003', 3, 2, '2024-03-12 16:45:00', 209800.00, 39862.00, 249662.00, 'TRANSFERENCIA', 'COMPLETADA'),
('FAC-2024-0004', 1, 2, '2024-04-02 11:00:00', 149900.00, 28481.00, 178381.00, 'TARJETA', 'COMPLETADA'),
('FAC-2024-0005', 4, 3, '2024-04-10 17:20:00', 179800.00, 34162.00, 213962.00, 'EFECTIVO', 'COMPLETADA'),
('FAC-2024-0006', 5, 2, '2024-04-18 18:00:00', 59900.00, 11381.00, 71281.00, 'EFECTIVO', 'COMPLETADA');

-- 11. Detalle de Ventas
INSERT INTO detalle_ventas (venta_id, inventario_id, cantidad, precio_unitario, subtotal) VALUES
-- Factura 1: 1 Jean Skinny S-Azul + 1 Camisa Oxford Slim Fit M-Blanca
(1, 4, 1, 119900.00, 119900.00),
(1, 2, 1, 79900.00, 79900.00),
-- Factura 2: 1 Jean Skinny S-Azul
(2, 4, 1, 119900.00, 119900.00),
-- Factura 3: 1 Vestido M-Rojo + 1 Jean Skinny S-Azul
(3, 8, 1, 95000.00, 95000.00),
(3, 4, 1, 114800.00, 114800.00),
-- Factura 4: 1 Chaqueta Bomber L-Negra
(4, 10, 1, 149900.00, 149900.00),
-- Factura 5: 1 Jean Skinny M-Azul + 1 Camiseta Polo M-Blanca
(5, 5, 1, 119900.00, 119900.00),
(5, 11, 1, 59900.00, 59900.00),
-- Factura 6: 1 Camiseta Polo M-Blanca
(6, 11, 1, 59900.00, 59900.00);