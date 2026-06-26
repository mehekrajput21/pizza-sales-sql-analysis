-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, sum(order_details.quantity) AS quantity
FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT hour(order_time) AS hour, count(order_id) AS order_count FROM orders
GROUP BY hour(order_time) ORDER BY hour asc;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, count(name) from pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT round(avg(quantity),0) from
(SELECT orders.order_date, sum(order_details.quantity) as quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name ORDER BY revenue desc limit 3;

