--
-- Scripts - 8.- Enunciados para Consultas con Funciones de Agregación
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Script del Enunciado 8.1 — Función COUNT: Volumen Global de Solicitudes de Servicio
-- Calcular la cantidad total de solicitudes de servicios registradas en la plataforma agrupadas por el estado de la transacción (Completado, Pendiente, Cancelado). 
-- (servicio_solicitud = usuario_servicio: FINALIZADO = Completado, SOLICITADO/EN_CURSO = Pendiente, CANCELADO = Cancelado)
-- ---------------------------------------------------------------------------------------------------------------------------------
SELECT CASE us.estado
           WHEN 'FINALIZADO' THEN 'Completado'
           WHEN 'CANCELADO'  THEN 'Cancelado'
           ELSE 'Pendiente'
       END                AS estado_solicitud,
       COUNT(*)           AS total_solicitudes
FROM usuario_servicio us
GROUP BY 1
ORDER BY total_solicitudes DESC;



-- ---------------------------------------------------------------------------------------------------------------------------------
-- Script del Enunciado 8.2 — Función SUM: Recaudo Comercial Total por Categoría de Producto
-- Calcular el monto total acumulado ($) en ventas de productos pertenecientes a la categoría 'Libros' y 'Tecnología/Computadores'.
-- ---------------------------------------------------------------------------------------------------------------------------------
SELECT tp.nombre            AS categoria_producto,
       COUNT(*)             AS cantidad_ventas,
       SUM(pt.precio_pagado) AS recaudo_total
FROM producto_transaccion pt
JOIN producto p       ON p.id_producto       = pt.id_producto
JOIN tipo_producto tp ON tp.id_tipo_producto = p.id_tipo_producto
WHERE tp.nombre IN ('Libros', 'Tecnología/Computadores')
GROUP BY tp.nombre
ORDER BY recaudo_total DESC;