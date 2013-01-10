require 'spec_helper'

describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

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
	
	it "should respond correctly on mobile app" do
		input = {id: other_user}
		
		post "mobile_create", input
		
		relationship = user.get_relationship(other_user)
		
		json_response = {status: "success"}.to_json
		
		relationship.friend_status.should == 'PENDING'
		relationship.follower_id.should == user.id
		relationship.followed_id.should == other_user.id
		
		response.body.should == json_response
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
		before { 
			sign_in(other_user)
			user.friend_request!(other_user) 
		}
		
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
		
		before {
			sign_in(other_user)
			user.friend_request!(other_user)
		}
	
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
		
	describe "following other users" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		
		before {
			sign_in(user)
			make_friends(user, other_user)
			user.unfollow!(other_user)
		}
	
		it "should work correctly on web app" do
		
		end
		
		it "should work correctly on mobile app" do
			input = {type: "FOLLOW", id: other_user.id}
			
			user.following?(other_user).should == false
			
			post "mobile_update", input
			json_response = {status: "success"}.to_json
			
			user.following?(other_user).should == true
			
			response.body.should == json_response
		end
	end
		
	describe "unfollowing other users" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
	
		before {
			sign_in(user)
			make_friends(user, other_user)
		}
	
		it "should work correctly on web app" do
		
		end
		
		it "should work correctly on mobile app" do
			input = {type:"UNFOLLOW", id: other_user.id}
			
			user.following?(other_user).should == true
			
			post "mobile_update", input
			json_response = {status: "success"}.to_json
			
			user.following?(other_user).should == false
			
			response.body.should == json_response
		end
	end
  end
end