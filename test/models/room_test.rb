require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  
  # testing time_intersects function
  test "Intersects" do
  	class_sched = {"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
  	 "weekdays"=>"MTTh", "start_time"=>"19:00", "end_time"=>"21:50"} 
  	test_time = Time.new(2016,7,4,19,15,0,Time.now().utc_offset)
  	assert Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,4,19,0,0,Time.now().utc_offset)
  	assert Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,4,21,50,0,Time.now().utc_offset)
  	assert Room.time_intersects(class_sched,test_time)
  end

  test "Doesn't intersect: wrong day" do
  	class_sched = {"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
  	 "weekdays"=>"M", "start_time"=>"19:00", "end_time"=>"21:50"} 
  	test_time = Time.new(2016,7,5,19,15,0,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,6,19,0,0,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,7,21,50,0,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,8,21,50,0,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,9,21,50,0,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,10,21,50,0,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  end

  test "Doesn't intersect: wrong time" do
  	class_sched = {"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
  	 "weekdays"=>"MTTh", "start_time"=>"19:00", "end_time"=>"21:50"} 
  	test_time = Time.new(2016,7,4,18,59,59,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,4,21,50,1,Time.now().utc_offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  end

  #testing is_vacant? function
  
end
