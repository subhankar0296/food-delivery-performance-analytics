
-- Dataset and Problem statement - https://8weeksqlchallenge.com/case-study-2/

-------------------------------------------------------------------
-- PIZZA RUNNER: DATABASE SETUP & INITIALIZATION
-------------------------------------------------------------------

CREATE DATABASE pizza_runner_db;
GO

USE pizza_runner_db;
GO

CREATE SCHEMA pizza_runner;
GO

-- Create Baseline Dimension Tables
CREATE TABLE pizza_runner.runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);

CREATE TABLE pizza_runner.customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

CREATE TABLE pizza_runner.runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

CREATE TABLE pizza_runner.pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);

CREATE TABLE pizza_runner.pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);

CREATE TABLE pizza_runner.pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);

-- Inserting Data
INSERT INTO pizza_runner.runners VALUES 
(1, '2021-01-01'), (2, '2021-01-03'), (3, '2021-01-08'), (4, '2021-01-15');

INSERT INTO pizza_runner.customer_orders VALUES 
(1, 101, 1, '', '', '2021-01-01 18:05:02'),
(2, 101, 1, '', '', '2021-01-01 19:00:52'),
(3, 102, 1, '', '', '2021-01-02 23:51:23'),
(3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 2, '4', '', '2021-01-04 13:23:46'),
(5, 104, 1, 'null', '1', '2021-01-08 21:00:29'),
(6, 101, 2, 'null', 'null', '2021-01-08 21:03:13'),
(7, 105, 2, 'null', '1', '2021-01-08 21:20:29'),
(8, 102, 1, 'null', 'null', '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1, 5', '2021-01-10 11:22:59'),
(10, 104, 1, 'null', 'null', '2021-01-11 18:34:49'),
(10, 104, 1, '2, 6', '1, 4', '2021-01-11 18:34:49');

INSERT INTO pizza_runner.runner_orders VALUES 
(1, 1, '2021-01-01 18:15:34', '20km', '32minutes', ''),
(2, 1, '2021-01-01 19:10:54', '20km', '27minutes', ''),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20mins', 'NaN'),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
(7, 2, '2021-01-08 21:30:45', '25km', '25mins', 'null'),
(8, 2, '2021-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
(9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
(10, 1, '2021-01-11 18:50:20', '10km', '10mins', 'null');

INSERT INTO pizza_runner.pizza_names VALUES (1, 'Meatlovers'), (2, 'Vegetarian');

INSERT INTO pizza_runner.pizza_recipes VALUES (1, '1, 2, 3, 4, 5, 6, 8, 10'), (2, '4, 6, 7, 9, 11, 12');

INSERT INTO pizza_runner.pizza_toppings VALUES 
(1, 'Bacon'), (2, 'BBQ Sauce'), (3, 'Beef'), (4, 'Cheese'), (5, 'Chicken'), (6, 'Mushrooms'), 
(7, 'Onions'), (8, 'Pepperoni'), (9, 'Peppers'), (10, 'Salami'), (11, 'Tomatoes'), (12, 'Tomato Sauce');


-------------------------------------------------------------------
-- DATA CLEANING STAGE
-------------------------------------------------------------------

-- Create Normalized Customer Orders View
CREATE VIEW pizza_runner.vw_customer_orders_clean AS
SELECT order_id, customer_id, pizza_id,
CASE WHEN exclusions IN ('', 'null', 'NaN') THEN NULL
ELSE exclusions END AS exclusions,
CASE WHEN extras IN ('', 'null', 'NaN') THEN NULL
ELSE extras END AS extras,
order_time
FROM pizza_runner.customer_orders;

-- Create Normalized Runner Logistics View
CREATE VIEW pizza_runner.vw_runner_orders_clean AS
SELECT order_id, runner_id,
CASE WHEN pickup_time IN ('', 'null', 'NaN') THEN NULL
ELSE CAST(pickup_time AS DATETIME) END AS pickup_time,
CASE WHEN distance IN ('', 'null', 'NaN') THEN NULL
ELSE CAST(REPLACE(distance, 'km', '') AS DECIMAL(5,2)) END AS distance_km,
CASE WHEN duration IN ('', 'null', 'NaN') THEN NULL
ELSE CAST(REPLACE(REPLACE(REPLACE(duration, 'mins', ''), 'minutes', ''), 'minute', '') AS INT) END AS duration_mins,
CASE WHEN cancellation IN ('', 'null', 'NaN') THEN NULL ELSE cancellation END AS cancellation
FROM pizza_runner.runner_orders;


-------------------------------------------------------------------
-- SECTION A: PIZZA METRICS
-------------------------------------------------------------------

-- A1: How many pizzas were ordered?
SELECT COUNT(*) AS total_pizzas_ordered FROM pizza_runner.vw_customer_orders_clean;

-- A2: How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_orders FROM pizza_runner.vw_customer_orders_clean;

-- A3: How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(pickup_time) AS successful_deliveries 
FROM pizza_runner.vw_runner_orders_clean 
WHERE cancellation IS NULL 
GROUP BY runner_id;

-- A4: How many of each type of pizza was delivered?
SELECT pn.pizza_name, COUNT(*) AS total_delivered
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name;

-- A5: How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id,
SUM(CASE WHEN co.pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers_Orders,
SUM(CASE WHEN co.pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian_Orders
FROM pizza_runner.vw_customer_orders_clean co
GROUP BY co.customer_id;

-- A6: What was the maximum number of pizzas delivered in a single order?
WITH order_counts AS (
SELECT co.order_id, COUNT(co.pizza_id) AS pizza_per_order
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.order_id
)
SELECT MAX(pizza_per_order) AS max_pizzas_delivered FROM order_counts;

-- A7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT co.customer_id,
SUM(CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS with_changes,
SUM(CASE WHEN co.exclusions IS NULL AND co.extras IS NULL THEN 1 ELSE 0 END) AS no_changes
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;

-- A8: How many pizzas were delivered that had both exclusions and extras?
SELECT SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END) 
AS both_changes_count
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;

-- A9: What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR, order_time) AS hour_of_day, COUNT(*) AS volume_ordered
FROM pizza_runner.vw_customer_orders_clean
GROUP BY DATEPART(HOUR, order_time);

-- A10: What was the volume of orders for each day of the week?
SELECT DATENAME(WEEKDAY, order_time) AS day_of_week, COUNT(*) AS volume_ordered
FROM pizza_runner.vw_customer_orders_clean
GROUP BY DATENAME(WEEKDAY, order_time), DATEPART(WEEKDAY, order_time)
ORDER BY DATEPART(WEEKDAY, order_time);


-------------------------------------------------------------------
-- SECTION B: RUNNER AND CUSTOMER EXPERIENCE
-------------------------------------------------------------------

-- B1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEDIFF(WEEK, '2021-01-01', registration_date) + 1 AS registration_week, 
COUNT(runner_id) AS runners_registered
FROM pizza_runner.runners
GROUP BY DATEDIFF(WEEK, '2021-01-01', registration_date);

-- B2: What was the average time in minutes it took for each runner to arrive at Pizza Runner HQ to pickup the order?
SELECT ro.runner_id, AVG(DATEDIFF(MINUTE, co.order_time, ro.pickup_time)) AS avg_pickup_lead_time_mins
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id;

-- B3: Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time AS (
SELECT co.order_id, COUNT(*) AS pizza_count,
DATEDIFF(MINUTE, MIN(co.order_time), MAX(ro.pickup_time)) AS prep_time_mins
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.order_id
)

SELECT pizza_count, AVG(prep_time_mins) AS avg_prep_time_mins
FROM prep_time
GROUP BY pizza_count
ORDER BY pizza_count;

-- B4: What was the average distance travelled for each customer?
SELECT co.customer_id, ROUND(AVG(ro.distance_km), 2) AS avg_distance_km
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;

-- B5: What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration_mins) - MIN(duration_mins) AS delivery_time_difference
FROM pizza_runner.vw_runner_orders_clean;

-- B6: What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id, ROUND(distance_km / (duration_mins / 60.0), 2) AS speed_kmh
FROM pizza_runner.vw_runner_orders_clean
WHERE cancellation IS NULL;

-- B7: What is the successful delivery percentage for each runner?
SELECT
runner_id, ROUND(100.0 * SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)/ COUNT(*), 2)
AS success_rate
FROM pizza_runner.vw_runner_orders_clean
GROUP BY runner_id;


-------------------------------------------------------------------
-- SECTION C: INGREDIENT OPTIMISATION
-------------------------------------------------------------------

-- C1: What are the standard ingredients for each pizza?
WITH toppings AS (
SELECT pizza_id, CAST(value AS INT) AS topping_id
FROM pizza_runner.pizza_recipes
CROSS APPLY STRING_SPLIT(CAST(toppings AS VARCHAR(MAX)), ',')
)

SELECT
CAST(pn.pizza_name AS VARCHAR(50)) AS pizza_name,
STRING_AGG(CAST(pt.topping_name AS VARCHAR(50)), ', ') AS standard_ingredients
FROM toppings t
JOIN pizza_runner.pizza_names pn ON t.pizza_id = pn.pizza_id
JOIN pizza_runner.pizza_toppings pt ON t.topping_id = pt.topping_id
GROUP BY CAST(pn.pizza_name AS VARCHAR(50));

-- C2: What was the most commonly added extra?
WITH extras AS (
SELECT CAST(value AS INT) AS topping_id
FROM pizza_runner.vw_customer_orders_clean
CROSS APPLY STRING_SPLIT(extras, ',')
WHERE extras IS NOT NULL
)

SELECT TOP 1
CAST(pt.topping_name AS VARCHAR(50)) AS topping_name,
COUNT(*) AS times_added
FROM extras e
JOIN pizza_runner.pizza_toppings pt ON e.topping_id = pt.topping_id
GROUP BY CAST(pt.topping_name AS VARCHAR(50))
ORDER BY times_added DESC;

-- C3: What was the most common exclusion?

WITH exclusions AS (
SELECT CAST(value AS INT) AS topping_id
FROM pizza_runner.vw_customer_orders_clean
CROSS APPLY STRING_SPLIT(exclusions, ',')
WHERE exclusions IS NOT NULL
)
SELECT TOP 1
CAST(pt.topping_name AS VARCHAR(50)) AS topping_name,
COUNT(*) AS times_removed
FROM exclusions e
JOIN pizza_runner.pizza_toppings pt ON e.topping_id = pt.topping_id
GROUP BY CAST(pt.topping_name AS VARCHAR(50))
ORDER BY times_removed DESC;


-------------------------------------------------------------------
-- SECTION D: PRICING AND RATINGS
-------------------------------------------------------------------

-- D1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT SUM(CASE WHEN co.pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;

-- D2: What if there was an additional $1 charge for any pizza extras?
WITH SplitExtras AS (
SELECT co.order_id,
    CASE WHEN co.pizza_id = 1 THEN 12 ELSE 10 END AS base_price
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
CROSS APPLY STRING_SPLIT(co.extras, ',')
WHERE ro.cancellation IS NULL
)
SELECT SUM(base_price) + COUNT(*) AS premium_revenue_usd
FROM SplitExtras;

-- D3: The Pizza Runner team now wants to add an additional ratings system... generate a schema for this new table and data.
CREATE TABLE pizza_runner.runner_ratings (
order_id INT PRIMARY KEY,
rating INT CHECK (rating BETWEEN 1 AND 5),
comments VARCHAR(255)
);

INSERT INTO pizza_runner.runner_ratings VALUES
(1, 5, 'Arrived very hot! Excellent packaging.'),
(2, 4, 'Fast shipping and pleasant service.'),
(3, 4, 'Driver struggled slightly to locate house.'),
(4, 3, 'Pizzas structural toppings slid to one side.'),
(5, 5, 'Flawless execution.'),
(7, 2, 'Driver did not speak or acknowledge customer.'),
(8, 4, 'Good speed.'),
(10, 5, 'Incredibly fast runtime!');


-------------------------------------------------------------------
-- SECTION E: BONUS DML CHALLENGES
-------------------------------------------------------------------

-- E1: Recreate a single reporting query containing detailed delivery logs for analysis
SELECT co.customer_id, co.order_id, ro.runner_id, rt.rating, co.order_time, ro.pickup_time,
DATEDIFF(MINUTE, co.order_time, ro.pickup_time) AS prep_time_mins, ro.duration_mins,
ROUND(ro.distance_km / (ro.duration_mins / 60.0), 1) AS speed_kmh,
COUNT(*) AS total_pizzas
FROM pizza_runner.vw_customer_orders_clean co
JOIN pizza_runner.vw_runner_orders_clean ro ON co.order_id = ro.order_id
LEFT JOIN pizza_runner.runner_ratings rt ON co.order_id = rt.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, co.order_id, ro.runner_id, rt.rating, co.order_time, ro.pickup_time,
ro.duration_mins, ro.distance_km;