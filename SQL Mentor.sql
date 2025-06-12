-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions

COPY user_submissions
FROM 'D:\user_sub_sql_mentor06nov.csv' 
DELIMITER ',' 
CSV HEADER;

--1--------------------
SELECT 
	COUNT(DISTINCT username)
FROM user_submissions

SELECT 
	DISTINCT username
FROM user_submissions

SELECT 
	username,
	COUNT(id) as total_submissions,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY username
ORDER BY points_earned DESC 

--2-----------------
SELECT * FROM user_submissions;

SELECT 
	-- EXTRACT(DAY FROM submitted_at) as day,
	TO_CHAR(submitted_at, 'DD-MM') as day,
	username,
	AVG(points) as daily_avg_points
FROM user_submissions
GROUP BY 1, 2
ORDER BY username;

--3-----------------
SELECT * FROM user_submissions;



WITH daily_submissions
AS
(
	SELECT 
		-- EXTRACT(DAY FROM submitted_at) as day,
		TO_CHAR(submitted_at, 'DD-MM') as daily,
		username,
		SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions
	FROM user_submissions
	GROUP BY 1, 2
),
users_rank
as
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) as rank
FROM daily_submissions
)

SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;

--4----------------
SELECT 
	username,
	SUM(CASE 
		WHEN points < 0 THEN 1 ELSE 0
	END) as incorrect_submissions,
	SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions,
	SUM(CASE 
		WHEN points < 0 THEN points ELSE 0
	END) as incorrect_submissions_points,
	SUM(CASE 
			WHEN points > 0 THEN points ELSE 0
		END) as correct_submissions_points_earned,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submissions DESC

--5--------------------
SELECT *  
FROM
(
	SELECT 
		-- WEEK()
		EXTRACT(WEEK FROM submitted_at) as week_no,
		username,
		SUM(points) as total_points_earned,
		DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as rank
	FROM user_submissions
	GROUP BY 1, 2
	ORDER BY week_no, total_points_earned DESC
)
WHERE rank <= 10
