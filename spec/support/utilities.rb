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

def generate_participants(micropost, num_participants)
	while num_participants > 0 do
		participant = FactoryGirl.create(:user)
		
		participant.participate!(micropost)
		
		num_participants-=1
	end
end