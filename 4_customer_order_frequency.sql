WITH customer_order_summary AS (
    SELECT o.customer_id,
           COUNT(o.order_id) AS order_count, 
           AVG(order_totals.total_revenue) AS average_order_value  
    FROM orders o
    JOIN (
        SELECT order_id,
               SUM(price) AS total_revenue
        FROM order_items
        GROUP BY order_id 
    ) AS order_totals 
    ON o.order_id = order_totals.order_id
    GROUP BY o.customer_id 
)
SELECT c.customer_id,
       c.customer_unique_id,
       c.customer_city,
       c.customer_state,
       cos.order_count,
       cos.average_order_value
FROM customer_order_summary cos
JOIN customers c ON c.customer_id = cos.customer_id  
ORDER BY cos.order_count DESC;
