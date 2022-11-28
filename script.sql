/*Create database*/
CREATE DATABASE claims;

USE claims;

/*data imported using Table Data Import Wizard*/

/*Cheking the number of rows*/
SELECT count(*) FROM claims;

SELECT * FROM claims;
/*Checking if the IDS are unique*/
SELECT COUNT(distinct `Claim ID`) FROM claims;
/*No duplicates in Claim ID*/

/*Checking values in "Time to Close". One value below zero was found.*/
SELECT 
	COUNT(`Time to Close`) AS number_information, 
	MIN(`Time to Close`) AS min_time_close, 
    MAX(`Time to Close`) AS max_time_close, 
    AVG(`Time to Close`) AS avg_time_close
FROM claims;

SELECT *
FROM claims
WHERE `Time to Close` < 0;
/*0000000-00.2019.0.00.0079	-57	R$3,672.00	999.68	SAO LUIS	0	FALSE	*/

/*Deleting the row with inconsistent value*/
DELETE 
FROM claims
WHERE `Time to Close` < 0;

/*Column Claim Amount was updated in order to extract the numbers from string and turn them into numeric*/
UPDATE claims
SET `Claim Amount` = CAST(REPLACE(SUBSTRING_INDEX(`Claim Amount`, '$', -1), ',', '') AS decimal);

ALTER TABLE claims MODIFY COLUMN `Claim Amount` double;

/*there are no null values in Claim Amount*/
SELECT * FROM claims
WHERE `Claim Amount` IS NULL;

/*Checking if values are consistent*/
SELECT 
	MIN(`Claim Amount`) AS min_claim_amount,
    MAX(`Claim Amount`) AS max_claim_amount,
    SUM(`Claim Amount`) AS sum_claim_amount
FROM claims;

/*Checking if values are consistent*/
SELECT 
	MIN(`Amount Paid`) AS min_amount_paid,
    MAX(`Amount Paid`) AS max_amount_paid,
    SUM(`Amount Paid`) AS sum_amount_paid
FROM claims;

SELECT DISTINCT Location
FROM claims;

SELECT `Individuals on Claim`, COUNT(`Individuals on Claim`)
FROM claims
GROUP BY `Individuals on Claim`
ORDER BY `Individuals on Claim`;

SELECT *
FROM claims
WHERE `Individuals on Claim` = 0;


SELECT `Linked Cases`, COUNT(*)
FROM claims
GROUP BY `Linked Cases`;

SELECT cause, COUNT(*)
FROM claims
GROUP BY cause;

UPDATE claims
SET Cause = 'unknown'
WHERE Cause ='';

/*How does the number of claims differ across locations?*/
WITH location_count AS(
	SELECT 
		Location, 
		COUNT(*) AS total_location,
       ROUND((COUNT(*)/(SELECT COUNT(*) FROM claims))*100, 2) AS perct
	FROM claims
	GROUP BY Location
	ORDER BY 2 DESC
)

SELECT
	location,
    total_location,
    perct,
    SUM(total_location) OVER (ORDER BY total_location DESC) AS cumulative_sum,
    SUM(perct) OVER (ORDER BY total_location DESC) AS cumulative_perct
FROM location_count;

/*How does the average time to close claims differ by location?*/
SELECT 
	location,
    COUNT(`Time to Close`) AS count,
    AVG(`Time to Close`) AS avg_close
FROM claims
GROUP BY location;
