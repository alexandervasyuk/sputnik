class AddIndexesToProposal < ActiveRecord::Migration
  def change
	add_index :proposals, :user_id
	add_index :proposals, :micropost_id
	add_index :proposals, [:user_id, :micropost_id], unique: true
  end
end
