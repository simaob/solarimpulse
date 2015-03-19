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
    INSERT INTO #{table_name} (time, lat, long, the_geom)
    VALUES ('#{r[0]}', #{r[1]}, #{r[2]}, ST_SetSRID(ST_Point(#{r[2]}, #{r[1]}),4326))
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
