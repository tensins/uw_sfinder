module ApplicationHelper
	# find all database entries that have attribute equal to value
	# returns an array
	def find_all_by(attribute,value)
		matched_arr = []
		Room.all.each do |room|
			matched_arr << room if room[attribute] == value
		end
		return matched_arr
	end

	def sort_by_time(all_rooms) # sort the the class array by start times and also sort the rooms by 
		# their room numbers
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
	
end
