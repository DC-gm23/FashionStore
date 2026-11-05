-- =====================================================
-- PROYECTO: FashionStore – Tienda de Ropa
-- ARCHIVO: database/consultas.sql
-- DESCRIPCIÓN: Consultas de lógica de negocio y analítica
-- =====================================================

USE local_xampp_d;

-- =====================================================
-- 1. OPERACIONES BÁSICAS (CRUD)
-- =====================================================

-- [INSERT] Registrar una nueva prenda en el catálogo
INSERT INTO prendas (codigo_referencia, categoria_id, proveedor_id, nombre, descripcion, precio_compra, precio_venta, estado)
VALUES ('REF-CHA-006', 4, 1, 'Chaqueta de Cuero Biker', 'Chaqueta 100% cuero ecológico con forro térmico', 85000.00, 189900.00, 'ACTIVO');

-- [SELECT con WHERE y ORDER BY] Buscar prendas activas de una categoría ordenadas por precio descendente
SELECT id, codigo_referencia, nombre, precio_venta
FROM prendas
WHERE estado = 'ACTIVO' AND categoria_id = 1
ORDER BY precio_venta DESC;

-- [UPDATE con WHERE] Actualizar existencias tras un reabastecimiento en bodega
UPDATE inventario
SET stock_actual = stock_actual + 10
WHERE sku = 'CAM001-S-BLA';

-- [DELETE con WHERE] Eliminación lógica o física controlada (ejemplo de eliminación física de un registro sin ventas)
DELETE FROM clientes
WHERE id = 5 AND NOT EXISTS (SELECT 1 FROM ventas WHERE cliente_id = 5);


-- =====================================================
-- 2. CONSULTAS CON RELACIONES (JOINs)
-- =====================================================

-- Vista detallada de inventario: Muestra el SKU completo, Prenda, Categoría, Color, Talla, Stock y Proveedor
SELECT 
    inv.sku,
    p.codigo_referencia,
    p.nombre AS prenda,
    cat.nombre AS categoria,
    t.codigo AS talla,
    col.nombre AS color,
    prov.razon_social AS proveedor,
    inv.stock_actual,
    inv.stock_minimo,
    p.precio_venta
FROM inventario inv
INNER JOIN prendas p ON inv.prenda_id = p.id
INNER JOIN categorias cat ON p.categoria_id = cat.id
INNER JOIN tallas t ON inv.talla_id = t.id
INNER JOIN colores col ON inv.color_id = col.id
INNER JOIN proveedores prov ON p.proveedor_id = prov.id
ORDER BY p.nombre ASC, t.id ASC;

-- Detalle de una factura específica con datos del cliente y vendedor
SELECT 
    v.numero_factura,
    v.fecha_venta,
    CONCAT(cli.nombre, ' ', cli.apellido) AS cliente,
    cli.documento,
    u.nombre AS vendedor,
    p.nombre AS producto,
    t.codigo AS talla,
    col.nombre AS color,
    det.cantidad,
    det.precio_unitario,
    det.subtotal
FROM ventas v
INNER JOIN clientes cli ON v.cliente_id = cli.id
INNER JOIN usuarios u ON v.usuario_id = u.id
INNER JOIN detalle_ventas det ON v.id = det.venta_id
INNER JOIN inventario inv ON det.inventario_id = inv.id
INNER JOIN prendas p ON inv.prenda_id = p.id
INNER JOIN tallas t ON inv.talla_id = t.id
INNER JOIN colores col ON inv.color_id = col.id
WHERE v.numero_factura = 'FAC-2024-0001';


-- =====================================================
-- 3. FUNCIONALIDAD INNOVADORA 1: ALERTAS DE REPOSICIÓN
-- =====================================================

-- Alerta de reposición automática: Identifica los SKUs con stock igual o inferior al mínimo configurado,
-- calculando las unidades sugeridas a pedir al proveedor y mostrando el contacto directo.
SELECT 
    inv.sku,
    p.nombre AS prenda,
    t.codigo AS talla,
    col.nombre AS color,
    inv.stock_actual,
    inv.stock_minimo,
    (inv.stock_minimo * 2 - inv.stock_actual) AS pedido_sugerido,
    prov.razon_social AS proveedor,
    prov.telefono AS contacto_proveedor,
    CASE 
        WHEN inv.stock_actual = 0 THEN 'URGENTE: AGOTADO'
        WHEN inv.stock_actual <= (inv.stock_minimo / 2) THEN 'ALERTA: STOCK CRÍTICO'
        ELSE 'REPOSICIÓN REQUERIDA'
    END AS nivel_alerta
FROM inventario inv
INNER JOIN prendas p ON inv.prenda_id = p.id
INNER JOIN tallas t ON inv.talla_id = t.id
INNER JOIN colores col ON inv.color_id = col.id
INNER JOIN proveedores prov ON p.proveedor_id = prov.id
WHERE inv.stock_actual <= inv.stock_minimo
ORDER BY inv.stock_actual ASC;


-- =====================================================
-- 4. FUNCIONALIDAD INNOVADORA 2: ANÁLISIS DE TENDENCIAS DE VENTAS
-- =====================================================

-- Tendencia de Productos Más Vendidos: Top prendas con mayor volumen de salida e ingresos generados
SELECT 
    p.codigo_referencia,
    p.nombre AS prenda,
    cat.nombre AS categoria,
    COUNT(det.id) AS transacciones,
    SUM(det.cantidad) AS unidades_vendidas,
    SUM(det.subtotal) AS ingresos_totales
FROM detalle_ventas det
INNER JOIN inventario inv ON det.inventario_id = inv.id
INNER JOIN prendas p ON inv.prenda_id = p.id
INNER JOIN categorias cat ON p.categoria_id = cat.id
INNER JOIN ventas v ON det.venta_id = v.id
WHERE v.estado = 'COMPLETADA'
GROUP BY p.codigo_referencia, p.nombre, cat.nombre
ORDER BY unidades_vendidas DESC;

-- Rendimiento y Rentabilidad por Categoría (Uso de COUNT, SUM, GROUP BY)
SELECT 
    cat.nombre AS categoria,
    COUNT(DISTINCT v.id) AS total_ventas_asociadas,
    SUM(det.cantidad) AS prendas_vendidas,
    SUM(det.subtotal) AS facturacion_total,
    SUM(det.cantidad * p.precio_compra) AS costo_mercancia,
    (SUM(det.subtotal) - SUM(det.cantidad * p.precio_compra)) AS ganancia_bruta
FROM categorias cat
INNER JOIN prendas p ON cat.id = p.categoria_id
INNER JOIN inventario inv ON p.id = inv.prenda_id
INNER JOIN detalle_ventas det ON inv.id = det.inventario_id
INNER JOIN ventas v ON det.venta_id = v.id
WHERE v.estado = 'COMPLETADA'
GROUP BY cat.id, cat.nombre
ORDER BY facturacion_total DESC;

-- Tendencia Mensual de Ingresos y Facturación (Histórico para dashboard)
SELECT 
    DATE_FORMAT(fecha_venta, '%Y-%m') AS periodo_mes,
    COUNT(id) AS cantidad_facturas,
    SUM(total) AS total_ingresos
FROM ventas
WHERE estado = 'COMPLETADA'
GROUP BY periodo_mes
ORDER BY periodo_mes DESC;


-- =====================================================
-- 5. CLÁUSULAS AVANZADAS: HAVING
-- =====================================================

-- Clientes frecuentes (Fidelización): Clientes que han realizado 2 o más compras
SELECT 
    cli.id,
    CONCAT(cli.nombre, ' ', cli.apellido) AS cliente,
    cli.telefono,
    cli.correo,
    COUNT(v.id) AS total_compras,
    SUM(v.total) AS monto_acumulado
FROM clientes cli
INNER JOIN ventas v ON cli.id = v.cliente_id
WHERE v.estado = 'COMPLETADA'
GROUP BY cli.id, cli.nombre, cli.apellido, cli.telefono, cli.correo
HAVING COUNT(v.id) >= 2
ORDER BY monto_acumulado DESC;

-- Categorías de Alta Salida: Categorías que han vendido más de 2 unidades en total
SELECT 
    cat.nombre AS categoria,
    SUM(det.cantidad) AS total_unidades
FROM categorias cat
INNER JOIN prendas p ON cat.id = p.categoria_id
INNER JOIN inventario inv ON p.id = inv.prenda_id
INNER JOIN detalle_ventas det ON inv.id = det.inventario_id
GROUP BY cat.id, cat.nombre
HAVING SUM(det.cantidad) > 2
ORDER BY total_unidades DESC;