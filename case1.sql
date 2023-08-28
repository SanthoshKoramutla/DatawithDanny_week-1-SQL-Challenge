use dannys_diner;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  #Case Study Questions:
/*
  1. What is the total amount each customer spent at the restaurant?
  2. How many days has each customer visited the restaurant?
  3. What was the first item from the menu purchased by each customer?
  4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  5. Which item was the most popular for each customer?
  6. Which item was purchased first by the customer after they became a member?
  7. Which item was purchased just before the customer became a member?
  8. What is the total items and amount spent for each member before they became a member?
  9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have?
 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,not just sushi - how many points do customer A and B have at the end of January?
*/



#1 What is the total amount each customer spent at the restaurant?

  select customer_id,sum(m.price) from menu m join 
  sales s on s.product_id=m.product_id
  group by customer_id
  order by customer_id;
  
#2 How many days has each customer visited the restaurant?
  select customer_id,count(distinct order_date) as days
  from sales
  group by customer_id
  order by customer_id;
  
#3 What was the first item from the menu purchased by each customer?

select customer_id, product_name from(
select customer_id, product_name,s.product_id , row_number() over(partition by customer_id order by 
order_date asc) as rnk
from sales s join menu m on s.product_id=m.product_id) as A where rnk=1;

#4W hat is the most purchased item on the menu and how many times was it purchased by all customers?
  

  select product_name, count(s.product_id) as cnt  from menu m join sales s 
  on s.product_id=m.product_id
 group by s.product_id
 order by cnt desc limit 1
  ;
  
#5 Which item was the most popular for each customer?

with cte as (select customer_id,product_id,dense_rank() over (partition by customer_id order by 
count(product_id) desc) as rnk
from 
sales 
group by customer_id,product_id)

select customer_id,product_name from cte c
join menu m
on c.product_id=m.product_id
where rnk=1
order by customer_id;

#6 Which item was purchased first by the customer after they became a member?

select s.customer_id,product_name,min(order_date)
from
sales s 
join
menu m
on s.product_id=m.product_id
join
members me
on s.customer_id=me.customer_id
where s.order_date>=me.join_date
group by s.customer_id
order by order_date
;


#7 Which item was purchased just before the customer became a member?
select s.customer_id,product_name,max(order_date)
from
sales s 
join
menu m
on s.product_id=m.product_id
join
members me
on s.customer_id=me.customer_id
where s.order_date<me.join_date
group by s.customer_id
order by order_date;

#8 What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(s.product_id) as total_items,
sum(price) as amt_spent from
sales s 
join menu m
on s.product_id=m.product_id
join members me on s.customer_id=me.customer_id
where s.order_date<me.join_date
group by customer_id;

#9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have? 


select s.customer_id,
sum(case m.product_id
when "1" then price*10*2
else price*10
end )as "points"
from menu m join sales s
on s.product_id=m.product_id
group by s.customer_id;

#10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select s.customer_id,
sum(case 
when m.product_id="1" and order_date>=join_date   then price*10*2*2
when order_date>=join_date then price*10*2
when m.product_id="1" then price*10*2
else price*10
end )as "points"
from menu m join sales s
on s.product_id=m.product_id
join members me on me.customer_id=s.customer_id
group by s.customer_id;
select * from members;




# making table
select s.customer_id, order_date, product_name,price,
case when
s.customer_id=me.customer_id and order_date>=join_date then "Y"
else "N"
end as 'member'
from
sales s join menu m on s.product_id=m.product_id
left join members me on s.customer_id=me.customer_id
order by s.customer_id;

# ranking
with cte as(
select s.customer_id, order_date, product_name,price,
case when
s.customer_id=me.customer_id and order_date>=join_date then "Y"
else "N"
end as 'member'
from
sales s join menu m on s.product_id=m.product_id
left join members me on s.customer_id=me.customer_id
order by s.customer_id)
select *, case when
member='Y' then
rank() over(partition by customer_id,member order by order_date)
else
' null'
end as 'ranking'
from cte

;

