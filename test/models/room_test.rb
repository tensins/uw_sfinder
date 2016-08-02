require 'test_helper'

# tests for the model room
class RoomTest < ActiveSupport::TestCase
  
  def setup
    @offset = Time.now.utc_offset
    @room = Room.new(room_name:"MC 2065",classes:[{"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
     "weekdays"=>"F", "start_time"=>"17:00", "end_time"=>"21:50","start_date"=>"05/06","end_date"=>"05/06"},
     {"subject"=>"CS", "catalog_number"=>"221", "section"=>"LEC 004",
     "weekdays"=>"MTF", "start_time"=>"8:30", "end_time"=>"9:50","start_date"=>nil,"end_date"=>nil}],
     building:"MC")
  end

  # testing time_intersects function
  test "Intersects" do
  	class_sched = {"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
  	 "weekdays"=>"MTF", "start_time"=>"19:00", "end_time"=>"21:50","start_date"=>"05/06","end_date"=>"08/02"} 
  	test_time = Time.new(2016,7,4,19,15,0,@offset)
  	assert Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,4,19,0,0,@offset)
  	assert Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,8,2,19,59,59,@offset) # check different day
  	assert Room.time_intersects(class_sched,test_time)
    test_time = Time.new(2016,5,6,19,0,0,@offset) # check different day
    assert Room.time_intersects(class_sched,test_time)
  end

  test "Doesn't intersect: wrong day" do
  	class_sched = {"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
  	 "weekdays"=>"M", "start_time"=>"19:00", "end_time"=>"21:50","start_date"=>"05/06","end_date"=>"08/02"} 
  	test_time = Time.new(2016,7,5,19,15,0,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,6,19,0,0,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,7,21,50,0,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,8,21,50,0,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,9,21,50,0,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,10,21,50,0,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
    test_time = Time.new(2016,8,3,0,0,0,@offset)
    assert_not Room.time_intersects(class_sched,test_time)
  end

  test "Doesn't intersect: wrong time" do
  	class_sched = {"subject"=>"AFM", "catalog_number"=>"417", "section"=>"LEC 001",
  	 "weekdays"=>"MTTh", "start_time"=>"19:00", "end_time"=>"21:50","start_date"=>"05/06","end_date"=>"08/02"} 
  	test_time = Time.new(2016,7,4,18,59,59,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  	test_time = Time.new(2016,7,4,21,50,1,@offset)
  	assert_not Room.time_intersects(class_sched,test_time)
  end

  #testing is_vacant? function
  test "Is vacant" do
    assert @room.is_vacant?(Time.new(2016,5,6,14,59,59,@offset))
    assert @room.is_vacant?(Time.new(2016,5,6,16,51,0,@offset))
    assert @room.is_vacant?(Time.new(2016,5,7,17,30,0,@offset))
    assert @room.is_vacant?(Time.new(2016,5,6,16,51,0,@offset))
    assert @room.is_vacant?(Time.new(2016,5,7,8,29,59,@offset))
    assert @room.is_vacant?(Time.new(2016,5,7,22,0,1,@offset))
  end

  test "Isn't vacant" do
    assert_not @room.is_vacant?(Time.new(2016,5,6,20,0,0,@offset))
    assert_not @room.is_vacant?(Time.new(2016,5,2,9,0,0,@offset))
    assert_not @room.is_vacant?(Time.new(2016,7,11,9,0,0,@offset))
  end
end
