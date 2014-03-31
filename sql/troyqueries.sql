--Some SQL queries on the database
--Troy Gittelmacher

--Query 1: Returns topic id's posted by a user
SELECT Users.name, Topic.id
FROM Users, Topic
WHERE Users.name = Topic.creator;

--Query 2: Returns all argument id's for a topic
SELECT Argument.id AS arg_id, Topic.id AS topic_id
FROM Argument, Topic
WHERE Argument.topic = Topic.id;

--Query 3: Returns opinions on a topic by a user
SELECT Users.id, Topic.id, Opinion.(text name?)
FROM Users, Topic, Opinion
WHERE topic.creator = Users.name
      AND Argument.topic = Topic.id;
      
--Query 4: Returns last 10 comments by a user in order of most recent date
SELECT Users.id, Comment.(text name?)
FROM Users, Comment
WHERE Comment.posted_by = Users.name
ORDER BY Comment.postdate DESC;
LIMIT 10;

--View 1: Creates a View on arguments about a topic in descending date order
CREATE OR REPLACE VIEW topic_arguments AS (
  SELECT Argument.id, Topic.id
  FROM Argument, Topic
  WHERE Argument.topic = topic.id);
  
--View 2: Creates a view that shows topics the user has participated in
-- Can be used to decide which arguments to show for a user. Similar to Query 1
CREATE OR REPLACE VIEW user_topics AS (
  SELECT Users.id, Topic.id
  FROM Users, Topic
  WHERE Users.name = Topic.creator
  GROUP BY Topic.id
  ORDER BY Count(Topic.id) DESC);

