class AddTempToUsers < ActiveRecord::Migration
  def change
    add_column :users, :temp, :boolean, :default => false
  end
end
