class Room < ActiveRecord::Base
	serialize :classes, Array # enforce an array as database entry
	validates :room_name, presence: true, uniqueness: true
	validates :building, presence: true

	# determine if the room is currently vacant 
	# (meaning no class is currently being held in there)
	def is_vacant?(curr_time) 
		curr_hour = curr_time.hour
		curr_min = curr_time.min
		curr_sec = curr_time.sec
		earliest_time = Time.new(curr_time.year,curr_time.month,curr_time.day,8,30,0,curr_time.utc_offset)
		latest_time = Time.new(curr_time.year,curr_time.month,curr_time.day,22,0,0,curr_time.utc_offset)

		# check if too early or too late for classes
		return true, nil if !(curr_time.between? earliest_time,latest_time)
		
		class_sched = complete_sched(curr_time)

		# now check if any classes coincide with the current time
		vacant = false
		n = class_sched.length
		next_class_time = nil
		for i in 0...n
			vacant = !Room.time_intersects(class_sched[i], curr_time)
			hour = class_sched[i]["start_time"].split(':')[0].to_i
			min = class_sched[i]["start_time"].split(':')[1].to_i
			seconds = 0
			class_time = Time.new(curr_time.year, curr_time.month, curr_time.day, hour, min, seconds,
				curr_time.utc_offset)
			
			if !vacant
				return vacant, next_class_time
			end

			if curr_time < class_time
				next_class_time = class_time
				break
			end
		end

		return true, next_class_time
	end
	
	# ex. class_sched = {"subject"=>"AFM",...,"weekdays"=>"MWTh","start_time"=>"19:00","end_time"=>"21:50"}
	# ex. curr_time = Time.now
	def Room.time_intersects(class_sched, curr_time) # see if the current time intersects with the class schedule
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
		else
			return false
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
	def Room.is_ended?(class_sched, curr_time)
		start_date = (class_sched["start_date"] == nil)? Time.new(2018,1,4,0,0,0,curr_time.utc_offset):
						Time.new(2017,class_sched["start_date"].split("/")[0].to_i,
							class_sched["start_date"].split("/")[1].to_i,0,0,0,curr_time.utc_offset) 
							#start date of course
		end_date = (class_sched["end_date"] == nil)? Time.new(2018,7,3,23,59,59,curr_time.utc_offset):
						Time.new(2017,class_sched["end_date"].split("/")[0].to_i,
							class_sched["end_date"].split("/")[1].to_i,23,59,59,curr_time.utc_offset) 
							# end date of course
		return !(curr_time.between? start_date,end_date) # means the classes have not yet ended
	end

	

	private
	# returns the complete schedule for the current room for today's date
	def complete_sched(curr_time)
		rt_sched = []

		# go through each class
		self.classes.each do |class_i|
			if Room.is_today?(class_i, curr_time)
				rt_sched.push(class_i)
			end
		end
		sort_class(rt_sched)
		return rt_sched
	end


	
	# sort a schedule
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