require 'spec_helper'

describe PollsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:non_friend) { FactoryGirl.create(:user) }
	let(:micropost) { FactoryGirl.create(:micropost, user: user) }
	
	describe "mobile app user" do
		describe "who wants to create a new poll" do
			describe "who is signed in" do
				before do
					sign_in(user)
				end
				
				describe "who is trying to add the poll to a valid micropost" do
					describe "who is friends with the creator" do
						describe "who provides all the correct info for a poll" do
							
						end
						
						describe "who does not provide all the correct info to make a poll" do
							it "should not create a new poll when type is missing and should give the reason for failure" do
								expect do
									post "create", poll: {micropost_id: micropost.id, poll_type: nil, question: "some question?" }, format: "mobile"
								end.not_to change { Poll.all.count }
								
								response.body.should == { status: "failure", failure_reason: "INVALID_POLL_TYPE" }.to_json
							end
							
							it "should not create a new poll when the question is missing and should give the reason for failure" do
								expect do
									post "create", poll: {micropost_id: micropost.id, poll_type: "NONE", question: nil }, format: "mobile"
								end.not_to change { Poll.all.count }
								
								response.body.should == { status: "failure", failure_reason: "INVALID_QUESTION" }.to_json
							end
						end
					end
					
					describe "who is not friends with the creator" do
						it "should not create the poll and should receive a failure indicator" do
							sign_out
							sign_in(non_friend)
						
							expect do
								post "create", poll: { micropost_id: micropost.id, poll_type: "LOCATION", question: "some question?" }, format: "mobile"
							end.not_to change { Poll.all.count }
							
							response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
						end
					end
				end
				
				describe "who is trying to add the poll to an invalid micropost" do
					it "should not create the poll on a nil micropost and should receive a failure indicator" do
						expect do
							post "create", poll: { micropost_id: nil, poll_type: "LOCATION", question: "some question?" }, format: "mobile"
						end.not_to change { Poll.all.count }
						
						response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
					end
					
					it "should not create the poll on a nonexistant micropost and should receive a failure indicator" do
						expect do
							post "create", poll: { micropost_id: 1000, poll_type: "LOCATION", question: "some question?" }, format: "mobile"
						end.not_to change { Poll.all.count }
						
						response.body.should == {status: "failure", failure_reason: "INVALID_MICROPOST"}.to_json
					end
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
				before do
					sign_in(user)
				end
				
				describe "who is trying to add the poll to a valid micropost" do
					describe "who is friends with the creator" do
						describe "who provides all the correct info to make a poll" do
							
						end
						
						describe "who does not provide all the correct info to make a poll" do
							it "should not create a new poll when type is missing and should give the reason for failure" do
								
							end
							
							it "should not create a new poll when the question is missing and should give the reason for failure" do
								
							end
						end
					end
					
					describe "who is not friends with the creator" do
						it "should not create the poll and should receive a failure indicator" do
							sign_out
							sign_in(non_friend)
						
							expect do
								post "create", poll: { micropost_id: micropost.id, poll_type: "LOCATION", question: "some question?" }
							end.not_to change { Poll.all.count }
						end
					end
				end
				
				describe "who is trying to add the poll to an invalid micropost" do
					it "should not create the poll on a nil micropost and should receive a failure indicator" do
						expect do
							post "create", poll: { micropost_id: nil, poll_type: "LOCATION", question: "some question?" }
						end.not_to change { Poll.all.count }
					end
					
					it "should not create the poll on a nonexistant micropost and should receive a failure indicator" do
						expect do
							post "create", poll: { micropost_id: 1000, poll_type: "LOCATION", question: "some question?" }
						end.not_to change { Poll.all.count }
					end
				end
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
				before do
					sign_in(user)
				end
				
				describe "who is trying to add it to a valid micropost" do
					describe "who is friends with the creator" do
						describe "who has all the correct info to make a poll" do
						
						end
						
						describe "who does not have all the correct info to make a poll" do
							it "should not create a new poll when type is missing and should give the reason for failure" do
								
							end
							
							it "should not create a new poll when the question is missing and should give the reason for failure" do
								
							end
						end
					end
					
					describe "who is not friends with the creator" do
						it "should not create the poll and should receive a failure indicator" do
							sign_out
							sign_in(non_friend)
						
							expect do
								xhr :post, :create, poll: { micropost_id: micropost.id, poll_type: "LOCATION", question: "some question?" }
							end.not_to change { Poll.all.count }
							
							response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
						end
					end
				end
				
				describe "who is trying to add it to an invalid micropost" do
					it "should not create the poll on a nil micropost and should receive a failure indicator" do
						expect do
							xhr :post, :create, poll: { micropost_id: nil, poll_type: "LOCATION", question: "some question?" }
						end.not_to change { Poll.all.count }
						
						response.body.should == { status: "failure", failure_reason: "INVALID_MICROPOST" }.to_json
					end
					
					it "should not create the poll on a nonexistant micropost and should receive a failure indicator" do
						expect do
							xhr :post, :create, poll: { micropost_id: 1000, poll_type: "LOCATION", question: "some question?" }
						end.not_to change { Poll.all.count }
						
						response.body.should == { status: "failure", failure_reason: "INVALID_MICROPOST" }.to_json
					end
				end
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