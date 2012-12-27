class Proposal < ActiveRecord::Base
  attr_accessible :content, :location, :micropost_id, :time, :user_id
  
  belongs_to :user
  belongs_to :micropost
  
  validates :user_id, presence: true
  validates :micropost_id, presence: true
end
