
create database pizzasales;

use pizzasales;

-- ********************************************************************************************************************************* --
-- ------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 1 = Retrieve the total number of orders placed.

SELECT 
    COUNT(*) AS total_order
FROM
    orders;
    
 -- ANSWER = Total No. of orders : 21350
 
-- -------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 2 = Calculate the total revenue generated from pizza sales.

select * from pizzas;
select * from order_details;

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price)) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- ANSWER = Total Revenue : 817860

-- -----------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 3 = Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- ANSWER = The Greek Pizza	35.95

-- ------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 4 = Identify the most common pizza size ordered.

select * from order_details;
select * from pizzas;

SELECT 
    pizzas.size, COUNT(order_details.quantity)
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.quantity) DESC
LIMIT 1;

-- ANSWER = L	18526

-- ------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 5 = List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- ANSWER = 
-- The Classic Deluxe Pizza	    = 2453
-- The Barbecue Chicken Pizza	= 2432
-- The Hawaiian Pizza	        = 2422
-- The Pepperoni Pizza	        = 2418
-- The Thai Chicken Pizza	    = 2371

-- -------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 6 = Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- ANSWER = 
-- Classic	14888
-- Supreme	11987
-- Veggie	11649
-- Chicken	11050

-- --------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 7 = Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS orders
FROM
    orders
GROUP BY HOUR(order_time);

-- ANSWER = 

-- 11	1231
-- 12	2520
-- 13	2455
-- 14	1472
-- 15	1468
-- 16	1920
-- 17	2336
-- 18	2399
-- 19	2009
-- 20	1642
-- 21	1198
-- 22	663
-- 23	28
-- 10	8
-- 9	1

-- -------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 8 = Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- ANSWER = 
-- Chicken	6
-- Classic	8
-- Supreme	9
-- Veggie	9

-- ------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 9 = Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity)) AS Average
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- ANSWER = 138

-- ------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 10 = Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- ANSWER = 
-- The Thai Chicken Pizza	43434.25
-- The Barbecue Chicken Pizza	42768
-- The California Chicken Pizza	41409.5

-- --------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 11 = Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- ANSWER = 
-- Classic	26.91
-- Supreme	25.46
-- Chicken	23.96
-- Veggie	23.68

-- -----------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 12 = Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cum_revenue from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id group by orders.order_date) as sales;


-- ANSWER =  table is very long so i don't mention the answer.

-- ------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 13 =  Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name , revenue 
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as ranks
from
(select pizza_types.category, pizza_types.name, 
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as table_a) as table_b
where ranks <= 3;


-- ANSWER = 

-- Chicken	The Thai Chicken Pizza	43434.25
-- Chicken	The Barbecue Chicken Pizza	42768
-- Chicken	The California Chicken Pizza	41409.5
-- Classic	The Classic Deluxe Pizza	38180.5
-- Classic	The Hawaiian Pizza	32273.25
-- Classic	The Pepperoni Pizza	30161.75
-- Supreme	The Spicy Italian Pizza	34831.25
-- Supreme	The Italian Supreme Pizza	33476.75
-- Supreme	The Sicilian Pizza	30940.5
-- Veggie	The Four Cheese Pizza	32265.70000000065
-- Veggie	The Mexicana Pizza	26780.75
-- Veggie	The Five Cheese Pizza	26066.5

-- -------------------------------------------------------------------------------------------------------------------------------------
-- ********************************************************************************************************************************** --




