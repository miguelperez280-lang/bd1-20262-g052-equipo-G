-- ---------------------------------------------------------------------------------------------------------------------------------
-- 9.- Enunciado para creación de Vista (VIEW) con 4 JOINs, GROUP BY y HAVING
-- Construya una vista (VIEW) con el enunciado del ítem 7. Debe crear la vista (darle un nombre) y ejecutarla.
-- ---------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_reporte_ventas_consolidado AS
SELECT p.nombre                         AS titulo_producto,
       tp.nombre                        AS categoria_producto,
       u.id_usuario                     AS id_comprador,
       u.nombre || ' ' || u.apellido    AS comprador,
       tu.nombre                        AS tipo_usuario_comprador,
       SUM(pt.precio_pagado)            AS total_pagado
FROM producto_transaccion pt
JOIN producto p       ON p.id_producto       = pt.id_producto
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
JOIN usuario u        ON u.id_usuario        = pt.id_usuario_comprador
JOIN tipo_usuario tu  ON tu.id_tipo_usuario  = u.id_tipo_usuario
WHERE tu.nombre IN ('Egresado', 'Estudiante')
GROUP BY p.nombre, tp.nombre, u.id_usuario, u.nombre, u.apellido, tu.nombre
HAVING SUM(pt.precio_pagado) > 100000;

SELECT * FROM vw_reporte_ventas_consolidado ORDER BY total_pagado DESC LIMIT 50;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 10.- Ejercicio del enunciado para consulta parametrizada (PREPARE / EXECUTE) con 4 JOINs (GROUP BY y HAVING)
-- ---------------------------------------------------------------------------------------------------------------------------------
PREPARE stmt_analisis_participacion_eventos (INT, DATE) AS
SELECT o.id_usuario                       AS id_organizador,
       o.nombre || ' ' || o.apellido      AS organizador,
       te.nombre                          AS tipo_evento,
       COUNT(*)                           AS total_participantes_confirmados
FROM evento_usuario eu
JOIN evento e        ON e.id_evento        = eu.id_evento
JOIN tipo_evento te  ON te.id_tipo_evento  = e.id_tipo_evento
JOIN usuario o       ON o.id_usuario       = e.id_usuario_organizador
JOIN tipo_usuario tu ON tu.id_tipo_usuario = o.id_tipo_usuario
WHERE e.id_tipo_evento = $1
  AND e.fecha_inicio  >= $2
  AND eu.estado = 'CONFIRMADO'
GROUP BY o.id_usuario, o.nombre, o.apellido, te.nombre
HAVING COUNT(*) >= 10
ORDER BY total_participantes_confirmados DESC;

EXECUTE stmt_analisis_participacion_eventos (3, DATE '2024-01-01');
EXECUTE stmt_analisis_participacion_eventos (1, DATE '2025-01-01');

DEALLOCATE stmt_analisis_participacion_eventos;


-- ---------------------------------------------------------------------------------------------------------------------------------
--11.- Ejercicio del enunciado para Evaluación Experimental de Rendimiento con ANALYZE
-- ---------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS usuario_1000;
DROP TABLE IF EXISTS usuario_100000;

CREATE TABLE usuario_1000 (
    id_usuario       INTEGER      PRIMARY KEY,
    id_tipo_usuario  SMALLINT     NOT NULL,
    nombre           VARCHAR(60)  NOT NULL,
    fecha_registro   TIMESTAMPTZ  NOT NULL
);
CREATE TABLE usuario_100000 (LIKE usuario_1000 INCLUDING ALL);

INSERT INTO usuario_1000
SELECT g, 1 + floor(random() * 9)::int, 'Nombre' || g,
       TIMESTAMPTZ '2023-01-01' + random() * (TIMESTAMPTZ '2026-11-01' - TIMESTAMPTZ '2023-01-01')
FROM generate_series(1, 1000) g;

INSERT INTO usuario_100000
SELECT g, 1 + floor(random() * 9)::int, 'Nombre' || g,
       TIMESTAMPTZ '2023-01-01' + random() * (TIMESTAMPTZ '2026-11-01' - TIMESTAMPTZ '2023-01-01')
FROM generate_series(1, 100000) g;

ANALYZE usuario_1000;
ANALYZE usuario_100000;

-- Misma consulta en ambas tablas (sin índice)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios
FROM usuario_1000
WHERE fecha_registro >= TIMESTAMPTZ '2025-06-01' AND fecha_registro < TIMESTAMPTZ '2025-07-01'
GROUP BY id_tipo_usuario;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios
FROM usuario_100000
WHERE fecha_registro >= TIMESTAMPTZ '2025-06-01' AND fecha_registro < TIMESTAMPTZ '2025-07-01'
GROUP BY id_tipo_usuario;

-- Misma consulta en ambas tablas (con índice sobre fecha_registro)
CREATE INDEX idx_usuario_1000_fecha   ON usuario_1000   (fecha_registro);
CREATE INDEX idx_usuario_100000_fecha ON usuario_100000 (fecha_registro);

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios
FROM usuario_1000
WHERE fecha_registro >= TIMESTAMPTZ '2025-06-01' AND fecha_registro < TIMESTAMPTZ '2025-07-01'
GROUP BY id_tipo_usuario;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_tipo_usuario, COUNT(*) AS total_usuarios
FROM usuario_100000
WHERE fecha_registro >= TIMESTAMPTZ '2025-06-01' AND fecha_registro < TIMESTAMPTZ '2025-07-01'
GROUP BY id_tipo_usuario;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.- Enunciado para Validación de Propiedades ACID en 4 Tablas del DDL
-- ---------------------------------------------------------------------------------------------------------------------------------
-- (pgAdmin se detiene al primer ERROR: ejecutar cada bloque sentencia por sentencia, seleccionando y presionando F5)

-- Preparación: producto de prueba con stock = 2
INSERT INTO producto (id_tipo_producto, id_usuario_vendedor, nombre, descripcion, precio, stock, estado)
SELECT 1, 1, 'PRODUCTO PRUEBA ACID', 'Producto para validar ACID', 150000, 2, 'Disponible'
WHERE NOT EXISTS (SELECT 1 FROM producto WHERE nombre = 'PRODUCTO PRUEBA ACID');

UPDATE producto SET stock = 2 WHERE nombre = 'PRODUCTO PRUEBA ACID';

-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.1.- Atomicidad (Atomicity): Demostrar que una compra de un producto que falla en medio de la transacción por 
-- saldo  insuficiente o error de clave foránea revierte absolutamente todas las operaciones previas mediante ROLLBACK, 
-- dejando las tablas intactas.
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Estado inicial (antes de la transacción)
SELECT p.nombre, p.stock,
       (SELECT COUNT(*) FROM producto_transaccion pt WHERE pt.id_producto = p.id_producto) AS compras_registradas
FROM producto p WHERE p.nombre = 'PRODUCTO PRUEBA ACID';

BEGIN;
    -- Paso 1: se registra la compra de 5 unidades (OK)
    INSERT INTO producto_transaccion (id_producto, id_usuario_comprador, cantidad, precio_pagado)
    SELECT id_producto, 2, 5, precio * 5 FROM producto WHERE nombre = 'PRODUCTO PRUEBA ACID';

    -- Paso 2: se descuenta el stock -> ERROR esperado (stock insuficiente, viola ck_producto_stock)
    UPDATE producto SET stock = stock - 5 WHERE nombre = 'PRODUCTO PRUEBA ACID';
ROLLBACK;

-- Estado final: igual al inicial (el INSERT del Paso 1 también se revirtió)
SELECT p.nombre, p.stock,
       (SELECT COUNT(*) FROM producto_transaccion pt WHERE pt.id_producto = p.id_producto) AS compras_registradas
FROM producto p WHERE p.nombre = 'PRODUCTO PRUEBA ACID';


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.2.- Consistencia (Consistency): Demostrar cómo las restricciones de integridad física (CHECK precio >= 0, FOREIGN KEY, NOT NULL) 
-- impiden que la base de datos ingrese a un estado de datos inconsistente o embasurado.
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Conteos iniciales
SELECT COUNT(*) AS productos_antes FROM producto;

BEGIN;
    SAVEPOINT sp_check;      -- CHECK (precio >= 0) -> ERROR
    INSERT INTO producto (id_tipo_producto, id_usuario_vendedor, nombre, precio, stock)
    VALUES (1, 1, 'Producto con precio negativo', -5000, 1);
    ROLLBACK TO SAVEPOINT sp_check;

    SAVEPOINT sp_fk;         -- FOREIGN KEY (tipo de producto inexistente) -> ERROR
    INSERT INTO producto (id_tipo_producto, id_usuario_vendedor, nombre, precio, stock)
    VALUES (999, 1, 'Producto con categoría inexistente', 10000, 1);
    ROLLBACK TO SAVEPOINT sp_fk;

    SAVEPOINT sp_notnull;    -- NOT NULL (nombre) -> ERROR
    INSERT INTO producto (id_tipo_producto, id_usuario_vendedor, nombre, precio, stock)
    VALUES (1, 1, NULL, 10000, 1);
    ROLLBACK TO SAVEPOINT sp_notnull;
ROLLBACK;

-- Conteo final: igual al inicial, no entró ningún dato inconsistente
SELECT COUNT(*) AS productos_despues FROM producto;


-- ---------------------------------------------------------------------------------------------------------------------------------
-- 12.4.- Durabilidad (Durability): Demostrar que una vez ejecutado exitosamente el comando COMMIT, los datos persisten de manera 
-- permanente en el almacenamiento físico de PostgreSQL (archivos WAL) incluso ante una simulación de desconexión imprevista del servidor.
-- ---------------------------------------------------------------------------------------------------------------------------------
BEGIN;
    INSERT INTO producto_transaccion (id_producto, id_usuario_comprador, cantidad, precio_pagado)
    SELECT id_producto, 2, 1, precio FROM producto WHERE nombre = 'PRODUCTO PRUEBA ACID';
    UPDATE producto SET stock = stock - 1 WHERE nombre = 'PRODUCTO PRUEBA ACID';
COMMIT;

-- Posición actual del registro WAL y archivo WAL donde quedó escrito el COMMIT
SELECT pg_current_wal_lsn() AS lsn, pg_walfile_name(pg_current_wal_lsn()) AS archivo_wal;

-- Simulación de desconexión imprevista (pgAdmin pierde la conexión: reconectar)
SELECT pg_terminate_backend(pg_backend_pid());

-- Nueva sesión: los datos confirmados siguen ahí
SELECT pt.id_transaccion, pt.cantidad, pt.precio_pagado, p.stock
FROM producto_transaccion pt
JOIN producto p ON p.id_producto = pt.id_producto
WHERE p.nombre = 'PRODUCTO PRUEBA ACID';