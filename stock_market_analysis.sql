
-- Which date in the sample saw the largest overall trading volume? On that date, which two stocks were traded most?
WITH biggest_day AS
(
SELECT date, SUM(volume) as overall_volume
FROM Stock_Prices
GROUP BY date
ORDER BY overall_volume DESC
LIMIT 1
)

SELECT symbol, volume, dense_rank() OVER(ORDER BY volume DESC) as volume_rank
FROM Stock_Prices
INNER JOIN biggest_day
ON Stock_Prices.date = biggest_day.date
LIMIT 2


-- On which day of the week does volume tend to be highest? Lowest?
WITH volume_by_day AS
(
SELECT date, SUM(volume) as overall_volume
FROM Stock_Prices
GROUP BY date
)

SELECT 
CASE strftime('%w',date)
WHEN '1' THEN 'Monday'
WHEN '2' THEN 'Tuesday'
WHEN '3' THEN 'Wednesday'
WHEN '4' THEN 'Thursday'
WHEN '5' THEN 'Friday'
END AS day_of_the_week,
SUM(overall_volume) as volume_by_day_of_the_week
FROM volume_by_day
GROUP BY day_of_the_week
ORDER BY volume_by_day_of_the_week DESC

-- On which date did Amazon (AMZN) see the most volatility, measured by the difference between the high and low price?
SELECT date, high, low, high - low AS volatility
FROM Stock_Prices
WHERE symbol = 'AMZN'
GROUP BY date
ORDER BY volatility DESC
LIMIT 1


-- If you could go back in time and invest in one stock from 1/2/2014 - 12/29/2017, which would you choose? What % gain would you realize?
WITH closing_price AS
(
SELECT symbol, close as ending_price
FROM Stock_Prices 
WHERE date = '2017-12-29'
)
,
lowest_historical_price AS
(
SELECT symbol, MIN(low) as lowest_price, date AS lowest_price_date
FROM Stock_Prices
GROUP BY symbol

)

SELECT lowest_historical_price.symbol, lowest_price, lowest_price_date, ending_price, ((ending_price - lowest_price) / lowest_price) *100 as percentage_gain
FROM lowest_historical_price
INNER JOIN closing_price
ON lowest_historical_price.symbol = closing_price.symbol
ORDER BY percentage_gain DESC
