class CreateGcaches < ActiveRecord::Migration
  def change
    create_table :gcaches do |t|
	  t.string :input
	  t.string :result
      t.timestamps
    end
  end
end
