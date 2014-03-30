-- Queries to gather data about users
-- How many topics has each user created?
\echo 'How many topics has each user created?'
SELECT Users.name, count(Topic.id) AS topics_posted
FROM Users INNER JOIN Topic
ON Topic.creator = Users.name
GROUP BY Users.name;

-- How many arguments has each user participated in?
\echo 'How many arguments has each user participated in?'
SELECT Users.name, count(Opinion.arg_id) AS arguments_participated_in
FROM Users INNER JOIN Opinion
ON Opinion.posted_by = Users.name
GROUP BY Users.name;
