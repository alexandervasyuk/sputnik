class AddIndexToMicroposts < ActiveRecord::Migration
  def change
	add_index :microposts, :updated_at
  end
end
