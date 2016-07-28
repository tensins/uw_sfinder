class Room < ActiveRecord::Base
	serialize :classes, Array # enforce an array as database entry
	validates :room_name, presence: true # ensure that the room name is not empty when creating a new room
	
end
