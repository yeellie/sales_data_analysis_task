-- 1. Add a new column "Ranking" that calculates the running count of transacKons 
-- for each unique merchant ID sorted by transacKon date. Save that output as new_transactions.csv.
SELECT *,
  COUNT (*) OVER(PARTITION BY merchant_id ORDER BY transaction_create_date) AS Ranking
FROM `teya-project-transactions.transactionsdata.transactions`

-- I used COUNT(*) window function with the OVER clause to calculate the running count of transactions for each unique merchant ID. 
-- The PARTITION BY clause ensures that the counting is done separately for each merchant ID, and the ORDER BY clause specifies the sorting based on the transaction creation date. 
-- The result is put in a new column named "Ranking". 
-- SELECT * corresponds to selecting all other rows from the transactions table.
-- In terms of cumulative transactions, Merchant 75 stands out with the highest count – 22,239 transactions. 
-- On the other hand, the lowest number corresponds to Merchant 100 with 5,120 transactions.

-- 2. Group merchants by onboarding month and output the first merchant to transact in each cohort ranked by earliest transaction date.
WITH RANKING AS (SELECT merchant_id, EXTRACT(MONTH FROM merchant_registration_date)
as Month,
 RANK() OVER(PARTITION BY EXTRACT(MONTH FROM merchant_registration_date) ORDER BY
MIN(transaction_create_date)) AS Ranks
FROM `teya-project-transactions.transactionsdata.transactions`
GROUP BY merchant_id, merchant_registration_date
ORDER BY Month)

SELECT merchant_id, Month, Ranks
FROM Ranking
WHERE Ranks = 1
ORDER BY Month

-- The RANKING CTE groups merchants by onboarding month using the EXTRACT function to extract the month from the merchant_registration_date. 
-- It then ranks the merchants within each cohort based on the earliest transaction date using the RANK() window function. 
-- The earliest transaction date was defined by MIN(transaction_create_date) function.
-- The main query selects columns from the RANKING CTE, where the rank is 1 (indicating the first merchant to transact in each cohort). 
-- The results are ordered by the onboarding month.
-- There are only four months during which merchants were onboarded. 
-- Some merchants had their first transactions months after the registration month. 
-- The largest number of merchants were registered during August, followed by September. 
-- The first merchant to transact from the April group was merchant_id 44, from August – 103, September – 789, December – 12.