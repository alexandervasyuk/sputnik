require 'spec_helper'

describe CharacteristicsAppsController do
	describe "mobile app user" do
		let(:user) { FactoryGirl.create(:user) }
		let(:friend) { FactoryGirl.create(:user) }
		let(:non_friend) { FactoryGirl.create(:user) }
		let(:micropost) { FactoryGirl.create(:micropost, user: user) }
		let(:non_apped_micropost) { FactoryGirl.create(:micropost, user: user) }
		let(:characteristics_app) { FactoryGirl.create(:characteristics_app, micropost: micropost) }
	
		before do
			make_friends(user, friend)
		end
	
		describe "who is logged in" do
			describe "who is friends with the creator of the micropost" do
				before { sign_in(friend) }
				
				describe "who is participating in the micropost" do
					describe "when there is not a characteristics app" do
						describe "who wants to create a new characteristics app" do
							
						end
						
						describe "who wants to destroy a characteristics app" do
						
						end
					end
					
					describe "when there is a characteristic app" do
						describe "who wants to create a new characteristics app" do
						
						end
						
						describe "who wants to destroy a characteristics app" do
						
						end
					end
				end
				
				describe "who is not participating in the micropost" do
				
				end
			end
			
			describe "who is not friends with the creator of the micropost" do
				before { sign_in(non_friend) }
				
				it "should not create a new characteristics app and should respond with a friends failure" do
					expect do
						post "create", micropost_id: non_apped_micropost.id, format: "mobile"
					end.not_to change { non_apped_micropost.characteristics_app }
					
					response.body.should == {status:"failure", failure_reason: "NOT_FRIENDS"}.to_json
				end
				
				it "should not destroy a characteristics app and should respond with a friends failure" do
					expect do
						delete "destroy", id: characteristics_app.id, format: "mobile"
					end.not_to change { micropost.characteristics_app }
					
					response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
				end
			end
		end
		
		describe "who is not logged in" do
			it "should not create a new characteristics app and should respond with a login failure" do
				expect do
					post "create", micropost_id: non_apped_micropost.id, format: "mobile"
				end.not_to change { non_apped_micropost.characteristics_app }
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
			
			it "should not destroy a characteristics app and should respond with a login failure" do
				expect do
					delete "destroy", id: characteristics_app.id, format: "mobile"
				end.not_to change { micropost.characteristics_app }
				
				response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
			end
		end
	end
end