/*
Creo una vista con la union de las tablas normalizadas previamente cargadas en la capa silver para desarrollar los KPIs que serán utilizados en la capa gold
*/

CREATE OR REPLACE VIEW `databricks-medallion-architecture`.gold.detalle_facturas
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
);




--------------------------------------------------------------------------------------

/*

Total ventas por anio:
- Familia
- Producto
*/

CREATE OR REPLACE VIEW `databricks-medallion-architecture`.gold.total_ventas_productos
AS 
SELECT *
FROM(
SELECT
  DISTINCT  
  YEAR(fecha_venta) AS anio,  
  producto,
  familia_producto,
  SUM(total_venta) OVER(PARTITION BY YEAR(fecha_venta))  AS total_ventas_por_anio,
  -- TOTAL VENTAS FAMILIA POR ANIO
  SUM(total_venta) OVER(PARTITION BY YEAR(fecha_venta), familia_producto) AS total_ventas_familia_por_anio,
   --TOTAL VENTAS PRODUCTO POR ANIO
  SUM(total_venta) OVER(PARTITION BY YEAR(fecha_venta), producto) AS total_ventas_producto_por_anio
FROM `databricks-medallion-architecture`.gold.detalle_facturas);

--------------------------------------------------------------------------------------

/*
Ranking de ventas por familia de producto
*/


CREATE OR REPLACE VIEW `databricks-medallion-architecture`.gold.rank_ventas_familia
AS 
SELECT *
FROM(      
      SELECT
      anio,
      familia_producto,
      total_ventas_familia_por_anio,
      DENSE_RANK() OVER(PARTITION BY anio ORDER BY total_ventas_familia_por_anio DESC) AS rank  
    FROM `databricks-medallion-architecture`.gold.total_ventas_productos
    GROUP BY anio,familia_producto,total_ventas_familia_por_anio
    
    );

