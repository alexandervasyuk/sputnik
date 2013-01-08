class CreateUserGcaches < ActiveRecord::Migration
  def change
    create_table :user_gcaches do |t|
	  t.integer :gcach_id
	  t.integer :user_id
      t.timestamps
    end
	
	add_index :user_gcaches, :gcach_id
	add_index :user_gcaches, :user_id
	add_index :user_gcaches, [:user_id, :gcach_id], unique: true
  end
end
