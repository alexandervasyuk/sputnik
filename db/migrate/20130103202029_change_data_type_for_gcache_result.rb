class ChangeDataTypeForGcacheResult < ActiveRecord::Migration
  def up
	change_table :gcaches do |t|
      t.change :result, :text
    end
  end

  def down
	change_table :gcaches do |t|
      t.change :result, :string
    end
  end
end
