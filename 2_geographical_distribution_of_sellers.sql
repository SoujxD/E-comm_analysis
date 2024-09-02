-- What is the distribution of sellers across different states?
with sellers_count as (
    SELECT seller_state , count(seller_id) as num_sellers
    from sellers
    GROUP BY seller_state
)
select seller_state , num_sellers,
    round((num_sellers::numeric / sum(num_sellers) over())*100,2) as seller_percentage
from sellers_count
order by num_sellers desc;