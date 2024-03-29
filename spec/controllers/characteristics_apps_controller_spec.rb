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
			describe "who is trying to create to a valid micropost" do
				describe "who is friends with the creator of the micropost" do
					before { sign_in(friend) }
					
					describe "who is participating in the micropost" do
						describe "when there is not a characteristics app" do
							before { friend.participate(non_apped_micropost) }
						
							describe "who wants to create a new characteristics app" do
								it "should create a characteristics app" do
									expect do
										post "create", characteristics_app: {micropost_id: non_apped_micropost.id}, format: "mobile"
									end.to change { non_apped_micropost.reload.characteristics_app }
									
									updated_app = non_apped_micropost.characteristics_app
									
									response.body.should == {status: "success"}.to_json
								end
							end
							
							describe "who wants to destroy a characteristics app" do
								it "should not destroy a characteristics app and should respond with a no characteristics app to destroy failure" do
									expect do
										delete "destroy", id: 10, format: "mobile"
									end.not_to change { micropost.reload.characteristics_app }
									
									response.body.should == {status: "failure", failure_reason: "INVALID_CHARACTERISTICS_APP"}.to_json
								end
							end
						end
						
						describe "when there is a characteristic app" do
							before do 
								friend.participate(non_apped_micropost) 
								friend.participate(micropost)
							end
						
							describe "who wants to create a new characteristics app" do
								it "should not create a characteristics app and should return a failure message saying the app exists" do
									characteristics_app.micropost(true)
								
									expect do
										post "create", characteristics_app: {micropost_id: micropost.id}, format: "mobile"
									end.not_to change { micropost.characteristics_app }
									
									response.body.should == {status: "failure", failure_reason: "APP_EXISTS"}.to_json
								end
							end
							
							describe "who wants to destroy a characteristics app" do
								it "should destroy a characteristics app successfully" do
									delete "destroy", id: characteristics_app.id, format: "mobile"
									
									micropost.characteristics_app.should be_nil
									
									response.body.should == {status: "success"}.to_json
								end
							end
						end
					end
					
					describe "who is not participating in the micropost" do
						it "should not create a new characteristics app and should respond with a participating failure" do
							expect do
								post "create", characteristics_app: {micropost_id: non_apped_micropost.id}, format: "mobile"
							end.not_to change { non_apped_micropost.characteristics_app }
							
							response.body.should == {status: "failure", failure_reason: "NOT_PARTICIPATING"}.to_json
						end
						
						it "should not destroy a characteristics app and should respond with a participating failure" do
							expect do
								delete "destroy", id: characteristics_app.id, format: "mobile"
							end.not_to change { micropost.characteristics_app }
							
							response.body.should == {status: "failure", failure_reason: "NOT_PARTICIPATING"}.to_json
						end
					end
				end
				
				describe "who is not friends with the creator of the micropost" do
				before { sign_in(non_friend) }
				
				it "should not create a new characteristics app and should respond with a friends failure" do
					expect do
						post "create", characteristics_app: {micropost_id: non_apped_micropost.id}, format: "mobile"
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
		
			describe "who is trying to create to an invalid micropost" do
				before { sign_in(user) }
			
				it "should not create a new characteristics app and should respond with an invalid micropost failure" do
					expect do
						post "create", characteristics_app: {micropost_id: 1000}, format: "mobile"
					end.not_to change { non_apped_micropost.characteristics_app }
					
					response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
				end
				
				it "should not destroy a characteristics app and should respond with an invalid micropost failure" do
					invalid_characteristics_app = FactoryGirl.create(:characteristics_app, micropost_id: 1000)
				
					expect do
						delete "destroy", id: invalid_characteristics_app.id, format: "mobile"
					end.not_to change { micropost.characteristics_app }
					
					response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
				end
			end
		end
		
		describe "who is not logged in" do
			it "should not create a new characteristics app and should respond with a login failure" do
				expect do
					post "create", characteristics_app: {micropost_id: non_apped_micropost.id}, format: "mobile"
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