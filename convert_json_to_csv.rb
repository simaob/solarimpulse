#!/usr/bin/env ruby


require 'date'
require 'csv'
require 'json'


j = JSON.parse(File.open("output_from_console_full2.json").read)


CSV.open("new_output.csv", "w") do |csv|
  j.each do |r|

    date_formatted = DateTime.strptime(r['TIME'].to_s, '%s').
      strftime("%Y-%m-%dT%H:%M:00Z")

    total_bat = 0.0
    (1..4).each do |i|
      b_from = (((r['B'+i.to_s].to_f/38.5*100)*10).round/10);
      b_to = ((((r['B'+i.to_s].to_f+(r['BC'+i.to_s].to_f*r['BV'+i.to_s].to_f/1000))/38.5*100)*10).round/10)
      total_bat += b_to
    end

    avg_bat = total_bat/4

    # time, lat, long, avg_bat
    csv << [date_formatted, r['LA'], r['LO'], avg_bat]
  end
end
