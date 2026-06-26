CREATE database pizza;
USE pizza;
CREATE TABLE orders (
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY(order_id)
);
CREATE TABLE order_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id)
);

-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales
SELECT 
round(sum(order_details.quantity * pizzas.price),2) AS total_revenue
FROM order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.
SELECT quantity, count(order_details_id)
FROM order_details GROUP BY quantity;

SELECT pizzas.size, count(order_details.order_details_id) as order_count
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size ORDER BY order_count desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, sum(order_details.quantity) AS quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC LIMIT 5;

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
