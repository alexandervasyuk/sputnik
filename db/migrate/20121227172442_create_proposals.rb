class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.string :content
      t.string :location
      t.datetime :time
      t.integer :user_id
      t.integer :micropost_id
	  t.integer :votes

      t.timestamps
	  
	add_index :proposals, :user_id
	add_index :proposals, :micropost_id
	add_index :proposals, [:user_id, :micropost_id], unique: true
    end
  end
end
