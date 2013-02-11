require 'spec_helper'
require 'capybara/rails'

describe UsersController do
	describe "creating a new user" do
		describe "creating a new user in beta" do
			let(:valid_user) { FactoryGirl.create(:temp_user) }
			
			before { set_in_beta }
		
			it "should allow the user to sign up if they've been invited/are temp" do
				user = {user: {name: "bob dole", email: valid_user.email, password: "foobar", password_confirmation: "foobar"}, timezone: "America/Los_Angeles"}
				
				expect do
					post "create", user
				end.to change { User.where("name = 'bob dole'").count }.from(0).to(1)
			end
			
			it "should not allow the user to sign up if they've not been invited/are not temp" do
				user = {user: {name: "bob dole", email: "bobdole@gmail.com", password: "foobar", password_confirmation: "foobar"}, timezone: "America/Los_Angeles"}
								
				expect do
					post "create", user
				end.not_to change { User.where("name = 'bob dole'") }
			end
		end
		
		describe "creating a new user not in beta" do
			before { set_not_in_beta }
		
			describe "user is not temp" do
				it "should correctly create the user and redirect to the feed page on a web app" do
					user = {user: {name: "Bo Chen", email: "test@testing.com", password: "foobar", password_confirmation: "foobar"}, timezone: "America/Los_Angeles"}
					
					post "create", user
					
					response.should redirect_to(root_path)
					
					created = User.find_by_email(user[:user][:email])
					created.should_not be_nil
					
					mail = ActionMailer::Base.deliveries.last
					
					mail['from'].to_s.should == "Happpening Team <notification@happpening.com>"
					mail['to'].to_s.should == created.email
				end
				
				it "should correctly create the user and return the correct response on mobile app" do
					user = {user: {name: "Bo Chen", email: "test@testing.com", password: "foobar", password_confirmation: "foobar"}, timezone: "America/Los_Angeles"}
					
					post "create_mobile", user
					
					json_response = {status: "success", failure_reason: ""}.to_json
					
					response.body.should == json_response
					
					created = User.find_by_email(user[:user][:email])
					created.should_not be_nil
					
					mail = ActionMailer::Base.deliveries.last
					
					mail['from'].to_s.should == "Happpening Team <notification@happpening.com>"
					mail['to'].to_s.should == created.email
				end
			end
			
			describe "user is temp" do
				let(:temp) { FactoryGirl.create(:temp_user) }
				
				it "should create the user successfully and redirect to the friends page" do
					user = {user: {name: "testee", email: temp.email, password: "foobar", password_confirmation: "foobar"}}

					expect do
						post "create", user
					end.to change { User.where("name = 'testee'").count }.by(1)
					
					response.should redirect_to("/friend")
				end
			end
			
			describe "using incorrect inputs" do
				let(:existing) { FactoryGirl.create(:user) }
				
				it "should not create when fields are empty" do
					user = {user: {name: "", email: "test@testing.com", password: nil, password_confirmation: nil}}
					
					post "create", user
					
					response.should render_template("users/new")
				end
				
				it "should not create when a user with that email already exists" do
					user = {user: {name: "bob", email: existing.email, password: "foobar", password_confirmation: "foobar"}}
					
					post "create", user
					
					response.should render_template("users/new");
				end	
			end
		end
	end

	describe "displaying a user" do
		describe "on the web app" do
			
		end
	
		describe "on the mobile app" do
			let(:logged_in){ FactoryGirl.create(:user) }
			let(:requested){ FactoryGirl.create(:user) }
			let(:logged_in_num_events) { 3 }
			let(:requested_num_events) { 4 }
			
			before { 
				sign_in(logged_in)
				generate_feed_items(logged_in, logged_in_num_events)
				generate_feed_items(requested, requested_num_events)
			}
		
			it "should give the correct result when it is the same user" do
				input = {id: logged_in.id}
					
				post "show_mobile", input
				
				events = logged_in.feed
				
				Rails.logger.debug("\n\nEvents: #{events.to_json}\n\n")
				
				json_response = {status: "success", is_user: true, is_friends: false, is_pending: false, is_waiting: false, events: events}.to_json
				
				response.body.should == json_response
				events.all.count.should == logged_in_num_events
			end
			
			it "should give the correct result when the two users are friends" do
				make_friends(logged_in, requested)
				
				input = {id: requested.id}
				
				post "show_mobile", input
				
				events = requested.feed
				
				json_response = {status: "success", is_user: false, is_friends: true, is_pending: false, is_waiting: false, events: events}.to_json
				
				response.body.should == json_response
				events.all.count.should == logged_in_num_events + requested_num_events
			end
			
			it "should give the correct result when there is a pending request from the logged in user" do
				logged_in.friend_request(requested)
				
				input = {id: requested.id}
				
				post "show_mobile", input
				
				events = []
				
				json_response = {status: "success", is_user: false, is_friends: false, is_pending: true, is_waiting: false, events: events}.to_json
				
				response.body.should == json_response
			end
			
			it "should give the correct result when the given user has made a request to the logged in user" do
				requested.friend_request(logged_in)
				
				input = {id: requested.id}
				
				post "show_mobile", input
				
				json_response = {status: "success", is_user: false, is_friends: false, is_pending: false, is_waiting: true, events: []}.to_json
				
				response.body.should == json_response
			end
			
			it "should give the correct result when the two users are not friends" do
				input = {id: requested.id}
				
				post "show_mobile", input
				
				json_response = {status: "failure", is_user: false, is_friends: false, is_pending: false, is_waiting: false, events: []}.to_json
				
				response.body.should == json_response
			end
		end
	end
end