-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### El área de Demand Planning requiere información con mayor frecuencia de las transacciones de venta y movimientos de mercadería realizadas. Para ello genera reportes  comerciales  a  través  del  área  de Reporting  con  diversos  KPIs,  indicadores segmentando por distintas categorías
-- MAGIC
-- MAGIC ##### Diagrama entidad-relación:
-- MAGIC ![Data Architecture](../../DER-Ventas.jpg)
-- MAGIC
-- MAGIC ###### El modelo cuenta con las siguientes tablas:
-- MAGIC - Clientes: Listado de los clientes dados de alta en el sistema de ventas.
-- MAGIC - Empleados: Maestro de empleados, el mismo esta compuesto por el identificador, nombre, apellido y sucursal en la que trabaja.
-- MAGIC - Locales: Maestro de sucursales compuesta por el identificador, nombre y tipo de local.
-- MAGIC - Productos: Maestro de productos con su precio agrupados por familia de producto.
-- MAGIC - Facturas: Tabla que registra todas las transacciones (ventas). Además contiene, la fecha de en que se realizó la operación, el empleado que hizo la venta, el cliente y la cantidad de productos vendidos
-- MAGIC
-- MAGIC   

-- COMMAND ----------

USE CATALOG 'databricks-medallion-architecture';
USE SCHEMA silver;

-- COMMAND ----------

SELECT
  COUNT(*)
FROM silver.fact_facturas

-- COMMAND ----------

WITH detalle_facturas AS
  (
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
  FROM silver.fact_facturas f
  LEFT JOIN silver.productos p
    ON f.producto = p.id_producto
  LEFT JOIN silver.clientes c
    ON f.cliente = c.id_cliente
  LEFT JOIN silver.empleados e
    on f.vendedor = e.id_vendedor
  LEFT JOIN silver.locales l
    ON e.sucursal = l.id_sucursal
    )

SELECT 
  *
FROM detalle_facturas
-- WHERE edad_cliente < 18

-- COMMAND ----------

SELECT
  num_factura

FROM(
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
      l.*
  FROM silver.fact_facturas f
  LEFT JOIN silver.productos p
    ON f.producto = p.id_producto
  LEFT JOIN silver.clientes c
    ON f.cliente = c.id_cliente
  LEFT JOIN silver.empleados e
    on f.vendedor = e.id_vendedor
  LEFT JOIN silver.locales l
    ON e.sucursal = l.id_sucursal
)
WHERE num_factura IS NULL
