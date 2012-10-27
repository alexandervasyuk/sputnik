class Participation < ActiveRecord::Base
  attr_accessible :micropost_id, :user_id

  belongs_to :user
  belongs_to :micropost

  validates :user_id, presence: true
  validates :micropost_id, presence: true
end
