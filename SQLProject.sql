
--Retrieve the total number of orders placed.
select COUNT(pizza.dbo.orders.order_id) as Total_Orders from pizza.dbo.orders;

--Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(pizza.dbo.order_details.quantity * pizza.dbo.pizzas.price), 2) AS Total_Revenue
FROM pizza.dbo.order_details INNER JOIN pizza.dbo.pizzas 
ON pizzas.pizza_id = order_details.pizza_id;



--Identify the highest-priced pizza.
SELECT TOP (1) pizza.dbo.pizza_types.name AS Name, ROUND(pizza.dbo.pizzas.price, 2) AS Price
FROM pizza.dbo.pizza_types INNER JOIN pizza.dbo.pizzas 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC;


--Identify the most common pizza size ordered.
select pizza.dbo.pizzas.size, count(pizza.dbo.order_details.order_details_id) as Order_Count
from pizza.dbo.pizzas join pizza.dbo.order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by Order_Count desc;


--List the top 5 most ordered pizza types along with their quantities.
select top(5)
pizza.dbo.pizza_types.name, sum(pizza.dbo.order_details.quantity) as qty
from pizza.dbo.pizza_types 
join pizza.dbo.pizzas
on pizza.dbo.pizza_types.pizza_type_id=pizza.dbo.pizzas.pizza_type_id
join pizza.dbo.order_details
on pizza.dbo.pizzas.pizza_id=pizza.dbo.order_details.pizza_id
group by pizza.dbo.pizza_types.name
order by qty desc;



--Join the necessary tables to find the total quantity of each pizza category ordered.
select
pizza.dbo.pizza_types.category, sum(pizza.dbo.order_details.quantity) as qty
from pizza.dbo.pizza_types join pizza.dbo.pizzas
on pizza.dbo.pizza_types.pizza_type_id=pizza.dbo.pizzas.pizza_type_id
join pizza.dbo.order_details
on pizza.dbo.pizzas.pizza_id=pizza.dbo.order_details.pizza_id
group by pizza.dbo.pizza_types.category
order by qty desc;


--Determine the distribution of orders by hour of the day.
select
DATEPART(HOUR,pizza.dbo.orders.time) as hours, COUNT(pizza.dbo.orders.order_id) as order_count
from
pizza.dbo.orders
group by DATEPART(HOUR,pizza.dbo.orders.time)
order by order_count desc;


--Join relevant tables to find the category-wise distribution of pizzas.
select
pizza.dbo.pizza_types.category, count(pizza.dbo.pizza_types.name) as pizza_name
from
pizza.dbo.pizza_types
group by pizza.dbo.pizza_types.category
order by pizza_name desc;


--Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(qtyperday) as avgqtyperday from
(select 
pizza.dbo.orders.date, sum(pizza.dbo.order_details.quantity) as qtyperday
from pizza.dbo.orders 
join pizza.dbo.order_details
on pizza.dbo.orders.order_id=pizza.dbo.order_details.order_id
group by pizza.dbo.orders.date) as order_qty;


--Determine the top 3 most ordered pizza types based on revenue.
select top(3)
pizza.dbo.pizza_types.name, sum(pizza.dbo.order_details.quantity * pizza.dbo.pizzas.price) as revenue
from
pizza.dbo.pizza_types
join  pizza.dbo.pizzas
on pizza.dbo.pizza_types.pizza_type_id=pizza.dbo.pizzas.pizza_type_id
join pizza.dbo.order_details
on pizza.dbo.order_details.pizza_id=pizza.dbo.pizzas.pizza_id
group by pizza.dbo.pizza_types.name
order by revenue desc;




--Calculate the percentage contribution of each pizza type to total revenue.
select
pizza.dbo.pizza_types.category, 
round(SUM(pizza.dbo.order_details.quantity * pizza.dbo.pizzas.price) / 
	(select sum(pizza.dbo.order_details.quantity*pizza.dbo.pizzas.price) from pizza.dbo.order_details 
	join pizza.dbo.pizzas on pizza.dbo.order_details.pizza_id=pizza.dbo.pizzas.pizza_id) *100,2) as revenue
from
pizza.dbo.pizza_types
join pizza.dbo.pizzas
on pizza.dbo.pizza_types.pizza_type_id=pizza.dbo.pizzas.pizza_type_id
join pizza.dbo.order_details
on pizza.dbo.pizzas.pizza_id=pizza.dbo.order_details.pizza_id
group by pizza.dbo.pizza_types.category
order by revenue desc;

--Analyze the cumulative revenue generated over time.
select
dt, 
round(sum(revenue) over(order by dt),2) as cum_revenue
from
(select
pizza.dbo.orders.date as dt, 
sum(pizza.dbo.order_details.quantity*pizza.dbo.pizzas.price) as revenue
from
pizza.dbo.order_details
join pizza.dbo.pizzas
on pizza.dbo.order_details.pizza_id=pizza.dbo.pizzas.pizza_id
join pizza.dbo.orders
on pizza.dbo.order_details.order_id=pizza.dbo.orders.order_id
group by pizza.dbo.orders.date) as sales


----Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH RevenueCTE AS (
    SELECT
        pizza.dbo.pizza_types.category,
        pizza.dbo.pizza_types.name,
        SUM(pizza.dbo.order_details.quantity * pizza.dbo.pizzas.price) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY pizza.dbo.pizza_types.category ORDER BY SUM(pizza.dbo.order_details.quantity * pizza.dbo.pizzas.price) DESC) AS rank
    FROM
        pizza.dbo.pizza_types
    JOIN
        pizza.dbo.pizzas ON pizza.dbo.pizza_types.pizza_type_id = pizza.dbo.pizzas.pizza_type_id
    JOIN
        pizza.dbo.order_details ON pizza.dbo.order_details.pizza_id = pizza.dbo.pizzas.pizza_id
    GROUP BY
        pizza.dbo.pizza_types.category,
        pizza.dbo.pizza_types.name
)

SELECT
    category,
    name,
    revenue
FROM
    RevenueCTE
WHERE
    rank <= 3
ORDER BY
    category,
    revenue DESC;

