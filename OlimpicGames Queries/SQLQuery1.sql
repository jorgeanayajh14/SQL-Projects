/*
SELECT TOP 10 * FROM [OlimpicGames].[dbo].noc_regions
SELECT TOP 10 * FROM [OlimpicGames].[dbo].athlete_events
*/

--1. How many olympics games have been held?
SELECT COUNT(DISTINCT Games) AS total_olimpic_games
FROM athlete_events

--2. List down all Olympics games held so far.
SELECT DISTINCT Year, Season, City
FROM athlete_events ORDER BY Year ASC

--3. Mention the total no of nations who participated in each olympics game?
WITH all_countries AS (
						SELECT DISTINCT Games, region
						FROM [OlimpicGames].[dbo].athlete_events ae JOIN [OlimpicGames].[dbo].noc_regions nc
						ON nc.NOC = ae.NOC
						GROUP BY Games, region)
SELECT  Games, COUNT(1) AS total_countries
FROM all_countries
GROUP BY Games
ORDER BY Games

--4. Which year saw the highest and lowest no of countries participating in olympics
WITH all_countries AS (
					SELECT DISTINCT Games, region
					FROM athlete_events ae JOIN noc_regions nr
					ON nr.NOC = ae.NOC
					GROUP BY Games, region),
	countries_number AS (
					SELECT Games, COUNT(1) AS total_countries
					FROM all_countries
					GROUP BY Games)
SELECT DISTINCT
CONCAT(FIRST_VALUE(Games) OVER(ORDER BY total_countries),
		' - ',
		FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) AS lowest_countries,
CONCAT (FIRST_VALUE(Games) OVER (ORDER BY total_countries DESC),
		' - ',
		FIRST_VALUE(total_countries) OVER(ORDER BY total_countries DESC)) AS highest_countries
FROM countries_number
ORDER BY 1

--5. Which nation has participated in all of the olympic games
WITH all_countries AS (SELECT DISTINCT Games, region
						FROM athlete_events ae JOIN noc_regions nr
						ON nr.NOC = ae.NOC
						GROUP BY Games, region),
	times_per_country AS (SELECT region AS country, COUNT(region) AS participations_number
						FROM all_countries
						GROUP BY region)
SELECT * FROM times_per_country
WHERE participations_number = (SELECT MAX(participations_number)
								FROM times_per_country)

--6. Identify the sport which was played in all summer olympics.
WITH all_sports AS (SELECT DISTINCT Games, Sport
					FROM athlete_events
					GROUP BY Games, Sport),
	times_per_sport AS (SELECT Sport, COUNT(Games) AS games_number
						FROM all_sports
						GROUP BY Sport)
SELECT * FROM times_per_sport
WHERE games_number = (SELECT MAX(games_number)
						FROM times_per_sport)

--7. Which Sports were just played only once in the olympics.
WITH all_sports AS (SELECT DISTINCT Games, Sport
					FROM athlete_events
					GROUP BY Games, Sport),
	times_per_sport AS (SELECT Sport, COUNT(Games) AS games_number
						FROM all_sports
						GROUP BY Sport)
SELECT tps.Sport, games_number, asp.Games
FROM times_per_sport tps
JOIN all_sports asp ON asp.Sport = tps.Sport 
WHERE games_number = 1 ORDER BY tps.Sport

--8. Fetch the total no of sports played in each olympic games.
WITH all_games AS(SELECT DISTINCT Games, Sport
					FROM athlete_events)
SELECT Games, COUNT(Sport) AS number_of_sports
FROM all_games
GROUP BY Games
ORDER BY number_of_sports DESC

--9. Fetch oldest athletes to win a gold medal
WITH gold_medals AS (
	SELECT 
	name,
	Sex,
	CAST(CASE
			WHEN Age = 'NA' THEN '0' 
			ELSE Age
		END
		AS INT) AS Age,
	Team,
	Games,
	Sport,
	Medal
	FROM athlete_events
	WHERE medal = 'Gold'),
	ranking AS
		(SELECT *, RANK() OVER(ORDER BY Age DESC) AS rnk
		FROM gold_medals)
SELECT 
	name,
	Sex,
	Age,
	Team,
	Games,
	Sport,
	Medal
FROM ranking
WHERE rnk = 1

--10. Find the Ratio of male and female athletes participated in all olympic games.
WITH all_athletes_sex AS (
		SELECT Sex, COUNT(1) AS cnt 
		FROM athlete_events
		GROUP BY Sex),
	men_athletes AS (
		SELECT cnt AS men_athletes_number
		FROM all_athletes_sex
		WHERE Sex = 'M'),
	women_athletes AS (
		SELECT cnt as women_athletes_number
		FROM all_athletes_sex
		WHERE Sex = 'F'),
	two_sexes AS (
		SELECT * FROM men_athletes
		CROSS JOIN women_athletes),
	ratio_answer AS (
		SELECT CAST(men_athletes_number AS float) / CAST(women_athletes_number AS float)
		AS ratio
		FROM two_sexes)
SELECT CONCAT('1:', ROUND((SELECT * FROM ratio_answer), 2)) AS ratio

--11. Fetch the top 5 athletes who have won the most gold medals.
SELECT Name, Team, COUNT(Medal) AS total_gold_medals 
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name, Team
HAVING COUNT(Medal) > 6
ORDER BY total_gold_medals DESC

--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
WITH total_medals_table AS (
		SELECT Name, Team, COUNT(1) AS total_medals
		FROM athlete_events
		WHERE Medal <> 'NA'
		GROUP BY Name, Team),
	ranking_table AS (
		SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
		FROM total_medals_table)
SELECT Name, Team, total_medals, rnk
FROM ranking_table
WHERE rnk <= 5

--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH t1 AS (
		SELECT region, Team, Name, Games, COUNT(1) AS total_medals
		FROM athlete_events ae
		JOIN noc_regions nr
		ON nr.NOC = ae.NOC
		WHERE Medal <> 'NA'
		GROUP BY region, Team, Name, Games),
	t2 AS (
		SELECT region, SUM(CAST(total_medals AS int)) AS total_medals
		FROM t1
		GROUP BY region),
	t3 AS (
		SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
		FROM t2)
SELECT * FROM t3
WHERE rnk <= 5


--14. List down total gold, silver and bronze medals won by each country.
SELECT region,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold_medals,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
FROM athlete_events ae
JOIN noc_regions nr
ON nr.NOC = ae.NOC
--WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY region
ORDER BY gold_medals DESC, silver_medals DESC, bronze_medals DESC, region

--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
SELECT Games, region,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold_medals,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
FROM athlete_events ae
JOIN noc_regions nr
ON nr.NOC = ae.NOC
--WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Games, region
ORDER BY Games, region

--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH t1 AS (
		SELECT Games, region,
		SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
		SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
		SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
		FROM athlete_events ae
		JOIN noc_regions nr
		ON nr.NOC = ae.NOC
		GROUP BY Games, region)
SELECT DISTINCT Games,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY gold DESC),
		' - ',
		FIRST_VALUE(gold) OVER(PARTITION BY Games ORDER BY gold DESC)) AS max_gold,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY silver DESC),
		' - ',
		FIRST_VALUE(silver) OVER(PARTITION BY Games ORDER BY silver DESC)) AS max_silver,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY bronze DESC),
		' - ',
		FIRST_VALUE(bronze) OVER(PARTITION BY Games ORDER BY bronze DESC)) AS max_bronze
FROM t1
ORDER BY Games

--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH t1 AS (
		SELECT Games, region,
		SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
		SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
		SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze,
		SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
		FROM athlete_events ae
		JOIN noc_regions nr
		ON nr.NOC = ae.NOC
		GROUP BY Games, region)
SELECT DISTINCT Games,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY gold DESC),
		' - ',
		FIRST_VALUE(gold) OVER(PARTITION BY Games ORDER BY gold DESC)) AS max_gold,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY silver DESC),
		' - ',
		FIRST_VALUE(silver) OVER(PARTITION BY Games ORDER BY silver DESC)) AS max_silver,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY bronze DESC),
		' - ',
		FIRST_VALUE(bronze) OVER(PARTITION BY Games ORDER BY bronze DESC)) AS max_bronze,
CONCAT(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER By total_medals DESC),
		' - ',
		FIRST_VALUE(total_medals) OVER(PARTITION BY Games ORDER BY total_medals DESC)) AS max_medals
FROM t1
ORDER BY Games

/*
SELECT TOP 10 * FROM [OlimpicGames].[dbo].noc_regions
SELECT TOP 10 * FROM [OlimpicGames].[dbo].athlete_events 
*/

--18. Which countries have never won gold medal but have won silver/bronze medals?
WITH t1 AS (
	SELECT region AS country,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
	FROM athlete_events ae
	JOIN noc_regions nr
	ON nr.NOC = ae.NOC
	GROUP BY region)
SELECT * FROM t1
WHERE gold = 0 AND (silver <> 0 OR bronze <> 0)
ORDER BY silver DESC, bronze DESC

--19. In which Sport/event, India has won highest medals.
WITH t1 AS (
		SELECT Sport, region,
		SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
		FROM athlete_events ae
		JOIN noc_regions nr
		ON nr.NOC = ae.NOC
		WHERE region = 'India'
		GROUP BY Sport, region),
	t2 AS (
		SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rnk
		FROM t1)
SELECT Sport, total_medals from t2
WHERE rnk = 1

--20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
SELECT region AS team, Sport, Games,
SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM athlete_events ae
JOIN noc_regions nr
ON nr.NOC = ae.NOC
WHERE Sport = 'Hockey' and region = 'India'
GROUP BY region, Sport, Games
ORDER BY total_medals DESC