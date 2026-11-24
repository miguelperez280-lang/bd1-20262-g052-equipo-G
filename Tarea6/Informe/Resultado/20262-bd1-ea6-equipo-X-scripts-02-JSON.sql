--
-- Scripts - Enunciados DML para Manipulación de Datos Semi-Estructurados (JSON)
-- Manipulación de Campo JSON (Perfil Profesional y Competencias)

-- 2.1.- UPDATE: registrar el resumen profesional, skills, áreas de interés, idiomas y proyectos destacados
UPDATE perfil
SET datos_profesional = '{
    "resumen": "Estudiante de Tecnología en Desarrollo de Software con interés en bases de datos y desarrollo backend.",
    "skills": ["SQL", "PostgreSQL", "Python", "C++", "Git"],
    "areas_interes": ["Bases de datos", "Ingeniería de software", "Análisis de datos"],
    "idiomas": [
        {"idioma": "Español", "nivel": "Nativo"},
        {"idioma": "Inglés",  "nivel": "B1"}
    ],
    "proyectos_destacados": [
        {"nombre": "Red Social Pascualina", "rol": "Modelado y programación de la base de datos", "anio": 2026},
        {"nombre": "Sistema de inventario", "rol": "Desarrollo de consultas SQL", "anio": 2025}
    ]
}'::jsonb
WHERE id_usuario = 1;

-- Registrar un perfil profesional sencillo para los primeros 50 estudiantes (para tener más filas con JSON)
UPDATE perfil
SET datos_profesional = jsonb_build_object(
        'resumen',              'Estudiante activo de la Red Social Pascualina',
        'skills',               jsonb_build_array('SQL', 'Excel', 'Trabajo en equipo'),
        'areas_interes',        jsonb_build_array('Bases de datos', 'Emprendimiento'),
        'idiomas',              jsonb_build_array(jsonb_build_object('idioma', 'Inglés', 'nivel', 'A2')),
        'proyectos_destacados', jsonb_build_array(jsonb_build_object('nombre', 'Proyecto de aula', 'anio', 2026))
    )
WHERE id_usuario BETWEEN 2 AND 50;

-- 2.2.- SELECT: extraer elementos específicos del documento JSON
SELECT p.id_usuario,
       u.nombre || ' ' || u.apellido                      AS nombre_completo,
       p.datos_profesional ->> 'resumen'                  AS resumen_profesional,
       p.datos_profesional -> 'skills' ->> 0              AS primera_skill,
       jsonb_array_length(p.datos_profesional -> 'skills') AS cantidad_skills,
       p.datos_profesional -> 'idiomas' -> 0 ->> 'idioma' AS primer_idioma,
       p.datos_profesional -> 'idiomas' -> 0 ->> 'nivel'  AS nivel_idioma,
       p.datos_profesional -> 'proyectos_destacados' -> 0 ->> 'nombre' AS primer_proyecto
FROM perfil p
JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.id_usuario = 1;

-- 2.3.- SELECT: listar todas las skills de un perfil (una fila por habilidad) y buscar perfiles por skill
SELECT p.id_usuario,
       jsonb_array_elements_text(p.datos_profesional -> 'skills') AS skill
FROM perfil p
WHERE p.id_usuario = 1;

SELECT p.id_usuario, u.nombre, u.apellido
FROM perfil p
JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.datos_profesional -> 'skills' ? 'PostgreSQL';

-- 2.4.- UPDATE: modificar el JSON (agregar una skill nueva y cambiar el nivel de inglés)
UPDATE perfil
SET datos_profesional = jsonb_set(
        jsonb_set(datos_profesional,
                  '{skills}',
                  (datos_profesional -> 'skills') || '"Power BI"'::jsonb),
        '{idiomas,1,nivel}', '"B2"')
WHERE id_usuario = 1;

SELECT datos_profesional -> 'skills'                  AS skills,
       datos_profesional -> 'idiomas' -> 1 ->> 'nivel' AS nivel_ingles
FROM perfil
WHERE id_usuario = 1;

-- 2.5.- UPDATE: eliminar una clave del JSON (areas_interes) del perfil
UPDATE perfil
SET datos_profesional = datos_profesional - 'areas_interes'
WHERE id_usuario = 1;

SELECT id_usuario,
       datos_profesional ? 'areas_interes' AS tiene_areas_interes,
       datos_profesional
FROM perfil
WHERE id_usuario = 1;