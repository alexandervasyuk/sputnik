class Relationship < ActiveRecord::Base
  attr_accessible :follower_id, :followed_id, :friend_status, :follow1, :follow2

  # AR Associations
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Validations
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
