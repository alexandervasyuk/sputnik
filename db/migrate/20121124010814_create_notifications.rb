class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.integer :user_id 
    	t.boolean :read
    	t.string :message
      t.timestamps
    end
    add_index :notifications, :user_id
  end
end
