/*
Script que carga los archivos .csv que se encuentran en el schema landing_zone a la capa bronze.

Los archivos de la carpeta input_files deben estar alojados en el schema landing_zone de la siguiente manera:

landing_zone/fact_and_dimension_files/clientes/clientes.csv
landing_zone/fact_and_dimension_files/empleados/empleados.csv
landing_zone/fact_and_dimension_files/facturas/facturas.csv
landing_zone/fact_and_dimension_files/locales/locales.csv
landing_zone/fact_and_dimension_files/productos/productos.csv

La estructura necesaria para realizar carga es la siguiente:

Catalog: databricks-medallion-architecture
Schema: bronze
*/

CREATE TABLE IF NOT EXISTS `databricks-medallion-architecture`.bronze.clientes 
AS 
SELECT * 
FROM read_files( '/Volumes/databricks-medallion-architecture/landing_zone/fact_and_dimension_files/clientes/clientes.csv', 
format => 'csv', header => true, 
delimiter => ';' 
);

CREATE TABLE IF NOT EXISTS `databricks-medallion-architecture`.bronze.empleados 
AS 
SELECT * 
FROM read_files( '/Volumes/databricks-medallion-architecture/landing_zone/fact_and_dimension_files/empleados/empleados.csv', 
format => 'csv', header => true, 
delimiter => ';' 
);

CREATE TABLE IF NOT EXISTS `databricks-medallion-architecture`.bronze.fact_facturas 
AS 
SELECT * 
FROM read_files( '/Volumes/databricks-medallion-architecture/landing_zone/fact_and_dimension_files/facturas/facturas.csv', 
format => 'csv', header => true, 
delimiter => ';' 
);


CREATE TABLE IF NOT EXISTS `databricks-medallion-architecture`.bronze.locales 
AS 
SELECT * 
FROM read_files( '/Volumes/databricks-medallion-architecture/landing_zone/fact_and_dimension_files/locales/locales.csv', 
format => 'csv', header => true, 
delimiter => ';' 
);

CREATE TABLE IF NOT EXISTS `databricks-medallion-architecture`.bronze.productos 
AS 
SELECT * 
FROM read_files( '/Volumes/databricks-medallion-architecture/landing_zone/fact_and_dimension_files/productos/productos.csv', 
format => 'csv', header => true, 
delimiter => ';' 
);



