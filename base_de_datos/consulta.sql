-- ------------------------------------------------------------
-- 1. VERIFICACIÓN DE CARGA DE TABLAS
-- ------------------------------------------------------------
SELECT 'customers' AS nombre_tabla,
        COUNT(*) AS cantidad_registros
FROM customers

UNION ALL

SELECT 'products',
        COUNT(*)
FROM products

UNION ALL

SELECT 'orders',
        COUNT(*)
FROM orders

UNION ALL

SELECT 'payments',
        COUNT(*)
FROM payments

UNION ALL

SELECT 'order_items',
        COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_status_history',
        COUNT(*)
FROM order_status_history

UNION ALL

SELECT 'order_audit',
        COUNT(*)
FROM order_audit;

/* 2. BÚSQUEDA DE ERRORES E INCONSISTENCIAS DE INTEGRIDAD */

-- 2.A Órdenes sin cliente (órdenes huérfanas)
SELECT COUNT(*) AS ordenes_sin_clientes
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 2.B Pagos sin orden asociada
SELECT COUNT(*) AS pagos_sin_orden
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 2.C Órdenes sin ítems asociados
SELECT COUNT(*) AS ordenes_sin_items
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- 2.D Órdenes sin historial de estado
SELECT 
    o.order_id,
    o.current_status,
    o.order_datetime
FROM orders o
LEFT JOIN order_status_history osh
    ON o.order_id = osh.order_id
WHERE osh.status_history_id IS NULL
ORDER BY o.order_id
LIMIT 12;

/* 3. VALIDACIÓN DE REGLAS DE NEGOCIO ====================== */

-- 3.A Órdenes con total negativo
SELECT COUNT(*) AS ordenes_negativas
FROM orders
WHERE order_total < 0;

-- 3.B Productos con precios o costos inválidos
SELECT COUNT(*) AS productos_invalidos
FROM products
WHERE unit_price < 0
    OR unit_cost < 0
    OR unit_price < unit_cost;

/* 4. AUDITORÍA DE PEDIDOS ===================================== */

-- 4.1 Últimos pedidos cancelados
SELECT
    o.order_id,
    o.order_datetime,
    c.full_name,
    c.email,
    o.current_status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.current_status = 'cancelled'
ORDER BY o.order_datetime DESC
LIMIT 12;

-- ------------------------------------------------------------
-- 4.2 Detalle completo de un pedido específico
-- ------------------------------------------------------------
-- Propósito: Muestra el detalle de un pedido específico
-- (ejemplo con order_id = 26276).
-- ------------------------------------------------------------
SELECT
    o.order_id,
    o.order_datetime,
    c.full_name,
    c.email,
    o.current_status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_id = 26276;

/* ============================================================
    5. PRODUCTOS Y CATÁLOGO
    ============================================================ */

-- ------------------------------------------------------------
-- 5.1 Productos sin movimiento comercial
-- ------------------------------------------------------------
-- Propósito: Identifica productos que nunca han sido vendidos
-- (no aparecen en order_items).
-- ------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.category
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

/* ============================================================
    6. SEGUIMIENTO DE PAGOS
    ============================================================ */

-- ------------------------------------------------------------
-- 6.1 Pagos en efectivo pendientes
-- ------------------------------------------------------------
-- Propósito: Muestra pagos en efectivo que aún están pendientes
-- para seguimiento y conciliación.
-- ------------------------------------------------------------
SELECT
    c.full_name,
    o.order_id,
    o.current_status,
    p.method,
    p.amount
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE p.method = 'cash'
    AND p.payment_status = 'pending'
LIMIT 12;

/* 7. ANÁLISIS POR MONEDA==================================== */

-- 7.A Pedidos entregados en USD
SELECT
    o.order_id,
    c.full_name,
    o.order_datetime,
    o.order_total,
    o.currency
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.currency = 'USD'
    AND o.current_status = 'delivered'
ORDER BY o.order_datetime DESC
LIMIT 12;

-- 7.B Pedidos entregados en PYG
SELECT
    o.order_id,
    c.full_name,
    o.order_datetime,
    o.order_total,
    o.currency
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.currency = 'PYG'
    AND o.current_status = 'delivered'
ORDER BY o.order_datetime DESC
LIMIT 12;


-- 7.C Clientes sin órdenes
SELECT
    c.customer_id,
    c.full_name,
    c.email
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

/* 8. RESUMEN DE PROBLEMAS DE INTEGRIDAD====================== */

SELECT 'Ordenes sin cliente' AS problema,
        COUNT(*) AS cantidad
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'Pagos sin orden',
        COUNT(*)
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'Ordenes con total negativo',
        COUNT(*)
FROM orders
WHERE order_total < 0

UNION ALL

SELECT 'Productos con precios invalidos',
        COUNT(*)
FROM products
WHERE unit_price < 0
    OR unit_cost < 0
    OR unit_price < unit_cost

UNION ALL

SELECT 'Ordenes sin items',
        COUNT(*)
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;