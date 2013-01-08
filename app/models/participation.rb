class Participation < ActiveRecord::Base
  after_save :update_micropost
  before_destroy :update_micropost

  attr_accessible :micropost_id, :user_id

  belongs_to :user
  belongs_to :micropost

  validates :user_id, presence: true
  validates :micropost_id, presence: true
  
  def update_micropost
	micropost = self.micropost
	
	micropost.updated_at = Time.now
	micropost.save
  end
end
