## Neo-Bank Engagement & Financial Impact Analysis

In this analysis, I explored user behavior and financial trends for a Neo-Bank platform to understand what drives user retention and transaction volume. Through this analysis, I applied dbt-style modeling conventions in BigQuery to transform raw data, built a predictive Machine Learning model in Python to forecast cash flow gaps, and designed interactive dashboards in Looker Studio to present strategic solutions to stakeholders.

## Executive Summary:

Using SQL in BigQuery, I modeled raw transaction and user lifecycle data into scalable staging and mart layers. By analyzing the data in Looker Studio, I discovered a critical business problem: while platform activity was booming (transaction volume grew 70x), users were spending more than they deposited, resulting in a projected -$46M cash flow gap. Furthermore, the data revealed that "Multi-Transaction Type" users were 5x stickier than "Single-Transaction Type" users. To solve the funding gap, I trained a Random Forest Classifier in Python to predict which users were likely to become "Net Spenders." The final recommendation to the Board was to target the 11.3% of single-feature users with cross-selling campaigns and funding incentives to close the gap.

## Business Problem:

The Neo-Bank wants to understand why users are treating the platform as a "secondary spending wallet" rather than a "primary funding bank." While transaction volume is increasing, the net cash flow is negative (-$31M). The bank has data on user stickiness, transaction types, and funding amounts, but it is unclear what behavioral factors drive users to fund their accounts versus drain them. Our team's analysis identifies the exact behavioral triggers (Feature Adoption) that increase funding, allowing the Customer Success and Marketing teams to build targeted retention and cross-sell strategies.

## Methodology

1. Data Preparation: Explored and transformed raw transaction data using SQL in BigQuery. Aggregated daily activity into monthly user cohorts.
2. Data Modeling: Applied dbt-style modeling conventions to organize data into raw, staging, intermediate, and mart layers for clean, scalable collaboration.
3. Data Analysis & Forecasting (Python): Extracted the mart tables into Google Colab. Engineered engagement metrics (Stickiness Ratio, Avg Days Between Transactions) and trained a Machine Learning model to predict future Net Cash Flow for 2019-2020.
4. Data Visualization (Looker Studio): Built a 7-page interactive dashboard to track Platform Growth, User Distribution, Habits Retention, and Present Solutions to the Board.
5. Strategic Recommendations: Proposed data-driven solutions, including a "Build the Habit in 30 Days" onboarding flow, a $5 bonus for keeping money in the bank for 30 days, and a Premium upsell for high-potential users.
