class AddColumnsToMicroposts < ActiveRecord::Migration
  def change
  	add_column :microposts, :location, :string
  	add_column :microposts, :time, :timestamp
  end
end
