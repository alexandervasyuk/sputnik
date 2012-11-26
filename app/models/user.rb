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
  
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate:false)
    UserMailer.delay.password_reset(self)
  end

  def feed

    relationships = Relationship.where("follower_id = :user_id and friend_status = 'FRIENDS' or followed_id = :user_id and friend_status = 'FRIENDS'", {user_id: self.id})
    
    friends = []
    
    relationships.each do |relationship|
      if relationship.follower_id == self.id && relationship.follow1
        friends.append(relationship.followed_id)
      elsif relationship.followed_id == self.id && relationship.follow2  
        friends.append(relationship.follower_id)
      end  
    end
    
    friends.append(self.id)
    
    Micropost.from_users(friends)
  end
  
  # def future_feed
  #   feed = []
    
  #   self.feed.each do |feed_item|
  #     if (feed_item.time + 180).future?
  #       feed << feed_item
  #     end
  #   end
    
  #   return feed
  # end
  
  def self.text_search(query)
    if query.present?
      find( :all, :conditions => [ 'name ~* ?', query ] )
    end
  end
  
  def received_friend_requests
    self.followers.where("friend_status = 'PENDING'")
  end
  
  def num_received_friend_requests
    received_friend_requests.count
  end
  
  def sent_friend_requests
    self.followed_users.where("friend_status = 'PENDING'")
  end
  
  def friends?(other)
    if other == self
      return true
    end    
    
    relationship = get_relationship(other)
    
    if !relationship.nil? && relationship.friend_status == "FRIENDS"
      return true
    end
    
    return false
  end

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

    return friends  
  end
  
  def get_relationship(other_user)
    relationship = Relationship.where("follower_id = :follower_id and followed_id = :followed_id or follower_id = :followed_id and followed_id = :follower_id", {follower_id: other_user.id, followed_id: self.id})[0]
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
  		
  		if self.friends?(User.find(follower_id))
  			if mutual_hash[followed_id].nil?
  				mutual_hash[followed_id] = 1
  			elsif
  				mutual_hash[followed_id] += 1
  			end
  		else self.friends?(User.find(followed_id))
  			if mutual_hash[follower_id].nil?
  				mutual_hash[follower_id] = 1
  			elsif
  				mutual_hash[follower_id] += 1
  			end
  		end
  	end
  	
  	print "asdfasdfasdf"
  	print mutual_hash
  	
  	mutual_array = mutual_hash.sort.reverse
  	
  	print "asdfasdfasdf"
  	print mutual_array
  	
  	mutual_users = []
  	mutual_array.each do |keyvalue|
  		mutual_users << User.find(keyvalue[0])
  	end
  	
  	return mutual_users
  end
  
  def friend_request!(other_user)
    relationships.create!(followed_id: other_user.id, friend_status: 'PENDING', follow1: false, follow2: false)
  end
  
  def accept_friend!(other_user)
    relationship = Relationship.where("follower_id = :follower_id and followed_id = :followed_id", {follower_id: other_user.id, followed_id: self.id})[0]
    
    relationship.friend_status = "FRIENDS"
    relationship.follow1 = true
    relationship.follow2 = true
    
    relationship.save
  end

  def follow!(other_user)
    relationship = Relationship.where("follower_id = :follower_id and followed_id = :followed_id or follower_id = :followed_id and followed_id = :follower_id", {follower_id: other_user.id, followed_id: self.id})[0]
    
    if relationship.follower_id == self.id
      relationship.follow1 = true
    elsif  
      relationship.follow2 = true
    end
    
    relationship.save
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
      if participation.micropost.time.future?
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
        if participation.micropost.time.future?
          future_participations.append(participation)
        end
      end
      
      return future_participations
    end
    
    mutual_participations = []
    if self.friends?(user)
      self.participations.each do |participation|
        if participation.micropost.time.future?
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
