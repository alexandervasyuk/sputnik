class CreateCharacteristicsApps < ActiveRecord::Migration
  def change
    create_table :characteristics_apps do |t|
	  t.integer :micropost_id
	
      t.timestamps
    end
  end
end
