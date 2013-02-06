class CreateCharacteristicsUsersJoinTable < ActiveRecord::Migration
 def up
	create_table :characteristics_users, :id => false do |t|
	  t.references :characteristic, :user
	end

	add_index :characteristics_users, [:characteristic_id, :user_id]
  end

  def down
	drop_table :characteristics_users
  end
end
