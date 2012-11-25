class MofidyReadFieldInNotifications < ActiveRecord::Migration
  def change
  	change_column :notifications, :read, :boolean, default:false, null:false
  end
end
