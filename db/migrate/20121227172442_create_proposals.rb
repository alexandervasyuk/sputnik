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
    end
  end
end
