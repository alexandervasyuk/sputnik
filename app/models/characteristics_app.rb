class CharacteristicsApp < ActiveRecord::Base
  attr_accessible :micropost_id
  has_many :characteristics
  
  belongs_to :micropost
end
