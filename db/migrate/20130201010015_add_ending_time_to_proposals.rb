class AddEndingTimeToProposals < ActiveRecord::Migration
  def change
	add_column :proposals, :end_time, :datetime
  end
end
