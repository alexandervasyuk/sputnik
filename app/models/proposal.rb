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
end
