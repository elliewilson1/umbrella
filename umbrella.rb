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
minutely = parsed_response.fetch("minutely")
hourly_data = hourly.fetch("data")

temp = current.fetch("temperature")
next_hour_summary = minutely.fetch("summary")

puts "It is currently #{temp}°F."
puts "Next hour: #{next_hour_summary}"

# This flag will help us later decide if we need to suggest an umbrella
any_precipitation = false

# Loop through each hour in the hourly data array
next_twelve_hours = hourly_data[1..12]
next_twelve_hours.each do |hour_data|
  precip_chance = hour_data.fetch("precipProbability") * 100
  
  # Only output the message if the chance is above 0%
  if precip_chance > 10
    # Convert the epoch time into a Time object
    forecast_time = Time.at(hour_data.fetch("time"))
    
    # Determine the number of hours from now
    hours_from_now = ((forecast_time - Time.now) / 3600).round
    puts "In #{hours_from_now} hours, there is a #{precip_chance.to_i}% chance of precipitation."
    
    any_precipitation = true
  end
end

if any_precipitation
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end
