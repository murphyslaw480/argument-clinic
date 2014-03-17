-- Clear out previous runs
DROP TABLE IF EXISTS
  Users,
  Topic,
  Argument,
  Opinion,
  Comment,
  Tag,
  OpinionVote,
  CommentVote,
CASCADE;

--Entities
CREATE TABLE Users (
  name varchar PRIMARY KEY,
  email varchar NOT NULL,
  password varchar NOT NULL
);

CREATE TABLE Topic (  -- the heart of an argument
  id integer PRIMARY KEY,
  text varchar NOT NULL,  -- a controversial statement to be argued about
  creator varchar REFERENCES Users (name),
  postdate date NOT NULL
  -- note: rage and logic scores are calculated by sum across arguments
  -- could use view
);

CREATE TABLE Argument (   -- one discussion instance based on a statement
  id integer,
  topic integer REFERENCES Topic (id), -- statement argument is based on
  startdate date NOT NULL,             -- date argument started
  enddate date NOT NULL,               -- date argument ended
  PRIMARY KEY (id, topic)              -- weak entity, depends on statement
  -- note: rage and logic scores are calculated by sum across opinions
  -- could use view
);

CREATE TABLE Opinion (   -- one expession of opinion in an argument
  text varchar NOT NULL,                     -- text response to argument
  posted_by varchar REFERENCES Users (name), -- who made the comment
  arg_id integer,                            -- argument instance where posted
  arg_topic integer,                         -- topic opinion is about
  postdate date NOT NULL,                    -- when it was posted
  rage integer DEFAULT 0,                    -- rage score (voted by others)
  logic integer DEFAULT 0,                   -- logic score (voted by others)
  PRIMARY KEY (posted_by, arg_id, arg_topic),
  -- an opinion must be associated with an argument
  FOREIGN KEY (arg_id, arg_topic) REFERENCES Argument (id, topic)
);

CREATE TABLE Comment (    -- comment on an opinion
  text varchar NOT NULL,                     -- text response to opinion
  posted_by varchar REFERENCES Users (name), -- who made the comment
  target varchar,                            -- recipient of comment
  arg_id integer,                            -- argument based on statement
  arg_topic integer,                         -- statement where posted
  postdate date NOT NULL,                    -- when it was posted
  rage integer DEFAULT 0,                    -- rage score (voted by others)
  logic integer DEFAULT 0,                   -- logic score (voted by others)
  PRIMARY KEY (posted_by, target, arg_id, arg_topic),
  -- a comment is associated with a single opinion
  FOREIGN KEY (target, arg_id, arg_topic)
    REFERENCES Opinion (posted_by, arg_id, arg_topic)
);

CREATE TABLE Tag (                        -- mapping of tags to topics
  text varchar,                           -- tag descriptive text
  topic integer REFERENCES Topic (id),    -- topic this was applied to
  PRIMARY KEY (text, topic)
);

CREATE TABLE OpinionVote ( -- vote on a users opinion on a certain topic
  voter varchar REFERENCES Users,   -- who made this vote?
  opinion_poster varchar,          -- recipient of vote
  arg_id integer,          -- id of argument where opinion was posted
  arg_topic integer,       -- topic under wich argument exists
  logic boolean,           -- thought opinion was logical
  rage boolean,            -- thought opinion was rage-inducing
  PRIMARY KEY (voter, opinion_poster, arg_id, arg_topic),
  -- a comment is associated with a single opinion
  FOREIGN KEY (opinion_poster, arg_id, arg_topic)
    REFERENCES Opinion (posted_by, arg_id, arg_topic)
);

CREATE TABLE CommentVote ( -- vote on a users comment on a certain opinion
  voter varchar REFERENCES Users, -- who made this vote?
  comment_poster varchar,             -- who made the comment
  opinion_poster varchar,             -- who stated opinion comment was on
  arg_id integer,                     -- argument where opinion was stated
  arg_topic integer,                  -- topic of argument
  logic boolean,                      -- thought comment was logical
  rage boolean,                       -- thought comment was rage-inducing
  PRIMARY KEY (voter, comment_poster, opinion_poster, arg_id, arg_topic),
  -- a comment is associated with a single opinion
  FOREIGN KEY (comment_poster, opinion_poster, arg_id, arg_topic)
    REFERENCES Comment (posted_by, target, arg_id, arg_topic)
);
