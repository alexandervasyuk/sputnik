class UpdateIndexOnGcaches < ActiveRecord::Migration
  def up
	add_index :gcaches, [:term, :name, :search_latitude, :search_longitude, :latitude, :longitude], unique: true, name: "primary_index"
	remove_index :gcaches, [:term, :search_latitude, :search_longitude]
  end

  def down
	add_index :gcaches, [:term, :search_latitude, :search_longitude], unique: true
	remove_index :gcaches, name: "primary_index"
  end
end
