USE salesDataWalmart;

SELECT * FROM sales;

--------------------Feature engineering----------------------

---time_of_day

SELECT
    Time,
    CASE
        WHEN CAST(Time AS TIME) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN CAST(Time AS TIME) BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;

ALTER TABLE sales ADD time_of_day NVARCHAR(10);

UPDATE sales
SET time_of_day = (
	CASE
        WHEN CAST(Time AS TIME) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN CAST(Time AS TIME) BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
	END
);

---day_name
SELECT
	date,
	FORMAT(date, 'dddd')
FROM sales;

ALTER TABLE Sales ADD Day_name NVARCHAR(20);

UPDATE Sales
SET Day_Name = (
	FORMAT(date, 'dddd')
);

----month name
SELECT 
	date,
	DATENAME(MONTH, date)
FROM sales;

ALTER TABLE Sales ADD month_name NVARCHAR(20);

UPDATE Sales
SET month_name = (
	DATENAME(MONTH, date)
);

--------------------EDA--------------------------
------Generic Questions
--Unique cities 
SELECT
	DISTINCT city
FROM sales;

--branch per city
SELECT 
	DISTINCT branch
FROM sales;

SELECT 
	DISTINCT city,
	branch
FROM sales;

------product
--How many product lines do we have?
SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

--What is the most common paying method
SELECT
	payment,
	COUNT(payment) AS Cnt
FROM sales
GROUP BY payment
ORDER BY Cnt DESC;

--What is the most selling product line?
SELECT
	product_line,
	SUM(quantity) as Sumqty
FROM sales
GROUP BY Product_line
ORDER BY Sumqty DESC;

--What is the most ordered product line?
SELECT
	product_line,
	COUNT(Invoice_ID) as Orders
FROM sales
GROUP BY Product_line
ORDER BY Orders DESC;

--What is the total revenue by month?
SELECT 
	month_name,
	ROUND(SUM(total),0) AS Revenue
FROM sales
GROUP BY month_name
ORDER BY Revenue DESC;

--What month had the largest COGS?
SELECT
	month_name,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

--What product line had the largest revenue
SELECT
	product_line,
	SUM(Total) AS Revenue
FROM sales
GROUP BY Product_line
ORDER BY Revenue DESC;

--What city had the largest revenue?
SELECT
	City,
	SUM(Total) AS Revenue
FROM sales
GROUP BY City
ORDER BY Revenue DESC;

--What product line has the largest Tax
SELECT
	product_line,
	ROUND(AVG(Tax),2) AS Tax
FROM sales
GROUP BY Product_line
ORDER BY Tax DESC;

--What branch sold more products than average product sold?
SELECT
	branch,
	SUM(Quantity) AS Qty
FROM sales
GROUP BY Branch
HAVING SUM(Quantity) > AVG(Quantity);

--What is the most common product line by gender?
SELECT
	gender,
	product_line,
	COUNT(product_line) AS OrderCount
FROM sales
GROUP BY Gender, Product_line
ORDER BY OrderCount DESC;

 --What is the average rating of each product line,
 SELECT
	product_line,
	ROUND(AVG(Rating), 2) AS AVgRating
FROM sales
GROUP BY Product_line
ORDER BY AVgRating DESC;

--Total Gross Income per Product Line (by Customer Type)
WITH ProductLineSummary AS (
    SELECT
        Product_line,
        Customer_type,
        ROUND(SUM(gross_income), 2) AS TotalGrossIncome
    FROM sales
    GROUP BY Product_line, Customer_type
)
SELECT 
	* 
FROM ProductLineSummary
ORDER BY Product_line;


-------------Sales--------------

--NuMber of sales in each time of the day per weekday
SELECT
	time_of_day,
	COUNT(*) AS NoOfSales
FROM sales
WHERE Day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY NoOfSales DESC;

--Customer type generating the most revenue
SELECT
	customer_type,
	ROUND(SUM(total), 0) AS Revenue
FROM sales
GROUP BY Customer_type
ORDER BY Revenue DESC;

--City with the largest tax (percentage)
SELECT
    city,
    ROUND(AVG(Tax), 2) AS Tax
FROM sales
GROUP BY city
ORDER BY Tax DESC; 

--Customer type pays the most in Tax
SELECT
    Customer_type,
    ROUND(AVG(Tax), 2) AS Tax
FROM sales
GROUP BY Customer_type
ORDER BY Tax DESC;

-----------Customer----------------
--How many Customer types does the data have?
SELECT
	COUNT(DISTINCT Customer_type) AS NoCustTYpe
FROM sales

--How many unique payment methods
SELECT
	COUNT(DISTINCT Payment) AS PaymentType
FROM sales;

---Most common customer type
SELECT
	Customer_type,
	COUNT(*) AS Cnt
FROM sales
GROUP BY Customer_type
ORDER BY  Cnt DESC;

--Gender split
SELECT
	Gender,
	COUNT(*) AS Cnt
FROM sales
GROUP BY Gender;

--Gender distribution per branch
SELECT
	Branch,
	Gender,
	COUNT(*) AS Cnt
FROM sales
GROUP BY Branch, Gender
ORDER BY Branch;

--Time Customers give the most rating
SELECT
	time_of_day,
	COUNT(Rating) AS NumOfRating
FROM sales
GROUP BY time_of_day
ORDER BY NumOfRating DESC;

--Time of the day when Customers give high ratings
SELECT
	time_of_day,
	AVG(Rating) AS AvgRating
FROM sales
GROUP BY time_of_day
ORDER BY AvgRating DESC;

--Time of the day Customers give most ratings per branch
SELECT
	Branch,
	time_of_day,
	COUNT(Rating) AS Cnt
FROM sales
GROUP BY Branch, time_of_day
ORDER BY Branch;

--Time of the day Customers give high ratings per branch
SELECT
	Branch,
	time_of_day,
	ROUND(Avg(Rating), 2) AS AvgRating
FROM sales
GROUP BY Branch, time_of_day
ORDER BY Branch;

--Day of the week with the best ratings
SELECT
	Day_name,
	ROUND(Avg(Rating), 2) AS AvgRating
FROM sales
GROUP BY Day_name
ORDER BY AvgRating DESC;

--Day of the week with best ratings per branch
SELECT
	Day_name,
	ROUND(Avg(Rating), 2) AS AvgRating
FROM sales
WHERE Branch = 'A'
GROUP BY Day_name
ORDER BY AvgRating DESC;

--Calculate Gross Profit across product lines
SELECT
	product_line,
	ROUND(SUM(Total) - SUM(cogs), 2) AS GrossProfit
FROM sales
GROUP BY Product_line
ORDER BY GrossProfit DESC;

SELECT
	product_line,
	SUM(gross_income) AS gross_income
FROM sales
GROUP BY Product_line
ORDER BY gross_income DESC;
