class Poll < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :micropost_id, :poll_type, :question
  
  # Associations
  belongs_to :micropost
  
  has_many :proposals
  
  # Validations
  validates_presence_of :poll_type
  validates_presence_of :question
  validates_presence_of :micropost_id
  
  def to_mobile
	mobile_proposals = []
	
	proposals.each do |proposal|
		mobile_proposals << proposal.to_mobile
	end
	
	{ id: micropost_id, poll_type: poll_type, question: question, proposals: mobile_proposals }
  end
end
