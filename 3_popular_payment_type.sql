with popular_payment as (
select order_id , count(payment_type) as popularity,
  payment_type
from order_payments
group by order_id , payment_type
ORDER BY popularity DESC)

select pp.popularity , pp.payment_type , sum(oi.price) as revenue
from popular_payment pp
join order_items oi on oi.order_id = pp.order_id
GROUP BY pp.popularity , pp.payment_type
order by revenue desc;