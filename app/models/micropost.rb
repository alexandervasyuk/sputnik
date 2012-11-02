class Micropost < ActiveRecord::Base
  attr_accessible :content, :location, :time
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :time, presence: true
  validates :location, presence: true, length: { maximum: 60 }

  default_scope order: 'microposts.created_at DESC'

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
  
  def self.from_users(users)
    where("user_id IN (?)", users)
  end
end
