#!/usr/bin/env ruby

require 'httparty'
require 'yaml'

cartodb_url = "http://simbiotica.cartodb.com/api/v2/sql"
secrets = YAML::load(File.open('secrets.yml'))
token = secrets['token']
table_name = "solarimpulse"

rows= CSV.read("new_output.csv")


rows.each do |r|


  sql = <<-SQL
    UPDATE #{table_name}
    SET avg_bat = #{r[3]}
    WHERE lat = #{r[1]} AND long = #{r[2]}
    AND time = '#{r[0]}'
  SQL

  puts sql

  options = {
    body: {
      api_key: token,
      q: sql
    }
  }

  a = HTTParty.post(cartodb_url, options)
  puts a
end
