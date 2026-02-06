CREATE TABLE orders(
	order_id NVARCHAR(50),
	order_date DATE,
	customer_id NVARCHAR(50),
	ship_date DATE,
	ship_mode NVARCHAR(50),
	product_id NVARCHAR(50),
	sales FLOAT,
	quantity TINYINT,
	discount FLOAT,
	profit FLOAT
);




SELECT TOP 5 *
FROM superstore_raw



INSERT INTO orders (
	order_id,
	order_date,
	customer_id,
	ship_date,
	ship_mode,
	product_id,
	sales,
	quantity,
	discount,
	profit
)
SELECT 
	Order_ID,
	Order_Date,
	Customer_ID,
	Ship_Date,
	Ship_Date,
	Product_ID,
	Sales,
	Quantity,
	Discount,
	Profit
FROM superstore_raw




SELECT COUNT(*) FROM superstore_raw
SELECT COUNT(*) FROM orders




CREATE TABLE products(
	product_id NVARCHAR(50),
	product_name NVARCHAR(150),
	category NVARCHAR(50),
	subcategory NVARCHAR(50),
)


INSERT INTO products (
	product_id,
	product_name,
	category,
	subcategory
)
SELECT 
	Product_ID,
	Product_Name,
	Category,
	Sub_Category
FROM superstore_raw





CREATE TABLE customers (
	customer_id NVARCHAR(50),
	customer_name NVARCHAR(50),
	segment NVARCHAR(50),
	country NVARCHAR(50),
	city NVARCHAR(50),
)


INSERT INTO customers (
	customer_id,
	customer_name,
	segment,
	country,
	city
) SELECT 
	Customer_ID,
	Customer_Name,
	Segment,
	Country,
	City
FROM superstore_raw




SELECT COUNT(*) AS ordenes_totales, COUNT(DISTINCT customer_id) AS consumidores_totales, COUNT(DISTINCT product_id) AS productos_totales
FROM orders




SELECT MIN(order_date) AS primer_orden, MAX(order_date) AS ultima_orden FROM orders



SELECT SUM(sales) AS ventas_totales, SUM(profit) AS ganancia_total, AVG(sales) AS venta_promedio FROM orders



SELECT DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS mes, SUM(sales) AS ventas_por_mes, SUM(profit) AS ganancia_por_mes
FROM orders
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY mes


SELECT
    COUNT(*) AS loss_orders
FROM orders
WHERE profit < 0;


SELECT discount, SUM(profit) AS ganancias_totales, COUNT(*) AS ordenes_totales FROM orders
GROUP BY discount ORDER BY discount



SELECT
    discount,
    AVG(profit) AS ganancia_promedio,
    COUNT(*) AS ordenes_totales
FROM orders
GROUP BY discount
ORDER BY discount;



SELECT
    discount,
    AVG(profit) AS ganancia_promedio
FROM orders
GROUP BY discount
HAVING AVG(profit) < 0
ORDER BY discount;




SELECT
	discount, 
	AVG(sales) AS ventas_promedio,
	COUNT(*) AS ordenes_totales
FROM orders
GROUP BY discount
ORDER BY discount



SELECT 
	p.category,
	SUM(o.sales) AS ventas_totales,
	SUM(o.profit) AS ganancias_totales,
	AVG(o.profit) AS ganancia_promedio,
	COUNT(*) AS ordentes_totales
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY ganancias_totales DESC
	


SELECT 
	p.category,
	p.subcategory,
	SUM(o.sales) AS ventas_totales,
	SUM(o.profit) AS ganancias_totales,
	AVG(o.profit) AS ganancia_promedio,
	COUNT(*) AS ordentes_totales
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.subcategory
ORDER BY ganancias_totales DESC




SELECT
    p.subcategory,
    AVG(o.discount) AS descuento_promedio,
    AVG(o.profit)   AS ganancia_promedio,
    COUNT(*)        AS ordenes_totales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.subcategory
ORDER BY ganancia_promedio DESC




SELECT
	o.product_id,
	p.product_name,
	SUM(o.profit) AS ganancia_total,
	COUNT(*) AS ordenes_totales
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY o.product_id, p.product_name 
HAVING SUM(o.profit) < 0 
ORDER BY ganancia_total DESC




SELECT
	o.product_id,
	p.product_name,
	SUM(o.profit)/NULLIF(SUM(o.sales), 0) AS ganancia_total,
	COUNT(*) AS ordenes_totales
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY o.product_id, p.product_name 
HAVING SUM(o.profit) < 0 
ORDER BY ganancia_total ASC




SELECT
	customer_id,
	SUM(sales) AS ventas_totales,
	SUM(profit) AS ganancias_totales,
	COUNT(*) AS ordenes_totales
FROM orders 
GROUP BY customer_id
ORDER BY ganancias_totales




SELECT
	customer_id,
	SUM(sales) AS ventas_totales,
	SUM(profit)/NULLIF(SUM(sales), 0) AS ganancias_totales,
	COUNT(*) AS ordenes_totales
FROM orders 
GROUP BY customer_id
ORDER BY ganancias_totales



SELECT
	customer_id,
	SUM(sales) AS ventas_totales,
	SUM(profit)/NULLIF(SUM(sales), 0) AS ganancias_totales,
	COUNT(*) AS ordenes_totales
FROM orders 
GROUP BY customer_id
HAVING SUM(profit)/NULLIF(SUM(sales), 0) < 0
ORDER BY ganancias_totales






SELECT 
	customer_id,
	AVG(discount) AS descuento_promedio,
	AVG(profit) AS ganancia_promedio
FROM orders
GROUP BY customer_id
ORDER BY ganancia_promedio ASC





SELECT
    customer_id,
    COUNT(*) AS ordenes_totales,
    SUM(profit) AS ganancias_totales,
    AVG(profit) AS ganancia_promedio
FROM orders
GROUP BY customer_id
ORDER BY ordenes_totales DESC



SELECT
    customer_id,
    COUNT(*) AS ordenes_totales,
    SUM(profit) AS ganancias_totales,
    AVG(profit) AS ganancia_promedio
FROM orders
GROUP BY customer_id
HAVING AVG(profit) < 0
ORDER BY ordenes_totales DESC





SELECT
    customer_id,
    MAX(order_date) AS fecha_ultima_orden
INTO #last_activity
FROM orders
GROUP BY customer_id;


#ACA ERROR

DECLARE @max_date DATE;



SELECT @max_date = MAX(order_date) FROM orders




SELECT
	customer_id,
	fecha_ultima_orden,
	CASE
		WHEN fecha_ultima_orden < DATEADD(day, -90, @max_date)
		THEN 1
		ELSE 0
	END AS churned
INTO churn_status
FROM #last_activity





#ACA ARREGLO ERROR


WITH ultima_actividad AS (
	SELECT 
		customer_id,
		MAX(order_date) AS fecha_ultima_orden
		FROM orders
		GROUP BY customer_id
)
SELECT
	la.customer_id,
	la.fecha_ultima_orden,
	CASE
		WHEN la.fecha_ultima_orden < DATEADD(day, -90, (SELECT MAX(order_date) FROM orders))
		THEN 1
		ELSE 0
	END AS churned
FROM ultima_actividad la;



CREATE VIEW view_churn AS 
WITH ultima_actividad AS (
	SELECT 
		customer_id,
		MAX(order_date) AS fecha_ultima_orden
		FROM orders
		GROUP BY customer_id
)
SELECT
	la.customer_id,
	la.fecha_ultima_orden,
	CASE
		WHEN la.fecha_ultima_orden < DATEADD(day, -90, (SELECT MAX(order_date) FROM orders))
		THEN 1
		ELSE 0
	END AS churned
FROM ultima_actividad la







SELECT AVG(CAST(churned AS FLOAT)) FROM view_churn



SELECT
	c.segment,
	AVG(CAST(churned AS FLOAT)) AS churn_promedio
FROM view_churn vch JOIN customers c ON c.customer_id = vch.customer_id
GROUP BY c.segment
ORDER BY churn_promedio DESC




SELECT
	c.city,
	AVG(CAST(churned AS FLOAT)) AS churn_promedio
FROM view_churn vch JOIN customers c ON c.customer_id = vch.customer_id
GROUP BY c.city
ORDER BY churn_promedio DESC



SELECT
	c.country,
	AVG(CAST(churned AS FLOAT)) AS churn_promedio
FROM view_churn vch JOIN customers c ON c.customer_id = vch.customer_id
GROUP BY c.country
ORDER BY churn_promedio DESC





CREATE VIEW view_ganancia_consumidor AS
SELECT
    customer_id,
    SUM(profit) AS ganancias_totales,
    SUM(sales) AS ventas_totales,
    COUNT(DISTINCT order_id) AS ordenes_totales
FROM orders
GROUP BY customer_id;



SELECT TOP 10 * FROM view_ganancia_consumidor







SELECT 
	ch.churned,
	AVG(gc.ganancias_totales) AS ganancia_promedio,
	COUNT(*) AS customers_total
FROM view_churn ch JOIN view_ganancia_consumidor gc ON ch.customer_id = gc.customer_id
GROUP BY ch.churned








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
LEFT JOIN view_churn ch
    ON c.customer_id = ch.customer_id
LEFT JOIN view_ganancia_consumidor gc
    ON c.customer_id = gc.customer_id;



SELECT * 
FROM view_analisis_churn