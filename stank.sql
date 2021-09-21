/* Seeing the entire table first */
SELECT * FROM shark_tank

/*
This query was written to update the table as there were entrepreneurs missing. Based on an online search, I updated to include the entrepreneurs names into the table for completeness of information
Source of the entrepreneurs information:https://sharkalytics.com/episodes 
*/

UPDATE shark_tank
SET entrepreneurs = 'Josh Hix and Nick Taranto'
WHERE title = 'Plated' and episode = 22

UPDATE shark_tank
SET entrepreneurs = 'Alice Brooks and Bettina Chen'
WHERE title = 'Roominate' and episode = 2

UPDATE shark_tank
SET entrepreneurs = 'Josh Brooks'
WHERE title = 'Postcard on the Run' and episode = 1

/*This query shows the breakdown of successful deals in each category */
SELECT category AS 'Category',
COUNT(category) AS 'No. of Deals'
FROM shark_tank
WHERE deal = 1
GROUP BY category
ORDER BY [No. of Deals] DESC

/* The highest valuation for each season under each category. */
SELECT season, category, MAX(valuation) AS 'Highest Valuation'
FROM shark_tank
WHERE deal = 1
GROUP BY season, category
ORDER BY season, category, [Highest Valuation] DESC


/* Top ten deals made in Shark Tank */
SELECT TOP 10 category, title, entrepreneurs, valuation, location
FROM shark_tank
WHERE deal = 1
ORDER BY valuation DESC

/* Top ten deals made in Shark Tank with multiple offers*/
SELECT TOP 10 category, title, entrepreneurs, valuation, location
FROM shark_tank
WHERE deal = 1 AND [Multiple Entreprenuers] = 1
ORDER BY valuation DESC


/* Average, lowest and highest valuation of deals made for each category across six seasons of Shark Tank*/
SELECT category AS 'Category', AVG(valuation) AS 'Average Val.', MIN(valuation) AS 'Min. Valuation', MAX(valuation) AS 'Max Valuation'
INTO Stats_Table
FROM shark_tank
WHERE deal = 1
GROUP BY category

SELECT * FROM Stats_Table;

/* Upp, Lower percentile and Median of valuation for each category */
SELECT DISTINCT(category) AS 'Category', 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY valuation) OVER (PARTITION BY category) AS 'Lower Percentile',
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY valuation) OVER (PARTITION BY category) AS 'Median Val.',
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY valuation) OVER (PARTITION BY category) AS 'Upp. Percentile'
INTO P_Table
FROM shark_tank
WHERE deal = 1

SELECT * FROM P_Table;


/* Combining both of the above tables created to form a table view that I will extract to make a box plot diagram in a data visualisation software such as Tableau for each business category */
CREATE VIEW box_plot
AS
(
SELECT stat.*, perc.[Lower Percentile], 
perc.[Median Val.], 
perc.[Upp. Percentile] 
FROM Stats_Table stat
JOIN P_Table perc
ON stat.Category = perc.Category
)

SELECT * FROM Box_Plot
ORDER BY [Average Val.] DESC;

/*Locations of successful deals */
SELECT category AS 'Category', title AS 'Company', 
COUNT(location) OVER (PARTITION BY category) AS 'No. of States', 
LEFT(location, CHARINDEX(',',location) - 1) AS 'City', -- The location included both the City and the State of the company, I needed to separate both values into two separate columns in order for Tableau to map their locations on a map chart accurately.
REPLACE(SUBSTRING(location, CHARINDEX(',', location), LEN(location)), ',', '') AS 'State',
AVG(valuation) OVER (PARTITION BY category) AS 'Avg Val.'
FROM shark_tank
WHERE deal = 1