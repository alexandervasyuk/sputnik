class Poll < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :micropost_id, :poll_type, :question
  
  belongs_to :micropost
  
  has_many :proposals
  
  def to_mobile
	mobile_proposals = []
	
	proposals.each do |proposal|
		mobile_proposals << proposal.to_mobile
	end
	
	{ id: micropost_id, poll_type: poll_type, question: question, proposals: mobile_proposals }
  end
end
