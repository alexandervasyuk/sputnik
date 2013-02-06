class UserGcach < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :user_id, :gcach_id
  
  belongs_to :user
  belongs_to :gcach
end
