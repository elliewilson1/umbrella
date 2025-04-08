# Write your solution here!

require "http"
require "json"
require "dotenv/load"

line_width = 40
puts "=" * line_width
puts "Will you need an umbrella today?".center(line_width)
puts "=" * line_width
puts

puts "Where are you located?"

# user_location = gets.chomp
user_location = "Miami"

puts "Checking the weather at #{user_location}...."

maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + ENV.fetch("GMAPS_KEY")

resp = HTTP.get(maps_url)

raw_response = resp.to_s

parsed_response = JSON.parse(raw_response)

results = parsed_response.fetch("results")

first_result = results.at(0)

geo = first_result.fetch("geometry")

loc = geo.fetch("location")

latitude = loc.fetch("lat")
longitude = loc.fetch("lng")

puts "Your coordinates are #{latitude}, #{longitude}."

# Take the lat/long
# Assemble the correct URL for the Pirate Weather API
# Get it, parse it, and dig out the current temperature

pirate_weather_url = "https://api.pirateweather.net/forecast/" + ENV.fetch("PIRATE_WEATHER_KEY") + "/#{latitude},#{longitude}"

resp = HTTP.get(pirate_weather_url)

raw_response = resp.to_s

parsed_response = JSON.parse(raw_response)

current = parsed_response.fetch("currently")
hourly = parsed_response.fetch("hourly")
# hours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
rain = hourly.fetch("data").at(0).fetch("precipProbability") * 100
# puts rain.to_i.to_s + "%"

temp = current.fetch("temperature")

next_hour = hourly.fetch("summary")

puts "It is currently #{temp}°F."
puts "Next hour: #{next_hour}"

# puts "In #{} hours, there is a #{} chance of precipitation."

if rain > 0
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end 
