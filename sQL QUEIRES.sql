create database walmart_db
use walmart_db
select * from walmart
select count(*) from walmart
select payment_method ,count(*) from walmart
group by payment_method

select count(distinct branch)
from walmart
select min(quantity) from walmart

-- Buisness problems 
/*. Analyze Payment Methods and Sales
● Question 1: What are the different payment methods, and how many transactions and
items were sold with each method?
● Purpose: This helps understand customer preferences for payment methods, aiding in
payment optimization strategies.
*/
-- answer 1
select payment_method ,count(*)  as No_of_payments ,
sum(quantity) as Quantity_sold from walmart
group by payment_method

/*2. Identify the Highest-Rated Category in Each Branch
● Question: Which category received the highest average rating in each branch?
● Purpose: This allows Walmart to recognize and promote popular categories in specific
branches, enhancing customer satisfaction and branch-specific marketing.
*/
SELECT *
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart
    GROUP BY branch, category
) AS ranked_data
WHERE rnk = 1;

/*
3. Determine the Busiest Day for Each Branch
● Question: What is the busiest day of the week for each branch based on transaction
volume?
● Purpose: This insight helps in optimizing staffing and inventory management to
accommodate peak days.
*/
select * from (
SELECT 
  branch,
  DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
  COUNT(*) AS no_transactions,
  Rank() over(partition by branch order by count(*) desc) as highest_rank
FROM walmart
GROUP BY branch, DAYNAME(STR_TO_DATE(date, '%d/%m/%Y'))) as ranked
where highest_rank  = 1

/*
4. Calculate Total Quantity Sold by Payment Method
● Question: How many items were sold through each payment method?
● Purpose: This helps Walmart track sales volume by payment type, providing insights
into customer purchasing habits
*/


select payment_method ,
sum(quantity) as Quantity_sold from walmart
group by payment_method

/* 5. Analyze Category Ratings by City
● Question: What are the average, minimum, and maximum ratings for each category in
each city?
● Purpose: This data can guide city-level promotions, allowing Walmart to address
regional preferences and improve customer experiences.
*/


select Category , 
round(avg(rating) ,2)as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart 
group by category

/*
6. Calculate Total Profit by Category
● Question: What is the total profit for each category, ranked from highest to lowest?
● Purpose: Identifying high-profit categories helps focus efforts on expanding these
products or managing pricing strategies effectively.
*/

select category,
round(sum(total),0) as  total_revenue ,
round(sum(total* profit_margin),0) as profit from walmart
group by category
order by profit desc

/*
7. Determine the Most Common Payment Method per Branch
● Question: What is the most frequently used payment method in each branch?
● Purpose: This information aids in understanding branch-specific payment preferences,
potentially allowing branches to streamline their payment processing systems.
 */

with cte as(
select branch,
payment_method , count(*) as total_transactions,
Rank() over (partition by branch order by count(*) desc) as rnk

from walmart 

group by branch,payment_method) 
select * from cte where rnk  = 1

/* 8. Analyze Sales Shifts Throughout the Day
● Question: How many transactions occur in each shift (Morning, Afternoon, Evening)
across branches?
● Purpose: This insight helps in managing staff shifts and stock replenishment schedules,
especially during high-sales periods.
*/
 select * from walmart
select branch,
     Case when HOUR( time) <12 THEN 'MORNING'
     WHEN  Hour(time)  between 12 and 17 then 'afternoon'
     else 'evening'
     end day_time,count(*) as total_sales
     
       from walmart
group by branch,day_time
order by branch,total_sales desc

/*9. Identify Branches with Highest Revenue Decline Year-Over-Year
● Question: Which branches experienced the largest decrease in revenue compared to
the previous year?
● Purpose: Detecting branches with declining revenue is crucial for understanding
possible local issues and creating strategies to boost sales or mitigate losses.
*/
--  ratio  =  last_year rev -  current year/last year *100
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 as (
 SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch)
    select r22.branch,
    r22.revenue as last_year_revenue
, r23.revenue as current_year_revenue,
 ROUND(((r22.revenue - r23.revenue) / r22.revenue) * 100, 2) AS Decrease_ratio
from revenue_2022 as r22
join revenue_2023 as r23
on r22.branch =  r23.branch
where r22.revenue > r23.revenue
order by Decrease_ratio desc
limit 5;
