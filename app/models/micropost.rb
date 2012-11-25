class Micropost < ActiveRecord::Base
  attr_accessible :content, :location, :time
  serialize :invitees
  
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :time, presence: true
  validates :location, presence: true, length: { maximum: 60 }

  #Setting time in the past is prohibitted
  validate :happened_in_the_past?

  #Participations
  has_many :participations, dependent: :destroy

  #Post
  has_many :posts, dependent: :destroy
  
  default_scope order: 'microposts.created_at DESC'

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
  
  def add_to_invited(user)
  	self.invitees[user.id] = 1
  	
  	update_attribute(:invitees, self.invitees)
  end
  
  def invited(user)
  	return !self.invitees[user.id].nil?
  end
  
  private

  def happened_in_the_past? 
    if !time.nil?
      (return false) if ((Time.current() - time) < 180.0)
      errors.add(:time, 'can not be set in the past') if (time.past?)
    end
  end
  
  def self.from_users(users)
    where("user_id IN (?)", users)
  end
end
