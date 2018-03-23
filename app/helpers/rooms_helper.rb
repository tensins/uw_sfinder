module RoomsHelper
	# gets all buildings
	# returns the building
	def get_buildings()
		# gets all the buildings used for classes / tutorials
		building_names = Room.select("building").distinct.order("building ASC")
		return building_names
	end 

	# gets rooms for  building
	# returns the room names as well as a bool array indicating if they're 
	# vacant or not
	def get_rooms(building, curr_time)
		rooms = Room.where(building: building).order("room_name ASC")
		vacancy = []

		# for each room, determine whether it's vacant or not
		sort_by_time(rooms)
		rooms.each do |room|
			vacant, next_time = room.is_vacant?(curr_time)
			if !vacant
				vacancy.push(nil)
			else
				if next_time.nil?
					# indiciates rest of day is free for this room
					vacancy.push({room_name: room.room_name, classes: room.classes, hours: -1})
				else
					hours, mins, seconds = time_until(curr_time, next_time)
					vacancy.push({room_name: room.room_name, classes: room.classes, 
						hours: hours, mins: mins, seconds: seconds})
				end
			end
		end
		
		return rooms, vacancy
	end


	def all_nil?(arr)
		arr.each do |element|
			if !element.nil?
				return false
			end
		end

		return true
	end

	# sort the the class array by start times and also sort the rooms by 
	# their room numbers
	def sort_by_time(all_rooms) 
		all_rooms = all_rooms.map do |room|
			sort_class(room.classes) # returns the sorted the classes of each room
			room
		end

		all_rooms.sort_by! do |room|
			room[:room_name].split(' ')[1].to_i
		end
	end


	def sort_class(all_classes) # sort all classes for a particular room
		all_classes.sort! do |class_1,class_2|
			class_1_hour = class_1["start_time"].split(":")[0].to_i
			class_1_min = class_1["start_time"].split(":")[1].to_i
			class_2_hour = class_2["start_time"].split(":")[0].to_i
			class_2_min = class_2["start_time"].split(":")[1].to_i
			Time.new(2016,1,1,class_1_hour,class_1_min,0,0).to_i <=>
			Time.new(2016,1,1,class_2_hour,class_2_min,0,0).to_i
		end
	end


	# will convert Time object that's in utc +0000 to -0500 ie. EST
	def toronto_time(curr_time)
		# have to go previous date
		return curr_time - 5.hour
	end


	# count how long we have until next time
	# 4:50:20 - 6:20:01 = 1:29:39
	def time_until(curr_time, next_time)
		time_diff = next_time - curr_time
		hours = (time_diff/3600).floor % 24
		time_diff -= hours * 3600
		minutes = (time_diff/60).floor % 60
		time_diff -= minutes * 60
		seconds = time_diff % 60

		return hours, minutes, seconds
	end
end
