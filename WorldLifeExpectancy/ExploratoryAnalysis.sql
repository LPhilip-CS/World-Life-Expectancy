# World Life Expectancy Project (Exploratory Data Analysis)


-- Analyze columns that may be of interest.
SELECT *
FROM WorldLifeExpectancy


-- What is the average life expectancy in the world? (Account for bad data, 0 values).
SELECT AVG(LifeExpectancy)
FROM WorldLifeExpectancy
WHERE  LifeExpectancy != 0;


-- The increase in life expectancy over 15 years by country. Which countries have done really well increasing their life expectancy?
SELECT Country, MIN(LifeExpectancy), MAX(LifeExpectancy), ROUND(MAX(LifeExpectancy) - MIN(LifeExpectancy), 1) AS LifeExpectancy15Y
FROM WorldLifeExpectancy
GROUP BY Country
HAVING MIN(LifeExpectancy) != 0 AND MAX(LifeExpectancy) != 0
ORDER BY LifeExpectancy15Y DESC;


-- The average life expectancy over the years. Is there a drastic change in life expectancy between 2007 - 2022 in the world?
SELECT Year, ROUND(AVG(LifeExpectancy), 2) AS YearlyAvg
FROM WorldLifeExpectancy
WHERE LifeExpectancy != 0
GROUP BY Year 
ORDER BY Year ASC;

SELECT ROUND(MAX(YearlyAvg) - MIN(YearlyAvg), 1) AS ChgInLifeExp
FROM (
    SELECT Year, ROUND(AVG(LifeExpectancy), 2) AS YearlyAvg
    FROM WorldLifeExpectancy
    WHERE LifeExpectancy != 0
    GROUP BY Year 
    ORDER BY Year ASC) AS YearlyAvgTbl;


-- Is there a corelation between life expectancy and a high or low GDP in each country?
SELECT Country, ROUND(AVG(LifeExpectancy), 1) AS LifeExp, ROUND(AVG(GDP), 1) AS GDP
FROM WorldLifeExpectancy
GROUP BY Country
HAVING LifeExp > 0 AND GDP > 0
ORDER BY GDP DESC;


-- Average life expectancies of high and low GDP countries. (Assume GDP > 1500 is considered HIGH).
SELECT
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS HighGDPCountries,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN LifeExpectancy ELSE NULL END), 2) AS HighGDPLifeExp,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS LowGDPCountries,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN LifeExpectancy ELSE NULL END), 2) AS LowGDPLifeExp
FROM WorldLifeExpectancy;


-- Is there a corelation between life expectancy and the status of a country?
SELECT Status, COUNT(DISTINCT country) AS CountOfCountries, ROUND(AVG(LifeExpectancy), 1) AS AvgLifeExp
FROM WorldLifeExpectancy
GROUP BY Status;


-- Is there a corelation between life expectancy and BMI?
SELECT Country, ROUND(AVG(LifeExpectancy), 1) AS LifeExp, ROUND(AVG(BMI), 1) AS BMI
FROM WorldLifeExpectancy
GROUP BY Country
HAVING LifeExp > 0 AND BMI > 0
ORDER BY BMI DESC;


-- What is adult mortality rate in the U.S. over the years? (Rolling total).
SELECT Country, Year, LifeExpectancy, AdultMortality, SUM(AdultMortality) OVER(PARTITION BY Country ORDER BY Year) AS RollingDeathTotal
FROM WorldLifeExpectancy
WHERE Country LIKE '%united states%';

