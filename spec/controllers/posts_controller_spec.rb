require 'spec_helper'

describe PostsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:micropost) { FactoryGirl.create(:micropost, user: user) }

	before { sign_in(user) }
	
	describe "creating a new post" do
		it "should successfully create a post on the web app" do
			event_post = {post: {content: "Lorem ipsum", micropost_id: micropost.id}}
			
			previous_posts = Post.all.count
			
			post "create", event_post
			
			updated_posts = Post.all.count
			updated_post = Post.where("user_id = :user_id and micropost_id = :micropost_id", {user_id: user.id, micropost_id: micropost.id})[0]
			
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_posts.should == previous_posts + 1
			updated_post.content.should == "Lorem ipsum"
		end
		
		it "should successfully create a post on the mobile app" do
			event_post = {post: {content: "Lorem ipsum", micropost_id: micropost.id}}
			
			previous_posts = Post.all.count
			
			post "create_mobile", event_post
			
			updated_posts = Post.all.count
			updated_post = Post.where("user_id = :user_id and micropost_id = :micropost_id", {user_id: user.id, micropost_id: micropost.id})[0]
			
			response_json = {status: "success"}.to_json
			
			response.body.should == response_json
			updated_posts.should == previous_posts + 1
			updated_post.content.should == "Lorem ipsum"
		end
		
		it "should generate internal notifications for all participating users" do
			#Missing test
		end
	end
end