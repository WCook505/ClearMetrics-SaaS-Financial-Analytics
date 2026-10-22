CREATE DATABASE clearmetrics_star;
USE clearmetrics_star;

-- table creation for star schema

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(80),
    industry VARCHAR(60),
    region VARCHAR(30)
);

CREATE TABLE dim_plan (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(40),
    monthly_price_usd DECIMAL(10,2)
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year_number INT,
    month_number INT,
    month_name VARCHAR(15),
    quarter_number INT
);

CREATE TABLE fact_invoices (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    plan_id INT,
    invoice_date_key INT,
    subscription_id INT,
    billing_cycle VARCHAR(10),
    invoice_amount_usd DECIMAL(12,2),
    invoice_status VARCHAR(10),

    FOREIGN KEY (customer_id)
        REFERENCES dim_customer(customer_id),
    FOREIGN KEY (plan_id)
        REFERENCES dim_plan(plan_id),
    FOREIGN KEY (invoice_date_key)
        REFERENCES dim_date(date_key)
);


-- Loading customers and plans

INSERT INTO clearmetrics_star.dim_customer
SELECT customer_id, customer_name, industry, region
FROM clearmetrics_finance.customers;

INSERT INTO clearmetrics_star.dim_plan
SELECT plan_id, plan_name, monthly_price_usd
FROM clearmetrics_finance.plans;

-- Populating date dimension

INSERT INTO clearmetrics_star.dim_date
SELECT DISTINCT
    CAST(DATE_FORMAT(invoice_date, '%Y%m%d') AS UNSIGNED),
    invoice_date,
    YEAR(invoice_date),
    MONTH(invoice_date),
    MONTHNAME(invoice_date),
    QUARTER(invoice_date)
FROM clearmetrics_finance.invoices;

-- Populating fact table

INSERT INTO clearmetrics_star.fact_invoices


-- Finding which subscription plan generated the most revenue

SELECT
    i.invoice_id,
    s.customer_id,
    s.plan_id,
    CAST(DATE_FORMAT(i.invoice_date, '%Y%m%d') AS UNSIGNED),
    i.subscription_id,
    s.billing_cycle,
    i.amount_usd,
    i.invoice_status
FROM clearmetrics_finance.invoices i
JOIN clearmetrics_finance.subscriptions s
    ON i.subscription_id = s.subscription_id;
    
    SELECT
    p.plan_name,
    SUM(f.invoice_amount_usd) AS total_revenue
FROM clearmetrics_star.fact_invoices f
JOIN clearmetrics_star.dim_plan p
    ON f.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY total_revenue DESC;

-- Finding how monthly invoice revenue changed over time

WITH monthly_revenue AS (
    SELECT
        d.year_number,
        d.month_number,
        SUM(f.invoice_amount_usd) AS total_revenue
    FROM fact_invoices f
    JOIN dim_date d
        ON f.invoice_date_key = d.date_key
    GROUP BY d.year_number, d.month_number
),
revenue_comparison AS (
    SELECT
        year_number,
        month_number,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY year_number, month_number
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    year_number,
    month_number,
    total_revenue,
    previous_month_revenue,
    ROUND(
        (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS revenue_growth_percent
FROM revenue_comparison
ORDER BY year_number, month_number;

