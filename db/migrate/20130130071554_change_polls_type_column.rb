class ChangePollsTypeColumn < ActiveRecord::Migration
  def up
	rename_column :polls, :type, :poll_type
  end

  def down
	rename_column :polls, :poll_type, :type
  end
end
