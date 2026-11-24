-- ---------------------------------------------------------------------------------
-- Scripts - Enunciados 3, 4, 5, 6 y 7 DML para consultas Sin Join, 1 Join, 2 Join, 3 Join y 4 Join
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- 3.- Enunciado para Consulta sin JOIN
-- Análisis de Precios y Disponibilidad en Oferta de Productos
-- ---------------------------------------------------------------------------------
SELECT id_producto                      AS codigo_producto,
       nombre                           AS titulo_producto,
       precio                           AS precio_base,
       ROUND(precio * 1.05, 2)          AS precio_venta_con_recargo_5pct,
       estado                           AS estado_disponibilidad
FROM producto
WHERE precio BETWEEN 50000 AND 500000
  AND estado = 'Disponible'
ORDER BY precio DESC
LIMIT 20;


-- ---------------------------------------------------------------------------------
-- 4.- Enunciado para consulta con 1 JOIN. 
-- Censo Institucional de Usuarios por Categoría
-- -----------------------------------------------------------------------------------
SELECT tu.nombre            AS categoria_usuario,
       COUNT(u.id_usuario)  AS total_usuarios
FROM usuario u
JOIN tipo_usuario tu ON tu.id_tipo_usuario = u.id_tipo_usuario
GROUP BY tu.nombre
ORDER BY total_usuarios DESC;


-- ---------------------------------------------------------------------------------
-- 5.- Enunciado para consulta con 2 JOINs
-- Trazabilidad de Eventos Académicos y sus Organizadores
-- ---------------------------------------------------------------------------------
SELECT e.titulo                          AS titulo_evento,
       te.nombre                         AS tipo_evento,
       e.fecha_inicio                    AS fecha_realizacion,
       u.nombre || ' ' || u.apellido     AS organizador,
       u.correo                          AS correo_organizador
FROM evento e
JOIN tipo_evento te ON te.id_tipo_evento = e.id_tipo_evento
JOIN usuario u      ON u.id_usuario      = e.id_usuario_organizador
WHERE e.fecha_inicio >= TIMESTAMPTZ '2024-01-01'
  AND e.fecha_inicio <  TIMESTAMPTZ '2026-01-01'      -- años 2024 y 2025
ORDER BY e.fecha_inicio
LIMIT 100;


-- ---------------------------------------------------------------------------------
-- 6.- Enunciado para consulta SELECT con 3 JOINs
-- Consumo de Servicios Académicos por Estudiantes Activos
-- ---------------------------------------------------------------------------------
SELECT u.nombre || ' ' || u.apellido  AS estudiante_solicitante,
       s.nombre                       AS servicio_solicitado,
       ts.nombre                      AS categoria_servicio,
       us.fecha_asignacion            AS fecha_solicitud
FROM usuario_servicio us
JOIN servicio s       ON s.id_servicio       = us.id_servicio
JOIN tipo_servicio ts ON ts.id_tipo_servicio = s.id_tipo_servicio
JOIN usuario u        ON u.id_usuario        = us.id_usuario
WHERE u.id_tipo_usuario = 1
  AND us.estado = 'FINALIZADO'
ORDER BY us.fecha_asignacion DESC
LIMIT 100;


-- ---------------------------------------------------------------------------------
-- 7.- Enunciado para consulta con 4 JOINs
-- Reporte Transaccional Consolidado de Venta de Productos
-- ---------------------------------------------------------------------------------
SELECT p.nombre                        AS titulo_producto,
       tp.nombre                       AS categoria_producto,
       pt.precio_pagado                AS precio_pagado,
       u.nombre || ' ' || u.apellido   AS comprador,
       tu.nombre                       AS tipo_usuario_comprador
FROM producto_transaccion pt
JOIN producto p       ON p.id_producto       = pt.id_producto
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
JOIN usuario u        ON u.id_usuario        = pt.id_usuario_comprador
JOIN tipo_usuario tu  ON tu.id_tipo_usuario  = u.id_tipo_usuario
WHERE tu.nombre IN ('Egresado', 'Estudiante')
  AND pt.precio_pagado > 100000
ORDER BY pt.precio_pagado DESC
LIMIT 100;


