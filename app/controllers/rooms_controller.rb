class RoomsController < ApplicationController

  # display all rooms
  def index
    # get the building passed in
    @building = params[:building].split(' ')[0].upcase # remove leading and trail spaces
    # get all valid rooms in that building
    @all_rooms = find_all_by("building",@building) # get all rooms in building
    @all_rooms.delete_if {|room| !room.is_vacant? Time.now()}
    @all_rooms = sort_by_time(@all_rooms) # sort the table according to start times
  end

  def home
  end 
end
