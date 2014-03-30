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

-- Tally up the rage score for a particular comment
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

-- Tally up the logic score for a particular opinion
CREATE OR REPLACE FUNCTION opinion_logic(
  opinion_poster varchar,
  arg_id integer,
  arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM OpinionVote vote
  WHERE vote.opinion_poster = $1
    AND vote.arg_id = $2
    AND vote.arg_topic = $3
    AND vote.logic = true;
$$ LANGUAGE SQL;

-- Tally up the rage score for a particular opinion
CREATE OR REPLACE FUNCTION opinion_rage(
  opinion_poster varchar,
  arg_id integer,
  arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM OpinionVote vote
  WHERE vote.opinion_poster = $1
    AND vote.arg_id = $2
    AND vote.arg_topic = $3
    AND vote.rage = true;
$$ LANGUAGE SQL;

-- Tally up the logic score for a particular argument
CREATE OR REPLACE FUNCTION argument_rage(arg_id integer, arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM OpinionVote vote
  WHERE vote.arg_id = $1
    AND vote.arg_topic = $2
    AND vote.logic = true;
$$ LANGUAGE SQL;

-- Tally up the rage score for a particular argument
CREATE OR REPLACE FUNCTION argument_rage(arg_id integer, arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM OpinionVote vote
  WHERE vote.arg_id = $1
    AND vote.arg_topic = $2
    AND vote.rage = true;
$$ LANGUAGE SQL;

-- Tally up the logic score for a particular topic
CREATE OR REPLACE FUNCTION topic_logic(arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM OpinionVote vote
  WHERE vote.arg_topic = $1
    AND vote.logic = true;
$$ LANGUAGE SQL;

-- Tally up the rage score for a particular topic
CREATE OR REPLACE FUNCTION topic_rage(arg_topic integer)
RETURNS bigint
AS $$
  select count(*)
  FROM OpinionVote vote
  WHERE vote.arg_topic = $1
    AND vote.rage = true;
$$ LANGUAGE SQL;
