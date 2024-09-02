/* Questions that i have solved :
Q.1] How much total revenue is generated from each city? Include the customer
   city, state, and total revenue.
*/
with revenue_per_order as (
    SELECT order_id, sum(price + freight_value) as total_revenue
    from order_items
    group by order_id
)

select c.customer_city , c.customer_state , sum(r.total_revenue) as total_revenue
from revenue_per_order r
join orders o on o.order_id = r.order_id
join customers c on c.customer_id = o.customer_id
GROUP BY c.customer_city,c.customer_state
order by total_revenue desc;