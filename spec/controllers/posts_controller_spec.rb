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
		
			describe "who wants to delete a post" do
			
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
			
			describe "who is friends with the creator of the micropost" do
				before { make_friends(user, friend) }
				
				describe "who wants to create a new post" do
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
							
							updated_post = Post.last
							updated_post.content.should == "Super strange content"
							
							response.body.should == {status: "success", post: updated_post.to_mobile}.to_json
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
				
				describe "who wants to delete a post" do
					describe "who owns the post" do
						let(:post) { FactoryGirl.create(:post, user: user, micropost: micropost) }
						
						it "should destroy the micropost" do
							post.should_not be_nil
							
							Post.count.should > 0
						
							expect do
								delete "destroy", id: post.id, format: "mobile"
							end.to change(Post, :count)
							
							response.body.should == {status: "success"}.to_json
						end
					end
					
					describe "who does not own the post" do
						let(:post) { FactoryGirl.create(:post, user: friend, micropost: micropost) }
						
						it "should not destroy the micropost but should receive an error indicator saying I must own the post to delete it" do
							post.should_not be_nil
							
							Post.count.should > 0
							
							expect do
								delete "destroy", id: post.id, format: "mobile"
							end.not_to change(Post, :count)
							
							response.body.should == {status: "failure", failure_reason: "NOT_OWNER"}.to_json
						end
					end
				end
			
				describe "who wants to refresh the posts in a micropost" do
					it "should successfully return the new posts" do
						posts = generate_posts_for(micropost, 5)
						
						set_latest_post(micropost, posts[2])
						
						get "refresh", micropost_id: micropost.id, format: "mobile"
						
						updated_posts = []
						posts[3..4].each do |post|
							updated_posts << post.to_mobile
						end
						
						updated_posts.reverse!
						
						response.body.should == {status: "success", replies: updated_posts, to_delete: []}.to_json
					end
					
					it "should successfully return the posts to delete from the view" do
						posts = generate_posts_for(micropost, 5)
						
						set_latest_post(micropost, posts[4])
						
						add_deleted_post(posts[1])
						
						get "refresh", micropost_id: micropost.id, format: "mobile"
						
						response.body.should == {status: "success", replies: [], to_delete: [posts[1].id]}.to_json
					end
				end
			end
			
			describe "who is not friends with the creator of the micropost" do
				it "should not create the post and should receive an error indicator to be friends with the creator" do
					expect do
						post "create", post: {content: "Something ridiculous", micropost_id: micropost.id}, format: "mobile"
					end.not_to change(Post, :count)
					
					response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
				end
				
				it "should not receive any post updates and should receive an error indicator to be friends with the creator" do
					get "refresh", micropost_id: micropost.id, format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
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
			
			it "should not delete the post and should receive an error indicator saying I must log in" do
				expect do
					delete "destroy", id: 10, format: "mobile"
				end.not_to change { Post.all.count }
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not receive any post updates and should receive an error indicator saying I must log in" do
				get "refresh", format: "mobile"
				
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
end