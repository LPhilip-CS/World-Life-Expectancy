# World Life Expectancy Project (Data Cleaning)



-- FINDING DUPLICATES
-- Finding duplicates by combining columns to create a unique column.
SELECT Country, Year, COUNT(CONCAT(Country, Year)) duplicates
FROM WorldLifeExpectancy
GROUP BY  Country, Year
HAVING duplicates > 1;

-- Identifying the row id's of records that are duplicates by using a window function.
SELECT *
FROM (
    SELECT Row_ID, CONCAT(Country, Year), ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM WorldLifeExpectancy
) AS Row_Table
WHERE Row_Num > 1;

-- Deleting duplicate records.
DELETE FROM WorldLifeExpectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID, CONCAT(Country, Year), ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
        FROM WorldLifeExpectancy
    ) AS Row_Table
    WHERE Row_Num > 1);



-- STANDARDIZING STATUS COLUMN
--Finding all blank values in Status column
SELECT DISTINCT(Status)
FROM WorldLifeExpectancy
WHERE Status != '';

SELECT DISTINCT(Country)
FROM WorldLifeExpectancy
WHERE Status = 'Developing';

-- Standardizing blank values with 'Developing' & 'Developed' countries. 
UPDATE WorldLifeExpectancy AS Table1 JOIN WorldLifeExpectancy AS Table2
ON Table1.Country = Table2.Country
SET Table1.Status = 'Developing'
WHERE Table1.Status = '' AND Table2.Status != '' AND Table2.Status = 'Developing';

UPDATE WorldLifeExpectancy AS Table1 JOIN WorldLifeExpectancy AS Table2
ON Table1.Country = Table2.Country
SET Table1.Status = 'Developed'
WHERE Table1.Status = '' AND Table2.Status != '' AND Table2.Status = 'Developed';



-- STANDARDIZING LIFE EXPECTANCY COLUMN
-- Finding all blank values in Life Expectancy column
SELECT *
FROM WorldLifeExpectancy
WHERE LifeExpectancy = '';

-- Self joining on a table to determine the expected average of blank values.
SELECT Table1.Country, Table1.Year, Table1.LifeExpectancy, Table2.Country, Table2.Year, Table2.LifeExpectancy, Table3.Country, Table3.Year, Table3.LifeExpectancy,
ROUND((Table2.LifeExpectancy + Table3.LifeExpectancy) / 2, 1)
FROM WorldLifeExpectancy AS Table1 JOIN WorldLifeExpectancy AS Table2
ON Table1.Country = Table2.Country AND Table1.Year = Table2.Year - 1
JOIN WorldLifeExpectancy AS Table3
ON Table1.Country = Table3.Country AND Table1.Year = Table3.Year + 1
WHERE Table1.LifeExpectancy = '';

-- Updating the column with the previous logic.
UPDATE WorldLifeExpectancy AS Table1 JOIN WorldLifeExpectancy AS Table2
ON Table1.Country = Table2.Country AND Table1.Year = Table2.Year - 1
JOIN WorldLifeExpectancy AS Table3
ON Table1.Country = Table3.Country AND Table1.Year = Table3.Year + 1
SET Table1.LifeExpectancy = ROUND((Table2.LifeExpectancy + Table3.LifeExpectancy) / 2, 1)
WHERE Table1.LifeExpectancy = '';


