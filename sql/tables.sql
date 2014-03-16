DROP TABLE IF EXISTS Users, Topic, Argument, Opinion, Comment;
--Entities
CREATE TABLE Users (
  name varchar PRIMARY KEY,
  email varchar NOT NULL,
  password varchar NOT NULL
);

CREATE TABLE Topic (  -- the heart of an argument
  id integer PRIMARY KEY,
  stated_by varchar REFERENCES Users (name),
  postdate date NOT NULL,
  tags varchar  -- comma separated list of descriptive tags
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
  stated_by varchar REFERENCES Users (name), -- who made the comment
  arg_id integer,                            -- argument instance where posted
  arg_topic integer,                         -- topic opinion is about
  postdate date NOT NULL,                    -- when it was posted
  rage integer DEFAULT 0,                    -- rage score (voted by others)
  logic integer DEFAULT 0,                   -- logic score (voted by others)
  PRIMARY KEY (stated_by, arg_id, arg_topic),
  -- an opinion must be associated with an argument
  FOREIGN KEY (arg_id, arg_topic) REFERENCES Argument (id, topic)
);

CREATE TABLE Comment (    -- comment on an opinion
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
    REFERENCES Opinion (stated_by, arg_id, arg_topic)
);
