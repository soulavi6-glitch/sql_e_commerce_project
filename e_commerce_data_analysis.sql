
alter table customers
alter column email type varchar(50);



select * from customers;

alter table productss
alter column product_name type varchar(50);


select * from productss;

select * from employees;

select * from orders;

select * from items;

select * from payments ;

select * from returns;

--Find each customer's customer_id, customer_name, total_orders, and customer_order_distribution. Calculate
--the total number of orders for every customer, including customers with zero orders, and calculate the
--cumulative distribution based on total_orders in ascending order. Customers with the same total_orders 
--must receive the same cumulative distribution value. Sort the final output by customer_order_distribution 
--ascending and then customer_id ascending.
select 
		c.customer_id,
		c.customer_name,
		c.total_orders,
		cume_dist() over (order by total_orders desc)as cumulative_dist
from	(select 
		c.customer_id,
		c.customer_name,
		count(o.order_id)as total_orders
		from customers c 
		left join orders o
		on o.customer_id=c.customer_id
		group by c.customer_id, c.customer_name
		having count(*)>=0)c
		order by customer_id asc
		
--Q97. Find each employee's employee_id, employee_name, total_orders, and order_distribution. Calculate each
--employee's total orders using the orders table, include employees who have placed zero orders,
--and use CUME_DIST() to calculate the cumulative distribution based on total_orders in descending order. 
--If multiple employees have the same total orders, they must receive the same distribution value.
--Sort the final output by order_distribution ascending and employee_id ascending.
select 
		e.employee_id,
		e.employee_name,
		e.total_orders,
		cume_dist()  over (order by e.total_orders desc)as cume_order_dist
from	(select 
		e.employee_id,
		e.employee_name,
		count(o.order_id)as total_orders
		from employees e
		left join orders o on
		o.employee_id=e.employee_id
		group by e.employee_id,
				e.employee_name
		having count(*)>=0)e
		order by cume_order_dist asc,
				e.employee_id asc
--Q96. Find each customer's customer_id, customer_name, total_orders, and customer_order_distribution by
--calculating the total number of orders placed by each customer and then applying CUME_DIST() over
--total_orders in ascending order. Include customers who have never placed an order, 
--ensure customers with equal total_orders receive the same distribution value, and sort the final output
--by customer_order_distribution ascending and then customer_id ascending.
select 
		c.customer_id,
		c.customer_name,
		c.total_orders,
		cume_dist() over (order by c.total_orders asc)as cume_dist_order
from	(select 
		c.customer_id,
		c.customer_name,
		count(o.order_id) as total_orders
		from customers c
		left join orders o on
		o.customer_id=c.customer_id
		group by c.customer_id,
				c.customer_name)c	
		order by cume_dist_order asc,
		customer_id asc
		
--Find each employee's employee_id, employee_name, total_orders, and employee_order_distribution by
--calculating the total number of orders handled by each employee and applying CUME_DIST() over total_orders
--in descending order. Include employees who have never handled an order, ensure employees with equal 
--total_orders receive the same distribution value, and return only employees whose
--employee_order_distribution is less than or equal to 0.50, sorted by employee_order_distribution
--ascending and then employee_id ascending.
select 
		c.employee_id,
		c.employee_name,
		c.total_orders,
		cume_dist_orders
from 	(select 
		e.employee_id,
		e.employee_name,
		count(o.order_id)as total_orders,
		cume_dist() over (order by count(o.order_id) desc)as cume_dist_orders
		from employees e 
		left join orders o on 
		o.employee_id=e.employee_id
		group by e.employee_id,
				e.employee_name)c
		where cume_dist_orders<=0.50
		order by cume_dist_orders asc,
		c.employee_id asc
		
--Find each customer's customer_id, customer_name, total_orders, and percent_rank_orders by calculating the 
--total number of orders for every customer, including customers with zero orders, and then applying 
--PERCENT_RANK() over total_orders in descending order. Return only customers whose percent_rank_orders is 
--greater than 0.25 and less than or equal to 0.75, sorting by percent_rank_orders ascending and then
--customer_id ascending.
select c.customer_id,
		c.customer_name,
		c.total_orders,
		c.percent_rank_orders
from	(select 
		c.customer_id,
		c.customer_name,
		count(o.order_id)as total_orders,
		percent_rank () over (order by count(o.order_id)desc)as percent_rank_orders
		from customers c 
		left join orders o 
		on o.customer_id = c.customer_id
		group by c.customer_id,
				c.customer_name)c
		where c.percent_rank_orders >0.25 and 
				c.percent_rank_orders<=0.75
		order by c.percent_rank_orders asc,
				c.customer_id;


--Find each customer’s order details along with the date of their next order. Return customer_id, order_id,
--order_date, and next_order_date. Calculate the next order date separately for each customer, ordered by 
--order_date ascending. Include the customer’s final order even when they have no next order, showing NULL 
--for next_order_date. Sort the final output by customer_id and order_date ascending.
select 
		customer_id,
		order_id,
		order_date,
		next_order_date
from	(select 
		customer_id,
		order_id,
		order_date,
		lead(order_date) over (partition by customer_id order by order_date asc)as next_order_date
		from orders
		order by customer_id asc
		
--Find customers whose next order was placed within 7 days of their current order. Return customer_id, 
--order_id, order_date, next_order_date, and gap_days. Calculate the next order date separately for each 
--customer using LEAD(), calculate the number of days between consecutive orders, and return only rows where
--the gap is 7 days or less. Exclude rows that have no next order. Sort by customer_id and 
--order_date ascending.				
select 
		customer_id,
		order_id,
		order_date,
		next_order_date,
		(next_order_date-order_date)as gap_days
from	(select 
		customer_id,
		order_id,
		order_date,
		lead(order_date) over (partition by customer_id order by order_date)as next_order_date
		from orders 
		)t
		where (next_order_date-order_date) <=7
		order by customer_id asc,
				order_date asc;

--Find each customer's order details and the status of their next order. Return customer_id, order_id, 
--order_date, order_status, and next_order_status. Use LEAD() to retrieve the next order's order_status for
--the same customer, ordering by order_date ascending. Include all orders, including the final order for 
--each customer where next_order_status will be NULL. Sort by customer_id and order_date ascending.
select 
		customer_id,
		order_id,
		order_date,
		order_status,
	lead(order_status) over (partition by customer_id order by order_date, order_status)as next_order_status
	from orders
	order by customer_id asc,
	order_date asc
	
--Find customers whose order status changed between consecutive orders. Return customer_id, order_id, 
--order_date, order_status, and next_order_status. Use LEAD() to retrieve the next order's status for the 
--same customer, ordered by order_date ascending and order_id ascending. Return only rows where the current 
--and next order statuses are different, excluding the final order when no next order exists. 
--Sort the output by customer_id and order_date ascending.
select 
		customer_id,
		order_id,
		order_date,
		order_status,
		next_order_status
from	(select 
		customer_id,
		order_id,
		order_date,
		order_status,
lead(order_status) over (partition by customer_id order by order_date asc, order_id asc)as next_order_status
		from orders)t
		where order_status <> next_order_status
		and next_order_status is not null
		order by customer_id  asc,
		order_date asc

SELECT
    customer_id,
    order_id,
    order_date,
    order_status,
    next_order_status
FROM (
    SELECT
        customer_id,
        order_id,
        order_date,
        order_status,
        LEAD(order_status) OVER (
            PARTITION BY customer_id
            ORDER BY order_date ASC, order_id ASC
        ) AS next_order_status
    FROM orders
) t
WHERE next_order_status IS NOT NULL
  AND order_status <> next_order_status
ORDER BY customer_id ASC, order_date ASC;

--Find each customer's order details and the date of their latest order. Return customer_id, order_id,
--order_date, and latest_order_date. Use LAST_VALUE() to calculate the latest order_date for each customer,
--considering all of that customer's orders. Include every order and sort the final output by customer_id 
--ascending and order_date ascending.
select 
		customer_id,
		order_id,
		order_date,
		last_value(order_date) over (partition by customer_id order by order_date
		rows between unbounded preceding and unbounded following)as latest_order_date
		from orders
		order by customer_id asc,
		 customer_id asc

--Find each customer's order details and the status of their final order. Return customer_id, order_id, 
--order_date, order_status, and final_order_status. Use LAST_VALUE() to retrieve the status of each 
--customer's final order across all their orders. Include every order and sort the output by customer_id 
--ascending, order_date ascending, and order_id ascending.
select 
		customer_id,
		order_id,
		order_date,
		order_status,
		last_value(order_status) over (partition by customer_id order by order_date, order_id
		rows between unbounded preceding and unbounded following)as final_order_status
		from orders
		order by customer_id asc,
		order_date asc,
		order_id asc

--Find each customer's order details and the delivery date of their final order. Return customer_id,
--order_id, order_date, delivery_date, and final_delivery_date. Use LAST_VALUE() to retrieve the 
--delivery_date from the customer's final order, considering all orders for that customer. 
--Include every order, even if the final delivery date is NULL. Sort by customer_id, order_date,
--and order_id, all ascending.  
select
		customer_id,
		order_id,
		order_date,
		delivery_date,
last_value(delivery_date) over (partition by customer_id order by order_date, order_id
rows between unbounded preceding and unbounded following)as final_delivery_date
		from orders
		order by customer_id asc,
		order_date asc,
		order_id asc
		
--Find each customer's customer_id, customer_name, order_id, order_date, order_status, and 
--latest_order_status, where latest_order_status shows the status of that customer's most recent order on
---every row belonging to that customer. Return only customers who have placed at least 3 orders. 
--Use LAST_VALUE() to identify the most recent order based on order_date, using order_id to break ties. 
--Display all qualifying orders, sorted by customer_id, order_date, and order_id in ascending order.
select * from (select 
		c.customer_id,
		c.customer_name,
		o.order_id,
		o.order_date,
		o.order_status,
last_value(o.order_status) over (partition by c.customer_id order by o.order_date, o.order_id
	rows  between unbounded preceding and unbounded following)as latest_order_status,
	count(o.order_id) over (partition by c.customer_id) as total_orders
		from customers c
		 join orders o on 
		o.customer_id=c.customer_id)as t
		where total_orders>=3
		order by customer_id asc,
		order_date asc,
		order_id asc

--Find each employee's employee_id, employee_name, order_id, order_date, order_status, and 
--final_order_status, where final_order_status displays the status of that employee's last order on every 
--row belonging to that employee. Consider only employees who have handled at least 5 orders, and identify 
--the last order using order_date in descending chronological importance, with order_id as the tie-breaker. 
--Return all orders for qualifying employees, including cancelled orders, sorted by employee_id,
--order_date, and order_id in ascending order.
select *
from	(select 
		e.employee_id,
		e.employee_name,
		o.order_id,
		o.order_date,
		o.order_status,
last_value(o.order_status) over (partition by e.employee_id order by o.order_date desc, o.order_id desc
	rows between unbounded preceding and unbounded following)as final_order_status,
count(o.order_id) over (partition by e.employee_id)as total_orders
		from employees e 
		join orders o on
		o.employee_id = e.employee_id) as t
		where total_orders >=5
		order by employee_id,
		order_date,
		order_id

--Find each customer's customer_id, customer_name, order_id, order_date, and order_status, along with the 
--difference in days between the current order and the customer's previous order. Return only orders where
--the gap is greater than 30 days, and only customers who have placed at least 3 orders. Sort by customer_id
--and order_date ascending.
select 
		t.customer_id,
		t.customer_name,
		t.order_id,
		t.order_date,
		t.order_status,
		t.previous_order_date,
		t.total_orders,
		(t.order_date - t.previous_order_date)as gap 
from	(select 
		c.customer_id,
		c.customer_name,
		o.order_id,
		o.order_date,
		o.order_status,
		lag(o.order_date) over (partition by c.customer_id order by o.order_date asc, order_id asc)
		as previous_order_date,
		count(o.order_id) over (partition by c.customer_id)as total_orders
		from customers c 
		join orders o on
		o.customer_id = c.customer_id)as t
		where (t.order_date - t.previous_order_date) >30 and
		total_orders >=3
		order by t.customer_id, t.order_date

--Find each employee's employee_id, employee_name, order_id, order_date, and order_status, along with the 
--previous order's date (previous_order_date) and the gap in days (gap_days) between consecutive orders 
--handled by that employee. Return only employees who have handled at least 4 orders and orders where the
--gap between consecutive orders is at least 15 days. Use PostgreSQL without a CTE, 
--and sort the results by employee_id, order_date, and order_id in ascending order.
select 
		t.employee_id,
		t.employee_name,
		t.order_id,
		t.order_date,
		t.order_status,
		t.previous_order,
		t.total_orders,
		(t.order_date - t.previous_order)as gap
from	(select 
		e.employee_id,
		e.employee_name,
		o.order_id,
		o.order_date,
		o.order_status,
		lag(o.order_date) over (partition by e.employee_id order by o.order_date, o.order_id)as previous_order,
		count(o.order_id) over(partition by e.employee_id)as total_orders
		from employees e 
		join orders o on
		o.employee_id=e.employee_id)as t
		where (t.order_date - t.previous_order)>=15 and
		t.total_orders >=4
		order by t.employee_id, t.order_date, t.order_id
		

--Find each customer's customer_id, customer_name, order_id, order_date, and order_status, along with the 
--next order's date (next_order_date) and the gap in days between the current order and the next order. 
--Return only customers who have placed at least 4 orders and orders where the gap to the next order is 
--greater than 20 days. Use PostgreSQL without a CTE, and sort by customer_id, order_date, and order_id
--ascending.
select 
		t.customer_id,
		t.customer_name,
		t.order_id,
		t.order_date,
		t.order_status,
		t.next_order,
		t.total_orders,
		(t.next_order-t.order_date)as gap
from	(select
		c.customer_id,
		c.customer_name,
		o.order_id,
		o.order_date,
		o.order_status,
		lead(o.order_date) over (partition by c.customer_id order by o.order_date, o.order_id)as next_order,
		count(o.order_id) over (partition by c.customer_id)as total_orders
		from customers c 
		join orders o on 
		o.customer_id = c.customer_id) as t
		where (t.next_order-t.order_date) >20 and
		t.total_orders >=4
		order by t.customer_id,
		t.order_date,
		t.order_id
		
--Find each employee's employee_id, employee_name, order_id, order_date, and order_status, along with the
--next order's date (next_order_date) and the gap in days between the current order and the next order. 
--Return only employees who have handled at least 5 orders and orders where the gap to the next order is
--at least 10 days. Use PostgreSQL without a CTE, and sort by employee_id, order_date, and order_id 
--ascending.
select
		t.employee_id,
		t.employee_name,
		t.order_date,
		t.order_id,
		t.order_status,
		t.next_order_date,
		(t.next_order_date - t.order_date)as gap
from	(select 
		e.employee_id,
		e.employee_name,
		o.order_id,
		o.order_date,
		o.order_status,
lead(o.order_date) over (partition by e.employee_id order by o.order_date, o.order_id)as next_order_date,
		count(o.order_id) over (partition by e.employee_id)as total_orders
		from employees e 
		join orders o on
		o.employee_id = e.employee_id)t
		where (t.next_order_date - t.order_date) >=10 and
		t.total_orders >=5
		order by t.employee_id,
					t.order_date,
					t.order_id

--Find each customer's customer_id, customer_name, order_id, order_date, and order_status, along with the
--previous order's date and the next order's date. Also calculate the number of days between the previous 
--and next orders. Return only customers who have placed at least 5 orders, and only rows where both the
--previous and next orders exist and the difference between their dates is at least 60 days. 
--Use PostgreSQL without a CTE, and sort by customer_id, order_date, and order_id ascending.
select 
		t.customer_id,
		t.customer_name,
		t.order_id,
		t.order_date,
		t.order_status,
		t.previous_order,
		t.next_order,
		t.total_orders,
		(t.next_order - t.previous_order)as gap
from (select 
		c.customer_id,
		c.customer_name,
		o.order_id,
		o.order_date,
		o.order_status,
	lag(o.order_date) over (partition by c.customer_id order by o.order_date, o.order_id)as previous_order,
	lead(o.order_date) over (partition by c.customer_id order by o.order_date, o.order_id)as next_order	,
	count(o.order_id) over (partition by c.customer_id)as total_orders
		from customers c 
		join orders o on
		o.customer_id = c.customer_id)t
		where (next_order - previous_order)>=60
		and t.total_orders >= 5 

--Find each employee's employee_id, employee_name, order_id, order_date, and order_status, along with the
--previous order date, next order date, and the number of days between those two dates. Return only 
--employees who have handled at least 6 orders, and only rows where both neighboring orders exist and the 
--difference between their dates is greater than 45 days. Use PostgreSQL without a CTE,
--and sort by employee_id, order_date, and order_id ascending.
select 
		t.employee_id,
		t.employee_name,
		t.order_id,
		t.order_date,
		t.order_status,
		t.previous_order,
		t.next_order,
		t.total_orders,
		(t.next_order-t.previous_order)as gap
from	(select 
		e.employee_id,
		e.employee_name,
		o.order_id,
		o.order_date,
		o.order_status,
lag(o.order_date) over (partition by e.employee_id order by o.order_date,o.order_id)as previous_order,
lead(o.order_date) over (partition by e.employee_id order by o.order_date, o.order_id)as next_order,
count(o.order_id) over (partition by e.employee_id)as total_orders
		from employees e
		join orders o 
		on e.employee_id = o.employee_id)t
		where (t.next_order-t.previous_order) >45 and
		t.total_orders >=6
		order by t.employee_id,
				t.order_date,
				t.order_id

--Find each customer's customer_id, customer_name, order_id, order_date, and order_status, along with the 
--previous order date, next order date, and the number of days between those two dates. Return only 
--customers who have placed at least 6 orders, and only rows where both neighboring orders exist and the 
--difference between their dates is at most 30 days. Use PostgreSQL without a CTE, 
--and sort by customer_id, order_date, and order_id ascending.
select 
		t.customer_id,
		t.customer_name,
		t.order_date,
		t.order_status,
		t.previous_order,
		t.next_order,
		t.total_orders,
		(t.next_order - t.previous_order) as gap
from	(select 
		c.customer_id,
		c.customer_name,
		o.order_date,
		o.order_id,
		o.order_status,
		lag(o.order_date) over (partition by c.customer_id order by o.order_date, o.order_id)as previous_order,
	lead(order_date) over (partition by c.customer_id order by o.order_date, o.order_id)as next_order,
	count(o.order_id) over (partition by c.customer_id)as total_orders
	from customers c 
	join orders o on
	o.customer_id = c.customer_id) as t
	where (t.next_order - t.previous_order) <=30 and
	t.total_orders >=6
	order by t.customer_id,
	t.order_date,
	t.order_id

--Find each customer's customer_id, customer_name, and total number of orders, but return only customers 
--whose total order count is greater than the average number of orders per customer, including customers 
--who placed zero orders when calculating that average. Use PostgreSQL, write the query without a CTE, 
--and sort the results by total order count descending, then customer_id ascending.
select 
		c.customer_id,
		c.customer_name,
		count(o.order_id) as total_orders
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name
		having count(o.order_id)>(select avg(order_count)
								from (select count(o2.order_id)as order_count
								from customers  c2
								left join orders o2 on
								o2.customer_id=c2.customer_id
								group by c2.customer_id)as t )
					order by total_orders desc, c.customer_id asc


--Question: Find each customer's customer_id, customer_name, and total_orders for customers whose total 
--number of orders is greater than the average number of orders per customer. Include customers with zero 
--orders when calculating the average.
select 
		c.customer_id,
		c.customer_name,
		count(o.order_id) as total_orders
		from customers c
		left join orders o
		on o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name
		having count(o.order_id) > (select avg(order_count)
							from(select count(o2.order_id) as order_count
							from customers c2
							left join orders o2 on
							o2.customer_id = c2.customer_id
							group by c2.customer_id)as t)
							order by total_orders;
							
							

--Find customers whose total number of orders is greater than the average order count of customers 
--from the same city. Include customers with zero orders when calculating each city's average.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id) as total_orders
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) > (select 
							avg(order_count)
							from (select
							c2.customer_id,
							c2.city,
							count(o2.order_id) as order_count
							from customers c2 
							left join 
							orders o2 on 
							o2.customer_id = c2.customer_id
							group by c2.customer_id, c2.city)as t
							where t.city =c.city)
							order by total_orders 
--Find customers whose total order count is greater than the average order count of all customers, 
--but only include customers whose order count is also greater than the average order count in their own city. 
--Include zero-order customers when calculating both averages.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id)as total_orders
		from customers c
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id,c.customer_name,
		c.city
		having count(o.order_id) >(select avg(t.order_count)
							from (select count(o2.order_id)as order_count
							from customers c2 
							left join orders o2 on 
							o2.customer_id = c2.customer_id
							group by c2.customer_id)as t) and 
							count(o.order_id) >(select avg(u.order_count)
							from (select c3.customer_id,
							c3.city,
							count(o3.order_id)as order_count
							from customers c3
							left join 
							orders o3 on
							o3.customer_id = c3.customer_id
							group by c3.customer_id, c3.city)as u
							where u.city = c.city)
							order by total_orders

--Q114. Find each customer's customer_id, customer_name, city, and total_orders for customers whose 
--total order count is greater than the average order count across all customers and who have placed 
--more orders than at least 2 other customers in their own city. Include customers with zero orders when 
--calculating the overall average. Use the customers and orders tables and return the results 
--sorted by total_orders in descending order.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id)as total_orders
		from customers c
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name,
		c.city
		having  count(o.order_id) > (select avg(order_count)
				from (select c2.customer_id,
								c2.city,
								count(o2.order_id)as order_count
								from customers c2 
								left join orders o2 on 
								c2.customer_id = o2.customer_id
								group by c2.customer_id, c2.city
								having count(o2.order_id)>=2)as t
								where c2.city = c.city)
order by total_orders

--Q114. Find each customer's customer_id, customer_name, city, and total_orders for customers whose
--total order count is greater than the average order count across all customers and who have placed more
--orders than at least two other customers in their own city. Include customers with zero orders
--when calculating the overall average. Use the customers and orders tables and
--sort the results by total_orders in descending order.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id) as total_orders
		from customers c 
		left join orders o on
		o.customer_id  = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) > (select avg(t.order_count) 
								from (select count(o2.order_id)as order_count
								from customers c2 
								left join orders o2 on
								o2.customer_id = c2.customer_id
								group by c2.customer_id) as t) and
						(select count(*) from
								(select count(o3.order_id)as order_count,
												c3.customer_id,
												c3.city
												from customers c3 
												left join orders o3 on
												o3.customer_id = c3.customer_id
												where c3.city = c.city
												group by c3.customer_id,c3.city)as u
												where u.order_count < count(o.order_id))>=2
												order by total_orders desc
												

--Q115. Find each customer's customer_id, customer_name, and total_orders for customers whose total order
--count is greater than the average order count across all customers. Include customers with zero orders 
--when calculating the average. Use the customers and orders tables, do not use a CTE, 
--and sort by total_orders in descending order, followed by customer_id in ascending order.
select 
		c.customer_id,
		c.customer_name,
		count(o.order_id)as total_orders
		from customers c 
		left join orders o on 
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name
		having count(o.order_id) > (select avg(order_count)
					from (select 
								c2.customer_id,
								count(o2.order_id)as order_count
								from customers c2 
								left join orders o2 on 
								o2.customer_id = c2.customer_id
								group by c2.customer_id)as u)
								order by total_orders desc , customer_id asc

--Find each customer's customer_id, customer_name, and total_orders for customers who have placed more 
--orders than the customer average within their own city. Include customers with zero orders when
--calculating each city's average. Use the customers and orders tables, do not use a CTE, 
--and sort by city ascending and total_orders descending
select 
		c.customer_id,
		c.customer_name, c.city,
		count (o.order_id)as total_orders
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) > (select avg(order_count)
					from (select c2.customer_id,
									c2.city,
									count(o2.order_id)as order_count
									from customers c2 
									left join orders o2 on
									o2.customer_id = c2.customer_id
									where c2.city = c.city
									group by c2.customer_id, c2.city
									)as u)
									order by total_orders desc, c.city asc

--Q117 — Advanced Self JOINs: Find pairs of customers who live in the same city but have different
--customer_id values.
--Return customer_id, customer_name, and city for both customers. 
--Display each pair only once and sort by city ascending.
select 
		c.customer_id as customer1_id,
		c.customer_name as customer1_id,
		c.city,
		c2.customer_id as customer2_id,
		c2.customer_name as customer2_name
		from customers c 
		 join customers c2 on
c2.city = c.city
and c.customer_id < c2.customer_id
order by c.city asc

--Q118. Find each customer's customer_id, customer_name, city, order_date, and the earliest order_date 
--recorded for that customer. Include customers with zero orders, and sort the results by customer_id 
--ascending and order_date ascending. Use the customers and orders tables.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		o.order_date,
		min(o.order_date)over (partition by c.customer_id)as earliest_order_date
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		order by c.customer_id asc, order_date asc

--Interview question: Find each customer's customer_id, customer_name, city, and total_orders. Include all
--customers, even those who have never placed an order. Return only customers whose total order count is 
--zero or at least three. Sort by total_orders descending, then customer_id ascending.
--Use the customers and orders tables.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id)as total_orders
		from customers c
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) =0 or count (o.order_id)>=3
		order by count(o.order_id) desc, c.customer_id asc

--Find each city and the number of customers living in that city who have placed at least one order.
--Return city and customers_with_orders. Count each customer only once, even if they have placed multiple 
--orders. Include only cities with at least two such customers, 
--and sort by customers_with_orders descending, then city ascending.
select 	
		c.city,
		count(distinct c.customer_id)as customers_in_city
		from customers c 
		inner join orders o on
		o.customer_id = c.customer_id
		group by c.city
		having count(distinct c.customer_id)  >=2
		order by  customers_in_city asc,
		c.city asc
		
--Find each city and the number of customers living in that city who have placed at least one order. \
--Return city and customers_with_orders. Count each customer only once, even if they have placed multiple
--orders. Include only cities with at least two such customers.
select 
		c.city,
		count(distinct c.customer_id)as customer_in_city
		from customers c 
		join orders o on
		o.customer_id = c.customer_id
		group by c.city
		having count(distinct c.customer_id) >=2
		order by c.city desc

--Find each customer’s customer_id, customer_name, and total number of orders. Return only customers who
--have placed at least 3 orders. Also include their city and sort the results by total orders in 
--descending order.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id) as total_orders
		from customers c 
		left join orders o on 
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) >=3
		order by total_orders desc

--Find each city and its average number of orders per customer. Include all customers in the calculation, 
--including customers who have placed zero orders. Return only cities having an average order count
--greater than 2. Return city and avg_orders_per_customer, sorted by average order count in descending order.
--Your turn. No hints.
select 
		c.city,
		avg(c.total_orders) as avg_order_per_cust
		from (select 
				c.customer_id,
				c.city,
				count(o.order_id)as total_orders
				from customers c 
				left join orders o on 
				o.customer_id = c.customer_id
				group by c.customer_id, c.city)as c
				group by c.city
				having avg(c.total_orders)>2
				order by avg_order_per_cust desc

--Find each employee's employee_id, employee_name, and total number of orders assigned to them. Include 
--employees with zero orders. Return only employees whose order count is greater than the average order
--count across all employees, including employees with zero orders. Sort by total orders descending.
select 
		e.employee_id,
		e.employee_name,
		count(o.order_id)as total_orders
		from employees e  
		left join orders o on 
		o.employee_id = e.employee_id
		group by e.employee_id,
					e.employee_name
		having count(o.order_id)>(select avg(e.total_orders)
									from (select e2.employee_id,
												e2.employee_name,
												count(o2.order_id)as total_orders
												from employees e2
												left join orders o2 on
												o2.employee_id = e2.employee_id
												group by e2.employee_id,
														e2.employee_name)as e)
		order by total_orders desc
		
--Find each customer's customer_id, customer_name, city, and total orders. Return customers whose total 
--order count is greater than the average order count of customers in their own city. Include customers
--with zero orders when calculating the city-wise average. Sort by city ascending and total 
--orders descending.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id)as total_orders
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) > (select avg(e.order_count)
							from (select 
										c2.city,
										c2.customer_id,
										count(o2.order_id)as order_count
										from customers c2
										left join orders o2 on 
										o2.customer_id = c2.customer_id
										group by c2.city, c2.customer_id)as e
										where e.city = c.city)
		order by c.city asc,total_orders desc								

--Find each employee's employee_id, employee_name, and the number of distinct customers whose orders have
--been handled by that employee. Return only employees who have handled orders for at least 3 different
--customers. Count each customer only once per employee, even if the employee handled multiple orders 
--for that customer. Sort by the number of distinct customers in descending order.
select
		e.employee_id,
		e.employee_name,
		count(distinct o.customer_id)as distinct_customers
		from employees e 
		left join orders o on
		o.employee_id = e.employee_id
		group by e.employee_id, e.employee_name
		having count(distinct o.customer_id )>=150
		order by distinct_customers desc

--Find each customer's customer_id, customer_name, and the number of distinct employees who have handled 
--their orders. Return only customers whose orders have been handled by at least 2 different employees.
--Count each employee only once per customer, even if the employee handled multiple orders.
--Sort by the number of distinct employees in descending order.
select 
		c.customer_id,
		c.customer_name,
		count(distinct o.employee_id)as distinct_employees
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id,
				c.customer_name
		having count(distinct o.employee_id) >=2 
		order by distinct_employees desc

---Find each city and the number of distinct employees who have handled orders for customers living in that
--city. Return only cities where at least 2 different employees have handled orders. Count each employee 
--only once per city, regardless of how many orders they handled. Return city and distinct_employees. 
--Sort by distinct employees in descending order.
select 
		c.city,
		count(distinct o.employee_id)as distinct_employees
		from customers c 
		left join orders o on
		o.customer_id =c.customer_id
		group by c.city
		having count(distinct o.employee_id)>=2
		order by distinct_employees desc

--Find each employee's employee_id, employee_name, and the total number of distinct cities in which they 
--have handled customer orders. Return only employees who have handled orders for customers from at least 
--2 different cities. Count each city only once per employee, regardless of the number of orders. 
--Sort by distinct cities in descending order.
select 
		e.employee_id,
		e.employee_name,
		count(distinct o.city)as distinct_city
		from employees e 
		left join orders o on
		o.employee_id = e.employee_id
		group by e.employee_id, e.employee_name
		having count(distinct o.city)>=2
		order by distinct_city desc

--Find each employee's employee_id, employee_name, total number of distinct customers served, and total 
--number of completed orders. Return only employees who have served at least 5 distinct customers and
--completed at least 3 orders. Count each customer only once, even if they placed multiple orders 
--with the same employee. Sort by completed orders in descending order.
select 
		e.employee_id,
		e.employee_name,
		count(distinct o.customer_id)as distinct_customers,
		count(case when order_status ='Completed' then 1  end)as completed_orders
		from employees e 
		left join orders o on
		o.employee_id = e.employee_id
		group by e.employee_id, e.employee_name
		having count(distinct o.customer_id) >=5 and 
				count(case when order_status ='Completed' then 1  end) >=3
		order by completed_orders  desc

--Find each customer's customer_id, customer_name, total number of orders, and number of distinct employees
--who have handled their orders. Return customers who have placed at least 4 orders and whose orders have 
--been handled by at least 2 different employees. Include only orders with status Completed or Delivered.
--Sort by total orders in descending order.
select
		c.customer_id,
		c.customer_name,
		count(case when o.order_status='Completed' or o.order_status = 'Delivered' then 1 end)as total_orders,
		count(distinct o.employee_id)as distinct_employees
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name
		having count(case when o.order_status='Completed' or o.order_status = 'Delivered' then 1 end) >=4 and
		count(distinct o.employee_id) >=2
		order by total_orders desc

--Find each city and the total number of distinct customers who have placed Completed orders and the total
--number of distinct employees who handled those orders. Return only cities having at least 5 distinct 
--customers and at least 3 distinct employees. Count customers and employees only once per city.
--Sort by distinct customers in descending order.
select 
		c.city,
		count(distinct case when o.order_status = 'Completed' then c.customer_id end)as customers_with_co,
		count(distinct case when o.order_status = 'Completed' then o.employee_id end)as distinct_employees
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.city
		having count(distinct  case when o.order_status = 'Completed' then c.customer_id end) >=5 and
count(distinct case when o.order_status = 'Completed' then o.employee_id end)	>=3
		order by customers_with_co desc

--Find each employee's employee_id, employee_name, total number of orders handled, and number of distinct 
--customers whose orders were successfully delivered. Return employees who have handled at least 10 total 
--orders and have successfully delivered orders to at least 4 distinct customers.
--Sort by total orders in descending order.
select
		e.employee_id,
		e.employee_name,
		count(o.order_id)as total_orders,
		count(distinct case when o.order_status = 'Delivered' then o.customer_id end)as customers_with_do
		from employees e 
		left join orders o on
		o.employee_id = e.employee_id
		group by e.employee_id, e.employee_name
		having count(o.order_id) >= 10 and
		count(distinct case when o.order_status = 'Delivered' then o.customer_id end) >=4
		order by total_orders desc
		
--Find each customer's customer_id, customer_name, city, total number of orders, and number of distinct 
--employees who handled their Completed orders. Return customers who have placed at least 6 total orders
--(any status) and whose Completed orders were handled by at least 2 different employees. 
--Include customers with zero orders when calculating the overall average order count, 
--and return only customers whose total orders are greater than that average.
--Sort by total orders in descending order.
select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id)as total_orders,
		count(distinct case when o.order_status = 'Completed' then o.employee_id end)as employees_with_co
		from customers c
		left join orders o on 
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city
		having count(o.order_id) >=6 and
		count(distinct case when o.order_status = 'Completed' then o.employee_id end) >=2 and
		count (o.order_id) >(select avg(t.order_count)
		from(select 
				c2.customer_id,
				count(o2.order_id)as order_count
				from customers c2
				left join orders o2 on
				o2.customer_id = c2.customer_id
				group by c2.customer_id)as t)
				order by total_orders desc
				
--Find each city, the total number of customers, the total number of Completed orders, and the number of
--distinct employees who handled those Completed orders. Return only cities where the total number of
--customers is greater than the average number of customers per city, and where at least 10 Completed 
--orders were handled by at least 3 distinct employees. Include cities even if some customers have never 
--placed an order. Sort by Completed orders in descending order.									
select
		c.city,
		count(distinct c.customer_id)as total_customers,
		count(case when o.order_status = 'Completed' then 1 end)as completed_orders,
		count(distinct case when o.order_status = 'Completed' then o.employee_id end)as employees_with_co
		from customers c
		left join orders o on 
		o.customer_id = c.customer_id
		group by c.city 
		having count(distinct c.customer_id) > (select avg(customer_count)
								from (select  c2.city,
								count(distinct c2.customer_id)as customer_count
								from customers c2
							
								group by  c2.city)as t)and 
		count(case when o.order_status = 'Completed' then 1 end) >=10  and 
		count(distinct case when o.order_status = 'Completed' then o.employee_id end) >=3 
		 order by completed_orders desc

--Find each employee's employee_id, employee_name, city-wise number of distinct customers they have handled,
--and total number of Completed orders in each city. Return only employee-city combinations where the
--employee has handled at least 3 distinct customers and completed at least 5 orders in that city.
--Include only Completed orders in both calculations.
--Sort by employee ID ascending and Completed orders descending.					
select 
		e.employee_id,
		e.employee_name,
		c.city,
		count( distinct c.customer_id) as distinct_customers,
		count(o.order_id)as completed_orders
		from employees e 
		join orders o on 
		o.employee_id = e.employee_id
		join customers c on
		o.customer_id = c.customer_id
		where order_status = 'Completed'
		group by e.employee_id,
					e.employee_name,
					c.city
					having count( distinct c.customer_id) >=3  and
					count(o.order_id) >=3
					order by e.employee_id , completed_orders desc

--Find each product's product_id, product_name, category, total quantity sold, and number of distinct
--customers who purchased it. Consider only orders with status 'Completed'. Return products whose total 
--quantity sold is greater than 50 and which have been purchased by at least 5 distinct customers. 
--Include products with zero sales when calculating the overall average quantity sold per product.
--Sort by total quantity sold in descending order. Use the prod, item, and ord tables.
select 
		p.product_id,
		p.product_name,
		p.category,
		sum(case when o.order_status = 'Completed' then i.quantity else 0 end)as total_quantity_sold,
		count(distinct case when o.order_status = 'Completed' then o.customer_id else 0 end)as purchased_customers
		from  products p 
		left join items i on
		i.product_id = p.product_id
		left join orders o on
		o.order_id = i.order_id
		group by p.product_id, p.product_name, p.category
		having sum(case when o.order_status = 'Completed' then i.quantity else 0 end ) >=50 and
		count(distinct case when o.order_status = 'Completed' then o.customer_id else 0 end ) >=5
		order by total_quantity_sold desc

--Q137. Find each category and its total number of products, total completed orders containing those 
--products, and total quantity sold. Include categories even if they have no completed orders. 
--Return only categories where the total quantity sold is greater than the average quantity sold 
--across all categories, including categories with zero sales. 
--Sort by total quantity sold in descending order. Use products, items, and orders.
select 
		e.category,
		e.total_products,
		e.completed_products,
		e.quantity_sold from(select 
		p.category,
		count(distinct p.product_id)as total_products,
		count(distinct case when o.order_status = 'Completed' then p.product_id end)as completed_products,
		coalesce(sum(case when o.order_status = 'Completed' then i.quantity else 0 end),0)as quantity_sold
		from products p
		left join items i on 
		i.product_id = p.product_id
		left join orders o on
		o.order_id = i.order_id
		group by p.category)as e
		where  e.quantity_sold > (select avg(quantity_sold)
					from (select 
								p.category,
		coalesce (sum(case when o.order_status = 'Completed' then i.quantity else 0 end),0)as quantity_sold
								from products p 
								left join items i on 
								p.product_id = i.product_id
								left join orders o on
								o.order_id = i.order_id
								group by p.category)as f)
		order by quantity_sold desc

--Q138. Find each customer's customer_id, customer_name, city, total number of orders, completed orders,
--and cancelled orders. Include customers who have never placed an order. Return only customers whose 
--completed orders are greater than the average number of completed orders across all customers, 
--including customers with zero completed orders. Also include only customers who have placed orders
--in at least 2 different years. Sort by completed orders in descending order.
select 
		e.customer_id,
		e.customer_name,
		e.city,
		e.total_orders,
		e.completed_orders,
		e.cancelled_orders,
		e.order_year 
from	(select 
		c.customer_id,
		c.customer_name,
		c.city,
		count(o.order_id) total_orders,
		count(case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
		count(case when o.order_status = 'Cancelled' then  o.order_id end)as cancelled_orders,
		count(distinct extract(year from o.order_date))as order_year
		from customers c 
		left join orders o on 
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city)as e 
		where e.completed_orders > (select avg(f.completed_orders)
				from (select c.customer_id,
				count(case when o.order_status = 'Completed' then o.order_id end)as completed_orders
				from customers c 
				left join orders o on
				o.customer_id = c.customer_id
				group by c.customer_id)as f)
				and e.order_year >= 2
				order by completed_orders desc
				

--Q139. Find each product's product_id, product_name, category, total quantity sold, total revenue,
--and number of distinct customers who purchased it. Include products with zero sales, consider only 
--orders with status 'Completed', and return only products whose total revenue is greater than the average
--revenue across all products, including products with zero revenue. Sort the results by total revenue 
--in descending order. Use the products, items, and orders tables.
select 
		e.product_id,
		e.product_name,
		e.category,
		e.quantity_sold,
		e.total_revenue,
		e.distinct_customers
from	(select 
		p.product_id,
		p.product_name,
		p.category,
		coalesce(sum(case when order_status = 'Completed' then i.quantity else 0 end),0)as quantity_sold,
		coalesce(sum(case when order_status = 'Completed' then i.quantity * i.unit_price else 0 end),0)as total_revenue,
		count(distinct case when o.order_status =  'Completed' then o.customer_id end)as distinct_customers
		from products p 
		left join items i on 
		i.product_id = p.product_id
		left join orders o on
		o.order_id = i.order_id
		group by p.product_id,
					p.product_name,
					p.category)as e 
		where e.total_revenue > (select avg(f.total_revenue)
		from (select p.product_id,
				coalesce(sum(case when order_status = 'Completed' then i.quantity * i. unit_price else 0  end),0)as total_revenue
				from products p
				left join items i on
				p.product_id = i.product_id
				left join orders o on
				o.order_id = i.order_id
				group by p.product_id)as f )
				order by total_revenue desc

--Find each employee's name, department, total number of completed orders handled, and total revenue
--generated from those orders. Include only employees who have handled at least 5 completed orders and
--generated revenue greater than the average revenue generated per employee across all employees. 
--Return employee_id, employee_name, department, completed_orders, and total_revenue. Sort by total_revenue
--in descending order.
select
		e.employee_name,
		e.department,
		e.completed_orders,
		e.total_revenue
from
	(select 
		e.employee_name,
		e.department,
	count(case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
	sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end)as total_revenue
	from employees e
	left join orders o on
	o.employee_id = e.employee_id
	left join items i on
	i.order_id = o.order_id
	group by e.employee_name,e.department)as e
	where e.total_revenue > (select avg(f.total_revenue)
	from(select e.employee_id,
			sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end)as total_revenue
			from employees e 
			left join orders o on
			o.employee_id = e.employee_id
			left join items i on
			i.order_id = o.order_id
			group by e.employee_id)as f)
	and e.completed_orders >=5
	order by total_revenue desc
		
--Find each employee's name and department, the total number of completed orders, and total revenue 
--generated from completed orders during each calendar year. Include only employee-year combinations where
--the employee handled at least 3 completed orders and generated revenue greater than the average revenue
--generated by employees in that same year. Return employee_id, employee_name, department, order_year, 
--completed_orders, and total_revenue. Sort by order_year ascending and total_revenue descending.
select 
		e.employee_id,
		e.employee_name,
		e.department,
		e.completed_orders,
		e.total_revenue,
		e.order_year
from	(select 	
		e.employee_id,
		e.employee_name,
		e.department,
		count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
		sum(case when o.order_status = 'Completed' then i.quantity*i.unit_price end)as total_revenue,
		extract(year from o.order_date)as order_year
		from employees e 
		left join orders o 
		on o.employee_id = e.employee_id 
		left join items i on
		o.order_id  = i.order_id
		group by	e.employee_id,
					e.employee_name,
					e.department,
					extract(year from o.order_date))as e
where e.total_revenue > (select avg(f.total_revenue)
from	
		(select e.employee_id,
		extract(year from o.order_date)as order_year,
		sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end)as total_revenue
		from employees e 
		left join orders o on
		o.employee_id =  e.employee_id
		left join items i on
		o.order_id = i.order_id
		group by e.employee_id,
		extract(year from o.order_date))as f
		where f.order_year = e.order_year) and 
		e.completed_orders >=3
		order by order_year asc, total_revenue desc;
		
--Find each customer's name, city, total number of completed orders, total revenue, and first and last 
--completed order dates. Include only customers who have placed at least 4 completed orders across their 
--entire history and whose revenue in their most recent calendar year is greater than their revenue 
--in the previous calendar year. Return customer_id, customer_name, city, completed_orders, 
--total_revenue, first_order_date, and last_order_date. Sort by total revenue in descending order.
select 
		f.customer_id,
		f.customer_name,
		f.city,
		f.completed_orders,
		f.total_revenue,
		f.first_co_orders,
		f.last_co_orders,
		f.order_year,
		f.previous_year
from	(select 
		e.customer_id,
		e.customer_name,
		e.city,
		e.completed_orders,
		e.total_revenue,
		e.first_co_orders,
		e.last_co_orders,
		e.order_year,
		row_number() over (partition by e.customer_id order by e.order_year)as rnk,
		lag(e.order_year) over (partition by e.customer_id order by e.order_year)as previous_year,
		lag(e.total_revenue) over (partition by e.customer_id order by e.order_year)as pre_year_revenue
from	(select 
		c.customer_id,
		c.customer_name,
		c.city,
	count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
	sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end)as total_revenue,
	min(case when o.order_status = 'Completed' then o.order_date end)as first_co_orders,
	max(case when o.order_status = 'Completed' then o.order_date end)as last_co_orders,
	extract(year from o.order_date)as order_year
	from customers c 
	left join orders o on
	o.customer_id = c.customer_id
	left join items i
	on i.order_id = o.order_id
	group by c.customer_id, c.customer_name, c.city, extract(year from o.order_date)) e)f
	where rnk =1 and
	f.completed_orders >=4 and
f.total_revenue > f.pre_year_revenue and
f.order_year = f.order_year+1
order by f.total_revenue desc

--Q143. Find each customer's yearly completed order count and total revenue, and identify customers whose 
--revenue increased compared with the immediately preceding year for at least two consecutive year-to-year
--comparisons. Return customer_id, customer_name, order_year, completed_orders, total_revenue,
--previous_year, previous_year_revenue, and revenue_increased. Include only qualifying customers and their
--relevant years, sorted by customer_id and order_year.
select *
from		(select
		*,
			lag(g.revenue_increased) over (partition by g.customer_id order by g.order_year) as pre_increased
	from		(select 
		*,
		case when f.total_revenue > f.previous_year_revenue and
		f.order_year = f.previous_order_year+1 then 1 else 0 end as revenue_increased
from				
	(select 
		* ,
lag(e.order_year) over (partition by e.customer_id order by e.order_year)as previous_order_year,
lag(e.total_revenue) over (partition by e.customer_id order by e.order_year)as previous_year_revenue
from
		(select 
		c.customer_id,
		c.customer_name,
count(case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end) as total_revenue,
extract(year from o.order_date)as order_year
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		left join items i on
		o.order_id = i.order_id
		group by c.customer_id, c.customer_name, extract(year from o.order_date))as e)f)g)h
		where revenue_increased = 1 and 
		pre_increased = 1 
		order by customer_id , order_year
		
--Find each employee's yearly performance by calculating the number of completed orders and total revenue 
--generated. Compare each employee's revenue with their previous year's revenue and identify employees
--whose revenue decreased for two consecutive year-to-year comparisons. Return employee_id, employee_name,
--department, order_year, completed_orders, total_revenue, previous_year_revenue, and revenue_decreased. 
--Include only qualifying employees and relevant years, sorted by employee_id and order_year.
select * from
(select * ,
lag(rev_decreased) over(partition by g.employee_id order by g.order_year)as pre_decresed
from (select *,
		case when f.total_revenue < f.pre_revenue and f.order_year = f.pre_ord_year+1
		then 1 else 0 end as rev_decreased
	
from (select *,
	lag (e.total_revenue) over (partition by e.employee_id order by e.order_year)as pre_revenue,
	lag(e.order_year) over (partition by e.employee_id order by e.order_year)as pre_ord_year
from
	(select 
		e.employee_id,
		e.employee_name,
		e.department,
		o.order_date,
count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end)as total_revenue,
extract(year from o.order_date)as order_year
from 	employees e
		left join orders o on
		o.employee_id = e.employee_id
		left join items i on
		i.order_id = o.order_id
group by e.employee_id, e.employee_name, e.department, o.order_date, extract(year from o.order_date) )e)f)
g)h
where rev_decreased = 1 and 
pre_decresed  =1

order by employee_id, order_year

---Find each customer's yearly completed order count and total revenue. Compare each customer's yearly
--revenue with the previous year's revenue and identify customers whose revenue increased by at least
--20% for two consecutive year-to-year comparisons. Return customer_id, customer_name, city, order_year, 
--completed_orders, total_revenue, previous_year_revenue, and revenue_growth_percentage. Include only 
--qualifying customers and the year in which the second consecutive increase occurs. Sort by customer_id 
--and order_year.

select * from (select *,
	sum(i.growth_flag) over (partition by i.customer_id order by i.order_year
	rows between 1 preceding and current row)as conse_growth
from	(select *,
	case when h.growth_percent >=20 and h.order_year = h.pre_order_year +1 then 1 else 0 end as 
	growth_flag
	
from
	(select 
		*,
		round(((g.total_revenue - g.pre_revenue)/nullif(g.pre_revenue,0))*100.0 , 2)as growth_percent
from (select
		*,
		case when f.total_revenue > f.pre_revenue and 
		f.order_year = f.pre_order_year +1 then 1 else 0 end as revenue_growth 
from	(select *, 
lag(e.total_revenue) over (partition by e.customer_id order by e.order_year)as pre_revenue,
lag(e.order_year) over (partition by e.customer_id order by e.order_year)as pre_order_year
from (select 
		c.customer_id,
		c.customer_name,
		c.city,
		
count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
sum(case when o.order_status ='Completed' then i.quantity * i.unit_price end)as total_revenue,
extract(year from o.order_date) :: int as order_year
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		left join items i on
		i.order_id = o.order_id
group by c.customer_id, c.customer_name, c.city,  extract(year from o.order_date))e)
f)
g)
h)
i
where conse_growth =2
ORDER BY customer_id, order_year;


--Using employees and orders, find employees whose completed order count increased in at least two 
--consecutive months compared with the previous month in the same year. Calculate each employee's monthly
--completed order count, use LAG() to compare it with the previous month, and return only employees meeting
--the condition. Display employee_id, employee_name, department, order_year, order_month, completed_orders,
--previous_month_orders, and growth_months. Sort by employee_id, order_year, and order_month.
select * from (select *,
		sum(growth_flag) over (partition by employee_id, order_year order by order_month
		rows between 1 preceding and current row)as conse_growth
from	(select *,
		case when f.completed_orders > f.pre_month_orders and 
		order_month = pre_month +1 then 1 else 0 end as growth_flag
from
	(select *,
lag(completed_orders) over (partition by e.employee_id, e.order_year order by e.order_month)as pre_month_orders,
lag(order_month) over (partition by employee_id order by order_month)as pre_month
from	(select 
		e.employee_id,
		e.employee_name,
		e.department,
count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
extract(month from o.order_date)as order_month,
extract(year from o.order_date)as order_year
		from employees e 
		left join orders o on
		o.employee_id = e.employee_id
		group by e.employee_id, e.employee_name, e.department,
		extract(month from o.order_date),
		extract(year from o.order_date))e
		)f
		)g
		)h
		where conse_growth = 2
		order by employee_id, order_year, order_month

--Using employees and orders, find employees whose monthly completed order count was greater than their 
--department's average monthly completed order count in at least three different months during the same 
--year. Calculate monthly completed orders for each employee, compare them against the department-wise 
--monthly average using a window function, and return employee_id, employee_name, department, order_year,
--order_month, completed_orders, department_avg_orders, and months_above_avg. Display only qualifying
--employees and sort by department, employee_id, order_year, and order_month.
select * from (select *,
count 	( case when completed_orders > dept_avg_orders then 1 end) over 
		(partition by employee_id, order_year )as conse_month
from  	(select *,
		avg(completed_orders) over (partition by department, order_year, order_month)as dept_avg_orders
from	(select 
		e.employee_id,
		e.employee_name,
		e.department,
extract(year from o.order_date)as order_year,
extract(month from o.order_date)as order_month,
count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders
		from employees e
		left join orders o on
		o.employee_id = e.employee_id
		group by e.employee_id, e.employee_name, e.department,
		extract(year from o.order_date),
		extract(month from o.order_date))e)f)g
		where conse_month =3
		order by department, employee_id, order_year, order_month

--Using customers, orders, and employees, find customers whose completed order count increased every year 
--for at least three consecutive years, compared with the previous year. Calculate each customer's yearly 
--completed order count, use LAG() to compare the current year with the previous year,
--identify consecutive yearly increases, and return customer_id, customer_name, city, order_year, 
--completed_orders, previous_year_orders, and growth_streak.
--Sort by customer_id and order_year.
select * from 
		(select *,
		sum(growth_streak) over (partition by customer_id order by order_year
		rows between 2 preceding and current row) as conse_year
from	(select *,
		case when completed_orders > pre_year_orders and order_year = pre_year +1 then 1 else 0 end as 
		growth_streak
from	(select *,
lag(completed_orders) over (partition by customer_id order by order_year)as pre_year_orders,
lag(order_year) over (partition by customer_id order by order_year)as pre_year
from	(select 
		c.customer_id,
		c.customer_name,
		c.city,
count(distinct case when o.order_status = 'Completed' then o.order_id end)as completed_orders,
		extract(year from o.order_date)as order_year
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		group by c.customer_id, c.customer_name, c.city,
		extract(year from o.order_date))e)f)g)h
		where conse_year = 3
		order by customer_id, order_year

--Using customers, orders, items, and products, identify customers whose completed-order revenue increased 
--by at least 25% for two consecutive year-to-year comparisons. Calculate each customer's yearly revenue 
--using order quantities and product prices, use LAG() to calculate previous-year revenue, calculate 
--revenue growth percentage, and identify customers who achieved the required growth for two consecutive
--comparisons. Return customer_id, customer_name, city, order_year, total_revenue, previous_year_revenue,
--growth_percentage, and growth_streak. Sort by customer_id and order_year.
select * from (
select *,
		sum(streak) over (partition by customer_id order by order_year
		rows between 1 preceding and current row)as conse_growth
from	(select 	*,
		case when growth_percent >=25 and order_year = prev_year +1 then 1 else 0 end as streak	
from	(select *,
		round((total_revenue - prev_year_revenue )/nullif(prev_year_revenue,0)*100.0,2)as growth_percent
from	(select *,
lag(total_revenue) over (partition by customer_id order by order_year)as prev_year_revenue,
lag(order_year) over (partition by customer_id order by order_year) prev_year
from	(select 
		c.customer_id,
		c.customer_name,
		c.city,
		extract(year from o.order_date)as order_year,
sum(case when o.order_status = 'Completed' then i.quantity * i.unit_price end)as total_revenue		
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id
		left join items i on
		o.order_id = i.order_id
		group by c.customer_id, c.customer_name, c.city, 
		extract(year from o.order_date))e)f)g)h)i
		where conse_growth = 2
		order by customer_id, order_year

--Using customers and orders, identify customers who placed orders in at least three different years but 
--skipped at least one calendar year between their first and last order years. Return customer_id, 
--customer_name, city, first_order_year, last_order_year, active_years, and missing_years. 
--Sort by customer_id.
select *  from (select *,
(last_order_year - first_order_year+1 ) - active_years  as missing_years
from	(select 
		c.customer_id,
		c.customer_name,
		c.city,
				count(distinct extract(year from o.order_date))as active_years,
		min(case when o.order_id is not null then extract(year from o.order_date)end )as first_order_year,
		max(case when o.order_id is not null then extract(year from o.order_date) end)as last_order_year
		from customers c 
		left join orders o on
		o.customer_id = c.customer_id 
		group by  
		c.customer_id,
		c.customer_name,
		c.city
		)e)f
		where active_years >=3 and missing_years >=1
		order by customer_id
























































































































































































































































































































































































































































































































































































































































































			