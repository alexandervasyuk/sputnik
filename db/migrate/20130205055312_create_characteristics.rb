class CreateCharacteristics < ActiveRecord::Migration
  def change
    create_table :characteristics do |t|
	  t.integer :micropost_id
	  t.string :characteristic
	
      t.timestamps
    end
  end
end
