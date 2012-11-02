class AddColumnsToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :friend_status, :string
    add_column :relationships, :follow1, :boolean
    add_column :relationships, :follow2, :boolean
  end
end
