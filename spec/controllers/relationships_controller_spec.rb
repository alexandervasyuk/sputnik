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
				it "should not send the friend request when there is already a friend request between the two users and should respond with a failure indicator" do
					user.friend_request(other_user)
					
					expect do
						expect do
							post "create", requested_id: other_user.id, format: "mobile"
						end.not_to change { user.get_relationship(other_user) }
					end.not_to change { other_user.notifications.count }
					
					response.body.should == {status: "failure", failure_reason: "RELATIONSHIP_EXISTS"}.to_json
				end
				
				it "should not send the friend request when an original friend request was ignored" do
					user.friend_request(other_user)
					other_user.ignore(user)
					
					expect do
						expect do
							post "create", requested_id: other_user.id, format: "mobile"
						end.not_to change { user.get_relationship(other_user) }
					end.not_to change { other_user.notifications.count }
					
					response.body.should == {status: "failure", failure_reason: "RELATIONSHIP_EXISTS"}.to_json
				end
			end
		end
		
		describe "who wants to accept a friend request" do
			describe "when there is a pending friend request from the other user" do
				before { other_user.friend_request(user) }
				
				it "should successfully accept the friend request" do
					post "update", id: other_user.id, requester_id: other_user.id, type: "ACCEPT", format: "mobile"
					
					response.body.should == {status: "success"}.to_json
					
					user.get_relationship(other_user).friend_status.should == "FRIENDS"
				end
				
				it "should alert the user who sent the friend request that their request has been accepted" do
					expect do
						post "update", id: other_user.id, requester_id: other_user.id, type: "ACCEPT", format: "mobile"
					end.to change { other_user.notifications.count }.by(1)
				end
			end
			
			describe "when there is not a pending friend request from the other user" do
				it "should not make the two users friends and should respond with a failure indicator saying there is no pending request" do
					post "update", id: other_user.id, requester_id: other_user.id, type: "ACCEPT", format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "NO_FRIEND_REQUEST"}.to_json
				end
			end
		end
		
		describe "who wants to ignore a friend request" do
			describe "when there is a pending friend request from the other user" do
				before { other_user.friend_request(user) }
				
				it "should successfully ignore the friend request" do
					post "update", id: other_user.id, requester_id: other_user.id, type: "IGNORE", format: "mobile"
					
					response.body.should == {status: "success"}.to_json
					
					user.get_relationship(other_user).friend_status.should == "IGNORED"
				end
			end
			
			describe "when there is not a pending friend request from the other user" do
				it "should not ignore the other user and should respond with a failure indicator saying that there is no pending request" do
					post "update", id: other_user.id, requester_id: other_user.id, type: "IGNORE", format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "NO_FRIEND_REQUEST"}.to_json
				end
			end
		end
		
		describe "who wants to defriend one of his friends" do
			describe "when that person is one of the users friends" do
				before { make_friends(user, other_user) }
				
				it "should successfully defriend the two users" do
					expect do
						delete "destroy", id: other_user.id, friend_id: other_user.id, format: "mobile"
					end.to change { user.friends.count }.by(-1)
					
					response.body.should == {status: "success"}.to_json
				end
			end
			
			describe "when that person is not one of the users friends" do
				it "should not defriend the two users and should respond with a failure indicator saying the two users are not friends" do
					delete "destroy", id: other_user.id, friend_id: other_user.id, format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
				end
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
end