-- allow quick access to the primary key of arguments that happened recently
CREATE INDEX recent_arguments ON Argument(id, topic, startdate DESC NULLS LAST);

