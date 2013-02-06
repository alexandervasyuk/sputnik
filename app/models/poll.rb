class Poll < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :micropost_id, :poll_type, :question
  
  belongs_to :micropost
  
  has_many :proposals
end
