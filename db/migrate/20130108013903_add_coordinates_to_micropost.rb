class AddCoordinatesToMicropost < ActiveRecord::Migration
  def change
	add_column :microposts, :latitude, :decimal
	add_column :microposts, :longitude, :decimal
  end
end
