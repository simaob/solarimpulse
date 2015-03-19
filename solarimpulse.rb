#!/usr/bin/env ruby

require 'httparty'
require 'active_support/core_ext/numeric/time'


URL = "http://storage.googleapis.com/rtw-bucket/airplane/datas/datas_minute_"



#i = 180
#
#while(i>0) do
cartodb_url = "http://simbiotica.cartodb.com/api/v2/sql"
token = ""
table_name = "solarimpulse"

failures = 0
loop do
  time = 3.minutes.ago
  timestamp = time.strftime("%Y%m%d%H%M")
  url = URL+"#{timestamp}.json"

  begin
    puts url
    resp = JSON.parse(HTTParty.get(url).body)
#    output = "/Users/Simao/Dropbox/Professional/Simbiotica-Vizz/solarimpulse/output.csv"
#
#    CSV.open(output, "ab") do |csv|
#      csv << [time, resp['LA'], resp['LO']]
#    end
    total_bat = 0.0
    (1..4).each do |i|
      b_from = (((resp['B'+i.to_s]/38.5*100)*10).round/10);
      b_to = ((((resp['B'+i.to_s]+(resp['BC'+i.to_s]*resp['BV'+i.to_s]/1000))/38.5*100)*10).round/10)
      puts "Battery #{i.to_s} #{b_from} - #{b_to}"
      total_bat += b_to
    end
    avg_bat = total_bat/4
    puts "We have avg battery of #{avg_bat}"
    puts "#{resp['TIME']}, #{resp['LA']}, #{resp['LO']}, #{avg_bat}"
    sql = <<-SQL
      INSERT INTO #{table_name} (time, lat, long, the_geom, avg_bat)
      VALUES ('#{time}', #{resp['LA']}, #{resp['LO']},
      ST_SetSRID(ST_Point(#{resp['LO']}, #{resp['LA']}),4326), #{avg_bat})
    SQL

    options = {
      body: {
        api_key: token,
        q: sql
      }
    }

    puts options[:body][:q]

    puts "saving to cartodb"
    a = HTTParty.post(cartodb_url, options)

    puts a
  rescue Exception => e
    puts "FAILED: #{e.message}"
    if failures == 3
      puts "I'll sleep for a bit"
      sleep(60*5)
      failures = 0
    else
      failures += 1
    end
  end
  sleep(60)
  #i = i-1
end

