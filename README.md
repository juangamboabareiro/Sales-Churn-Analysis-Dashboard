# Análisis de Churn y Rentabilidad de Clientes

- SQL Server
- Tableau
- Data Analytics



## Resumen del Proyecto

Este proyecto analiza el churn de clientes utilizando datos transaccionales del dataset Superstore.
El foco no está únicamente en medir cuántos clientes se pierden, sino en entender qué tipo de clientes se pierden y cuál es el impacto en la rentabilidad del negocio.

El análisis se realiza en SQL Server, donde se construyen las métricas clave, y luego se exportan SQL VIEWS para visualización en Tableau.




## Objetivos del Análisis

- Analizar ventas y ganancias a nivel global, temporal y por producto
- Medir churn de clientes a partir de inactividad (90 dias)
- Relacionar churn con rentabilidad del cliente
- Identificar churn económicamente riesgoso
- Generar datasets listos para visualización en Tableau




## Modelado de Datos en SQL

A partir de la tabla cruda superstore_raw, se normalizaron los datos en tres tablas principales:

### orders

Contiene la información transaccional de cada orden:

- fechas
- ventas (sales)
- ganancias (profit)
- descuentos
- productos
- clientes



### products

Contiene información descriptiva del producto:

- categoría
- subcategoría
- nombre del producto



### customers

Contiene información del cliente:

- nombre
- segmento
- ciudad
- país




## Exploratory Data Analysis (EDA) en SQL

### Evolución temporal

``` sql
SELECT 
  DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS mes,
  SUM(sales) AS ventas_por_mes,
  SUM(profit) AS ganancia_por_mes
FROM orders
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY mes;
```

Se analiza la evolución mensual de ventas y ganancias para observar si existe estacionalidad o periodos de caida/crecimiento



### Descuentos y rentabilidad

``` sql
SELECT
  discount,
  AVG(profit) AS ganancia_promedio
FROM orders
GROUP BY discount
HAVING AVG(profit) < 0;
```


Este análisis muestra que:

ciertos niveles de descuento generan pérdidas promedio

más ventas no implican necesariamente mayor rentabilidad





### Rentabilidad por producto y categoría

Se analiza qué categorías y subcategorías:

concentran ganancias

presentan márgenes negativos

Esto permite detectar:

productos problemáticos

líneas que venden mucho pero erosionan el margen



👤 Análisis a Nivel Cliente


Rentabilidad por cliente


``` sql
CREATE VIEW view_ganancia_consumidor AS
SELECT
  customer_id,
  SUM(profit) AS ganancias_totales,
  SUM(sales) AS ventas_totales,
  COUNT(DISTINCT order_id) AS ordenes_totales
FROM orders
GROUP BY customer_id;
```


Esta vista resume el valor económico total de cada cliente.




### Definición de Churn

El churn se define como inactividad del cliente.

Un cliente se considera churned si su última compra ocurrió más de 90 días antes de la fecha máxima del dataset.


``` sql
CREATE VIEW view_churn AS 
WITH ultima_actividad AS (
  SELECT 
    customer_id,
    MAX(order_date) AS fecha_ultima_orden
  FROM orders
  GROUP BY customer_id
)
SELECT
  customer_id,
  fecha_ultima_orden,
  CASE
    WHEN fecha_ultima_orden < DATEADD(day, -90, (SELECT MAX(order_date) FROM orders))
    THEN 1
    ELSE 0
  END AS churned
FROM ultima_actividad;
```


churned = 1 → cliente inactivo

churned = 0 → cliente activo

Este enfoque es común en análisis reales cuando no existe una cancelación explícita.





### Churn por Segmento y Región

Ejemplo por segmento:


``` sql
SELECT
  c.segment,
  AVG(CAST(churned AS FLOAT)) AS churn_promedio
FROM view_churn vch
JOIN customers c ON c.customer_id = vch.customer_id
GROUP BY c.segment;
```


Esto permite identificar:

segmentos con mayor propensión al churn

diferencias estructurales entre tipos de clientes




### Churn vs Rentabilidad

``` sql
SELECT 
  ch.churned,
  AVG(gc.ganancias_totales) AS ganancia_promedio,
  COUNT(*) AS customers_total
FROM view_churn ch
JOIN view_ganancia_consumidor gc 
  ON ch.customer_id = gc.customer_id
GROUP BY ch.churned;
```


Este cruce muestra que:

no todo churn tiene el mismo impacto económico

perder clientes de alta ganancia es mucho más costoso que perder clientes no rentables





### Vista Analítica Final


``` sql
CREATE VIEW view_analisis_churn AS
SELECT
  c.customer_id,
  c.segment,
  c.city,
  ch.churned,
  gc.ganancias_totales,
  gc.ventas_totales,
  gc.ordenes_totales,
  CASE
    WHEN gc.ganancias_totales < 0 THEN 'Sin ganancia'
    WHEN gc.ganancias_totales BETWEEN 0 AND 500 THEN 'Poca ganancia'
    ELSE 'Alta Ganancia'
  END AS ganancia
FROM customers c
LEFT JOIN view_churn ch ON c.customer_id = ch.customer_id
LEFT JOIN view_ganancia_consumidor gc ON c.customer_id = gc.customer_id;
```

Esta vista:

integra churn + valor económico

queda lista para consumo directo en Tableau

representa el dataset final del proyecto




## Visualización en Tableau

El dashboard se construye a partir de view_analisis_churn e incluye:

KPIs de churn y ganancias

churn por segmento

churn vs ganancia total

identificación de churn económicamente riesgoso

El foco está en priorizar decisiones, no en reducir churn de forma indiscriminada.






## Conclusiones

El churn no es un problema en sí mismo.
El verdadero riesgo está en perder clientes que generan valor.
