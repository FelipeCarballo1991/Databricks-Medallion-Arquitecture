-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### El área de Demand Planning requiere información con mayor frecuencia de las transacciones de venta y movimientos de mercadería realizadas. Para ello genera reportes  comerciales  a  través  del  área  de Reporting  con  diversos  KPIs,  indicadores segmentando por distintas categorías
-- MAGIC
-- MAGIC ##### Diagrama entidad-relación:
-- MAGIC ![Data Architecture](DER-Ventas.jpg)
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
USE SCHEMA bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## [TABLE] Clientes
-- MAGIC ### Quality checks
-- MAGIC - Null or duplicate primary keys.
-- MAGIC - Unwanted spaces in string fields or null values.
-- MAGIC - Invalid Dates
-- MAGIC

-- COMMAND ----------

-- Null or duplicate primary keys.
SELECT 
  id_cliente
FROM bronze.clientes
GROUP BY id_cliente
HAVING COUNT(*) > 1 OR id_cliente IS NULL;

-- Unwanted spaces in string fields or null values.
SELECT 
  nombre,
  apellido,
  sexo,
  fecha_nacimiento
FROM bronze.clientes
WHERE (nombre != TRIM(nombre) OR nombre IS NULL)
   OR (apellido != TRIM(apellido) OR apellido IS NULL)
   OR (sexo != TRIM(sexo) OR sexo IS NULL)
   OR (fecha_nacimiento IS NULL);


-- Invalid Dates
SELECT 
  MIN(fecha_nacimiento),
  MAX(fecha_nacimiento)
FROM bronze.clientes


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Transformations
-- MAGIC - Concat names
-- MAGIC - Cardidality gender.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC

-- COMMAND ----------

SELECT 
  id_cliente,
  CONCAT(nombre, ' ', apellido) AS nombre_completo,
  CASE 
      WHEN sexo = 'null' THEN 'No especificado'
      ELSE sexo 
  END AS sexo,  
  fecha_nacimiento
FROM bronze.clientes



