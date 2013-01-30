class UpdatePollsTables < ActiveRecord::Migration
  def up
	add_column :proposals, :poll_id, :integer
	remove_column :proposals, :micropost_id
  end

  def down
	add_column :proposals, :micropost_id, :integer
	remove_column :proposals, :poll_id
  end
end
