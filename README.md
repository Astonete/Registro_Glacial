# Registro_Glacial
Construir una base de datos Modelo y Tablas relacional funcional que permita Importación y análisis desde CSV


5.1 Creación del Modelo y Tablas

    - insertar datos de csv a sql
    - interpretar el significado de cada campo
    - Crear tus propias tablas
    - Definir tipos de datos adecuados
    - Establecer claves primarias
    - Definir y justificar relaciones

5.2 Inserción de Datos

- Insertar los datos desde los CSV
- Respetar el orden lógico de inserción
- Permitir que las violaciones de integridad caigan

5.3 Integridad y Restricciones

    - Claves primarias reales
    - Claves foráneas reales
    - NO NULO coherentes
    - CHECK para evitar valores inválidos
    - ÚNICO cuando el dominio lo requiere
    - Índices en columnas críticas

5.4 Consultas Estructurales (sin agregaciones)

    - Navegar el modelo
    - Relacionar entidades
    - Rastrear estados y eventos
    - Detectar ausencias
    - Solo se permite usar: SELECT , JOIN, WHERE, ORDER BY.
    - No se permiten: GROUP BY , Funciones de agregación.

5.5 Validación de Integridad

    - Relaciones rotas
    - Valores inválidos
    - Entidades incompletas
    - Estados imposibles
    - Registros inconsistentes

5.6 Seguridad – Inyección SQL 🔒

    - Cómo ocurre una inyección SQL
    - Qué práctica la habilita
    - Qué consecuencias puede tener
    - Cómo debe diseñarse correctamente el acceso a datos
    - Qué cambia al usar consultas parametrizadas