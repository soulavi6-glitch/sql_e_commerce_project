# sql_e_commerce_project
SQL analysis of e-commerce data using PostgreSQL to study sales, customers, items, and product performance
# E-commerce Data Analysis (SQL)

SQL analysis of e-commerce data using PostgreSQL to study employee performance, customer loyalty and revenue growth.

## Tools Used
- PostgreSQL
- pgAdmin

## Database Tables
customers, productss, employees, orders, items, payments, returns

## Business Questions Answered

### 1. Which employees handle more orders than average?
Counts the orders each employee handled and keeps only those above the average of all employees.

### 2. Who are the most engaged customers?
Finds customers with 6 or more orders, completed orders handled by at least 2 different employees, and total orders above the customer average.

### 3. Which customers are consistently reliable?
Finds customers with above-average completed orders who ordered in 2 or more different years. Completed and cancelled orders are shown separately.

### 4. Which customers grew their revenue year over year?
Calculates each customer's completed-order revenue per year (quantity x unit price) and compares it with their previous year using LAG().

### 5. Which customers had 2 consecutive years of 20%+ revenue growth?
Calculates the growth percentage between years, flags years with 20% or more growth, and keeps customers who had this growth in 2 years in a row.

## SQL Concepts Used
| Concept | Where it is used |
|---|---|
| LEFT JOIN (multiple tables) | Joining customers, orders, items and employees |
| GROUP BY and HAVING | Filtering grouped results |
| Subqueries and nested subqueries | Comparing against averages and building step-by-step logic |
| Conditional aggregation (CASE WHEN) | Counting only completed or cancelled orders |
| COUNT DISTINCT | Counting unique orders and employees |
| Window functions: LAG, ROW_NUMBER | Comparing a customer's year with the previous year |
| SUM() OVER with window frame | Checking growth across consecutive years |
| EXTRACT, ROUND, NULLIF, type casting | Working with dates and safe percentage maths |

## Key Insights
- [Add a real finding, e.g. number of employees above average]
- [Add a real finding, e.g. number of customers with 2 years of 20%+ growth]
- [Add a real finding, e.g. top city by customer revenue]

## Files
- `e_commerce_data_analysis.sql`: all queries used in this project
