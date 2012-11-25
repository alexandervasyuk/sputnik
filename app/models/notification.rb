class Notification < ActiveRecord::Base
  attr_accessible :user_id, :message, :link
  belongs_to :user

  validates :user_id, presence: true
  # validates :read, presence: true This gives an error for some reason
  validates :message, presence: true
end
