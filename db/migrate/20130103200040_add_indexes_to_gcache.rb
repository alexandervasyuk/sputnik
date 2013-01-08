class AddIndexesToGcache < ActiveRecord::Migration
  def change
	add_index :gcaches, :input
  end
end
