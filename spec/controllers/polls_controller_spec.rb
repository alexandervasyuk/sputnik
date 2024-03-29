require 'spec_helper'

describe PollsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:friend) { FactoryGirl.create(:user) }
	let(:non_friend) { FactoryGirl.create(:user) }
	let(:micropost) { FactoryGirl.create(:micropost, user: user) }
	
	before do 
		make_friends(user, friend)
	end
	
	describe "mobile app user" do
		describe "who wants to create a new poll" do
			describe "who is signed in" do
				before do
					sign_in(user)
				end
				
				describe "who is trying to add the poll to a valid micropost" do
					describe "who is friends with the creator" do
						describe "who provides all the correct info for a poll" do
							it "should create a new poll and give a success indicator" do
								expect do
									expect do
										post "create", poll: {micropost_id: micropost.id, poll_type: "NONE", question: "some question?" }, format: "mobile"
									end.to change { Poll.all.count }.by(1)
								end.to change { micropost.polls.count }.by(1)
								
								response.body.should == { status: "success", failure_reason: "" }.to_json
							end
							
							it "should create a new poll with the values from the initial proposals" do
								proposals = (0..5).to_a.collect { |item| {content: "asdfasdf"} }
							
								post "create", poll: {micropost_id: micropost.id, poll_type: "NONE", question: "some question?" }, initial_proposals: proposals, format: "mobile"
								
								latest_poll = Poll.last
								latest_poll.proposals.count.should == proposals.count
								
								response.body.should == { status: "success", failure_reason: "" }.to_json
							end
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
	
		describe "who wants to pull details about a poll" do
			let(:poll) { FactoryGirl.create(:poll, micropost: micropost) }
		
			before do
				5.times do 
					FactoryGirl.create(:proposal, poll: poll)
				end
			end
		
			describe "who is logged in" do
				describe "who is friends with the creator" do
					before { sign_in(friend) }
				
					describe "who is participating in the micropost" do
						before { friend.participate(micropost) }
						
						it "should receive information about the poll" do
							get "detail", id: poll.id, format: "mobile"
							
							poll.proposals.count.should > 0
							
							response.body.should == {status: "success", poll_type: poll.poll_type, question: poll.question, proposals: poll.proposals.collect { |proposal| proposal.to_mobile } }.to_json
						end
					end
					
					describe "who is not participating in the micropost" do
						it "should not receive any information about the poll and should recieve a failure indicator saying I need to participate in the micropost" do
							get "detail", id: poll.id, format: "mobile"
							
							response.body.should == {status: "failure", failure_reason: "NOT_PARTICIPATING"}.to_json
						end
					end
				end
				
				describe "who is not friends with the creator" do
					before { sign_in(non_friend) }
				
					it "should not receive any information about the poll and should receive a failure indicator saying I need to be friends with the creator" do
						get "detail", id: poll.id, format: "mobile"
						
						response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
					end
				end
			end
			
			describe "who is not logged in" do
				it "should not receive any information about the poll and should receive a failure indicator saying I need to log in" do
					get "detail", id: poll.id, format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
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