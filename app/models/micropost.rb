class Micropost < ActiveRecord::Base
  attr_accessible :content, :location, :time, :end_time, :latitude, :longitude
  serialize :invitees
  
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  
  #Setting time in the past is prohibitted
  validate :time_input_valid?

  #End times must be accompanied by start times
  validate :start_and_end_times?
  
  #Participations
  has_many :participations, dependent: :destroy

  #Post
  has_many :posts, dependent: :destroy
  
  #Proposal
  has_many :polls, dependent: :destroy
  
  #Characteristic
  has_many :characteristics, dependent: :destroy
  
  default_scope order: 'microposts.created_at DESC'
  
  #Before Destroy
  after_destroy do
	participations.delete
  end

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
  
  def after_post(post_id)
	self.posts.where("id > :id", {id: post_id})
  end
  
  def invited(user)
  	return !self.invitees[user.id].nil?
  end
  
  def to_mobile
	participants = []
  
	self.participations.each do |participation|
		participant = participation.user
		
		participants << {participant_id: participant.id, participant_name: participant.name, participant_picture: participant.avatar.url}
	end
  
  	{id: self.id, creator_picture: self.user.avatar.url, creator_id: self.user.id, creator_name: self.user.name, event_title: self.content, event_location: self.location, event_time: self.time, event_end_time: self.end_time, latitude: self.latitude, longitude: self.longitude, participations: participants}
  end
  
  #These are the actual participants in an event
  def non_creator_participants
  	participations.where("user_id != ?", self.user.id)
  end
  
  private

  def time_input_valid?
    if !time.nil? && (Time.current - time) > 180.0
		errors.add(:time, 'can not be set in the past') if (time.past?)
		return false
	end
  end
  
  def start_and_end_times?
	if time.nil? && end_time
		errors.add(:time, " must be present to have an end time")
		return false
	elsif time && end_time	
		if end_time < time
			errors.add(:time, " must be before the end time")
			return false
		end
	end
  end
  
  def self.from_users(users)
    where("user_id IN (?)", users).order("time DESC")
  end
end
