class RemoveUserIdFromProposals < ActiveRecord::Migration
  def up
	remove_column :proposals, :user_id
  end

  def down
	add_column :proposals, :user_id, :integer
  end
end
