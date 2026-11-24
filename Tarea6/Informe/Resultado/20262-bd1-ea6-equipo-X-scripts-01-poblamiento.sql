--
-- Script Poblamiento
-- Red Social Pascualina - EA6 - PostgreSQL
--

--
--  Ajustes 
--    

BEGIN;

ALTER TABLE perfil
    ADD COLUMN datos_profesional JSONB;

ALTER TABLE producto
    ADD COLUMN estado VARCHAR(15) NOT NULL DEFAULT 'Disponible',
    ADD CONSTRAINT ck_producto_estado CHECK (estado IN ('Disponible', 'Agotado', 'Inactivo'));

CREATE TABLE evento_usuario (
    id_evento          INTEGER      NOT NULL,
    id_usuario         INTEGER      NOT NULL,
    fecha_inscripcion  TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado             VARCHAR(15)  NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT pk_evento_usuario        PRIMARY KEY (id_evento, id_usuario),
    CONSTRAINT ck_evento_usuario_estado CHECK (estado IN ('PENDIENTE', 'CONFIRMADO', 'CANCELADO')),
    CONSTRAINT fk_evento_usuario_evento
        FOREIGN KEY (id_evento) REFERENCES evento (id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_evento_usuario_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE producto_transaccion (
    id_transaccion        BIGSERIAL,
    id_producto           INTEGER        NOT NULL,
    id_usuario_comprador  INTEGER        NOT NULL,
    cantidad              INTEGER        NOT NULL DEFAULT 1,
    precio_pagado         NUMERIC(12,2)  NOT NULL,
    fecha_transaccion     TIMESTAMPTZ    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_producto_transaccion          PRIMARY KEY (id_transaccion),
    CONSTRAINT ck_producto_transaccion_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_producto_transaccion_precio   CHECK (precio_pagado >= 0),
    CONSTRAINT fk_producto_transaccion_producto
        FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_producto_transaccion_comprador
        FOREIGN KEY (id_usuario_comprador) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMIT;


--
-- 1.1- Poblamiento Directo mediante INSERT INTO (Catálogos Base):
--

-- Tabla rol: 4 registros
INSERT INTO rol (id_rol, nombre, descripcion) VALUES
(1, 'Administrador', 'Control total de la plataforma'),
(2, 'Auxiliar',      'Apoyo en la moderación y gestión de contenidos'),
(3, 'Miembro',       'Usuario registrado con acceso a las funciones de la red'),
(4, 'Visitante',     'Acceso restringido de solo consulta');

-- Tabla tipo_usuario: 9 registros 
INSERT INTO tipo_usuario (id_tipo_usuario, nombre, descripcion) VALUES
(1, 'Estudiante',    'Estudiante activo de la institución'),
(2, 'Docente',       'Docente vinculado a la institución'),
(3, 'Egresado',      'Graduado de la institución'),
(4, 'Empleado',      'Personal administrativo vinculado'),
(5, 'Empresario',    'Empresario aliado de la comunidad'),
(6, 'Ex-Empleado',   'Antiguo personal administrativo'),
(7, 'Ex-Estudiante', 'Antiguo estudiante no graduado'),
(8, 'Ex-Docente',    'Antiguo docente de la institución'),
(9, 'Guess',         'Invitado externo a la comunidad');

-- Tabla tipo_servicio: 20 registros 
INSERT INTO tipo_servicio (id_tipo_servicio, nombre, descripcion) VALUES
(1,  'Asesoría académica',        'Acompañamiento en asignaturas y trabajos'),
(2,  'Tutoría',                   'Tutorías personalizadas por materia'),
(3,  'Monitoría',                 'Monitorías de apoyo a cursos'),
(4,  'Mantenimiento Moto',        'Revisión y mantenimiento de motocicletas'),
(5,  'Mantenimiento Computadores','Reparación y mantenimiento de equipos'),
(6,  'Desarrollo de Software',    'Desarrollo de aplicaciones y sitios web'),
(7,  'Diseño Gráfico',            'Piezas gráficas e identidad visual'),
(8,  'Fotografía',                'Cubrimiento fotográfico de actividades'),
(9,  'Transporte',                'Transporte y domicilios'),
(10, 'Clases de Idiomas',         'Clases particulares de idiomas'),
(11, 'Clases de Música',          'Clases particulares de música'),
(12, 'Asesoría Contable',         'Apoyo en temas contables y tributarios'),
(13, 'Asesoría Jurídica',         'Orientación legal básica'),
(14, 'Traducción',                'Traducción de documentos'),
(15, 'Corrección de Textos',      'Revisión de redacción y ortografía'),
(16, 'Alquiler de Equipos',       'Alquiler de equipos y herramientas'),
(17, 'Catering',                  'Alimentación para eventos'),
(18, 'Entrenamiento Deportivo',   'Entrenamiento personalizado'),
(19, 'Asesoría de Proyectos',     'Acompañamiento en proyectos y emprendimientos'),
(20, 'Otros Servicios',           'Servicios no clasificados');

-- Tabla tipo_producto: 20 registros 
INSERT INTO tipo_producto (id_tipo_producto, nombre, descripcion) VALUES
(1,  'Libros',                   'Libros académicos y de literatura'),
(2,  'Tecnología/Computadores',  'Computadores, periféricos y accesorios'),
(3,  'Motocicletas',             'Motocicletas nuevas y usadas'),
(4,  'Alimentos',                'Comestibles y bebidas'),
(5,  'Papelería',                'Útiles escolares y de oficina'),
(6,  'Ropa',                     'Prendas de vestir'),
(7,  'Calzado',                  'Zapatos y tenis'),
(8,  'Accesorios',               'Accesorios personales'),
(9,  'Electrodomésticos',        'Electrodomésticos del hogar'),
(10, 'Muebles',                  'Muebles y enseres'),
(11, 'Deportes',                 'Artículos deportivos'),
(12, 'Instrumentos Musicales',   'Instrumentos y accesorios musicales'),
(13, 'Herramientas',             'Herramientas manuales y eléctricas'),
(14, 'Repuestos',                'Repuestos para vehículos y equipos'),
(15, 'Bicicletas',               'Bicicletas y accesorios'),
(16, 'Videojuegos',              'Consolas y videojuegos'),
(17, 'Celulares',                'Teléfonos móviles y accesorios'),
(18, 'Arte y Manualidades',      'Obras y materiales de arte'),
(19, 'Cosméticos',               'Productos de cuidado personal'),
(20, 'Otros Productos',          'Productos no clasificados');

-- Tabla tipo_evento: 20 registros 
INSERT INTO tipo_evento (id_tipo_evento, nombre, descripcion) VALUES
(1,  'Congreso',            'Congresos académicos y científicos'),
(2,  'Conferencia',         'Conferencias y charlas magistrales'),
(3,  'Taller',              'Talleres prácticos'),
(4,  'Seminario',           'Seminarios de profundización'),
(5,  'Hackatón',            'Maratones de programación'),
(6,  'Torneo Deportivo',    'Competencias deportivas'),
(7,  'Evento Cultural',     'Muestras artísticas y culturales'),
(8,  'Feria Empresarial',   'Ferias de emprendimiento y empresa'),
(9,  'Feria de Empleo',     'Ferias de vinculación laboral'),
(10, 'Concierto',           'Presentaciones musicales'),
(11, 'Exposición',          'Exposiciones y muestras'),
(12, 'Charla de Egresados', 'Encuentros con egresados'),
(13, 'Curso Corto',         'Cursos de corta duración'),
(14, 'Webinar',             'Eventos virtuales'),
(15, 'Cine Foro',           'Proyección y discusión de películas'),
(16, 'Jornada de Salud',    'Jornadas de bienestar y salud'),
(17, 'Voluntariado',        'Actividades de responsabilidad social'),
(18, 'Reunión de Grupo',    'Encuentros de grupos y semilleros'),
(19, 'Inducción',           'Jornadas de inducción'),
(20, 'Otros Eventos',       'Eventos no clasificados');

-- Tabla programa: programas académicos usados por usuario y evento
INSERT INTO programa (nombre, facultad, nivel_formacion) VALUES
('Tecnología en Desarrollo de Software',          'Ingeniería',            'TECNOLOGIA'),
('Tecnología en Análisis de Datos',               'Ingeniería',            'TECNOLOGIA'),
('Ingeniería de Software',                        'Ingeniería',            'PROFESIONAL'),
('Ingeniería Mecánica',                           'Ingeniería',            'PROFESIONAL'),
('Ingeniería Eléctrica',                          'Ingeniería',            'PROFESIONAL'),
('Administración de Empresas',                    'Producción y Diseño',   'PROFESIONAL'),
('Diseño Industrial',                             'Producción y Diseño',   'PROFESIONAL'),
('Tecnología en Producción Industrial',           'Producción y Diseño',   'TECNOLOGIA'),
('Técnico en Sistemas',                           'Ingeniería',            'TECNICO'),
('Especialización en Gerencia de Proyectos',      'Producción y Diseño',   'POSGRADO');

--
-- 1.2- Poblamiento Masivo Automatizado (Generadores Aleatorios):
--

WITH distribucion (tipo, cantidad) AS (
    VALUES (1, 7000), (2, 500), (3, 10000), (4, 500), (5, 50),
           (6, 50), (7, 300), (8, 100), (9, 50)
),
gen AS (
    SELECT d.tipo,
           ROW_NUMBER() OVER (ORDER BY d.tipo, g) AS n
    FROM distribucion d
    CROSS JOIN LATERAL generate_series(1, d.cantidad) AS g
),
datos AS (
    SELECT n, tipo,
           (ARRAY['Juan','María','Carlos','Ana','Luis','Laura','Andrés','Camila','Sebastián','Valentina',
                  'Daniel','Sofía','Felipe','Isabela','Santiago','Paula','Mateo','Daniela','Diego','Natalia',
                  'Kevin','Mariana','Julián','Carolina','Esteban','Juliana','David','Manuela','Alejandro','Luisa'])
                  [1 + floor(random() * 30)::int] AS nombre,
           (ARRAY['Gómez','Rodríguez','Martínez','López','García','Hernández','Pérez','Sánchez','Ramírez','Torres',
                  'Flórez','Vargas','Castro','Rojas','Ortiz','Moreno','Muñoz','Álvarez','Restrepo','Ospina',
                  'Galeano','Zapata','Cardona','Giraldo','Mejía','Londoño','Arango','Henao','Jaramillo','Salazar'])
                  [1 + floor(random() * 30)::int] AS apellido,
           1 + floor(random() * 10)::int AS id_programa,
           TIMESTAMPTZ '2023-01-01' + random() * (TIMESTAMPTZ '2026-11-01' - TIMESTAMPTZ '2023-01-01') AS fecha_registro
    FROM gen
)
INSERT INTO usuario (id_rol, id_tipo_usuario, id_programa, nombre, apellido, correo,
                     contrasena_hash, fecha_registro, activo)
SELECT CASE WHEN tipo = 9 THEN 4                       -- Guess -> Visitante
            WHEN tipo = 4 AND n % 50 = 0 THEN 1        -- algunos empleados -> Administrador
            WHEN tipo = 4 AND n % 10 = 0 THEN 2        -- otros empleados -> Auxiliar
            ELSE 3 END,                                -- resto -> Miembro
       tipo,
       id_programa,
       nombre,
       apellido,
       lower(nombre) || '.' || lower(apellido) || n || '@pascualbravo.edu.co',
       md5(random()::text || n::text) || md5(n::text),
       fecha_registro,
       (random() < 0.95)
FROM datos
ORDER BY n;

-- ---------- perfil: un perfil por usuario (1:1) ----------
INSERT INTO perfil (id_usuario, biografia, intereses, semestre, fecha_nacimiento)
SELECT u.id_usuario,
       'Miembro de la Red Social Pascualina',
       (ARRAY['Programación','Bases de datos','Deportes','Música','Emprendimiento','Diseño','Investigación'])
            [1 + floor(random() * 7)::int],
       CASE WHEN u.id_tipo_usuario = 1 THEN 1 + floor(random() * 10)::int END,
       DATE '1965-01-01' + floor(random() * 14000)::int
FROM usuario u;

-- ---------- evento: 3.000 registros ----------
-- Los organizadores son 60 docentes (id_tipo_usuario = 2)
WITH org AS (
    SELECT array_agg(id_usuario ORDER BY id_usuario) AS ids
    FROM (SELECT id_usuario FROM usuario WHERE id_tipo_usuario = 2 ORDER BY id_usuario LIMIT 60) s
),
gen AS (
    SELECT g,
           1 + floor(random() * 20)::int AS id_tipo_evento,
           1 + floor(random() * 60)::int AS pos_org,
           1 + floor(random() * 10)::int AS id_programa,
           TIMESTAMPTZ '2024-01-01' + random() * (TIMESTAMPTZ '2026-12-31' - TIMESTAMPTZ '2024-01-01') AS inicio,
           (ARRAY['Auditorio Principal','Sala de Sistemas','Cancha Múltiple','Biblioteca','Aula Magna',
                  'Plazoleta Central','Laboratorio','Sala de Conferencias'])[1 + floor(random() * 8)::int] AS lugar,
           50 + floor(random() * 151)::int AS cupo
    FROM generate_series(1, 3000) g
)
INSERT INTO evento (id_tipo_evento, id_usuario_organizador, id_programa, titulo, descripcion,
                    lugar, fecha_inicio, fecha_fin, cupo_maximo)
SELECT gen.id_tipo_evento,
       org.ids[gen.pos_org],
       gen.id_programa,
       te.nombre || ' institucional No. ' || gen.g,
       'Evento generado automáticamente para la Red Social Pascualina',
       gen.lugar,
       gen.inicio,
       gen.inicio + interval '3 hours',
       gen.cupo
FROM gen
CROSS JOIN org
JOIN tipo_evento te ON te.id_tipo_evento = gen.id_tipo_evento
ORDER BY gen.g;

-- ---------- servicio: 3.000 registros ----------
INSERT INTO servicio (id_tipo_servicio, id_usuario_oferente, nombre, descripcion, precio, activo)
SELECT 1 + floor(random() * 20)::int,
       1 + floor(random() * 18550)::int,
       (ARRAY['Asesoría','Tutoría','Monitoría','Acompañamiento','Taller práctico','Mantenimiento',
              'Revisión técnica','Clase particular'])[1 + floor(random() * 8)::int] || ' No. ' || g,
       'Servicio generado automáticamente para la Red Social Pascualina',
       (floor(random() * 196) * 1000 + 5000)::numeric(12,2),
       (random() < 0.9)
FROM generate_series(1, 3000) g;

-- ---------- producto: 3.000 registros ----------
WITH gen AS (
    SELECT g,
           1 + floor(random() * 20)::int AS id_tipo_producto,
           1 + floor(random() * 18550)::int AS id_vendedor,
           (ARRAY['Libro','Computador','Moto','Combo de comida','Cuaderno','Camiseta','Tenis','Audífonos',
                  'Mesa','Balón','Guitarra','Taladro','Casco','Bicicleta','Consola','Celular'])
                  [1 + floor(random() * 16)::int] AS base,
           (floor(random() * 990) * 1000 + 10000)::numeric(12,2) AS precio,
           random() AS r
    FROM generate_series(1, 3000) g
)
INSERT INTO producto (id_tipo_producto, id_usuario_vendedor, nombre, descripcion, precio, stock, estado)
SELECT id_tipo_producto,
       id_vendedor,
       base || ' No. ' || g,
       'Producto generado automáticamente para la Red Social Pascualina',
       precio,
       CASE WHEN r < 0.80 THEN 1 + floor(random() * 50)::int ELSE 0 END,
       CASE WHEN r < 0.80 THEN 'Disponible' WHEN r < 0.90 THEN 'Agotado' ELSE 'Inactivo' END
FROM gen
ORDER BY g;

-- ---------- evento_usuario (relación): 36.000 registros (12 participantes por evento) ----------
WITH gen AS (
    SELECT e.id_evento, k, random() AS r
    FROM evento e
    CROSS JOIN generate_series(0, 11) AS k
)
INSERT INTO evento_usuario (id_evento, id_usuario, fecha_inscripcion, estado)
SELECT gen.id_evento,
       1 + ((gen.id_evento * 7919 + gen.k * 11979) % 18550),
       e.fecha_inicio - (1 + floor(random() * 30)::int) * interval '1 day',
       CASE WHEN gen.r < 0.75 THEN 'CONFIRMADO' WHEN gen.r < 0.90 THEN 'PENDIENTE' ELSE 'CANCELADO' END
FROM gen
JOIN evento e ON e.id_evento = gen.id_evento;

-- ---------- usuario_servicio (servicio_solicitud): 6.000 registros ----------
WITH gen AS (
    SELECT i, random() AS r
    FROM generate_series(1, 6000) i
)
INSERT INTO usuario_servicio (id_usuario, id_servicio, fecha_asignacion, estado)
SELECT 1 + ((i * 7919) % 18550),
       1 + ((i - 1) % 3000),
       TIMESTAMPTZ '2024-01-01' + random() * (TIMESTAMPTZ '2026-11-01' - TIMESTAMPTZ '2024-01-01'),
       CASE WHEN r < 0.45 THEN 'FINALIZADO'
            WHEN r < 0.65 THEN 'SOLICITADO'
            WHEN r < 0.85 THEN 'EN_CURSO'
            ELSE 'CANCELADO' END
FROM gen
ORDER BY i;

-- ---------- producto_transaccion: 6.000 registros ----------
WITH gen AS (
    SELECT g,
           1 + floor(random() * 3000)::int  AS id_producto,
           1 + floor(random() * 18550)::int AS id_comprador,
           1 + floor(random() * 3)::int     AS cantidad,
           TIMESTAMPTZ '2024-01-01' + random() * (TIMESTAMPTZ '2026-11-01' - TIMESTAMPTZ '2024-01-01') AS fecha
    FROM generate_series(1, 6000) g
)
INSERT INTO producto_transaccion (id_producto, id_usuario_comprador, cantidad, precio_pagado, fecha_transaccion)
SELECT p.id_producto, gen.id_comprador, gen.cantidad, p.precio * gen.cantidad, gen.fecha
FROM gen
JOIN producto p ON p.id_producto = gen.id_producto
WHERE p.id_usuario_vendedor <> gen.id_comprador
ORDER BY gen.g;

-- ---------- Verificación del poblamiento ----------
SELECT 'usuario' AS tabla, COUNT(*) AS registros FROM usuario
UNION ALL SELECT 'perfil',               COUNT(*) FROM perfil
UNION ALL SELECT 'evento',               COUNT(*) FROM evento
UNION ALL SELECT 'servicio',             COUNT(*) FROM servicio
UNION ALL SELECT 'producto',             COUNT(*) FROM producto
UNION ALL SELECT 'evento_usuario',       COUNT(*) FROM evento_usuario
UNION ALL SELECT 'usuario_servicio',     COUNT(*) FROM usuario_servicio
UNION ALL SELECT 'producto_transaccion', COUNT(*) FROM producto_transaccion;

-- Distribución de usuarios por tipo
SELECT id_tipo_usuario, COUNT(*) AS total
FROM usuario
GROUP BY id_tipo_usuario
ORDER BY id_tipo_usuario;

