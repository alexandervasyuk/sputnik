class Notification < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  validates :user_id, presence: true
  validates :read, presence: true
  validates :message, presence: true
end
