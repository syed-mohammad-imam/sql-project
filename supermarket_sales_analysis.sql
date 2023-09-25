

create database supermarket;

use supermarket;

create table sales 
(
InvoiceID varchar(15),
Branch varchar(1),
Customertype  varchar(10),
Gender varchar(6),
Productkey varchar(6),
Unitprice float,
Quantity integer,
Tax5 float,
Total float,
Date_transaction date,
Time_invoice time,
Payment varchar(15),
Cogs float,
Gross_margin float,
Gross_income float,
Rating float);


create table branch
 (
Branch varchar(1),
City varchar(10)
);


create table product
(
ProductKey varchar(7),
Productline varchar(25)
);


insert into branch values

("A", "Yangon"),
("B", "Mandalay"),
("C", "Naypyitaw");



insert into product values
("EA101",	"Electronic accessories"),
("FA102",	"Fashion accessories"),
("FB202",	"Food and beverages"),
("HB103",	"Health and beauty"),
("HL303",	"Home and lifestyle"),
("ST404",	"Sports and travel");



insert into sales values

("750-67-8428","A","Member","Female","HB103",74.69,7,26.14,548.97,'05.01.2019',"13:08:00","Ewallet",418.26,0.2,130.71,9.1),
("226-31-3081","C","Normal","Female","EA101",15.3,2,3.80,80.2,'08.03.2019',"10:29:00","Cash",61.3,0.2,19.11,9.6),
("631-41-3108","A","Normal","Male","HL303",46.40,6,16.21,349.06,'03.03.2019',"13:23:00","Credit card",259.16,0.2,81.11,7.4);

/* as sample 
*/


use supermarket;



# 1.Retrieve the total sales for each branch ?

select branch , round(sum(total),0) as total_sales
from sales
group by branch
order by branch;

# 2.Calculate the average rating for each product line ?

select p.productline, round(avg(s.rating),2) as avg_rating
from sales as s
join product as p on s.productkey = p.productkey
group by p.productline
order by p.productline;


# 3.Find the total gross income for each month in 2019 ?

select monthname(date_transaction) as month_of_year, sum(gross_income)
from sales
group by month_of_year;


# 4.Identify the top 5 products with the highest gross income ?

select p.productline, s.productkey, sum(s.gross_income) as gross_income
from sales s
inner join product p on s.productkey = p.productkey
group by p.productline, s.productkey
order by gross_income desc 
limit 5;



# 5.Calculate the total tax amount collected for each payment method ?

select payment, round(SUM(tax5),0) as tax_collected
from sales 
group by payment;



# 6.What is the gender distribution of customers for each branch ?


with genderDistribution as
(
select branch, gender, count(*) genderCount
from sales
group by branch, gender
order by branch)

select branch, gender, genderCount,
round((genderCount*100) / sum(genderCount) over (partition by branch), 2) as percentage
from genderDistribution
order by branch, gender;


# 7.How does the gross margin percentage vary between Member and Normal customers ?

select customertype,
    avg(gross_margin) as avg_margin,
    min(gross_margin) as min_margin,
    max(gross_margin) as max_margin
from
sales
group by
customertype;



# 8.Are there any seasonal trends in sales based on the date and time of the purchases ?

select
monthname(date_transaction) as mth,
ROUND(sum(total),0) as total_sales
from
sales
group by
MTH
order by 
MTH;


# 9.Which branch has the highest average total sales per month in 2019 ?



with t1 as (

--- monthly average sale 

select mth, round(avg(total_sales),0) as averagebymonth from(
select branch, monthname(date_transaction) as mth, sum(total) as total_sales
from sales
group by branch, mth) x
group by mth),
    
--- monthly branch wise sale

t2 as (
select branch, monthname(date_transaction) as month_name, round(sum(total),0) as total_monthly_sales
from sales
group by branch, month_name)


--- compate average and monthly sales

select *
from t2
join t1 on t2.total_monthly_sales > t1.averagebymonth
where month_name = mth
order by averagebymonth desc;



# 10.Find the total revenue generated by Male and Female customers for each product line ?

--- total revenue generated by each product line 

select s.gender, p.productline as product_name, round(sum(s.total),0) as total_revenue
from sales as s
join product as p on s.productkey = p.productkey
group by gender, product_name;


  --- total revenue and gender contribution for each product line revenue
  
with total_revenue_table as( 

# total revenue by gender and product line

select s.gender, p.productline as product_name, round(sum(s.total),0) as total_revenue
from sales as s
join product as p on s.productkey = p.productkey
group by gender, product_name)

# gender contribution for each individual product line

select gender, product_name, total_revenue,
round((total_revenue * 100) / sum(total_revenue) over (partition by product_name),2) as cont_percentage
from total_revenue_table
order by product_name;



# 11.Determine the peak hours of sales for each branch ?



select branch, hour(time_invoice) as purchase_time, count(*) as no_of_order
from sales
group by branch, purchase_time
order by purchase_time;




# 12.Calculate the month-over-month growth rate in net income for each branch ?


select branch, monthNumber, netIncome,
(netIncome - lag(netIncome) over(partition by branch order by monthNumber)) / lag(netIncome) over(partition by branch order by monthNumber) * 100 as growthRate
from
	(select branch, month(date_transaction) as monthNumber, sum((total-tax5)) as netIncome
	 from sales
	 group by branch, monthNumber
	 order by monthNumber) monthlyNetIncome;



