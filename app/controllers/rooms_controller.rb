class RoomsController < ApplicationController
  # the index action
  def home
  	@all_rooms = []
  end

  # find all empty rooms in the building submitted in the form
  def find
  	@building = params[:text].split(' ')[0].upcase # remove leading and trail spaces
    
    @all_rooms = find_all_by("building",@building)
   	@all_rooms.each do |room|
   		@all_rooms.delete(room) if !(room.is_vacant?) # delete rooms that aren't vacant
    end
  	render 'home'
  end

  def show # show a specific room that's been clicked

  end

end
