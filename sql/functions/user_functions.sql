CREATE FUNCTION topics_by_user(name varchar)
RETURNS TABLE(id integer, text varchar)
AS $$
SELECT id, text
FROM Topic
WHERE creator = name;
$$ LANGUAGE SQL;
