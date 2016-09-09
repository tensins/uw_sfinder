# change current term and run'rake db:seed' each new term to update the rooms and schedules
# also, change the Room.is_today? method's dates

apikey = "3b21abe0bcae9daa1bfdae8baee017db"
current_term = '1169'

def add_room(room_name,building,classes=[]) # function to add a room into the database
	room = Room.new(room_name:room_name,building:building,classes:classes)
	room.save
end

def get_building(room_name) # get the building name from the room name
	room_name.split(' ')[0]
end

def get_number(room_name)
	room_name.split(' ')[1]
end

# 1. get all the courses being offered this term
# 2. for each course, if the room they're held in is unique in the all_rooms array, insert it
# 3. for all rooms in the all_rooms array, add them in the database as well as their classes array
all_rooms = []
all_courses = ((HTTParty.get("https://api.uwaterloo.ca/v2/terms/#{current_term}/courses.json?
	key=#{apikey}")).parsed_response)["data"] # get the courses offered for the current term
all_courses.each do |course| # for each course, find where its held and insert it as a room if unique
	classes = ((HTTParty.get("https://api.uwaterloo.ca/v2/terms/#{current_term}/#{course['subject']}/#{course['catalog_number']}"\
	"/schedule.json?key=#{apikey}")).parsed_response)["data"] # get the data of all the sections of this particular course
	
	classes.each do |section| # for each section, get its location and add into all_rooms
		date = section['classes'][0]['date']
		location = section['classes'][0]['location']
		if !(date['is_cancelled'] || date['is_closed'] || (location['building']==nil) || date['is_tba']) # make sure
			room_name = "#{location['building']} #{location['room']}"
			all_rooms << room_name if !(all_rooms.include?(room_name))
		end
	end
end

all_rooms.each do |room| # for each room, want to get its schedule and pass the array as classes
	schedule = ((HTTParty.get("https://api.uwaterloo.ca/v2/buildings/#{get_building(room)}/#{get_number(room)}/"\
		"courses.json?key=#{apikey}")).parsed_response)["data"]
	schedule.map do |cl| # delete all the unwanted attributes of the has
		cl.delete("title")
		cl.delete("enrollment_total")
		cl.delete("instructors")
		cl.delete("building")
		cl.delete("room")
		cl.delete("term")
		cl.delete("last_updated")
	end
	add_room(room,get_building(room),schedule) # add the room to the database
end