class AddInviteesToMicropost < ActiveRecord::Migration
  def change
    add_column :microposts, :invitees, :text
  end
end
