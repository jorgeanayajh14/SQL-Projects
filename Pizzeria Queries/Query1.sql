/*
select * from orders
select * from item
select * from address
*/

SELECT
	o.order_id,
	i.item_price,
	o.quantity,
	i.item_cat,
	i.item_name,
	o.created_at,
	a.delivery_address1,
	a.delivery_address2,
	a.delivery_city,
	a.delivery_zipcode,
	o.delivery
FROM orders o
LEFT JOIN item i
ON i.item_id = o.item_id
LEFT JOIN address a
ON a.add_id = o.add_id