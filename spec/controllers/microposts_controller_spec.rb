require 'spec_helper'

describe MicropostsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:destroy_micropost) { FactoryGirl.create(:micropost, content: "content1", user: user) }
	let(:update_micropost) { FactoryGirl.create(:micropost, content: "content2", user: user) }
	
	describe "desktop app user" do
		describe "who is logged in" do
			before { sign_in user }
		
			describe "who wants to create a new micropost" do				
				describe "no errors in form input" do
					it "should successfully save the record and redirect to the micropost's detail page" do
						["now", "12:30PM January 5th", "tomorrow", "tomorrow at 5PM"].each do |time|
							micropost = {micropost: {content: "Lorem ipsum", location: "Lorem ipsum", time: time}}
							
							expect do
								post "create", micropost
							end.to change { Micropost.all.count }.by(1)
						end
					end
					
					it "should successfully save the record and render the event details page even if there are empty fields in location or time" do
						micropost = {micropost: {content: "Lorem ipsum", location: nil, time: nil}}
						
						expect do
							post "create", micropost
						end.to change { Micropost.all.count }.by(1)
						
						micropost = Micropost.all.last
						
						response.should redirect_to(detail_micropost_path(micropost.id))
					end
				end
				
				describe "errors in form input" do
					it "should not create records on incorrectly formatted times" do
						["hi", "never"].each do |time|
							micropost = {micropost: {content: "Lorem Ipsum", location: "Lorem Ipsum", time: time}}
						
							expect do
								post "create", micropost
							end.not_to change { Micropost.all.count }
							
							response.should render_template("static_pages/home")
						end
					end
				end
			end
			
			describe "who wants to destroy a micropost" do
				describe "who owns the micropost" do
					it "should destroy a micropost if the user owns the micropost" do
						micropost = FactoryGirl.create(:micropost, user: user)
						user.participate(micropost)
						
						delete = {id: micropost.id}
						
						expect do
							expect do
								post "destroy", delete
							end.to change { Micropost.all.count }.by(-1)
						end.to change { user.participations.all.count }.by(-1)
					end
					
					it "should change the session to include the id of the newest deleted item" do
						micropost = FactoryGirl.create(:micropost, user: user)
						user.participate(micropost)
						
						delete = {id: micropost.id}
						
						post "destroy", delete
						
						session[:to_delete].should include(micropost.id)
					end
				end
				
				describe "who does not own the micropost" do
					it "should not destroy a micropost if the user does not own the micropost" do
						micropost = FactoryGirl.create(:micropost, user: user)
						
						other_user = FactoryGirl.create(:user)
						other_micropost = FactoryGirl.create(:micropost, user: other_user)
						
						expect do
							post "destroy", {id: other_micropost.id}
						end.not_to change { Micropost.all.count }
						
						flash[:error].should_not be_nil
						response.should redirect_to(root_url)
					end
				end
			end
			
			describe "who wants to update a micropost" do
				describe "who owns the micropost" do
					describe "who is using correct input values" do
						let(:micropost) { FactoryGirl.create(:micropost, user: user) }
						let(:num_participants) { 3 }
					
						it "should update the micropost" do
							edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
							post "update", edit
							
							updated_micropost = Micropost.find(micropost.id)
							updated_micropost.content.should == "new content"
							updated_micropost.location.should == "new location"
							
							response.should redirect_to(detail_micropost_path(micropost.id))
						end
						
						describe "there is one participant" do
							before { generate_participants micropost, 1 }
							
							it "should send an email to one participant on update" do
								ActionMailer::Base.deliveries = []
								
								edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
								post "update", edit
								
								mail = ActionMailer::Base.deliveries.last
								
								participants = micropost.participations
								
								mail['from'].to_s.should == "John via Happpening <notification@happpening.com>"
								mail['to'].to_s.should == participants[0].user.email
								
								updated_micropost = Micropost.find(micropost.id)
								updated_micropost.content.should == "new content"
								updated_micropost.location.should == "new location"
							end
						end
						
						describe "there are multiple participants" do
							before { generate_participants micropost, num_participants }
							
							it "should send emails to all participants on update" do
								ActionMailer::Base.deliveries = []
								
								micropost.participations.count.should == num_participants
								
								edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
								post "update", edit
								
								participants = micropost.participations
								
								#ActionMailer::Base.deliveries.last['from'].to_s.should be_nil
								emails = [participants[0].user.email, participants[1].user.email, participants[2].user.email]
								
								ActionMailer::Base.deliveries.last(3).each do |mail|
									emails.should include(mail['to'].to_s)
								end
								
								ActionMailer::Base.deliveries.count.should == num_participants
							end
							
							it "should send internal notifications to all participants on update" do
								ActionMailer::Base.deliveries = []
							end
						end
					end
					
					describe "who is not using correct input values" do
						# UNTESTED
					end
				end
				
				describe "who does not own the micropost" do
					it "should not update the micropost if the user does not own the micropost" do
						micropost = FactoryGirl.create(:micropost)
						
						edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
						
						post "update", edit
						
						updated_micropost = Micropost.find(micropost.id)
						updated_micropost.content.should_not == "new content"
						updated_micropost.location.should_not == "new location"
						
						flash[:error].should_not be_nil
						response.should redirect_to(root_url)
					end
				end
			end
			
			describe "who wants detail on a micropost" do
				let(:micropost) { FactoryGirl.create(:micropost, user: user) }
				let(:friend) { FactoryGirl.create(:user) }
				let(:not_friend) { FactoryGirl.create(:user) }
				let(:data) { {id: micropost.id} }
				
				describe "who is friends with the creator of the micropost" do
					it "should correctly return the detail page" do
						make_friends(user, friend)
						sign_in(friend)
						
						post "detail", data
						
						response.should render_template("microposts/detail")
					end
				end
				
				describe "who is no friends with the creator of the micropost" do
					it "should redirect to the root url if the users are not friends" do
						sign_in(not_friend)
						
						post "detail", data
						
						response.should redirect_to(root_url)
					end
				end
			end
		
			describe "who wants to pull the newest feed items" do
				
			end
			
			describe "who wants to pull the newest pool items" do
				
			end
		end
		
		describe "who is not logged in" do
			it "should redirect to the signin page on create" do
				micropost = {micropost: {content: "Lorem Ipsum", location: "Lorem Ipsum", time: "now"}}
							
				post "create", micropost
				
				response.should redirect_to signin_url
			end
			
			it "should redirect to the signin page on create" do
				micropost = FactoryGirl.create(:micropost, user: user)
				user.participate(micropost)
				
				delete = {id: micropost.id}
				
				post "destroy", delete
				
				response.should redirect_to signin_url
			end
			
			it "should redirect to the signin page on update" do
				micropost = FactoryGirl.create(:micropost, user: user)
				
				edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
				
				post "update", edit
				
				response.should redirect_to signin_url
			end
			
			it "should redirect to the signin page on detail request" do
				micropost = FactoryGirl.create(:micropost, user: user)
				
				post "detail", id: micropost.id
				
				response.should redirect_to signin_url
			end
		end
	end
	
	describe "mobile app user" do
		describe "who is logged in" do
			before { sign_in user }
			
			describe "who wants to create a new micropost" do
				describe "no errors in form input" do
					it "should successfully save the record and receive a success indicator" do
						expect do
							post "create", micropost: {content: "Lorem ipsum", location: "Lorem ipsum", time: "now"}, format: "mobile"
						end.to change { Micropost.all.count }.by(1)
						
						response.body.should == {status: "success", feed: user.feed, pool: user.pool, created: Micropost.last.to_mobile}.to_json
					end
				end
				
				describe "errors in form input" do
					it "should not create records on incorrectly formatted times" do
						["hi", "never"].each do |time|
							expect do
								post "create", micropost: {content: "Lorem Ipsum", location: "Lorem Ipsum", time: time}, format: "mobile"
							end.not_to change { Micropost.all.count }
							
							response.body.should == {status: "failure", failure_reason: "TIME_FORMAT"}.to_json
						end
					end
				end
			end
			
			describe "who wants to destroy a micropost" do
			
			end
			
			describe "who wants to update a micropost" do
				
			end
			
			describe "who wants detail on a micropost" do
				let(:micropost) { FactoryGirl.create(:micropost, user: user) }
				let(:friend) { FactoryGirl.create(:user) }
				let(:not_friend) { FactoryGirl.create(:user) }
				
				describe "who is friends with the creator of the micropost" do
					before do 
						generate_posts_for(micropost, 3)
						@poll = FactoryGirl.create(:poll, micropost: micropost)
						
						5.times do 
							user.proposals << FactoryGirl.create(:proposal, poll: @poll)
						end
						
						user.save
					end
		
					it "should correctly return the information as json" do
						make_friends(user, friend)
						sign_in(friend)
					
						replies_data = []
						polls_data = []
						
						micropost.posts.reverse.each do |post|
							replies_data << {replier_picture: post.user.avatar.url, replier_id: post.user.id, reply_text: post.content, reply_picture: post.photo.url, replier_name: post.user.name, posted_time: post.created_at}
						end
						
						micropost.polls.each do |poll|
							polls_data << poll.to_mobile
						end
						
						get "detail", id: micropost.id, format: "mobile"
						
						response_json = {status: "success", failure_reason: "", micropost: micropost.to_mobile, polls: polls_data, replies_data: replies_data}.to_json
						
						response.body.should == response_json
					end
				end
				
				describe "who is not friends with the creator of the micropost" do
					it "should return an error code as json to the mobile app" do
						response_json = {status:"failure", failure_reason: "NOT_FRIENDS"}.to_json
						
						sign_in(not_friend)
						
						post "detail", id: micropost.id, format: "mobile"
						
						response.body.should == response_json
					end
				end
			end
		
			describe "who wants to pull the newest feed items" do
				let(:friend) { FactoryGirl.create(:user) }
				before { make_friends(friend, user) }
			
				it "should give the correct update on the mobile app when there is nothing to delete" do
					first_event = generate_feed_item(friend)
					sleep(1.1)
					second_event = generate_feed_item(friend)
					sleep(1.1)
					third_event = generate_feed_item(friend)
					sleep(1.1)
					fourth_event = generate_feed_item(friend)
					
					session[:feed_latest] = first_event.updated_at + 1.seconds
					
					get "refresh", format: "mobile"

					updates = [fourth_event.to_mobile, third_event.to_mobile, second_event.to_mobile]
					to_delete = []
					
					json_response = {status: "success", feed_items: updates, to_delete: to_delete}.to_json
					
					response.body.should == json_response
					updates.count.should == 3
				end
				
				it "should give the correct update on the mobile app when there is something to delete" do
					first_event = generate_feed_item(friend)
					sleep(1.1)
					second_event = generate_feed_item(friend)
					sleep(1.1)
					third_event = generate_feed_item(friend)
					sleep(1.1)
					fourth_event = generate_feed_item(friend)
					
					fourth_event_id = fourth_event.id
					
					session[:feed_latest] = fourth_event.updated_at + 1.seconds
					
					sign_in(friend)
					post "destroy", id: fourth_event.id
					
					session[:to_delete].should include(fourth_event_id)
					
					sign_in(user)
					get "refresh", format: "mobile"
					
					json_response = {status: "success", feed_items: [], to_delete: [fourth_event_id]}.to_json
					
					response.body.should == json_response
				end
				
				it "should give the correct update on the mobile app where there are new items and something to delete" do
					first_event = generate_feed_item(friend)
					sleep(1.1)
					second_event = generate_feed_item(friend)
					sleep(1.1)
					third_event = generate_feed_item(friend)
					sleep(1.1)
					fourth_event = generate_feed_item(friend)
					sleep(1.1)
					fourth_event_id = fourth_event.id
					fifth_event = generate_feed_item(friend)
					sleep(1.1)
					
					session[:feed_latest] = fourth_event.updated_at + 1.seconds
					
					sign_in(friend)
					expect do
						delete "destroy", id: fourth_event.id
					end.to change { Micropost.all.count }.by(-1)
					
					session[:to_delete].should include(fourth_event_id)
					
					sign_in(user)
					get "refresh", format: "mobile"
					
					json_response = {status: "success", feed_items: [fifth_event.to_mobile], to_delete: [fourth_event_id]}.to_json
					
					response.body.should == json_response
				end
			end
			
			describe "who wants to pull the newest pool items" do
			
			end
		end
		
		describe "who is not logged in" do
			it "should return an error message with the failure reason being LOGIN" do
				expect do
					post "create", micropost: {content: "Lorem Ipsum", location: "Lorem Ipsum", time: "now"}, format: "mobile"
				end.not_to change { Micropost.all.count }
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not destroy a micropost and should respond with a login failure" do
				expect do
					delete "destroy", id: 1, format: "mobile"
				end.not_to change { Micropost.all.count }
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not update a micropost and should respond with a login failure" do
				expect do
					put "update", id: update_micropost.id, micropost: {content: "New Content", location: "New Location", time: "in 5 minutes"}, format: "mobile"
				end.not_to change { update_micropost }
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not pull details on a micropost and should respond with a login failure" do
				get "detail", id: update_micropost.id, format: "mobile"
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not pull the newest feed items and should respond with a login failure" do
				get "refresh", format: "mobile"
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not pull the newest pool items and should respond with a login failure" do
				
			end
		end
	end
end