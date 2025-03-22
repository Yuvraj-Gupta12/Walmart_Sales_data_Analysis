--creating table 
create table walmart( 			
Invoice_ID varchar(15),
Branch char(5),
City text,
Customer_type text, 
Gender text,
Product_line text,
Unit_price decimal(5,2),
Quantity int,
"Tax_5%" numeric,
Total numeric,
Date varchar(15),
Time TIME,
Payment text,
cogs numeric,
gross_margin_percentage numeric,
gross_income numeric,
Rating numeric
);
--Data importing
copy Walmart
from 'D:\Data\WalmartSalesData.csv.csv'
delimiter ','
csv header;

--Chanage data type  of date column from varchar to date
alter table walmart alter column date type date using date::date;

------------------------feature engineering-------------------------------------
--1. Time_of_the_day
select time,
(case when time between '00:00:00' and '12:00:00' then 'Morning'
      when time between '12:01:00' and '16:00:00' then 'Afternoon'
	  else 'Evening'
end
) from walmart;

ALTER TABLE Walmart ADD COLUMN time_of_day VARCHAR(20);

UPDATE walmart
SET time_of_day = (case when time between '00:00:00' and '12:00:00' then 'Morning'
      when time between '12:01:00' and '16:00:00' then 'Afternoon'
	  else 'Evening'
end
);
--2. Day_name
alter table walmart add column day_name varchar(20);
																--Extracting day from date
update walmart set day_name= to_char(date,'day');

--3.Month_name
alter table walmart add column month_name varchar(20);
																--Extracting month from date
update walmart set month_name=to_char(date,'month');

-------------------Exploratory Data Analysis(EDA)-------------------------

------------------------------Sales Analysis
--1.Total revenue by month
select month_name,round(sum(total),2) as total_sales from walmart group by 1 order by 2 desc;

--2. Which Regions/City have the highest Revenue
select city,round(sum(total),2) as revenue from walmart group by 1  order by 2 desc limit 1;

--3. which day of week has highest sales during the period
select day_name,sum(total) from walmart group by 1 order by 2 desc;

--4. Total Gross income during the period
select round(sum(gross_income),2) as total_income from walmart;

--5. Which region sold highest unit
select city,branch,sum(quantity) as total_quantity from walmart group by 1,2 order by 3 desc limit 1;


---------------------------------------------Product Analysis
--1.What are the diffrent products in the store
select distinct(product_line) from walmart;

--2. Products Generating Highest Revenue
select product_line,sum(total) as total_revenue from walmart group by 1 order by 2 desc limit 1;

--3. What are The Average Revenue Per Product
select product_line,round(avg(total),2) as avg_revenue from walmart group by 1 order by 2 desc;

--4.Which Product type has highest and lowest sales during the period
select * from
(select product_line,sum(total),'Highest' as Sales_Category from walmart group by 1 order by 2 desc limit 1)
UNION
select * from 
(select product_line,sum(total),'Lowest' as Sales_Category from walmart group by 1 order by 2 limit 1);

--5. What is the average rating per product
select product_line,round(avg(rating),2) as avg_rating from walmart group by 1 order by sum(total) desc; --highest selling product at top

--6. What is the average unit price per product
select product_line,round(avg(unit_price),2) as avg_price from walmart group by 1 order by sum(total) desc;

----------------------------------------------------Customer Analysis
--1. What Type of Customers are generating Highest Revenue
select customer_type,round(sum(total),2) as revenue from walmart group by 1 order by 2 desc limit 1;

--2.What is The Average Sales Per Customer Type
select customer_type,round(avg(total),2) as revenue from walmart group by 1 order by 2 desc;
							
--3. Which modes of payment customers mostly used
select payment,count(payment) from walmart group by 1 order by 2 desc limit 1;

--4. What is the gender distribution per branch
select gender,branch,count(gender) as total_count
from walmart group by 1,2 order by 3 desc;


