/*
select * from orders
select * from recipe
select * from item
select * from ingredient
select * from address
select * from v1
*/

ALTER VIEW v1 AS

WITH t1 AS (
	SELECT
		o.item_id,
		i.sku,
		i.item_name,
		r.ing_id,
		r.quantity AS recipe_quantity,
		ing.ing_name,
		ing.ing_weight,
		(ing.ing_price / 100) AS ing_price,
		SUM(o.quantity) AS order_quantity
	FROM orders o
	LEFT JOIN item i
	ON i.item_id = o.item_id
	LEFT JOIN recipe r
	ON r.recipe_id = i.sku
	LEFT JOIN ingredient ing
	ON ing.ing_id = r.ing_id
	GROUP BY o.item_id, i.sku, i.item_name, r.quantity, ing.ing_name, ing.ing_weight, r.ing_id, ing.ing_price)
SELECT 
	item_name,
	ing_name,
	ing_weight,
	ing_price,
	ing_id,
	(recipe_quantity * order_quantity) AS ordered_weight,
	(ing_price / ing_weight) AS unit_cost,
	(recipe_quantity * order_quantity) * (ing_price / ing_weight) AS ingredient_cost
FROM t1