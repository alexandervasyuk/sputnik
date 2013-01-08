class UpdateGcache < ActiveRecord::Migration
  def up
	change_table :gcaches do |t|
		t.string :name, :address
		t.decimal :longitude, :latitude
		t.remove :input, :result
	end
  end

  def down
	change_table :gcaches do |t|
		t.string :input
		t.text :result
		t.remove :name, :address, :longitude, :latitude
		t.index :input
	end
  end
end
