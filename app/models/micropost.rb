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
  has_one :characteristics_app, dependent: :destroy
  
  default_scope order: 'microposts.created_at DESC'
  
  # ActiveRecord Hooks
  before_save do
	# Make sure that the invitees are set
	if !self.invitees
		self.invitees = {}
	end
  end
  
  # Instance Methods
  
  # Adds the specified user to the invited list
  def add_to_invited(user)
	if user && !user.new_record?
		self.invitees[user.id] = 1
		
		update_attribute(:invitees, self.invitees)
	end
  end
  
  # Gives the number of invitees that are in this micropost
  def num_invitees
	self.invitees.keys.count
  end
  
  #  Checks if the given user is invited to this micropost
  def invited?(user)
  	return self.invitees[user.id]
  end
  
  def to_mobile
	participants = []
  
	self.participations.each do |participation|
		participant = participation.user
		
		participants << {participant_id: participant.id, participant_name: participant.name, participant_picture: participant.avatar.url}
	end
  
  	{id: self.id, creator_picture: self.user.avatar.url, creator_id: self.user.id, creator_name: self.user.name, event_title: self.content, event_location: self.location, event_time: self.time, event_end_time: self.end_time, latitude: self.latitude, longitude: self.longitude, participations: participants}
  end
  
  def posts_to_mobile
	posts.collect { |post| post.to_mobile }
  end
  
  def participating_users
	participants = []
  
	participations.each do |participation|
		participants << User.find(participation.user_id)
	end
	
	return participants
  end
  
  #These are the actual participants in an event
  #def non_creator_participants
  #	participations.where("user_id != ?", self.user.id)
  #end
  
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
