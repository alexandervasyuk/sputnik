class Participation < ActiveRecord::Base
  attr_accessible :micropost_id, :user_id

  # AR Associations
  belongs_to :user
  belongs_to :micropost

  # Validations
  validates :user_id, presence: true
  validates :micropost_id, presence: true
  
  # AR Hooks
  after_save :update_micropost
  before_destroy :update_micropost
  
  def update_micropost
	micropost = self.micropost
	micropost.updated_at = Time.now
	
	micropost.save
  end
end
