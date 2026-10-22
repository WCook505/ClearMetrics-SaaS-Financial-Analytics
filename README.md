# ClearMetrics — SaaS Financial Analytics SQL Portfolio

**Synthetic data only.** No real companies or individuals. Dates run through September 2026. Currency USD. Generated deterministically (seed 42).

## Tables and relationships
- customers (customer_id PK): fictional business accounts
- plans (plan_id PK): subscription tiers and standard monthly-equivalent price
- subscriptions (subscription_id PK, customer_id FK, plan_id FK): one subscription per customer, monthly or annual, with optional cancellation date
- invoices (invoice_id PK, subscription_id FK): billed amounts, invoice and due dates, and payment status
- payments (payment_id PK, invoice_id FK): payment transactions (zero or one per invoice in this synthetic dataset)

## Dataset size
- Customers: 240
- Plans: 4
- Subscriptions: 240
- Invoices: 5834
- Payments: 5506

## Import into MySQL Workbench (simplest)
1. Open MySQL Workbench and connect to a MySQL 8+ server.
2. File > Open SQL Script, select `setup_and_data.sql`.
3. Click the lightning-bolt Execute button to run the **entire script**.
4. Refresh SCHEMAS; expand `clearmetrics_finance`.
5. Run `USE clearmetrics_finance; SELECT * FROM invoices LIMIT 10;`.

**Warning:** The setup script drops and recreates the database `clearmetrics_finance`. Do not run it after adding your own work to that database without backing up.

## Metric definitions and caveats
- The `monthly_price_usd` field is the standard monthly equivalent for each plan. Annual invoices bill 12 times that amount.
- **MRR** at a month-end snapshot is the sum of monthly-equivalent plan prices for subscriptions active at that date. **ARR** = 12 × MRR. This is modeled run-rate, not recognized GAAP revenue.
- Active at a date: `start_date <= snapshot_date AND (cancel_date IS NULL OR cancel_date > snapshot_date)`. The `status` column describes status as of 2026-09-30, not historical status.
- Invoices and payments represent billing and cash collection, not necessarily earned revenue.
- Canceled subscriptions do not have invoices on or after the cancellation date.
- Payments may occur after invoice date. A `partial` invoice has a single partial payment.
- The dataset is intentionally clean; use joins, CTEs, window functions and business questions to demonstrate SQL skills.

## Suggested analysis questions (write the queries yourself)
1. Which plans generate the most billed revenue?
2. What is total invoiced versus collected by month?
3. Which industries have the highest total invoice amounts?
4. Which accounts have unpaid balances?
5. What is the month-end ARR trend?
6. How many customers churned each month?
7. What is the average monthly charge by plan?
8. Rank the top 10 accounts by total payments using a window function.
9. Use a CTE to calculate monthly revenue and `LAG()` to find month-over-month changes.
10. Compare retention of signup cohorts after 3 and 6 months.

## Portfolio tip
Include your SQL scripts, clear metric definitions, screenshots of results, and a README explaining what the results mean. Never describe synthetic data as real company results.
