-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
round(sum(order_details.quantity * pizzas.price) / (SELECT 
round(sum(order_details.quantity * pizzas.price),2) AS total_revenue
FROM order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id)*100,2) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category order by revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from
(SELECT orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
JOIN orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT name, revenue from 
(SELECT category, name, revenue,
rank() over(partition by category order by revenue  desc) as rn
from
(SELECT pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) AS A )AS B
WHERE rn <= 3;