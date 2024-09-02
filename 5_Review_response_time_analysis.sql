with review_response_time as (
    SELECT r.review_id,
        r.order_id,
        extract(epoch from(CAST(r.review_answer_timestamp AS TIMESTAMP) - 
               CAST(r.review_creation_date AS TIMESTAMP)))/3600 as response_hours
    from order_reviews r 
    where r.review_answer_timestamp is not null
    )
select c.customer_city,
    c.customer_state,
    avg(rrt.response_hours) as avg_response_hours
from review_response_time rrt 
join orders o on o.order_id =  rrt.order_id
join customers c on c.customer_id = o.customer_id
GROUP BY c.customer_city, c.customer_state
ORDER BY avg_response_hours;