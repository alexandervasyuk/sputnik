require 'spec_helper'

describe MicropostsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:non_creator) { FactoryGirl.create(:user) }
	let(:destroy_micropost) { FactoryGirl.create(:micropost, content: "content1", user: user) }
	let(:update_micropost) { FactoryGirl.create(:micropost, content: "content2", user: user) }
	let(:invite_micropost) { FactoryGirl.create(:micropost, content: "content3", user: user) }
	
	let(:invitee) { FactoryGirl.create(:user) }
	
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
							end.not_to change { Micropost.find(:all).count }
							
							#response.should render_template("static_pages/home")
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
				describe "when the micropost is valid" do
					describe "who is the owner of the micropost" do
						it "should successfully destroy the micropost" do
							expect do
								delete "destroy", id: destroy_micropost.id, format: "mobile"
							end.to change { Micropost.find_by_id(destroy_micropost.id) }
							
							response.body.should == {status: "success"}.to_json
						end
						
						it "should destroy all polls data" do
							generate_polls_for(destroy_micropost, 5)
							
							expect do
								delete "destroy", id: destroy_micropost.id, format: "mobile"
							end.to change { Poll.all.count }.by(-5)
						end
						
						it "should destroy all participation data" do
							generate_participants(destroy_micropost, 5)
							
							expect do
								delete "destroy", id: destroy_micropost.id, format: "mobile"
							end.to change { Participation.all.count }.by(-5)
						end
						
						it "should destroy all posts" do
							generate_posts_for(destroy_micropost, 5)
							
							expect do
								delete "destroy", id: destroy_micropost.id, format: "mobile"
							end.to change { Post.all.count }.by(-5)
						end
					end
					
					describe "who is not the owner of the micropost" do
						before { sign_in(non_creator) }
					
						it "should receive a failure indicator saying the user must be the owner of the micropost" do
							#expect do 
							delete "destroy", id: destroy_micropost.id, format: "mobile"
							#end.not_to change { Micropost.all.count }
							
							response.body.should == {status: "failure", failure_reason: "NOT_OWNER"}.to_json
						end
					end
				end
				
				describe "when the micropost is invalid" do
					it "should receive a failure indicator saying the micropost must be valid" do
						expect do
							delete "destroy", id: 1000, format: "mobile"
						end.not_to change { Micropost.all.count }
						
						response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
					end
				end
			end
			
			describe "who wants to update a micropost" do
				describe "when the micropost is valid" do
					describe "who is the owner of the micropost" do
						describe "who gives valid values for the new micropost details" do							
							it "should update the micropost and receive a success indicator" do
								expect do
									expect do
										expect do
											expect do
												put "update", id: update_micropost.id, micropost: {content: "NEW CONTENT", location: "NEW LOCATION", time: "in 30 minutes", end_time: "in 1 hour"}, format: "mobile"
											end.to change { update_micropost.reload.content }
										end.to change { update_micropost.reload.location }
									end.to change { update_micropost.reload.time }
								end.to change { update_micropost.reload.end_time }
								
								response.body.should == {status: "success"}.to_json
							end
						end
						
						describe "who gives invalid values for the new micropost details" do
							it "should not update the micropost for missing content and should receive a failure indicator saying I need to provide valid values" do
								expect do
									put "update", id: update_micropost.id, micropost: {content: nil, time: "in 5 minutes"}, format: "mobile"
								end.not_to change { Micropost.find_by_id(update_micropost.id) }
						
								response.body.should == {status: "failure", failure_reason: "INVALID_CONTENT"}.to_json
							end
							
							it "should not update the micropost for invalid time and should receive a failure indicator saying I need to provide valid values" do
								expect do
									put "update", id: update_micropost.id, micropost: {content: "content", time: "invalid"}, format: "mobile"
								end.not_to change { Micropost.find_by_id(update_micropost.id) }
						
								response.body.should == {status: "failure", failure_reason: "TIME_FORMAT"}.to_json
							end
							
							it "should not update the micropost for only end time provide and should receive a failure indicator saying I need to provide valid values" do
								expect do
									put "update", id: update_micropost.id, micropost: {content: "content", end_time: "in 5 minutes"}, format: "mobile"
								end.not_to change { Micropost.find_by_id(update_micropost.id) }
						
								response.body.should == {status: "failure", failure_reason: "INVALID_TIME"}.to_json
							end
						end
					end
					
					describe "who is not the owner of the micropost" do
						before { sign_in(non_creator) }
						
						it "should not update the micropost and should receive a failure indicator saying I must be the owner" do
							expect do
								put "update", id: update_micropost.id, micropost: {content: "New Content", location: "New Location", time: "in 5 minutes"}, format: "mobile"
							end.not_to change { Micropost.find_by_id(update_micropost.id) }
						
							response.body.should == {status: "failure", failure_reason: "NOT_OWNER"}.to_json
						end
					end
				end
				
				describe "when the micropost is invalid" do
					it "should not update the micropost and should receive a failure indicator about invalid micropost" do
						put "update", id: 1000, micropost: {content: "New Content", location: "New Location", time: "in 5 minutes"}, format: "mobile"
						
						response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
					end
				end
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
		
			describe "who wants to invite a friend on happening to the micropost" do
				before do
					generate_invitees_for(invite_micropost, 3)
				end
				
				describe "who is inviting to a valid micropost" do
					describe "who is the creator" do				
						describe "who is inviting one their friends" do
							before { make_friends(user, invitee) }
						
							describe "who is inviting a user who is not already participating in the micropost" do
								describe "who is inviting a user who has not already been invited to the micropost" do
									it "should successfully invite them to the micropost" do
										expect do
											post "invite", micropost_id: invite_micropost.id, invitee_id: invitee.id, format: "mobile"
										end.to change { invite_micropost.reload.invitees }
								
										response.body.should == {status: "success"}.to_json
									end
									
									it "should send a notification and email notifying the invitee of this" do
										expect do
											expect do
												post "invite", micropost_id: invite_micropost.id, invitee_id: invitee.id, format: "mobile"
											end.to change { invitee.reload.notifications.count }
										end.to change { ActionMailer::Base.deliveries.count }
									end
								end
								
								describe "who is inviting a user who has already been invited to the micropost" do
									before { invite_micropost.add_to_invited(invitee) }
								
									it "should not invite them to join and should receive a failure indicator saying that only non invitees can be invited" do
										expect do
											post "invite", micropost_id: invite_micropost.id, invitee_id: invitee.id, format: "mobile"
										end.not_to change { invite_micropost.reload.invitees }
								
										response.body.should == {status: "failure", failure_reason: "ALREADY_INVITED"}.to_json
									end
								end
							end
							
							describe "who is inviting a user who is already participating in the micropost" do
								before { invitee.participate(invite_micropost) }
								
								it "should not invite them to join and should receive a failure indicator saying that only non participants can be invited" do
									expect do
										post "invite", micropost_id: invite_micropost.id, invitee_id: invitee.id, format: "mobile"
									end.not_to change { invite_micropost.reload.invitees }
							
									response.body.should == {status: "failure", failure_reason: "ALREADY_PARTICIPATING"}.to_json
								end
							end
						end
						
						describe "who is inviting a user who is not one of their friends" do
							it "should not invite them to join and should receive a failure indicator saying that only friends can be invited this way" do
								expect do
									post "invite", micropost_id: invite_micropost.id, invitee_id: invitee.id, format: "mobile"
								end.not_to change { invite_micropost.reload.invitees }
						
								response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
							end
						end
					end
					
					describe "who is not the creator" do
						before do 
							sign_in(non_creator)
						end
					
						it "should not invite them and should receive a failure indicator saying only creators can invite" do
							expect do
								post "invite", micropost_id: invite_micropost.id, invitee_id: invitee.id, format: "mobile"
							end.not_to change { invite_micropost.reload.invitees }
					
							response.body.should == {status: "failure", failure_reason: "NOT_OWNER"}.to_json
						end
					end
				end
				
				describe "who is inviting to an invalid micropost" do
					it "should not invite them and should receive a failure indicator saying only creators can invite" do
						expect do
							post "invite", micropost_id: 1000, invitee_id: invitee.id, format: "mobile"
						end.not_to change { invite_micropost.reload.invitees }
				
						response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
					end
				end
			end
			
			describe "who wants to invite friends using emails" do
				describe "who is the creator of the micropost" do
					describe "who enters valid comma separated emails" do
						describe "when users are not part of the micropost" do
							describe "when users are not already invited" do
							
							end
							
							describe "when users are already invited to the micropost" do
							
							end
						end
						
						describe "when users are part of the micropost" do
							
						end
					end
					
					describe "who does not enter comma separated emails or valid emails" do
						
					end
				end
				
				describe "who is not the creator of the micropost" do
					before do
						sign_in(non_creator)
					end
				
					it "should not invite them to the micropost and should give the failure reason that only creators can invite others" do
						post "invite_emails", micropost_id: invite_micropost.id, emails: ["asdfasdf", "asdf"], format: "mobile"
							
						response.body.should == {status: "failure", failure_reason: "NOT_OWNER"}.to_json
					end
				end
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
		
			it "should not invite a friend on happening to a micropost and should respond with a login failure" do
				post "invite", micropost_id: invite_micropost.id, invite_id: invitee.id, format: "mobile"
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
		
			it "should not invite users using email and should respond with a login failure" do
				post "invite_emails", micropost_id: invite_micropost.id, emails: ["asdfasdf", "asdfasdf"], format: "mobile"
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
		end
	end
end