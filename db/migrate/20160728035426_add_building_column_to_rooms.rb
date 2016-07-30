class AddBuildingColumnToRooms < ActiveRecord::Migration
  def change
  	add_column :rooms, :building, :string
  end
end
