class AddLinkToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :link, :string, default: ''
  end
end
