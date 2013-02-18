class Proposal < ActiveRecord::Base
  attr_accessible :content, :location, :poll_id, :time, :end_time
  
  belongs_to :poll
  
  has_and_belongs_to_many :users
  
  validates :poll_id, presence: true
  
  def to_mobile
	users = []
	
	self.users.each do |user|
		users << user.id
	end
  
	{ id: self.id, content: content, time: time, end_time: end_time, users: users }
  end
  
  # Method that adds the user to the proposal if the user is not present, and removes the user if the user is
  def toggle_user(user)
	if users.all.include? user
		users.delete user
	else
		users << user
	end
	
	save
  end
end
