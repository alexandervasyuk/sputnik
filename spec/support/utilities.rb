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

# Micropost Generation Helper

# Generates the specified number of participants for the specified micropost
def generate_participants(micropost, num_participants)
	owner = micropost.user
	
	while num_participants > 0 do
		participant = FactoryGirl.create(:user)
		
		make_friends(owner, participant)
		participant.participate!(micropost)
		
		num_participants-=1
	end
end

# Generates the specified number of posts for the specified micropost
def generate_posts_for(micropost, num_posts)
	creator = micropost.user

	while num_posts > 0 do
		poster = FactoryGirl.create(:user)
		make_friends(poster, creator)
		poster.participate!(micropost)
		
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
	
	generate_participants(micropost, 1)
	
	return micropost
end

# Generates a pool item for the user based on the qualifications of a pool item
def generate_pool_item(user)
	FactoryGirl.create(:micropost, user: user)
end

def make_friends(user1, user2)
	user1.friend_request!(user2)
	user2.accept_friend!(user1)
end

def generate_microposts_for(user, num_microposts)
	while num_microposts > 0 do
		user1 = FactoryGirl.create(:user)
		make_friends(user, user1)
		
		micropost = FactoryGirl.create(:micropost, user: user1)
		
		num_microposts-=1
	end
end

def set_in_beta
	Rails.configuration.in_beta = true
end

def set_not_in_beta
	Rails.configuration.in_beta = false
end