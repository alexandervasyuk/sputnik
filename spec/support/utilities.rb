include ApplicationHelper

def sign_in(user)
  #visit signin_path
  #fill_in "Email",    with: user.email
  #fill_in "Password", with: user.password
  #click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
  cookies[:time_zone] = "America/Los_Angeles"
end

def sign_out
	cookies[:remember_token] = nil
end

# Micropost Generation Helper

# Generates the specified number of participants for the specified micropost
def generate_participants(micropost, num_participants)
	owner = micropost.user
	
	while num_participants > 0 do
		participant = FactoryGirl.create(:user)
		
		make_friends(owner, participant)
		participant.participate(micropost)
		
		num_participants-=1
	end
end

# Generates the specified number of posts for the specified micropost
def generate_posts_for(micropost, num_posts)
	creator = micropost.user

	while num_posts > 0 do
		poster = FactoryGirl.create(:user)
		make_friends(poster, creator)
		poster.participate(micropost)
		
		post = FactoryGirl.create(:post, user: poster, micropost: micropost)
		
		num_posts-=1
	end
end

# Generates the specified number of polls for the specified micropost
def generate_polls_for(micropost, num_polls)
	while num_polls > 0 do
		FactoryGirl.create(:poll, micropost: micropost)

		num_polls-=1
	end
end	

# Generates the specified number of invitees for the specified micropost
def generate_invitees_for(micropost, num_invitees)
	while num_invitees > 0 do
		micropost.add_to_invited(FactoryGirl.create(:user))
		
		num_invitees-=1
	end
end

# Generates the specified number of characteristics for the specified micropost
def generate_characteristics_for(micropost, num_characteristics)
	while num_characteristics > 0 do
		FactoryGirl.create(:characteristic, micropost: micropost)
		
		num_characteristics-=1
	end
end

# Generates a feed item for the user based on the qualifications of a feed item
def generate_feed_item(user)
	micropost = FactoryGirl.create(:micropost, user: user)
	
	generate_participants(micropost, 2)
	
	Rails.logger.debug("\n\nGenerating Feed Item With ID: #{micropost.id}\nContent: #{micropost.content}\nLocation: #{micropost.location}\nTime: #{micropost.time}\nUser ID: #{micropost.user.id}\nUpdated At: #{micropost.updated_at}\n")
	
	return micropost
end

def generate_feed_items(user, num_feed_items)
	while num_feed_items > 0
		generate_feed_item(user)
		
		num_feed_items-=1
	end
end

# Generates a pool item for the user based on the qualifications of a pool item
def generate_pool_item(user)
	pool_item = FactoryGirl.create(:incomplete_micropost, user: user)
	
	user.participate(pool_item)
	
	Rails.logger.debug("\n\nGenerating Pool Item With ID: #{pool_item.id}\nContent: #{pool_item.content}\nLocation: #{pool_item.location}\nTime: #{pool_item.time}\nUser ID: #{pool_item.user.id}\nUpdated At: #{pool_item.updated_at}\n")
	
	return pool_item
end

def generate_alt_pool_item(user)
	
end

def make_friends(user1, user2)
	user1.friend_request(user2)
	user2.accept_friend(user1)
end

def generate_microposts(user, num_microposts)
	while num_microposts > 0 do
		micropost = FactoryGirl.create(:micropost, user: user)
		user.participate(micropost)
		
		num_microposts-=1
	end
end

def generate_friends(user, num_friends)
	while num_friends > 0 do
		user1 = FactoryGirl.create(:user)
		make_friends(user1, user)
		
		num_friends-=1
	end
end

def set_in_beta
	Rails.configuration.in_beta = true
end

def set_not_in_beta
	Rails.configuration.in_beta = false
end