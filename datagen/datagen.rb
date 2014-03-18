#!/usr/bin/ruby
require 'faker'
require 'random_word'
#avoid warning
I18n.config.enforce_available_locales = true
#Generate random data to populate database

users_gen = {  
  name: Faker::Internet.method(:user_name),
  email: Faker::Internet.method(:email),
  password: Faker::Internet.method(:password)
}

def generate_insert_statements generators, table_name, num_rows 
  column_names = generators.keys.map{|k| k.to_s}
  statement = "INSERT INTO #{table_name}\n(#{column_names.join ', '})\nVALUES\n"
  num_rows.times do
    # call each generator to create a random value for that column
    vals = generators.values.map{|g| g.call}
    # append the generated values to the INSERT string
    statement << "(#{vals.join(', ')}),\n"
  end
  statement.chomp(",\n") + ';'
end

puts generate_insert_statements users_gen, "Users", 10

n = Faker::Name.method(:name)
puts n.call
