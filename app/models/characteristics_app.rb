class CharacteristicsApp < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :characteristics
  
  belongs_to :micropost
end
