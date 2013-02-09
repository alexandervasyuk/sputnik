class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :avatar, :temp
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  
  #Additional Attributes
  has_secure_password

  has_attached_file :avatar, styles: {medium: "300x300>", thumb: "52x52>"}, 
     :path => ":rails_root/public/assets/profile/:id/:style/:basename.:extension",
     :processors => [:cropper],
     :storage => :s3,
     :s3_credentials => "#{Rails.root}/config/s3.yml",
     default_url: "default_profile.jpg"
    
  #Associations

  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  #Participation
  has_many :participations, dependent: :destroy
  has_many :followed_posts, through: :participations, source: :micropost

  #Posts
  has_many :posts, dependent: :destroy

  #Notifications
  has_many :notifications, dependent: :destroy

  #Proposals
  has_and_belongs_to_many :proposals
  
  #Characteristics
  has_and_belongs_to_many :characteristics
  
  #Gcaches
  has_many :user_gcaches
  has_many :gcaches, through: :user_gcaches
  
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  #Validations
  validates :name,  presence: true, length: { maximum: 50 }, unless: :temp?
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, unless: :temp?
  validates :password_confirmation, presence: true, unless: :temp?
  
  validates_attachment_content_type :avatar, content_type: ['image/jpeg', 'image/png', 'image/gif'], unless: :temp?
  
  # Class Methods
  
  # Class method responsible for running full text search on the name field 
  def self.text_search(query)
    if query.present?
      find(:all, :conditions => [ 'name ~* ?', query ])
    end
  end
  
  # Responsible for generating a password reset token
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  # Sets the password reset token
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate:false)
    UserMailer.delay.password_reset(self)
  end

  # The user's feed. Items in a user's feed meets two reqs
  # a. All fields (content, location, time) are specified
  # b. There are at least two participants
  def feed
    Micropost.where("microposts.user_id in (?) AND location IS NOT NULL AND time IS NOT NULL AND (time > ? OR end_time > ?)", self.friends, Time.current().beginning_of_day, Time.current().beginning_of_day).joins("INNER JOIN participations ON microposts.id = participations.micropost_id").group("microposts.id").having("count(*) > 1").order("time ASC")
  end
  
  # The user's pool. Items in a user's pool FAIL one of the conditions of the feed
  def pool
	Micropost.where("microposts.user_id in (?) AND (time IS NULL OR (time IS NOT NULL AND time > ?) OR (end_time IS NOT NULL AND end_time > ?) OR location IS NULL)", self.friends, Time.current().beginning_of_day, Time.current().beginning_of_day).joins("INNER JOIN participations ON microposts.id = participations.micropost_id ").group("microposts.id").having("count(*) = 1 OR (count(*) > 1 AND (location IS NULL OR time IS NULL))")
  end
  
  # Method responsible for grabbing any new feed elements that were added after the page was rendered
  def feed_after(latest_update)  
	if latest_update.present? 
		self.feed.where("microposts.updated_at > ?", latest_update)
	end
  end
  
  # Instance method responsible for grabbing any new pool elements that were added after the page was rendered
  def pool_after(latest_update)
	if latest_update.present?
		self.pool.where("microposts.updated_at > ?", latest_update)
	end
  end
  
  # Instance method responsible for grabbing the set of users that have made a friend request to this user
  def received_friend_requests
    self.followers.where("friend_status = 'PENDING'")
  end
  
  # Instance method responsible for grabbing the set of users that this user has made a friend request to
  def sent_friend_requests
    self.followed_users.where("friend_status = 'PENDING'")
  end
  
  # Instance method responsible for determining whether this user is friends with the specified user
  def friends?(other)
	return true if other == self
  
    relationship = get_relationship(other)
    
    return relationship && relationship.friend_status == "FRIENDS"
  end
  
  # Instance method responsible for ignoring another user's friend request
  def ignore(other)  
	relationship = get_relationship(other)
	
	if relationship && relationship.friend_status == "PENDING" && relationship.followed_id == self.id	
		relationship.friend_status = "IGNORED"
		
		return relationship.save
	end
	
	return false
  end

  # Instance method responsible for retrieving all of a user's friends
  # Candidate for condensation
  def friends  
    friends = []
    friendships = Relationship.where("follower_id = :user_id and friend_status = 'FRIENDS' or followed_id = :user_id and friend_status = 'FRIENDS'", {user_id: self.id})

    friendships.each do |friendship|
      if friendship.followed_id == self.id
        friends.append(friendship.follower)
      else
        friends.append(friendship.followed)
      end
    end

	friends << self
	
    return friends  
  end
  
  # Instance method responsible for retrieving the relationship between two users
  def get_relationship(other_user)
	if other_user.present?
		Relationship.where("follower_id = :follower_id and followed_id = :followed_id or follower_id = :followed_id and followed_id = :follower_id", {follower_id: other_user.id, followed_id: self.id})[0]
	end
  end
  
  # Instance method responsible for checking whether there is a pending friend request from this user to the other_user 
  def pending?(other_user)
	relationship = get_relationship(other_user)
	
	return relationship && relationship.friend_status == "PENDING" && relationship.follower_id == self.id
  end

  #Following

  def following?(other_user)
    relationship = get_relationship(other_user)
    
    if relationship.follower_id == self.id
        return relationship.follow1
      else  
        return relationship.follow2
      end
    
    return false
  end
  
  #Gets a list of users that the user may know sorted by 
  def suggested_friends
  	people_may_know_query = "select r.follower_id, r.followed_id from Relationships r where r.follower_id in (select u1.id from Users u1, Relationships r1 where r1.follower_id = #{self.id} and r1.followed_id = u1.id and r1.friend_status = 'FRIENDS' and not u1.temp or r1.follower_id = u1.id and r1.followed_id = #{self.id} and r1.friend_status = 'FRIENDS') and r.followed_id != #{self.id} and r.followed_id not in (select u1.id from Users u1, Relationships r1 where r1.follower_id = #{self.id} and r1.followed_id = u1.id and r1.friend_status = 'FRIENDS' or r1.follower_id = u1.id and r1.followed_id = #{self.id} and r1.friend_status = 'FRIENDS') and r.friend_status = 'FRIENDS' or r.followed_id in (select u1.id from Users u1, Relationships r1 where r1.follower_id = #{self.id} and r1.followed_id = u1.id and r1.friend_status = 'FRIENDS' or r1.follower_id = u1.id and r1.followed_id = #{self.id} and r1.friend_status = 'FRIENDS') and r.follower_id != #{self.id} and r.follower_id not in (select u1.id from Users u1, Relationships r1 where r1.follower_id = #{self.id} and r1.followed_id = u1.id and r1.friend_status = 'FRIENDS' or r1.follower_id = u1.id and r1.followed_id = #{self.id} and r1.friend_status = 'FRIENDS') and r.friend_status = 'FRIENDS'"
  	
  	people_may_know = ActiveRecord::Base.connection.execute(people_may_know_query)
  	mutual_hash = {}
  	people_may_know.each do |result|
  		#Interface of result {"follower_id"=>value, "followed_id"=>value}
  		follower_id = result["follower_id"].to_i
  		followed_id = result["followed_id"].to_i
  		
  		if self.friends?(User.find(follower_id)) && self.get_relationship(User.find(followed_id)).nil?
  			if mutual_hash[followed_id].nil?
  				mutual_hash[followed_id] = 1
  			elsif
  				mutual_hash[followed_id] += 1
  			end
  		else self.friends?(User.find(followed_id)) && self.get_relationship(User.find(follower_id)).nil?
  			if mutual_hash[follower_id].nil?
  				mutual_hash[follower_id] = 1
  			elsif
  				mutual_hash[follower_id] += 1
  			end
  		end
  	end
  	mutual_array = mutual_hash.sort.reverse
  	
  	mutual_users = []
  	mutual_array.each do |keyvalue|
  		mutual_users << User.find(keyvalue[0]) if keyvalue[1] > 1
  	end
  	
  	return mutual_users
  end
  
  def friend_request!(other_user)
    Relationship.create!(follower_id: self.id, followed_id: other_user.id, friend_status: 'PENDING', follow1: false, follow2: false)
  end
  
  def accept_friend!(other_user)
    relationship = self.get_relationship(other_user)
    
    relationship.friend_status = "FRIENDS"
    relationship.follow1 = true
    relationship.follow2 = true
    
    relationship.save!
  end

  def follow!(other_user)
    relationship = get_relationship(other_user)
    
	if relationship
		if relationship.follower_id == self.id
		  relationship.follow1 = true
		else
		  relationship.follow2 = true
		end
		
		relationship.save!
	end
  end

  def unfollow!(other_user)
    relationship = Relationship.where("follower_id = :follower_id and followed_id = :followed_id or follower_id = :followed_id and followed_id = :follower_id", {follower_id: other_user.id, followed_id: self.id})[0]
    
    if relationship.follower_id == self.id
      relationship.follow1 = false
    elsif  
      relationship.follow2 = false
    end
    
    relationship.save
  end
  
  def crop_profile
    reprocess_avatar
  end
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end  

  #Participation

  def participate!(micropost)
    participations.create!(micropost_id: micropost.id)
  end

  def participates?(micropost)
    participations.find_by_micropost_id(micropost.id)
  end

  def unparticipate!(micropost)
    participations.find_by_micropost_id(micropost.id).destroy
  end
  
  def has_participations?
    participations.any?
  end
  
  def has_future_participations?
    future_participations = []
    
    participations.each do |participation|
	  current_micropost = participation.micropost
	
      if current_micropost.time && current_micropost.time.future?
        future_participations.append(participation)
      end
    end
    
    future_participations.any?
  end
  
  #Method that returns all of the future events that both users are attending. It is important to do this because
  #we do not want users to be able to see events that are not created by themselves or their friends
  def common_participations(user)
    if user == self
      future_participations = []
      
      participations.each do |participation|
        if !participation.micropost.time || participation.micropost.time && participation.micropost.time.future?
          future_participations.append(participation)
        end
      end
      
      return future_participations
    end
    
    mutual_participations = []
    if self.friends?(user)
      self.participations.each do |participation|
        if !participation.micropost.time || participation.micropost.time && participation.micropost.time.future?
          mutual_participations.append(participation)
        end
      end
    end
    
    return mutual_participations
  end

  #Notifications methods
  def num_unread_notifications
    self.notifications.where("read = false").count
  end
  
  def latest_unread_notification
  	notification = self.notifications.order("created_at DESC").first
  	
  	if !notification.nil?
  		return "#{notification.id}"
  	else
  		return ""
  	end
  end
  
  def later_unread_notifications(latest_time)
  	self.notifications.where("id > ?", latest_time).order("created_at DESC")
  end
  
  #Gcaches methods
  def gather_gcaches(current_location)
	result = []
	
	latitude_upper = 37.867868  + 0.45
	latitude_lower = 37.867868  - 0.45
	longitude_upper = -122.260797 + 0.45
	longitude_lower = -122.260797 - 0.45
	
	
	self.gcaches.where("latitude < :latitude_upper and latitude > :latitude_lower and longitude < :longitude_upper and longitude > :longitude_lower", {latitude_upper: latitude_upper, latitude_lower: latitude_lower, longitude_upper: longitude_upper, longitude_lower: longitude_lower}).each do |gcach|
		result << gcach.name
	end
	
	return result
  end

  private
  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
  
  def reprocess_avatar
    avatar.reprocess!
  end
  
  def temp?
  	return self.temp
  end
end
