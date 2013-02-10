class Post < ActiveRecord::Base
	attr_accessible :content, :micropost_id, :user_id, :photo

	has_attached_file :photo, styles: { standard: "400x400>" }, 
		:path => ":rails_root/public/assets/posts/:id/:style/:basename.:extension",
		:storage => :s3,
		:s3_credentials => "#{Rails.root}/config/s3.yml"

	# AR Associations
	belongs_to :user
	belongs_to :micropost

	# Validations
	validates :content, presence: true
	validates :user_id, presence: true
	validates :micropost_id, presence: true

	def to_mobile
		replier = self.user

		{replier_picture: replier.avatar.url, reply_text: self.content, replier_name: replier.name, posted_time: self.created_at, posted_id: self.id}
	end

	def update_micropost
		micropost = self.micropost

		micropost.updated_at = Time.now
		micropost.save
	end
  
	# AR Callbacks
	after_save :update_micropost
	before_destroy :update_micropost
end
