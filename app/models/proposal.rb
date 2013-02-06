class Proposal < ActiveRecord::Base
  attr_accessible :content, :location, :poll_id, :time, :end_time
  
  belongs_to :poll
  
  has_and_belongs_to_many :users
  
  validates :poll_id, presence: true
end
