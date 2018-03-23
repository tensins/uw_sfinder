class RoomsController < ApplicationController
  include RoomsHelper
  # display all rooms
  def index
    # indicates the building queried in the get request
    @inp = params[:building].upcase
    
    # gets the rooms for this building and as well as if they are vacant or not
    @curr_time = toronto_time(Time.now())
    rooms, @vacancy = get_rooms(@inp, @curr_time)
    @vacant_rooms = []
    for i in 0...@vacancy.length
      if @vacancy[i].nil?
        next
      end
      @vacant_rooms.push(@vacancy[i])
    end
  end

  # action for home page which contains rooms that are curently vacant 
  # for the longest time
  def main
    # fetch all the buildings
    @buildings = get_buildings()
    
  end

end
