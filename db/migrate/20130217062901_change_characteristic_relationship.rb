class ChangeCharacteristicRelationship < ActiveRecord::Migration
  def up
	rename_column :characteristics, :micropost_id, :characteristics_app_id
  end

  def down
	rename_column :characteristics, :characteristics_app_id, :micropost_id
  end
end
