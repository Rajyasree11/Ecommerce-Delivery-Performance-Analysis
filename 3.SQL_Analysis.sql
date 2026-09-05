/* How many delivered orders have a valid customer delivery date and can be included in delivery performance analysis? */
SELECT COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

/* How many delivered orders were delayed compared with those delivered on time? */
SELECT
    CASE
        WHEN order_delivered_customer_date::date >
             order_estimated_delivery_date::date
        THEN 'Delayed'
        ELSE 'On Time'
    END AS status,
    COUNT(*) AS orders
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
GROUP BY status;

/* When delivery delays occur, what is the average number of days orders are delivered late? */
SELECT ROUND(AVG(
    order_delivered_customer_date::date -
    order_estimated_delivery_date::date
), 2) AS avg_delay_days
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_customer_date::date >
    order_estimated_delivery_date::date;

/* Which customer states have the highest number of delayed orders?*/
SELECT
    c.customer_state,
    COUNT(*) AS delayed_orders
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date::date >
    o.order_estimated_delivery_date::date
GROUP BY c.customer_state
ORDER BY delayed_orders DESC;	

/* What is the average customer review score for delayed orders compared with on-time orders?*/
SELECT
    CASE
        WHEN o.order_delivered_customer_date::date >
             o.order_estimated_delivery_date::date
        THEN 'Delayed'
        ELSE 'On Time'
    END AS status,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM orders o
JOIN order_reviews r
ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY status;
