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
-- MAGIC INTEGRANTES:
-- MAGIC   

-- COMMAND ----------

USE CATALOG 'databricks-medallion-architecture';
USE SCHEMA gold;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Bussines Questions (PRODUCTOS)
-- MAGIC
-- MAGIC - Total ventas por anio:
-- MAGIC   - Familia
-- MAGIC   - Producto
-- MAGIC
-- MAGIC

-- COMMAND ----------

With total_ventas_productos AS (
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
FROM detalle_facturas
)



-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### TOP 5 POR ANIO POR FAMILIA Y POR PRODUCTO
-- MAGIC

-- COMMAND ----------

With total_ventas_productos AS (
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
FROM detalle_facturas
)

SELECT
  anio,
  familia_producto,
  total_ventas_familia_por_anio,
  DENSE_RANK() OVER(PARTITION BY anio ORDER BY total_ventas_familia_por_anio DESC) AS rank  
FROM total_ventas_productos
GROUP BY anio,familia_producto,total_ventas_familia_por_anio


-- COMMAND ----------

-- MAGIC %md
-- MAGIC - Cantidad total de productos vendidos por anio
-- MAGIC - Cantidad total de productos vendidos por familia
-- MAGIC - Comparar venta producto con el anio anterior y clasificar
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 1. Generar un listado de la cantidad de productos vendidos por año de manera descendente.

-- COMMAND ----------

SELECT
  YEAR(fecha_venta) AS Year,
  SUM(cantidad_vendida) AS cant_total_vendida
FROM detalle_facturas
GROUP BY  YEAR(fecha_venta)
ORDER BY SUM(cantidad_vendida) DESC;


SELECT
  *,
  SUM(cantidad_vendida) OVER (PARTITION BY YEAR(fecha_venta)) AS cant_vendida_por_anio,
  SUM(cantidad_vendida) OVER (PARTITION BY YEAR(fecha_venta), producto) AS cant_vendida_por_anio_y_producto
FROM detalle_facturas

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Top-5 de los empleados que menos vendieron según cantidad vendida, indicando apellido y nombre en un sólo campo. 

-- COMMAND ----------

-- DBTITLE 1,Cell 6
SELECT
  nombre_vendedor,
  SUM(cantidad_vendida) AS cantidad_total_vendida
FROM silver.detalle_facturas
WHERE nombre_vendedor IS NOT NULL
GROUP BY nombre_vendedor
ORDER BY SUM(cantidad_vendida) DESC
LIMIT 5


-- COMMAND ----------

-- MAGIC %md
-- MAGIC  3. ¿Cuántos clientes compraron mes anterior ?
-- MAGIC
-- MAGIC (No logré entender la consigna pero calculé la cantidad de clientes del mes anterior en base a la fecha máxima de venta)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 4. ¿Cuál fue el producto que se vendió mas en el año 2022? ¿A qué familia de producto pertenece?

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 5. Siguiendo con el punto anterior ¿Y cuál fue el más rentable?

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 6. Top-10 de sucursales según monto vendido, indicando el monto, ordenado de mayor a menor. El informe debe mostrar:
-- MAGIC - Tipo de local
-- MAGIC - Nombre del local
-- MAGIC - Monto vendido

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 7. Se detectaron ventas (facturas) realizadas por vendedores que no estan mas en la compañia (no estan en el maestro de empleados). Por lo tanto, nos solicitan un listado de dichos empleados con la cantidad de ventas (facturas). ¿Cuántos empleados son?

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 8. Nos piden clasificar a los vendedores en funcion de su rendimiento (facturación) para el año actual.
-- MAGIC - "Excelente" si el vendedor ha vendido por más de 10 millones de pesos en total.
-- MAGIC - "Bueno" si el vendedor ha vendido entre 5 y 10 millones de pesos en total.
-- MAGIC - "Regular" si el vendedor ha vendido menos de 5 millones de pesos en total.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 9. Muestra el número total de facturas para cada vendedor que haya realizado más de 100 ventas el año anterior. Incluye el nombre del vendedor y la cantidad de facturas.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 10. Generar un listado de los clientes que realizaron mas de 50 compras y que su edad sea mayor al premedio de edad del total de nuestra base de clientes. Ordenar el listado por edad de manera ascendente

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
