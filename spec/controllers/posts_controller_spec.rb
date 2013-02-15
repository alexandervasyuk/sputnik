require 'spec_helper'

describe PostsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:friend) { FactoryGirl.create(:user) }
	let(:micropost) { FactoryGirl.create(:micropost, user: friend) }

	describe "desktop app user" do
		describe "who is logged in" do
			before { sign_in(user) }
			
			describe "who wants to create a new post" do
				describe "who is friends with the creator of the micropost" do
					before { make_friends(user, friend) }
					
					describe "who is using valid values" do
						describe "who is not participating in the micropost" do
							it "should create the post and should make the user participating in the micropost afterwards" do
								event_post = {post: {content: "Something ridiculous", micropost_id: micropost.id}}
							
								expect do
									post "create", event_post
								end.to change { Post.all.count }.by(1)
								
								user.participating?(micropost).should be_true
							end
						end
					
						it "should successfully create a post" do
							event_post = {post: {content: "Something ridiculous", micropost_id: micropost.id}}
							
							expect do
								post "create", event_post
							end.to change { Post.all.count }.by(1)
							
							updated_post = Post.last
							
							response.should redirect_to(detail_micropost_path(micropost.id))
							
							updated_post.content.should == "Something ridiculous"
						end
						
						it "should generate internal notifications for all participating users" do
							#Missing test
						end
					end
					
					describe "who is not using valid values" do
						it "should not create the post with a nil micropost" do
							event_post = {post: {content: "Something ridiculous", micropost_id: nil}}
						
							expect do
								post "create", event_post
							end.not_to change { Post.all.count }
						end
						
						it "should not create the post with an unexisting micropost" do
							event_post = {post: {content: "Something ridiculous", micropost_id: 1000}}
						
							expect do
								post "create", event_post
							end.not_to change { Post.all.count }
						end
						
						it "should not create the post with a blank content and no picture" do
							# UNTESTED
						end
					end
				end
				
				describe "who is not friends with the creator of the micropost" do
					it "should not create the post and should display an error saying the user must be friends" do
						event_post = {post: {content: "Something ridiculous", micropost_id: micropost.id}}
						
						expect do
							post "create", event_post
						end.not_to change { Post.all.count }
						
						flash[:error].should_not be_nil
					end
				end
			end
		end
		
		describe "who is not logged in" do
			it "should not create the post and should redirect the user to the sign in page" do
				event_post = {post: {content: "Something ridiculous", micropost_id: micropost.id}}
					
				expect do
					post "create", event_post
				end.not_to change { Post.all.count }
					
				response.should redirect_to signin_url
			end
		end
	end
	
	describe "mobile app user" do
		describe "who is logged in" do
			before { sign_in(user) }
			
			describe "who wants to create a new post" do
				describe "who is friends with the creator of the micropost" do
					before { make_friends(user, friend) }
					
					describe "who is using valid values" do
						describe "who is not participating in the micropost" do
							it "should create the post and should make the user participating in the micropost afterwards" do							
								expect do
									post "create", post: {content: "Something ridiculous", micropost_id: micropost.id}, format: "mobile"
								end.to change { Post.all.count }.by(1)
								
								user.participating?(micropost).should be_true
							end
						end
					
						it "should successfully create a post on the mobile app" do
							expect do
								post "create", post: {content: "Super strange content", micropost_id: micropost.id}, format: "mobile"
							end.to change { Post.all.count }.by(1)
							
							response.body.should == {status: "success"}.to_json
							
							updated_post = Post.last
							updated_post.content.should == "Super strange content"
							
							response.body.should == {status: "success"}.to_json
						end
						
						it "should generate internal notifications for all participating users" do
							#Missing Test
						end
					end
					
					describe "who is not using valid values" do
						it "should not create the post with a nil micropost" do
							expect do
								post "create", post: {content: "Something ridiculous", micropost_id: nil}, format: "mobile"
							end.not_to change { Post.all.count }
							
							response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
						end
						
						it "should not create the post with an unexisting micropost" do						
							expect do
								post "create", post: {content: "Something ridiculous", micropost_id: 1000}, format: "mobile"
							end.not_to change { Post.all.count }
							
							response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
						end
						
						it "should not create the post with a blank content and no picture" do
							# UNTESTED
						end
					end
				end
				
				describe "who is not friends with the creator of the micropost" do
					it "should not create the post and should receive error indicator tobe friends with the creator" do
						event_post = {}
						
						expect do
							post "create", post: {content: "Something ridiculous", micropost_id: micropost.id}, format: "mobile"
						end.not_to change { Post.all.count }
						
						response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
					end
				end
			end
		end
		
		describe "who is not logged in" do
			it "should not create the post and should receive an error indicator saying I must log in" do
				expect do
					post "create", post: {content: "Something ridiculous", micropost_id: micropost.id}, format: "mobile"
				end.not_to change { Post.all.count }
					
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
		end
	end
	
	describe "ajax app user" do
		describe "who is logged in" do
			before { sign_in(user) }
			
			describe "who is friends with the creator of the micropost" do
				describe "who is participating in the micropost" do
				
				end
				
				describe "who is not participating in the micropost" do
				
				end
				
				
			end
			
			describe "who is not friends with the creator of the micropost" do
				
			end
		end
		
		describe "who is not logged in" do
		
		end
	end

	describe "making a mobile update request" do	
		it "should respond with the correct data when there are new posts" do
			first_post = FactoryGirl.create(:post, micropost: micropost, user: user)
			generate_posts_for(micropost, 3)
		
			post_update = {micropost_id: micropost.id}
			
			updates = []
			
			micropost.posts.each do |post|
				updates << post.to_mobile
			end
			
			response_json = {status: "success", replies_data: updates}.to_json
			
			post "mobile_refresh", post_update
			
			response.body.should == response_json
		end
	end
end