--Netflix Project--
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

--1. Count the number of Movies vs TV Shows
SELECT 
   type,
   COUNT(*)AS total_content
FROM netflix
GROUP BY 1;


--2. Find the most common rating for movies and TV shows
SELECT
	type,
	rating
FROM
(
	SELECT 
		type, 
		rating,
		count(*)AS rating_count,
		RANK()OVER(PARTITION BY type ORDER BY COUNT(*) DESC)AS ranking
	FROM netflix
	GROUP BY 1,2
)AS t1
WHERE 
    ranking = 1;
	

--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND 
	release_year = 2020;


--4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country,','))AS new_country,
	COUNT(show_id)AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--5. Identify the longest movie
SELECT *
FROM netflix
WHERE
	type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


--6. Find content added in the last 5 years
SELECT * FROM netflix
WHERE
	TO_DATE(date_added ,'Month DD,YYYY') >= CURRENT_DATE - INTERVAL'5 Years';
	

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE 
	director ILIKE '%Rajiv Chilaka%';


--8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1)::INT> 5 ;


--9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,','))AS genre,
	COUNT(show_id)AS total_content
FROM netflix
GROUP BY 1;


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
SELECT
	country,
	release_year,
	COUNT(show_id)as total_release,
	ROUND(
	    COUNT(show_id)::numeric/
		                       (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric*100
		,2
		 )as avg_release
FROM netflix
GROUP BY 1,2
ORDER BY avg_release
LIMIT 5;


--11. List all movies that are documentaries
SELECT * FROM
	(SELECT 
		*,
		UNNEST(STRING_TO_ARRAY (listed_in,','))AS genre
	FROM netflix
	WHERE 
		type = 'Movie')
WHERE 
	genre='Documentaries';
	
'
--12. Find all content without a director
SELECT * FROM netflix
WHERE director IS null;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT (YEAR FROM CURRENT_DATE)-10;


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts,','))as actor,
	COUNT (*)
FROM netflix
WHERE
	country = 'India'
	AND
	type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
SELECT
	category,
	type,
	count(*)as content_count
FROM(
	SELECT 
		*,
		CASE 
	 		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad' 
			ELSE 'Good'
	 	END AS category
	FROM netflix
	)AS categorised_content
GROUP BY 1,2
ORDER BY 2










