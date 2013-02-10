require 'spec_helper'

describe Post do
  before do
	@user = FactoryGirl.create(:user)
	@micropost = FactoryGirl.create(:micropost, user: @user)
	
	@post = FactoryGirl.create(:post, user: @user, micropost: @micropost)
  end
  
  subject { @post }
  
  it { should respond_to(:user) }
  it { should respond_to(:micropost) }
  
  # Validation Testing
  describe "creating a new post" do
	it "should not create a post without content or photo" do
		post = Post.new(micropost_id: @micropost.id, user_id: @user.id)
		
		post.should_not be_valid
	end
	
	it "should not create a post without a user" do
		post = Post.new(content: "asdfasdf", micropost_id: @micropost.id)
		
		post.should_not be_valid
	end
	
	it "should not create a post without a micropost" do
		post = Post.new(content: "asdfasdf", user_id: @user.id)
		
		post.should_not be_valid
	end
  end
  
  # AR Callback Testing
  describe "creating a new post" do
	it "should update the micropost updated at field" do
		expect do
			new_post = FactoryGirl.create(:post, micropost: @micropost, user: @user)
		end.to change { @micropost.reload.updated_at }
	end
  end
  
  describe "deleting a post" do
	it "should update the micropost updated at field" do
		expect do
			@post.destroy
		end.to change { @micropost.reload.updated_at }
	end
  end
end
