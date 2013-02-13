require 'spec_helper'

describe PollsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:micropost) { FactoryGirl.create(:micropost, user: user) }

	describe "mobile app user" do
		describe "who wants to create a new poll" do
			describe "who is signed in" do
				before do
					sign_in(@user)
				end
				
				
			end
			
			describe "who is not signed in" do
				it "should not create the poll and should receive a login failure response" do
					expect do
						post "create", poll: { micropost_id: micropost.id, poll_type: "LOCATION", question: "some question?" }, format: "mobile"
					end.not_to change { Poll.all.count }
					
					response.body.should == { status: "failure", failure_reason: "LOGIN" }.to_json
				end
			end
		end
	end
	
	describe "desktop app user" do
		describe "who wants to create a new poll" do
			describe "who is signed in" do
			
			end
			
			describe "who is not signed in" do
				it "should not create the poll and should receive a login failure response" do
					expect do
						post "create", poll: { micropost_id: micropost.id, poll_type: "LOCATION", question: "some question?" }
					end.not_to change { Poll.all.count }
					
					response.should redirect_to signin_url
				end
			end
		end
	end
	
	describe "ajax app user" do
		describe "who wants to create a new poll" do
			describe "who is signed in" do
			
			end
			
			describe "who is not signed in" do
				it "should not create the poll and should receive a login failure response" do
					expect do
						xhr :post, :create, poll: { micropost_id: micropost.id, poll_type: "LOCATION", question: "some question?" }
					end.not_to change { Poll.all.count }
					
					response.body.should == { status: "failure", failure_reason: "LOGIN" }.to_json
				end
			end
		end
	end
end