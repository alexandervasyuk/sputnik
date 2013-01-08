class Gcach < ActiveRecord::Base
  attr_accessible :name, :address, :latitude, :longitude
  
  #Users
  has_many :user_gcaches
  has_many :users, through: :user_gcaches
end
