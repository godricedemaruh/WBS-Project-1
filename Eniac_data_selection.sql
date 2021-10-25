USE magist;

# 1. Task:
SELECT COUNT(order_id) AS "All order_id" FROM orders;

# 2. Task:
SELECT COUNT(order_id) AS "Important order_id" FROM orders
WHERE order_status NOT IN ("unavailable", "canceled");

# 99441-98207=1234   ==> only 1234 orders were not deliverated!

# 3. Task:
SELECT COUNT(order_id) AS "Important order_id in 2017" FROM orders
#WHERE order_status NOT IN ("unavailable", "canceled")
#AND 
WHERE YEAR(order_purchase_timestamp) = 2017;
# 45101 ordered tech products - 44379 (not unavailable or candeled) = 722   >  1,6 %

# 4. Task:
SELECT COUNT(product_id) FROM products;

# 5. Task:
SELECT COUNT(product_id), product_category_name_english FROM products p
RIGHT JOIN product_category_name_translation pcnt ON pcnt.product_category_name = p.product_category_name
GROUP BY  product_category_name_english
ORDER BY COUNT(product_id) DESC;

SELECT COUNT(product_id), product_category_name_english FROM products p
RIGHT JOIN product_category_name_translation pcnt ON pcnt.product_category_name = p.product_category_name
WHERE product_category_name_english IN ("computers_accessories", "telephony", "electronics")
GROUP BY  product_category_name_english
ORDER BY COUNT(product_id) DESC;

# 6. Task:
SELECT COUNT(DISTINCT product_id) FROM order_items;
SELECT COUNT(product_id) FROM products;

# > 32951

SELECT COUNT(order_id) FROM orders;
# > 99441

SELECT COUNT(DISTINCT p.product_id) FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id
ORDER BY p.product_id;

# every product has been ordered

SELECT COUNT(DISTINCT p.product_id), product_category_name_english FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation pcnt ON pcnt.product_category_name = p.product_category_name
WHERE product_category_name_english = "electronics"
OR product_category_name_english = "telephony"
OR product_category_name_english = "computers_accessories"
GROUP BY product_category_name_english;

# 3290 products from the 3 categories have been ordered
# 1639	computers_accessories
# 517	electronics
# 1134	telephony

# 7. TASK:
SELECT MAX(price), MIN(price) FROM order_items;

# 8. TASK:
SELECT MAX(payment_value), MIN(payment_value) FROM order_payments;

------------------------------------

# 1. Task:
# ("computers_accessories", "telephony", "electronics")

# 2. Task:
SELECT pcnt.product_category_name_english, COUNT(DISTINCT o.order_id) FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE order_purchase_timestamp LIKE "%2018%"
AND pcnt.product_category_name_english IN ( "electronics", "telephony", "computers_accessories")
AND order_status NOT IN ("unavailable", "canceled")
GROUP BY pcnt.product_category_name_english;
 
# computers_accessories	4030
# electronics	1722
# telephony	2153

# 3. Task:
SELECT pcnt.product_category_name_english, ROUND(AVG(price),0) FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE order_purchase_timestamp LIKE "%2018%"
AND pcnt.product_category_name_english IN ( "electronics", "telephony", "computers_accessories")
AND order_status NOT IN ("unavailable", "canceled")
GROUP BY pcnt.product_category_name_english;

# electronics	55
# computers_accessories	107
# telephony	77

# 4. Task: Are expensive tech products popular? (in 2017): 
SELECT COUNT(oi.order_id),
	CASE
    WHEN price >= 400 THEN "expensive"
    WHEN price >= 100 THEN "medium"
    ELSE "cheap"
    END AS price_category
FROM order_items oi
INNER JOIN orders o ON o.order_id = oi.order_id
INNER JOIN products p ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE o.order_purchase_timestamp LIKE "%2017%"
AND NOT (o.order_status = "canceled" OR "unavailable")
AND (pc.product_category_name_english = "electronics"
OR pc.product_category_name_english = "computers_accessories"
OR pc.product_category_name_english = "telephony")
GROUP BY price_category
ORDER BY COUNT(oi.order_id) DESC;

# orders: 4406 > cheap, 1628 > medium, 132 > expensive   (2017, tech-products)

# 5. Task: How many sellers are there?

SELECT COUNT(seller_id) FROM sellers;
# > 3095 Sellers

# 6. Task:
# Revenue per Seller per year per Product Category
SELECT s.seller_id, pc.product_category_name_english as "Product Category", ROUND(SUM(price),0) AS "Sales Revenue",
MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp) FROM order_items oi
INNER JOIN orders o ON o.order_id = oi.order_id
INNER JOIN sellers s ON s.seller_id = oi.seller_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE order_purchase_timestamp LIKE "%2017%"
AND NOT (order_status = "canceled" OR "unavailable")
AND (pc.product_category_name_english = "electronics"
OR pc.product_category_name_english = "computers_accessories"
OR pc.product_category_name_english = "telephony")
GROUP BY s.seller_id, pc.product_category_name_english
ORDER BY ROUND(SUM(price),0) DESC;

# 7. Task: Revenue per Seller per year per Product Category

SELECT s.seller_id, pc.product_category_name_english as "Product Category", ROUND(SUM(price),0) AS "Sales Revenue",
MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp) FROM order_items oi
INNER JOIN orders o ON o.order_id = oi.order_id
INNER JOIN sellers s ON s.seller_id = oi.seller_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE order_purchase_timestamp LIKE "%2017%"
AND NOT (order_status = "canceled" OR "unavailable")
AND (pc.product_category_name_english = "electronics"
OR pc.product_category_name_english = "computers_accessories"
OR pc.product_category_name_english = "telephony")
GROUP BY s.seller_id, pc.product_category_name_english
ORDER BY ROUND(SUM(price),0) DESC;

# 8. Task: What’s the average time between the order being placed and the product being delivered?

SELECT ROUND(AVG(TIMESTAMPDIFF(second, order_purchase_timestamp, order_delivered_customer_date) / 60 / 60 / 24),2) AS TIME_DIFF FROM orders
WHERE order_purchase_timestamp LIKE "%2017%";

# > Average delivery time in 2017


# 9. TASK: How many orders are delivered on time vs orders delivered with a delay?
SELECT COUNT(order_id),
CASE
    WHEN NOT order_delivered_customer_date IS NULL
    OR NOT order_estimated_delivery_date IS NULL
    AND order_delivered_customer_date <= order_estimated_delivery_date THEN "on time delivery"
    ELSE "late delivery"
END AS delivery_comparison
FROM orders
WHERE order_purchase_timestamp LIKE "%2017%"
GROUP BY delivery_comparison;

# > 43426 = on time delivery / 1675 = late delivery


# 10. Task: Is there any pattern for delayed orders, e.g. big products being delayed more often?

# Has the fright_value an influence on late delivery?
SELECT COUNT(o.order_id), oi.freight_value,
CASE
    WHEN NOT o.order_delivered_customer_date IS NULL
    OR NOT o.order_estimated_delivery_date IS NULL
    AND o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN "on time delivery"
    ELSE "late delivery"
END AS delivery_comparison
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_purchase_timestamp LIKE "%2017%"
GROUP BY delivery_comparison, oi.freight_value
ORDER BY oi.freight_value DESC;
# > no!

# Has the weight_value an influence on late delivery?
SELECT COUNT(o.order_id), p.product_weight_g,
CASE
    WHEN NOT o.order_delivered_customer_date IS NULL
    OR NOT o.order_estimated_delivery_date IS NULL
    AND o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN "on time delivery"
    ELSE "late delivery"
END AS delivery_comparison
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id
WHERE o.order_purchase_timestamp LIKE "%2017%"
GROUP BY delivery_comparison, p.product_weight_g
ORDER BY p.product_weight_g DESC;
# > No!

# COUNT(o.order_id), , avg_product_volume_dm3

# Has the size an influence on late delivery?
SELECT ROUND(AVG((p.product_length_cm * p.product_height_cm * p.product_width_cm) / 1000),0) AS avg_product_volume_dm3,
CASE
    WHEN NOT o.order_delivered_customer_date IS NULL
    OR NOT o.order_estimated_delivery_date IS NULL
    AND o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN "on time delivery"
    ELSE "late delivery"
END AS delivery_comparison
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id
WHERE o.order_purchase_timestamp LIKE "%2017%"
GROUP BY delivery_comparison
ORDER BY avg_product_volume_dm3 DESC;

# 20 > late delivery, 16 > on time delivery



# Total revenue of Eniac's on Spain for 2017 is 12268417 euros
# Total revenue in the 3 categories: computers_accessories > 400491 real, telephony > 142331 real, electronics > 55971 real
# Total revenue in all product categories = 6108492 real
#
