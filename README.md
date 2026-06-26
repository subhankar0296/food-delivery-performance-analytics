# 🍕 Food Delivery Performance Analytics Dashboard

## 📌 Project Overview

This project demonstrates an end-to-end Business Intelligence solution built using **SQL Server** and **Power BI** to analyze food delivery operations, customer ordering patterns, delivery performance, and key business metrics.

Starting with raw Pizza Runner transactional data, the project performs data cleaning and transformation using SQL before building an interactive Power BI dashboard. The dashboard provides actionable insights into sales performance, delivery efficiency, customer behavior, and store-level operations to support data-driven business decisions.

---

## 🎯 Business Objective

The objective of this project is to help business stakeholders:

- Monitor overall delivery performance
- Analyze customer ordering patterns
- Identify peak demand periods
- Evaluate store-level performance
- Track delivery success and cancellations
- Improve operational efficiency through data-driven insights

---

## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| SQL Server (T-SQL) | Data Cleaning & Transformation |
| Power BI Desktop | Data Visualization & Dashboard |
| DAX | KPI & Business Metric Calculations |
| Data Modeling | Star Schema Design |

---

## 📂 Project Workflow

### 1. Database Setup

- Created the Pizza Runner database and relational tables.
- Loaded raw transactional data into SQL Server.
- Organized customer, runner, pizza, and order information for analysis.

### 2. Data Cleaning & Transformation (SQL)

The raw dataset contained missing values, inconsistent formats, and text-based numeric fields. The following transformations were performed:

- Replaced blank values and text-based `"null"` values with SQL `NULL`.
- Converted distance and duration fields into numeric data types.
- Standardized cancellation records.
- Cleaned pickup timestamps.
- Created analytical SQL views:
  - `vw_customer_orders_clean`
  - `vw_runner_orders_clean`
- Prepared clean datasets for reporting and analysis.

### 3. Data Modeling (Power BI)

- Imported cleaned SQL views into Power BI.
- Designed a Star Schema data model for efficient reporting.
- Created relationships between fact and dimension tables.
- Built a dynamic Calendar table using DAX.
- Developed calculated columns and measures for KPI reporting.
- Optimized the data model for better performance and filtering.

---

## 📊 Dashboard KPIs

The dashboard provides the following key performance indicators:

- Total Revenue
- Total Orders
- Successful Deliveries
- Delivery Success Rate
- Average Delivery Time
- Average Delivery Distance
- Average Customer Rating
- Store-wise Revenue
- Store-wise Delivery Performance

---

## 📈 Key Business Insights

### 🕒 Peak Demand

- Customer demand is highest at **1:00 PM**, indicating a strong lunch rush.
- Additional demand peaks occur at **6:00 PM** and **12:00 AM**.

### 🍕 Product Performance

- **Meatlovers** is the best-selling pizza, contributing **71.43%** of total orders (10 out of 14 pizzas).

### 🏪 Store Performance

**Store 1**
- Generated the highest revenue (**$70**).
- Achieved the fastest average delivery time (**22.25 minutes**).
- Maintained the highest customer rating (**4.5 / 5**).

**Store 2**
- Recorded the longest average delivery distance (**23.93 km**).
- Had the slowest average delivery time (**26.67 minutes**).
- Received the lowest customer rating (**3.0 / 5**).

### 🚚 Delivery Performance

- Overall delivery success rate is **80%**.
- One order was cancelled at **Store 2** and one at **Store 3**.

### 💡 Business Recommendation

Longer delivery times have a direct impact on customer satisfaction. Optimizing delivery routes and dispatch efficiency, particularly for **Store 2**, can improve delivery performance and customer ratings.

---

## 📊 Dashboard Features

- Executive KPI Dashboard
- Interactive Slicers and Filters
- Store Performance Analysis
- Revenue Analysis
- Delivery Performance Tracking
- Customer Rating Analysis
- Hourly Order Trend Analysis
- Conditional Formatting
- Interactive Navigation Buttons

---

## 📷 Dashboard Preview

<img width="856" height="487" alt="image" src="https://github.com/user-attachments/assets/5323fdb2-1ad1-40c4-afad-9d391129e278" />


---

## 📁 Repository Structure

```text
Food-Delivery-Performance-Analytics/
│
├── SQL/
│   └── food-delivery-performance-analytics.sql
│
├── Power BI/
│   └── Food Delivery Performance Analytics Dashboard.pbix
│
├── Images/
│   └── Dashboard.png
│
└── README.md
```

---

## 💡 Skills Demonstrated

- SQL Data Cleaning
- Data Transformation
- ETL
- SQL Views
- SQL Server
- Star Schema Data Modeling
- DAX Calculations
- KPI Development
- Business Intelligence
- Power BI Dashboard Design
- Data Visualization
- Business Analysis
- Performance Reporting

---

## 👨‍💻 Author

**Subhankar Mondal**

**Skills:** SQL • Power BI • DAX • Data Analytics • Business Intelligence
