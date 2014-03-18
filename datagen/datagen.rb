#!/usr/bin/ruby
require 'faker'
#avoid warning from faker
I18n.config.enforce_available_locales = true
#Generate random data to populate database

users_gen = {  
  name: proc {Faker::Internet.user_name},
  email: proc {Faker::Internet.email},
  password: proc {Faker::Internet.password}
}

def generate_table generators, num_rows 
  column_names = generators.keys.map{|k| k.to_s}
  rows = []
  num_rows.times do
    # call each generator to create a random value for that column
    vals = generators.values.map{|g| g.call}
    # each row is a hash of column_name => value
    rows << Hash[generators.map{|k,v| [k, v.call]}]
  end
  return rows
end

def generate_insert_statements table_name, table
  # assume keys (column names) are the same for each row
  column_names = table.first.keys
  statement = "INSERT INTO #{table_name}\n(#{column_names.join ', '})\nVALUES\n"
  table.each do |row|
    # append the generated values to the INSERT string
    statement << "(#{row.values.join(', ')}),\n"
  end
  statement.chomp(",\n") + ';'
end

users = generate_table users_gen, 10
puts generate_insert_statements "Users", users
