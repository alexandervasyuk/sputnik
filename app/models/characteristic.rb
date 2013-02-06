class Characteristic < ActiveRecord::Base
  attr_accessible :micropost_id, :characteristic
  
  # Micropost
  belongs_to :micropost
  
  # Users
  has_and_belongs_to_many :users
end
