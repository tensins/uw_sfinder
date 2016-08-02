class RoomsController < ApplicationController
  def home
  end

  # find all empty rooms in the building submitted in the form
  def find
  	@building = params[:building].split(' ')[0].upcase # remove leading and trail spaces
    
    @all_rooms = find_all_by("building",@building)
   	@all_rooms.each do |room|
   		@all_rooms.delete(room) if !(room.is_vacant?(Time.new(2016,7,11,9,0,0,Time.now.utc_offset))) # delete rooms that aren't vacant
    end
    @all_rooms = sort_by_time(@all_rooms) # sort the table according to start times
  	render 'index'
  end

  # display all rooms
  def index
  	@all_rooms = []
  end

  def show

  end

end
