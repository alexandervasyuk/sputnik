class Micropost < ActiveRecord::Base
  attr_accessible :content, :location, :time
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

  private

  def happened_in_the_past?
    if !time.nil?
      errors.add(:time, 'Time can not be set in the past') if (time.past?)
    end
  end
end
