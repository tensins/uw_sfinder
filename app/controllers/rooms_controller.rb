class RoomsController < ApplicationController

  # display all rooms
  def index
    @building = params[:building].split(' ')[0].upcase # remove leading and trail spaces
    
    @all_rooms = find_all_by("building",@building) # get all rooms in building
    #@all_rooms.each do |room|
     # @all_rooms.delete(room) if !(room.is_vacant? Time.now) # delete rooms that aren't vacant
    #end
    @all_rooms.delete_if {|room| !room.is_vacant? Time.now}
    @all_rooms = sort_by_time(@all_rooms) # sort the table according to start times
    @offset = Time.now.utc_offset
  end

  def home
  end 
end
