#!/usr/bin/ruby
require 'date'
require 'faker'
require 'random-word'

# limits on random time values
$latest_time = Time.now
$earliest_time = $latest_time.to_date.prev_year.to_time
$argument_len = 24 * 60 * 60  # an argument lasts a day

#avoid warning from faker
I18n.config.enforce_available_locales = true
#Generate random data to populate database

# remove entries that would violate a unique primary key constraint
# priary_key is an array of column names that compose the primary key
def remove_duplicates table, primary_key
  table.uniq {|row| row.values_at(*primary_key)}
end

def generate_table generators, num_rows
  column_names = generators.keys.map{|k| k.to_s}
  rows = []
  num_rows.times do
    # each row is a hash of column_name => value
    rows << Hash[generators.map{|k,v| [k, v.call]}]
  end
  return rows
end

# convert values into postgres format
def format_value val
  case val
  when Time
    "timestamp '#{val.to_s.sub /\s-\d{4}$/, ''}'"  # add timestamp, strip zone
  when String
    "'#{val}'"
  else
    val
  end
end

def generate_insert_statements table_name, table
  # assume keys (column names) are the same for each row
  column_names = table.first.keys
  statement = "INSERT INTO #{table_name} (#{column_names.join ', '}) VALUES\n"
  table.each do |row|
    # append the generated values to the INSERT string
    vals = row.values.map {|v| format_value v}
    statement << "(#{vals.join(', ')}),\n"
  end
  statement.chomp(",\n") + ';'
end

# create Users
users_gen = {
  "name" => proc {Faker::Internet.user_name},
  "email" => proc {Faker::Internet.email},
  "password" => proc {Faker::Internet.password}
}
users = remove_duplicates(generate_table(users_gen, 10), %w{name})

# create Topics
topic_id = 0
topic_gen = {
  "id" => proc {topic_id += 1},
  "text" => proc {Faker::Lorem.sentence},
  "creator" => proc {users.sample["name"]},
  "postdate" => proc {rand($earliest_time..$latest_time)}
}
topic = generate_table(topic_gen, 15)

# create Arguments
arg_id = [0] * (topic.length + 1)   # argument id counters
ref_topic = nil                 # store referenced topic row
tmpdate = nil                      # store startdate of current row
argument_gen = {
  "topic" => proc {(ref_topic = topic.sample)["id"]},
  "id" => proc {arg_id[ref_topic["id"]] += 1},
  "startdate" => proc {tmpdate = rand(ref_topic["postdate"]..$latest_time)},
  "enddate" => proc {tmpdate + $argument_len}
}
argument = remove_duplicates(generate_table(argument_gen, 30), %w{id topic})

# create Opinons
ref_arg = nil                 # store referenced argument row
opinion_gen = {
  "text" => proc {Faker::Lorem.sentence},
  "posted_by" => proc {users.sample["name"]},
  "arg_id" => proc {(ref_arg = argument.sample)["id"]},
  "arg_topic" => proc {ref_arg["topic"]},
  "postdate" => proc {rand(ref_arg["startdate"]..ref_arg["enddate"])},
}
opinion = remove_duplicates(generate_table(opinion_gen, 90),
                            %w{posted_by arg_id arg_topic})

ref_opinion = nil                 # store referenced opinion row
comment_gen = {
  "text" => proc {Faker::Lorem.sentence},
  "posted_by" => proc {users.sample["name"]},
  "target" => proc {(ref_opinion = opinion.sample)["posted_by"]},
  "arg_id" => proc {ref_opinion["arg_id"]},
  "arg_topic" => proc {ref_opinion["arg_topic"]},
  "postdate" => proc do
    arg_end = argument.find{|row|
      row["id"] == ref_opinion["arg_id"] &&
      row["topic"] == ref_opinion["arg_topic"]
    }["enddate"]
    rand(ref_opinion["postdate"]..arg_end)
  end
}
comment = remove_duplicates(generate_table(comment_gen, 220),
                            %w{posted_by target arg_id arg_topic})

taglist = RandomWord.adjs.to_a.sample 10  # choose words to use for all tags
tag_gen = {
  "text" => proc {taglist.sample},
  "topic" => proc {topic.sample["id"]},
}
tag = remove_duplicates(generate_table(tag_gen, 30), %w{text})

ref_opinion = nil                 # store referenced opinion row
opinionvote_gen = {
  "voter" => proc {users.sample["name"]},
  "opinion_poster" => proc {(ref_opinion = opinion.sample)["posted_by"]},
  "arg_id" => proc {ref_opinion["arg_id"]},
  "arg_topic" => proc {ref_opinion["arg_topic"]},
  "logic" => proc {[true, false].sample},
  "rage" => proc {[true, false].sample}
}
opinionvote = remove_duplicates(generate_table(opinionvote_gen, 100),
                                %w{voter opinion_poster arg_id arg_topic})

ref_comment = nil                 # store referenced comment row
commentvote_gen = {
  "voter" => proc {users.sample["name"]},
  "comment_poster" => proc {(ref_comment = comment.sample)["posted_by"]},
  "opinion_poster" => proc {ref_comment["target"]},
  "arg_id" => proc {ref_comment["arg_id"]},
  "arg_topic" => proc {ref_comment["arg_topic"]},
  "logic" => proc {[true, false].sample},
  "rage" => proc {[true, false].sample}
}
commentvote = remove_duplicates(generate_table(commentvote_gen, 100),
                      %w{voter comment_poster opinion_poster arg_id arg_topic})

puts generate_insert_statements "Users", users.uniq
puts generate_insert_statements "Topic", topic.uniq
puts generate_insert_statements "Argument", argument.uniq
puts generate_insert_statements "Opinion", opinion.uniq
puts generate_insert_statements "Comment", comment.uniq
puts generate_insert_statements "Tag", tag.uniq
puts generate_insert_statements "OpinionVote", opinionvote.uniq
puts generate_insert_statements "CommentVote", commentvote.uniq
