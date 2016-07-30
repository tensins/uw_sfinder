class Room < ActiveRecord::Base
	serialize :classes, Array # enforce an array as database entry
	validates :room_name, presence: true, uniqueness: true
	validates :building, presence: true

	def is_vacant? # determine if the room is currently vacant (meaning no class is currently being held in there)
		curr_time = Time.now
		curr_hour = curr_time.hour
		curr_min = curr_time.min
		curr_sec = curr_time.sec
		curr_time_se = curr_time.to_i
		earliest_time = Time.new(curr_time.year,curr_time.month,curr_time.day,8,30,0,curr_time.utc_offset).to_i
		latest_time = Time.new(curr_time.year,curr_time.month,curr_time.day,22,0,0,curr_time.utc_offset).to_i
		return true if ((curr_time_se < earliest_time) || (curr_time_se > latest_time))
		self.classes.each do |a_class| # determine if the current time coincides with any classes schedule
			return false if Room.time_intersects(a_class,curr_time) 
		end
		return true
	end

	# ex. class_sched = {"subject"=>"AFM",...,"weekdays"=>"MWTh","start_time"=>"19:00","end_time"=>"21:50"}
	# ex. curr_time = Time.now
	def Room.time_intersects(class_sched,curr_time)
		# first see if the day intersects
		curr_day = curr_time.wday # the day of the week 0-6. 0 for sunday
		case curr_day # set today's wday appropriately. (god bless ruby's dynamic typing)
			when 1; curr_day="M"
			when 2; curr_day="T"
			when 3; curr_day="W"
			when 4; curr_day="Th"
			when 5; curr_day="F"
		else; return false # if it's currently a weekend, just return false(no classes on weekends)
		end

		wday_array = [] # array for the days the class occurs
		wday_str = class_sched["weekdays"]
		
		if wday_str.include? "Th"
			wday_array << "Th"
			wday_str.slice! "Th"
		end
		
		wday_str = wday_str.split('')
		wday_str.each {|char| wday_array << char}

		return false if !(wday_array.include? curr_day) # if it occurs on a different day, return false

		#now see if the time intersects
		start_hour = class_sched["start_time"].split(':')[0].to_i 
		start_min =  class_sched["start_time"].split(':')[1].to_i
		end_hour = class_sched["end_time"].split(':')[0].to_i
		end_min = class_sched["end_time"].split(':')[1].to_i

		# to_i gives the milliseconds since January 1 , 1970
		start_time = Time.new(curr_time.year,curr_time.month,curr_time.day,start_hour,start_min,
			0,curr_time.utc_offset).to_i
		end_time = Time.new(curr_time.year,curr_time.month,curr_time.day,end_hour,end_min,
			0,curr_time.utc_offset).to_i
		curr_time = curr_time.to_i 
		return true if (curr_time>=start_time)&&(curr_time<=end_time)
		return false
	end

end