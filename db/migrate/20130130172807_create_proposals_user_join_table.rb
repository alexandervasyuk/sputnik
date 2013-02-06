class CreateProposalsUserJoinTable < ActiveRecord::Migration
  def up
	create_table :proposals_users, :id => false do |t|
	  t.references :proposal, :user
	end

	add_index :proposals_users, [:proposal_id, :user_id]
  end

  def down
	drop_table :proposals_users
  end
end
