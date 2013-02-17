module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
  
  def has_microposts?
    return current_user.followed_users.length > 0
  end
  
  def check_friends_with_creator(friends)
	if !friends
		respond_to do |format|
			format.html {redirect_to :back, flash: {error: "You must become friends with the user who created that event to view its details" } }
			format.mobile { render json: { status: "failure", failure_reason: "NOT_FRIENDS" } }
		end
	end
  end
  
  def check_participating_in(micropost)
	if !current_user.participating?(micropost)
		respond_to do |format|
			format.html { redirect_to :back, flash: { error: "Cannot make a poll on this happening, please participate in it first" } }
			format.mobile { render json: { status: "failure", failure_reason: "NOT_PARTICIPATING" } }
		end
	end
  end	
end
