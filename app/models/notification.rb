class Notification < ActiveRecord::Base
  attr_accessible :user_id, :message, :link
  belongs_to :user

  validates :user_id, presence: true
  # validates :read, presence: true This gives an error for some reason
  validates :message, presence: true
  
  def to_mobile
	{id: self.id, message: self.message, link: self.link}
  end
  
  def unread?
	return !read
  end
end
