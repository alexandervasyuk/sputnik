class Post < ActiveRecord::Base
  attr_accessible :content, :micropost_id, :user_id

  belongs_to :user
  belongs_to :micropost

  validates :content, presence: true
  validates :user_id, presence: true
  validates :micropost_id, presence: true
end
