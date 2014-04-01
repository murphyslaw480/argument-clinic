-- These views maintain lists of the top scores in various categories
-- Such things would typically be displayed in a prominent place for users to
-- see, and would change as time progresses

-- Find the topics with the highest average aggregate logic score
CREATE VIEW top_logical_topics AS
  SELECT t.id, t.text, avg(argument_logic(a.id, a.topic)) AS avg_logic
  FROM Topic t, Argument a
  WHERE t.id = a.topic
  GROUP BY t.id
  ORDER BY avg_logic desc
  LIMIT 10;

-- Find the topics with the highest average aggregate rage score
CREATE VIEW top_rage_inducing_topics AS
  SELECT t.id, t.text, avg(argument_rage(a.id, a.topic)) AS avg_logic
  FROM Topic t, Argument a
  WHERE t.id = a.topic
  GROUP BY t.id
  ORDER BY avg_logic desc
  LIMIT 10;
