class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
	  t.integer :micropost_id
	  t.string :type
	
      t.timestamps
    end
  end
end
