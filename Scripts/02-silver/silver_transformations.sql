/*
Script que carga y normaliza las tablas provenientes de la capa bronze.

Catalog: databricks-medallion-architecture
Schema: Silver
*/

CREATE OR REPLACE TABLE  `databricks-medallion-architecture`.silver.clientes 
AS 
SELECT * 
FROM (
      SELECT 
      id_cliente,       
      CONCAT(nombre, ' ', apellido) AS nombre_completo,
      CASE 
          WHEN sexo = 'null' THEN 'No especificado'
          ELSE sexo 
      END AS sexo,  
      fecha_nacimiento
    FROM `databricks-medallion-architecture`.bronze.clientes
);

--------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE  `databricks-medallion-architecture`.silver.empleados 
AS 
SELECT * 
FROM (
      WITH cte_empleado AS (
            SELECT 
                id_vendedor,
                sucursal,  
                CONCAT(nombre, ' ', CASE WHEN apellido = "null" THEN "" ELSE apellido END) AS nombre_completo,
                COUNT(*) OVER (PARTITION BY  CONCAT(nombre, ' ', CASE WHEN apellido = "null" THEN "" ELSE apellido END)) AS duplicados   
            FROM `databricks-medallion-architecture`.bronze.empleados
        )

        SELECT 
            id_vendedor,
            sucursal,
            nombre_completo
        FROM cte_empleado
        WHERE duplicados = 1
);


--------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE  `databricks-medallion-architecture`.silver.locales 
AS 
SELECT * 
FROM (
      SELECT 
        *
      FROM `databricks-medallion-architecture`.bronze.locales
);

--------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE  `databricks-medallion-architecture`.silver.productos 
AS 
SELECT * 
FROM (
      SELECT 
        *
      FROM `databricks-medallion-architecture`.bronze.productos
);

--------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE  `databricks-medallion-architecture`.silver.fact_facturas 
AS 
SELECT * 
FROM (
      SELECT 
        *
      FROM `databricks-medallion-architecture`.bronze.fact_facturas
);


