require 'spec_helper'
require 'capybara/rails'

describe UsersController do
	describe "creating a new user" do
		describe "user is not temp" do
			it "should correctly create the user and redirect to the feed page" do
				user = {user: {name: "Bo Chen", email: "test@testing.com", password: "foobar", password_confirmation: "foobar"}}
				
				post "create", user
				
				response.should redirect_to(root_path)
				
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
				
				post "create", user
				
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