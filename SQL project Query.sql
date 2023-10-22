/**
---------------- SQL DATA ANALYSIS ------------------

-> Data Description: District Wise number of mental health patients such as severe mental illness, common mental disorder, 
alcohol, and substance abuse, cases referred to higher centers, suicide attempt cases.
-> Published On: 03/02/2022
-> Updated On: 03/02/2022
-> Contributors: Karnataka Health and Family Welfare Department, Karnataka
**/

-- #1. Combining the individual datasets into one table

-- Creating the temporary table "combined"

Create table combined (
SL_No tinyint,
DISTRICT nvarchar(50),
TIME_PERIOD nvarchar(50),
SEVERE_MENTAL_DISORDER_SMD int,
COMMON_MENTAL_DISORDER_CMD int,
ALCOHOL_SUBSTANCE_ABUSE int,
CASES_REFERRED_TO_HIGHER_CENTRES int,
SUICIDE_ATTEMPT_CASES int,
Others int,
Total int
);

-- UNION ALL to insert them into the 'combined' table.

INSERT INTO combined
SELECT * FROM [PortfolioProjects].[medic].[MHPatients_201819]
UNION ALL
SELECT * FROM [PortfolioProjects].[medic].[MHPatients_201920]
UNION ALL
SELECT * FROM [PortfolioProjects].[medic].[MHPatients_202021]
UNION ALL
SELECT * FROM [PortfolioProjects].[medic].[MHPatients_202122]

-- View top 50 from the temp table

SELECT TOP(50) * FROM combined;


/** -------------  AGGREGATIONS  --------------- **/

-- #2. Aggregating total case counts for each city in Karnataka.

Select DISTRICT, SUM(Total) 
FROM combined
GROUP BY DISTRICT
ORDER BY SUM(Total) desc

-- Raichur has the highest mental health case counts throughout the 4 years.
-- Shimoga has the lowest counts.

	--> Distinct count of Districts
	SELECT DISTINCT(DISTRICT) FROM combined

	-- The unique district names show 31 but the values are for 4 years across the 30  districts.
	-- We see that SHIVAMOGGA is misspelled in one of the tables as SHIMOGA leading to lowest counts.

	--> Converting SHIMOGA to SHIVAMOGGA
	UPDATE combined
	SET DISTRICT = 'SHIVAMOGGA'
	WHERE DISTRICT = 'SHIMOGA';


--> #3. Aggregating total case counts with update done (SHIVAMOGGA) to spot the highest and lowest counts

Select DISTRICT, SUM(Total) 
FROM combined
GROUP BY DISTRICT
ORDER BY SUM(Total) desc

-- Now we have KODAGU with the lowest counts (35,698)


--> #4. Aggregation of all illness cases based on Date (year) 

Select TIME_PERIOD, SUM(Total) as TotalCases
FROM combined
GROUP BY TIME_PERIOD
ORDER BY SUM(Total) desc

-- 2019-20 has the highest number of cases. followed by 2018-19
-- 2021-22 has almost half as less as these two years which is questionable.

/** Column Names Ref: SEVERE_MENTAL_DISORDER_SMD, COMMON_MENTAL_DISORDER_CMD, 
ALCOHOL_SUBSTANCE_ABUSE, CASES_REFERRED_TO_HIGHER_CENTRES, SUICIDE_ATTEMPT_CASES, 
Others, Total **/


--> #5. Break down of aggregation in the years 2018 and 2019.

Select TIME_PERIOD, SUM(SEVERE_MENTAL_DISORDER_SMD) as SMD, SUM(COMMON_MENTAL_DISORDER_CMD) as CMD, 
SUM(ALCOHOL_SUBSTANCE_ABUSE) as ASA, SUM(CASES_REFERRED_TO_HIGHER_CENTRES) as CasesRefered, SUM(SUICIDE_ATTEMPT_CASES) as Suicides, 
SUM(Others) as others, SUM(Total) as Total
FROM combined
GROUP BY TIME_PERIOD
ORDER BY SUM(Total) desc

-- The total cases recorded in 2021-22 is consistently less that half the numbers of the previous timeperiod, over all fields
-- The Suicide cases have seen an increase in 2020-21 (marking the start of covid)


--> #6. Let us look at the distrct with highest and lowest counts.
Select DISTRICT, TIME_PERIOD, SUM(SEVERE_MENTAL_DISORDER_SMD) as SMD, SUM(COMMON_MENTAL_DISORDER_CMD) as CMD, 
SUM(ALCOHOL_SUBSTANCE_ABUSE) as ASA, SUM(CASES_REFERRED_TO_HIGHER_CENTRES) as CasesRefered, SUM(SUICIDE_ATTEMPT_CASES) as Suicides, 
SUM(Others) as others, SUM(Total) as Total
FROM combined
WHERE DISTRICT IN ('Raichur','Kodagu')
GROUP BY TIME_PERIOD, DISTRICT
ORDER BY DISTRICT, TIME_PERIOD
-- Raichur's numbers show a decreasing trend over the time periods. 
-- Althougth Kodagu has case numbers lesser than Raichur's, their suicide cases are significantly higher. 

-------------------- PERCENTAGE AGGREGATIONS ------------------------

--> #7. Let us look at the % of each category with respect to the total for all districts over the years, 
Select DISTRICT, TIME_PERIOD, 
ROUND(SUM(SEVERE_MENTAL_DISORDER_SMD)/SUM(cast(Total as float)) * 100, 2) as SMD_percentage, 
ROUND(SUM(COMMON_MENTAL_DISORDER_CMD)/SUM(cast(Total as float))* 100, 2) as CMD_percentage, 
ROUND(SUM(ALCOHOL_SUBSTANCE_ABUSE)/SUM(cast(Total as float)) * 100, 2) as ASA_percentage, 
ROUND(SUM(CASES_REFERRED_TO_HIGHER_CENTRES)/SUM(cast(Total as float)) * 100, 2) as CasesRefered_percentage, 
ROUND(SUM(SUICIDE_ATTEMPT_CASES)/SUM(cast(Total as float)) * 100, 2) as Suicides_percentage, 
ROUND(SUM(Others)/SUM(cast(Total as float)) * 100, 2) as Others_percentage, 
SUM(Total)/SUM(cast(Total as float)) * 100 as Total_percentage
FROM combined
GROUP BY TIME_PERIOD, DISTRICT
ORDER BY DISTRICT, TIME_PERIOD

-- #8. Let's put the above input into a specific table
Create table combined_percentage (
SL_No tinyint,
DISTRICT nvarchar(50),
TIME_PERIOD nvarchar(50),
SMD_percentage float,
CMD_percentage float,
ASA_percentage float,
CasesRefered_percentage float,
Suicides_percentage float,
Others_percentage float,
Total_percentage float
);

-- Insert the values into this combined_percentage table.
INSERT INTO combined_percentage
Select SL_NO, DISTRICT, TIME_PERIOD, 
ROUND(SUM(SEVERE_MENTAL_DISORDER_SMD)/SUM(cast(Total as float)) * 100, 2) as SMD_percentage, 
ROUND(SUM(COMMON_MENTAL_DISORDER_CMD)/SUM(cast(Total as float))* 100, 2) as CMD_percentage, 
ROUND(SUM(ALCOHOL_SUBSTANCE_ABUSE)/SUM(cast(Total as float)) * 100, 2) as ASA_percentage, 
ROUND(SUM(CASES_REFERRED_TO_HIGHER_CENTRES)/SUM(cast(Total as float)) * 100, 2) as CasesRefered_percentage, 
ROUND(SUM(SUICIDE_ATTEMPT_CASES)/SUM(cast(Total as float)) * 100, 2) as Suicides_percentage, 
ROUND(SUM(Others)/SUM(cast(Total as float)) * 100, 2) as Others_percentage, 
SUM(Total)/SUM(cast(Total as float)) * 100 as Total_percentage
FROM combined
GROUP BY TIME_PERIOD, DISTRICT, SL_NO
ORDER BY DISTRICT, TIME_PERIOD

--> Let's see how it looks
SELECT * FROM combined_percentage			-- looks neat

-- #9. Average of percentages for every district

SELECT DISTRICT, AVG(SMD_percentage) as SMD_avg, AVG(CMD_percentage) as CMD_avg, 
AVG(ASA_percentage) as ASA_avg, AVG(Suicides_percentage) as Suicides_avg, 
AVG(CasesRefered_percentage) as CasesRef_avg, AVG(Others_percentage) as Other_avg
FROM combined_percentage
GROUP BY DISTRICT


/**
-- INFERENCES FROM PERCENTAGE TABLE:

1. Davanagere typically has recorded the highest average percentage of Severe Mental Disorder (SMD) cases and 
has approximately 65% of the total cases attributing to mental health cases over the period of 4 years.
2. More than half the cases in Bangalore Urban over the 4 years contribute to Common Mental Disorders (CMD) 
3. Alcholo Substance Abuse is the highest in Mysore on average over the years.
4. Hassan has recorded on an average the highest suicide rate (12.6%) over the 4 years, and 
with about 12.4% cases refered to higher centers for action.. Hassan has the highest priority cases recorded.

-- Cases refered to higher centers may refer to cases that have slightly gone beyond control or those that have higher intensity and urgency than the others.
-- In those terms we can say HASSAN is the District that has seen consistently high percentage of avergae cases across all
 these kinds of cases on its overall population of approximately 92,000
**/

-- #10. Looking at the average mental disorders cases alone

SELECT DISTRICT,AVG(SMD_percentage) as SMD_avg, AVG(CMD_percentage) as CMD_avg, 
(AVG(SMD_percentage) + AVG(CMD_percentage)) as TotalMD_percentage,
AVG(ASA_percentage) as ASA_avg, AVG(Suicides_percentage) as Suicides_avg, 
AVG(CasesRefered_percentage) as CasesRef_avg, AVG(Others_percentage) as Other_avg
FROM combined_percentage
GROUP BY DISTRICT
ORDER BY (AVG(SMD_percentage) + AVG(CMD_percentage)) desc

-- There are 17 districts who've recorded more than 50% average mental health cases (common and severe)
-- Among those Davanagere has a shocking 65.6% which is roughly 37,700 cases of the total reported cases of 57,480
-- Raichur has seen the highest, followed by Bangalore Urban


-- #11. Bangalore Urban and Rural comparison
SELECT DISTRICT, TIME_PERIOD, SMD_percentage, CMD_percentage, Suicides_percentage
FROM combined_percentage
WHERE DISTRICT IN ('BANGALORE RURAL','BANGALORE URBAN')
GROUP BY TIME_PERIOD,DISTRICT,SMD_percentage, CMD_percentage, Suicides_percentage
ORDER BY SMD_percentage desc

-- Bangalore Urban has seen a higher percentage of mental health issues to close to 70% in the years os 2020 and 2021
-- Even the suicide rates are higher compared to the previous years.
-- While Bangalore Rural has its percentage drop during the years 2020 & 2021
-- The reason could either be awareness of cases or the amount of cases in general which are lesser in Banglore Rural than Urban


/**
------------------------------------------  FINAL NOTES  --------------------------------------------

----------------------------- OBSERVATIONS -----------------------------
-- From the above dataset, we have been able to quantify the kinds of cases based on Districts and Time period
-- Their percentages with respect to the total cases reported have also been looked at.
-- The district(s) that has supposedly intense cases has been spotted too.
-- And possible reasoning the data jump is due to COVID's effect on people's mental state of mind.

----------------------------- RECOMMENDATION --------------------------------
-- A larger population is always great for study. It could be a larger amount of cities or a study over a larger period of time.