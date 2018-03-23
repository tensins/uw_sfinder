# change current term and run 'heroku run rake db:seed' each new term to update the rooms and schedules
# also, change the Room.is_today? method's dates

apikey = "3b21abe0bcae9daa1bfdae8baee017db"
# term is '1' + [year] + [start_month]
current_term = '1181'

def add_room(room_name,building,classes=[]) # function to add a room into the database
	room = Room.new(room_name:room_name,building:building,classes:classes)
	if room.valid?
		puts("saved")
	end
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

all_rooms = Hash.new()

i = 0
all_courses = ((HTTParty.get("https://api.uwaterloo.ca/v2/terms/#{current_term}/\
courses.json?key=#{apikey}")).parsed_response)["data"]
all_courses.each do |course|
	if i == 100
		break
	end
	i += 1
	# get schedule for the course this term
	puts("https://api.uwaterloo.ca/v2/terms/#{current_term}/\
#{course['subject']}/#{course['catalog_number']}/schedule.json?key=#{apikey}")
	classes = ((HTTParty.get("https://api.uwaterloo.ca/v2/terms/#{current_term}/\
#{course['subject']}/#{course['catalog_number']}/schedule.json?key=#{apikey}"))
	.parsed_response)["data"] 
	
	classes.each do |section|
		date = section['classes'][0]['date']
		location = section['classes'][0]['location']
		if !(date['is_cancelled'] || date['is_closed'] || (location['building']==nil) || date['is_tba'])
			room_name = "#{location['building']} #{location['room']}"
			if all_rooms[room_name].nil?
				all_rooms[room_name] = true
			end
		end
	end
end

all_rooms.each do |room, garbage|
	schedule = ((HTTParty.get("https://api.uwaterloo.ca/v2/\
buildings/#{get_building(room)}/#{get_number(room)}/\
courses.json?key=#{apikey}")).parsed_response)["data"]

	 # delete all the unwanted attributes from request
	schedule.map do |cl|
		cl.delete("title")
		cl.delete("enrollment_total")
		cl.delete("instructors")
		cl.delete("building")
		cl.delete("room")
		cl.delete("term")
		cl.delete("last_updated")
	end
	
	add_room(room, get_building(room), schedule)
end