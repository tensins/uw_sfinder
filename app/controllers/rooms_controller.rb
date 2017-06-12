class RoomsController < ApplicationController

  # display all rooms
  def index
    # get the building passed in
    inp = params[:building]
    # @home will be used to determine if user just arriving at home page
    @home = inp.nil?
    if !@home
      inp_arr = inp.split(' ')
      @all_rooms = []
      @curr_time = Time.now.in_time_zone('Eastern Time (US & Canada)')
      @building = inp_arr[0].upcase # remove leading and trail spaces
      if (inp_arr.length > 1)
        @room_name = @building + " " + inp_arr[1]
        @room = Room.find_by(room_name:@room_name)
        @all_rooms << @room unless @room.nil?
        @all_rooms = sort_by_time(@all_rooms)
        @building = inp
      else
        # get all valid rooms in that building
        @all_rooms = find_all_by("building",@building) # get all rooms in building
        @all_rooms.delete_if {|room| !room.is_vacant? @curr_time}
        @all_rooms = sort_by_time(@all_rooms) # sort the table according to start times
      end
    end
  end

end
