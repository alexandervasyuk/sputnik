require 'spec_helper'

describe ProposalsController do
	let(:poll) { FactoryGirl.create(:poll) }
	let(:micropost) { poll.micropost }
	let(:creator) { micropost.user }

	before do
		@participant = FactoryGirl.create(:user)
		@participant.participate(micropost)
		
		@non_participant = FactoryGirl.create(:user)
		
		make_friends(@participant, creator)
		make_friends(@non_participant, creator)
	end
	
	describe "desktop app user" do
		describe "who wants to create a new proposal" do
			describe "who is logged in" do
				before { sign_in(creator) }
			
				describe "who is friends with the creator" do
					describe "who picks a valid poll to put their poposal in" do
						it "should allow participants to add proposals to the poll for a generic poll" do	
							sign_in(@participant)
							
							request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
							
							expect do
								post "create", request_hash
							end.to change { Proposal.all.count }.by(1)
						end
						
						it "should allow non-participants to add proposals and should also participate them in the event for a generic poll" do
							sign_in(@non_participant)
							
							request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
							
							expect do
								post "create", request_hash
							end.to change { Proposal.all.count }.by(1)
							
							@non_participant.participating?(micropost).should be_true
						end
						
						it "should increase the number of proposals of the user who made the proposal for a generic poll" do
							request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
							
							expect do
								post "create", request_hash
							end.to change { creator.proposals.all.count }.by(1)
						end
						
						it "should add the current user to an existing proposal if it exists for a generic poll" do
							existing_proposal = FactoryGirl.create(:content_proposal, poll: poll, content: "Testing123")
							
							request_hash = {proposal: {content: "Testing123", location: "", time: "", poll_id: poll.id}}
							
							# Tests
							expect do
								expect do
									post "create", request_hash
								end.not_to change { Proposal.all.count }
							end.to change { existing_proposal.users.all.count }.by(1)
						end
						
						it "should create a new proposal for a thing to do for a generic poll" do
							request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
							
							expect do
								post "create", request_hash
							end.to change { Proposal.all.count }.by(1)
							
							# Tests
							response.should redirect_to(detail_micropost_path(micropost.id))
							
							Proposal.last.content.should == "Lorem ipsum"
						end
						
						it "should create a new proposal for a new place to go for a generic poll" do
							request_hash = {proposal: {content: "", location: "Lorem ipsum", time: "", poll_id: poll.id}}
							
							expect do
								post "create", request_hash
							end.to change { Proposal.all.count }.by(1)
							
							# Tests
							response.should redirect_to(detail_micropost_path(micropost.id))
							
							Proposal.last.location.should == "Lorem ipsum"
						end
						
						it "should create a new proposal for a time to go for a generic poll" do
							request_hash = {proposal: {content: "", location: "", time: "now", poll_id: poll.id}}
							
							expect do
								post "create", request_hash
							end.to change { Proposal.all.count }.by(1)
							
							#Tests
							response.should redirect_to(detail_micropost_path(micropost.id))
							
							Proposal.last.time.should_not be_nil
						end
					end
					
					describe "who does not pick a valid poll" do
						it "should not create a proposal on a nil poll" do
							request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: nil}}
							
							expect do
								post "create", request_hash
							end.not_to change { creator.proposals.all.count }
						end
						
						it "should not create a proposal on an invalid poll" do
							request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: 1000}}
							
							expect do
								post "create", request_hash
							end.not_to change { creator.proposals.all.count }
						end
					end
				end
				
				describe "who is not friends with the creator" do
					it "should not allow users who are not friends with the creator to make proposals" do	 
						sign_out							
						non_friend = FactoryGirl.create(:user)
						
						sign_in(non_friend)
						
						request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
						
						expect do
							post "create", request_hash
						end.not_to change { Proposal.all.count }
					end
				end
			end
			
			describe "who is not logged in" do
				it "should not allow users who are not signed in to make proposals" do
					request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
					
					expect do
						post "create", request_hash
					end.not_to change { Proposal.all.count }
					
					response.should redirect_to signin_url
				end
			end
		end
		
		describe "updating a proposal" do
			let(:proposal) { FactoryGirl.create(:proposal, poll: poll) }
		
			describe "who can make an update" do
				it "should not allow users who are not signed in to make updates" do
					# SEE CORRESPONDING TEST IN CREATE
				end
				
				it "should not allow users who are not friends with the creator to make updates" do
					# SEE CORRESPONDING TEST IN CREATE
				end
				
				it "should allow participants to make updates" do
					
				end
				
				it "should allow non-participants to make updates, but should also participate them in the micropost" do
					
				end
			end
			
			it "should not update a proposal on a nil proposal id" do
				request_hash = {id: nil}
			end
			
			it "should not update a proposal on an invalid proposal id" do
				request_hash = {id: 10000}
			end
		
			it "should add the user to the proposal if he is not on it" do				
				participant = FactoryGirl.create(:user)
				make_friends(creator, participant)
				
				participant.participate(micropost)
				
				sign_in(participant)
				
				request_hash = {id: proposal.id, proposal: {poll_id: poll.id}}
				
				expect do
					post "update", request_hash
				end.to change { participant.proposals.all.count }.by(1)
			end
			
			it "should remove the user from the proposal if he is on it" do
				
			end
		end
	end
	
	describe "mobile app user" do
		describe "who wants to create a new proposal" do
			describe "who is logged in" do
				before { sign_in(creator) }
				
				describe "who is friends with the creator" do
					
					describe "who does not pick a valid poll" do
						it "should not create a proposal on a nil poll" do
							expect do
								post "create", proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: nil}, format: "mobile"
							end.not_to change { creator.proposals.all.count }
							
							response.body.should == {status: "failure", failure_reason: "INVALID_POLL"}.to_json
						end
						
						it "should not create a proposal on an invalid poll" do
							expect do
								post "create", proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: 1000}, format: "mobile"
							end.not_to change { creator.proposals.all.count }
							
							response.body.should == {status: "failure", failure_reason: "INVALID_POLL"}.to_json
						end
					end
				end
				
				describe "who is not friends with the creator" do
					it "should not allow users who are not friends with the creator to make proposals" do	 
						sign_out							
						non_friend = FactoryGirl.create(:user)
						
						sign_in(non_friend)
						
						expect do
							post "create", proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}, format: "mobile"
						end.not_to change { Proposal.all.count }
						
						response.body.should == {status: "failure", failure_reason: "NOT_FRIENDS"}.to_json
					end
				end
			end
			
			describe "who is not logged in" do
				it "should not allow users who are not signed in to make proposals and should return a failure indicator" do						
					expect do
						post "create", proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}, format: "mobile"
					end.not_to change { Proposal.all.count }
					
					response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
				end
			end
		end
	end
end