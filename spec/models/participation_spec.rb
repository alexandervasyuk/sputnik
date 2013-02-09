require 'spec_helper'

describe Participation do
  before do
	# Creating initial objects
	@user = FactoryGirl.create(:user)
	@micropost = FactoryGirl.create(:micropost)
	
	# Making the users friends so that the user can participate in the micropost
	make_friends(@user, @micropost.user)
	
	# Making the user participate in the micropost
	@user.participate(@micropost)
	
	# Setting up the participating model object
	@participation = @user.participating?(@micropost)
  end
  
  subject { @participation }
  
  it { should respond_to(:micropost) }
  it { should respond_to(:user) }
  
  # Validation Testing
  describe "required attributes" do
	it "should not allow a nil micropost_id" do
		participation = Participation.create(user_id: @user.id)
		
		participation.should_not be_valid
	end
	
	it "should not allow a nil user_id" do
		participation = Participation.create(micropost_id: @micropost.id)
		
		participation.should_not be_valid
	end
  end
  
  describe "adding a participant to micropost" do
	it "should update the micropost's updated_at field" do
		new_user = FactoryGirl.create(:user)
		
		make_friends(new_user, @micropost.user)
		
		expect do
			new_user.participate(@micropost)
		end.to change { @micropost.updated_at }
	end
  end
  
  describe "removing a participant from a micropost" do
	it "should update its updated_at field" do
		expect do
			@participation.destroy
		end.to change { @micropost.updated_at }
	end
  end
end
