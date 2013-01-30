class AddFieldsToGcaches < ActiveRecord::Migration
  def change
	add_column :gcaches, :term, :string
	add_column :gcaches, :search_latitude, :decimal
	add_column :gcaches, :search_longitude, :decimal
	add_column :gcaches, :rank, :decimal
	
	add_index :gcaches, [:term, :search_latitude, :search_longitude], unique: true
  end
end
