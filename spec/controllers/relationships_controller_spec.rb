require 'spec_helper'

describe RelationshipsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  describe "mobile app user" do
	describe "who is logged in" do
		before { sign_in(user) }
	
		describe "who wants to make a friend request" do
			describe "when the two users have no relationship" do
				it "should successfully create the friend request" do
					post "create", requested_id: other_user.id, format: "mobile"
					
					relationship = user.get_relationship(other_user)
					
					json_response = {status: "success"}.to_json
					
					relationship.friend_status.should == 'PENDING'
					relationship.follower_id.should == user.id
					relationship.followed_id.should == other_user.id
					
					response.body.should == json_response
				end
				
				it "should alert the user who is receiving the friend request" do
					# UNTESTED
					# Need to test email + notifications
					
					expect do 
						post "create", requested_id: other_user.id, format: "mobile"
					end.to change { other_user.notifications.count }.by(1)
				end
			end
			
			describe "when the two users have a relationship" do
				it "should not send the friend request and should respond with a failure indicator" do
				
				end
			end
		end
		
		describe "who wants to accept a friend request" do
			describe "when there is a pending friend request from the other user" do
				it "should successfully accept the friend request" do
				
				end
				
				it "should alert the user who sent the friend request that their request has been accepted" do
				
				end
			end
			
			describe "when there is not a pending friend request from the other user" do
				it "should not make the two users friends and should respond with a failure indicator saying there is no pending request" do
				
				end
			end
		end
		
		describe "who wants to ignore a friend request" do
			describe "when there is a pending friend request from the other user" do
				it "should successfully ignore the friend request" do
				
				end
			end
			
			describe "when there is not a pending friend request from the other user" do
				it "should not ignore the other user and should respond with a failure indicator saying that there is no pending request" do
				
				end
			end
		end
		
		describe "who wants to defriend one of his friends" do
			describe "when that person is one of the users friends" do
			
			end
			
			describe "when that person is not one of the users friends" do
			
			end
		end
	end
	
	describe "who is not logged in" do
		it "should not make a friend request and should respond with a failure indicator saying the user must log in" do
		
		end
		
		it "should not accept a friend request and should respond with a failure indicator saying the user must log in" do
		
		end
		
		it "should not ignore a friend request and should respond with a failure indicator saying the user must log in" do
		
		end
		
		it "should not defriend the friend and should respond with a failure indicator saying the user must log in" do
		
		end
	end
  end
  
  describe "desktop app user" do
  
  end
  
  describe "ajax app user" do
  
  end
  
  before { sign_in user }

  describe "creating a relationship" do
    it "should increment the Relationship count with AJAX" do
      expect do
        xhr :post, :create, relationship: { followed_id: other_user.id }
      end.to change(Relationship, :count).by(1)
    end

    it "should respond with success with AJAX" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      response.should be_success
    end
	
	
  end

  describe "destroying a relationship" do
    before { make_friends(user, other_user) }
    let(:relationship) { user.get_relationship(other_user) }

    it "should decrement the Relationship count on web app" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end
	
	it "should respond correctly on mobile app" do
		input = {id: other_user}
		
		post "mobile_destroy", input
		
		relationship = user.get_relationship(other_user)
		relationship.should be_nil
		
		json_response = {status: "success"}.to_json
		
		response.body.should == json_response
	end
  end

  describe "updating a relationship" do	
	describe "accepting friend requests" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		before do
			sign_in(other_user)
			user.friend_request(other_user) 
		end
		
		it "should work correctly on web app" do
			
		end
		
		it "should work correctly on mobile app" do
			relationship = user.get_relationship(other_user)
			relationship.friend_status.should == "PENDING"
		
			input = {type: "ACCEPT", id: user.id}
			
			user.friends?(other_user).should == false
			
			post "mobile_update", input
			json_response = {status: "success"}.to_json
			
			user.friends?(other_user).should == true
			
			response.body.should == json_response
		end
	end
		
	describe "ignoring friend requests" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		
		before do
			sign_in(other_user)
			user.friend_request(other_user)
		end
	
		it "should work correctly on web app" do
		
		end
		
		it "should work correctly on mobile app" do
			input = {type: "IGNORE", id: user.id}
			
			user.friends?(other_user).should == false
			
			post "mobile_update", input
			json_response = {status: "success"}.to_json
			
			user.ignored?(other_user).should == true
			
			response.body.should == json_response
		end
	end
  end
end