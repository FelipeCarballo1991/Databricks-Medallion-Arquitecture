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

--------------------------------------------------------------------------------------
/*
Creo una vista con la union de las tablas normalizadas previamente cargadas en la capa silver para desarrollar los KPIs que serán utilizados en la capa gold
*/

CREATE OR REPLACE VIEW `databricks-medallion-architecture`.silver.detalle_facturas
AS 
SELECT * 
FROM (
      SELECT  
      f.num_factura,
      f.fecha_venta,
      p.nombre AS producto,
      p.familia AS familia_producto,
      f.cantidad AS cantidad_vendida,
      p.precio_unitario AS precio_unitario_producto,
      f.cantidad * p.precio_unitario AS total_venta,
      c.nombre_completo AS nombre_cliente,
      c.sexo AS sexo_cliente,
      c.fecha_nacimiento AS fecha_nacimiento_cliente,
      DATEDIFF(YEAR,c.fecha_nacimiento,CURRENT_DATE()) AS edad_cliente,
      e.nombre_completo AS nombre_vendedor,
      l.nombre AS local,
      l.tipo AS tipo_local
  FROM `databricks-medallion-architecture`.silver.fact_facturas f
  LEFT JOIN `databricks-medallion-architecture`.silver.productos p
    ON f.producto = p.id_producto
  LEFT JOIN `databricks-medallion-architecture`.silver.clientes c
    ON f.cliente = c.id_cliente
  LEFT JOIN `databricks-medallion-architecture`.silver.empleados e
    on f.vendedor = e.id_vendedor
  LEFT JOIN `databricks-medallion-architecture`.silver.locales l
    ON e.sucursal = l.id_sucursal
      
)
