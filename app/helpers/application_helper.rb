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
end
