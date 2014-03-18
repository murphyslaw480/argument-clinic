#!/usr/bin/ruby
require 'date'
require 'faker'

# limits on random time values
$latest_time = Time.now
$earliest_time = $latest_time.to_date.prev_year.to_time
$argument_len = 24 * 60 * 60  # an argument lasts a day

#avoid warning from faker
I18n.config.enforce_available_locales = true
#Generate random data to populate database

# select a random row from the given table
# extract the values from columns specified as keys in column_map
# rename those keys to the values in column_map
def select_rand_row table, column_map
  Hash[table.sample.map{|k,v| [column_map[k], v]}].delete_if{|k,v| k.nil?}
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
    "timetamp '#{val.to_s.sub /\s-\d{4}$/, ''}'"  # add timestamp, strip zone
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
users = generate_table users_gen, 10

# create Topics
topic_id = 0
topic_gen = {
  "id" => proc {topic_id += 1},
  "text" => proc {Faker::Lorem.sentence},
  "creator" => proc {users.sample["name"]},
  "postdate" => proc {rand($earliest_time..$latest_time)}
}
topic = generate_table topic_gen, 10

# create Arguments
arg_id = [0] * (topic.length + 1)   # argument id counters
current_topic = nil                 # store referenced topic row
tmpdate = nil                      # store startdate of current row
argument_gen = {
  "topic" => proc {(current_topic = topic.sample)["id"]},
  "id" => proc {arg_id[current_topic["id"]] += 1},
  "startdate" => proc {tmpdate = rand(current_topic["postdate"]..$latest_time)},
  "enddate" => proc {tmpdate + $argument_len}
}
argument = generate_table argument_gen, 10

# create Opinons
current_arg = nil                 # store referenced argument row
opinion_gen = {
  "text" => proc {Faker::Lorem.sentence},
  "posted_by" => proc {users.sample["name"]},
  "arg_id" => proc {(current_arg = argument.sample)["id"]},
  "arg_topic" => proc {current_arg["topic"]},
  "postdate" => proc {rand(current_arg["startdate"]..current_arg["enddate"])},
}
opinion = generate_table opinion_gen, 10

puts generate_insert_statements "Users", users
puts generate_insert_statements "Topic", topic
puts generate_insert_statements "Argument", argument
puts generate_insert_statements "Opinion", opinion
