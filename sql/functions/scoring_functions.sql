-- Tally up the logic score for a particular comment
CREATE OR REPLACE FUNCTION comment_logic(
  comment_poster varchar,
  opinion_poster varchar,
  arg_id integer,
  arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM CommentVote vote
  WHERE vote.comment_poster = $1
    AND vote.opinion_poster = $2
    AND vote.arg_id = $3
    AND vote.arg_topic = $4
    AND vote.logic = true;
$$ LANGUAGE SQL;

-- Tally up the logic score for a particular comment
CREATE OR REPLACE FUNCTION comment_rage(
  comment_poster varchar,
  opinion_poster varchar,
  arg_id integer,
  arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM CommentVote vote
  WHERE vote.comment_poster = $1
    AND vote.opinion_poster = $2
    AND vote.arg_id = $3
    AND vote.arg_topic = $4
    AND vote.rage = true;
$$ LANGUAGE SQL;
