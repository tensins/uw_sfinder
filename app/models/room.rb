class Room < ActiveRecord::Base
	serialize :classes, Array # enforce an array as database entry
	validates :room_name, presence: true, uniqueness: true
	validates :building, presence: true

	def is_vacant?(curr_time) # determine if the room is currently vacant (meaning no class is currently being held in there)
		curr_hour = curr_time.hour
		curr_min = curr_time.min
		curr_sec = curr_time.sec
		earliest_time = Time.new(curr_time.year,curr_time.month,curr_time.day,8,30,0,curr_time.utc_offset)
		latest_time = Time.new(curr_time.year,curr_time.month,curr_time.day,22,0,0,curr_time.utc_offset)
		
		# by doing this we save some computation time (probably not even noticable but still included)
		return true if !(curr_time.between? earliest_time,latest_time)
		
		# now check if any classes coincide with the current time
		self.classes.each do |a_class|
			return false if Room.time_intersects(a_class,curr_time)
		end
		return true
	end
	
	# ex. class_sched = {"subject"=>"AFM",...,"weekdays"=>"MWTh","start_time"=>"19:00","end_time"=>"21:50"}
	# ex. curr_time = Time.now
	def Room.time_intersects(class_sched,curr_time) # see if the current time intersects with the class schedule
		# first see if the day intersects
		return false if (!Room.is_today?(class_sched,curr_time) || 
						  Room.is_ended?(class_sched,curr_time)) # return false immediately if the class is not today or
		# the class has already ended for the term

		# now see if the time intersects
		start_hour = class_sched["start_time"].split(':')[0].to_i 
		start_min =  class_sched["start_time"].split(':')[1].to_i
		end_hour = class_sched["end_time"].split(':')[0].to_i
		end_min = class_sched["end_time"].split(':')[1].to_i

		# to_i gives the milliseconds since January 1 , 1970
		start_time = Time.new(curr_time.year,curr_time.month,curr_time.day,start_hour,start_min,
			0,curr_time.utc_offset)
		end_time = Time.new(curr_time.year,curr_time.month,curr_time.day,end_hour,end_min,
			0,curr_time.utc_offset)
		return curr_time.between? start_time,end_time
	end
	# returns true if the class occurs today
	def Room.is_today?(class_sched,curr_time)
		curr_day = curr_time.wday
		case curr_day 
			when 1; curr_day="M"
			when 2; curr_day="T"
			when 3; curr_day="W"
			when 4; curr_day="Th"
			when 5; curr_day="F"
		else; return false
		end

		wday_array = [] # array of when class occurs
		wday_str = class_sched["weekdays"].dup
		
		if wday_str.include? "Th"
			wday_array << "Th"
			wday_str.slice! "Th"
		end
		wday_str = wday_str.split('')
		wday_str.each {|char| wday_array << char}
		return wday_array.include? curr_day # if the current day is in the array return true
	end
 
 	# return false if the current date is within the start and end dates
	def Room.is_ended?(class_sched,curr_time)
		# ** should update these values each new term **
		start_date = (class_sched["start_date"] == nil)? Time.new(2017,5,1,0,0,0,curr_time.utc_offset):
						Time.new(2017,class_sched["start_date"].split("/")[0].to_i,
							class_sched["start_date"].split("/")[1].to_i,0,0,0,curr_time.utc_offset) 
							#start date of course
		end_date = (class_sched["end_date"] == nil)? Time.new(2017,7,25,23,59,59,curr_time.utc_offset):
						Time.new(2017,class_sched["end_date"].split("/")[0].to_i,
							class_sched["end_date"].split("/")[1].to_i,23,59,59,curr_time.utc_offset) 
							# end date of course
		return !(curr_time.between? start_date,end_date) # means the classes have not yet ended
	end
end