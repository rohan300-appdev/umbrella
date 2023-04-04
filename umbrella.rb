require "open-uri"
require "json"
require "date"

puts "Where are you?"

user_loc = gets.chomp
# user_loc = "chicago"

gmap_key = ENV.fetch("GMAPS_KEY")
weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

puts "Checking the weather at " + user_loc +"...."

coordinates_uri = URI.open("https://maps.googleapis.com/maps/api/geocode/json?address=#{user_loc}o&key=#{gmap_key}")

parse_coordinates = JSON.parse(coordinates_uri.read)

latitude = parse_coordinates["results"][0]["geometry"]["location"]["lat"]
longitude = parse_coordinates["results"][0]["geometry"]["location"]["lng"]

puts "Your coordinates are #{latitude}, #{longitude}."

weather_uri = URI.open("https://api.pirateweather.net/forecast/#{weather_key}/#{latitude},#{longitude}")


parse_weather = JSON.parse(weather_uri.read)

temp = parse_weather["currently"]["temperature"]

puts "It is currently #{temp}°F"

current_time = Time.at(parse_weather["currently"]["time"])

hourly_weather = parse_weather['hourly']

flag = true
data = hourly_weather['data']
0.upto(12) do |hour_weather_ind|
  hour_weather = data[hour_weather_ind]
  if hour_weather["precipProbability"] > 0.1
    if flag
      puts "Next hour: Rain"
      flag = false
    end
    time_difference = ((Time.at(hour_weather["time"]) - current_time)/(60 * 60)).to_i
    puts "In #{time_difference} hours, there is a #{(hour_weather["precipProbability"] * 100).to_i}% chance of precipitation."
  end
end
if flag
  puts "Next hour: Clear"
  puts "You probably won't need an umbrella."
else
  puts "You might want to take an umbrella!"
end
