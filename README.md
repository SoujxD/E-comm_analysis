# Introduction
 #  🚀Data Analysis Project: Uncovering Business Insights 📊
Welcome to the SQL Data Analysis Project! This project dives deep into transactional data to extract valuable insights that drive business decisions. Using SQL, I analyzed customer behaviors, payment trends, product reviews, and seller performance to uncover patterns and trends. Our goal is to transform raw data into actionable insights, providing a comprehensive view of the business landscape.

## 🎯 Key Focus Areas:
- 🌍 Customer Demographics & Geographical Insights: Explore where your customers are and how their locations impact purchasing behavior.
- ⭐ Product Reviews & Ratings Analysis: Understand customer satisfaction by analyzing review scores across different product categories.
- 💳 Payment Preferences: Discover the most popular payment methods and how they vary by region.
- 📈 Sales Correlation Analysis: Identify trends between the number of items purchased and the total payment value.
- 🏆 Top Sellers & Category Performance: Highlight the top-performing sellers and explore which product categories contribute the most to sales.

This project leverages the power of SQL to query and visualize data, turning complex datasets into clear and actionable business intelligence. Let's dive in and discover the insights hidden within your data! 🚀📊

SQL queries? Check them out here : [project-sql Folder](/projectsql/)


# Background

## 📚 Background
For this project, I utilized a comprehensive dataset sourced from Kaggle. The dataset contains detailed information on customer orders, payments, product reviews, and seller performance, providing a rich foundation for conducting various data analyses.

📁 Dataset Overview:
The dataset includes multiple interconnected tables with information such as:

- Customer Details: Including location data and unique identifiers.
- Order Information: Covering order items, payment methods, and values.
- Product Reviews: Detailing customer feedback and review scores.
- Sellers & Geolocation: Providing insights into seller locations and their performance metrics.
# Tools i used

Tools I Used:

To effectively analyze data and manage the project, I utilized the following tools:

- SQL: Employed for querying and managing relational databases, facilitating complex data retrieval and manipulation tasks.
- PostgreSQL: Used as the database management system for storing, organizing, and querying data, leveraging its advanced features for robust data handling.
- Visual Studio Code (VSCode): Utilized as the primary code editor for writing and editing scripts, enhancing productivity with its versatile features and extensions.
- Git: Applied for version control to track changes, collaborate with others, and manage the project's source code history.
- GitHub: Leveraged for hosting the project's repository, enabling collaboration, and sharing code and documentation with stakeholders. These tools were integral to the project’s execution, ensuring efficient data management, code development, and version control.

# The Analysis
## 📝 Questions Solved
### Q1: How Much Total Revenue is Generated from Each City?

*Objective*:
To calculate the total revenue generated from each city, including details such as the customer city, state, and total revenue.

SQL Solution:

The solution involves two main steps:

- Calculate Revenue Per Order: A Common Table Expression (CTE) named revenue_per_order was created to calculate the total revenue for each order by summing the price and freight_value from the order_items table.
- Aggregate Revenue by City and State: The main query joins the revenue_per_order CTE with the orders and customers tables to aggregate the total revenue by customer city and state.

```sql
WITH revenue_per_order AS (
    SELECT order_id, SUM(price + freight_value) AS total_revenue
    FROM order_items
    GROUP BY order_id
)

SELECT 
    c.customer_city, 
    c.customer_state, 
    SUM(r.total_revenue) AS total_revenue
FROM 
    revenue_per_order r
JOIN 
    orders o ON o.order_id = r.order_id
JOIN 
    customers c ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_city, c.customer_state
ORDER BY 
    total_revenue DESC;
```

Explanation:

- The query first calculates the revenue for each order.
- It then joins this data with the orders and customers tables to map revenue data to specific cities and states.
- Finally, it groups the results by customer city and state and orders them in descending order of total revenue.
### Q2: What is the distribution of sellers across different states?
SQL Solution:

A CTE (sellers_count) calculates the number of sellers in each state by grouping the sellers table by seller_state.
The main query calculates the percentage of sellers in each state relative to the total number of sellers.

- SQL Query:
```sql
WITH sellers_count AS (
    SELECT seller_state, COUNT(seller_id) AS num_sellers
    FROM sellers
    GROUP BY seller_state
)

SELECT 
    seller_state, 
    num_sellers,
    ROUND((num_sellers::numeric / SUM(num_sellers) OVER()) * 100, 2) AS seller_percentage
FROM 
    sellers_count
ORDER BY 
    num_sellers DESC;
```
Result Format:

Seller | State	| Number of Sellers	|Seller Percentage (%)|
-------|--------|-------------------|---------------------|
State  | A	    | 150	            |25.00                |
State  | B	    | 100	            |16.67                |
...	...	...

### Q3: What are the most popular payment methods, and how do they correlate with the total revenue generated?

SQL Solution:

- A CTE (popular_payment) counts the popularity of each payment type per order from the order_payments table.
- The main query joins this with the order_items table to sum the revenue associated with each payment type.

SQL Query:
```sql 
WITH popular_payment AS (
    SELECT order_id, COUNT(payment_type) AS popularity, payment_type
    FROM order_payments
    GROUP BY order_id, payment_type
    ORDER BY popularity DESC
)

SELECT 
    pp.popularity, 
    pp.payment_type, 
    SUM(oi.price) AS revenue
FROM 
    popular_payment pp
JOIN 
    order_items oi ON oi.order_id = pp.order_id
GROUP BY 
    pp.popularity, pp.payment_type
ORDER BY 
    revenue DESC;
```

### Q4: How many orders has each customer placed, and what is the average order value for each customer?

SQL Solution:

- A CTE (customer_order_summary) calculates the order count and average order value for each customer by joining orders with order totals from order_items.
- The main query joins this summary with customers to get detailed customer information.


SQL Query:
```sql
WITH customer_order_summary AS (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS order_count, 
        AVG(order_totals.total_revenue) AS average_order_value  
    FROM 
        orders o
    JOIN (
        SELECT 
            order_id,
            SUM(price) AS total_revenue
        FROM 
            order_items
        GROUP BY 
            order_id 
    ) AS order_totals 
    ON 
        o.order_id = order_totals.order_id
    GROUP BY 
        o.customer_id 
)

SELECT 
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    cos.order_count,
    cos.average_order_value
FROM 
    customer_order_summary cos
JOIN 
    customers c ON c.customer_id = cos.customer_id  
ORDER BY 
    cos.order_count DESC;
```

### Q5: What is the average time taken to respond to reviews, and how does it vary by customer location?

SQL Solution:

- A CTE (review_response_time) calculates the response time for each review by finding the difference between the review_creation_date and review_answer_timestamp.
- The main query joins this with orders and customers to calculate the average response time by customer city and state.

SQL Query:
```sql
WITH review_response_time AS (
    SELECT 
        r.review_id,
        r.order_id,
        EXTRACT(EPOCH FROM (CAST(r.review_answer_timestamp AS TIMESTAMP) - 
               CAST(r.review_creation_date AS TIMESTAMP))) / 3600 AS response_hours
    FROM 
        order_reviews r 
    WHERE 
        r.review_answer_timestamp IS NOT NULL
)

SELECT 
    c.customer_city,
    c.customer_state,
    AVG(rrt.response_hours) AS avg_response_hours
FROM 
    review_response_time rrt 
JOIN 
    orders o ON o.order_id =  rrt.order_id
JOIN 
    customers c ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_city, c.customer_state
ORDER BY 
    avg_response_hours;
```

# What i learned

### 🚀 What I Learned
From the SQL analysis conducted on the dataset, I gained the following insights:

Working with CTEs (Common Table Expressions):

- Learned how to use CTEs effectively to simplify complex queries by breaking them down into manageable parts. This technique was particularly useful in queries involving multiple aggregations and joins, making the SQL more readable and easier to debug.
Aggregations and Grouping:

- Explored various aggregation functions like SUM(), COUNT(), AVG(), and ROUND() to calculate metrics such as total revenue, number of sellers, and average order values.
Understood the importance of grouping data (GROUP BY) to analyze trends and distributions, such as the geographical spread of sellers and payment method popularity.
Data Joining Techniques:

- Improved my skills in joining tables (JOIN) to combine data from multiple sources, which is essential for comprehensive analyses. For example, merging customer details with order and review data provided deeper insights into customer behavior and review response times.
Calculating Percentages and Correlations:

- Developed proficiency in calculating percentages using window functions (OVER()) to determine distributions, like the proportion of sellers across different states.
Analyzed correlations between variables, such as payment methods and revenue generation, which are key for understanding business performance metrics.
Time-based Calculations:

- Gained experience in handling date and time data types, extracting time differences, and converting them into meaningful metrics, like average response times for reviews. This helped in measuring operational efficiencies and identifying areas for improvement.
Insightful Data Representation:

- Understood how to format query results to present insights effectively. For instance, structuring results with clear headers and ordered data made it easier to interpret trends in revenue, customer orders, and seller distribution.
Data-Driven Decision Making:

- Reinforced the importance of data analysis in driving business decisions. By examining metrics like revenue per city and response times, I could identify key areas for operational and strategic improvements.
This project not only enhanced my technical skills in SQL but also highlighted the value of data in making informed business decisions.
# Conclusion

### 🚀 Gained Insights
This SQL analysis project offered key insights into:

- CTEs (Common Table Expressions): Simplified complex queries for better readability and debugging.
- Aggregations and Grouping: Used functions like SUM(), COUNT(), and AVG() to analyze data distributions and trends.
- Data Joining: Enhanced ability to merge data from multiple sources for comprehensive analysis.
- Percentages and Correlations: Calculated percentages and analyzed correlations to understand business performance.
- Time-based Calculations: Measured operational efficiencies by handling date and time data.
- Data Representation: Formatted results for clearer interpretation of trends.
### 🚀 Closing Thoughts

Overall, this project significantly improved my SQL skills and demonstrated the power of data in decision-making. It emphasized the importance of clear data presentation and analysis for driving strategic improvements and operational efficiencies, marking a major step in my data analysis journey. 🚀📊