require 'spec_helper'

describe ProposalsController do
	let(:poll) { FactoryGirl.create(:poll) }
	let(:micropost) { poll.micropost }
	let(:creator) { micropost.user }
	
	before { sign_in(creator) }
	
	describe "creating a new proposal" do
	
		describe "who can make a proposal" do
			it "should not allow users who are not signed in to make proposals" do
				sign_out
				
				request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
				
				expect do
					post "create", request_hash
				end.not_to change { Proposal.all.count }
			end
			
			it "should not allow users who are not friends with the creator to make proposals" do
				sign_out
				
				non_friend = FactoryGirl.create(:user)
				
				sign_in(non_friend)
				
				request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
				
				expect do
					post "create", request_hash
				end.not_to change { Proposal.all.count }
			end
		
			it "should allow participants to add proposals" do
				# Sign the current user out
				sign_out
				
				participant = FactoryGirl.create(:user)
				make_friends(participant, creator)
				
				participant.participate(micropost)
				
				sign_in(participant)
				
				request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
				
				expect do
					post "create", request_hash
				end.to change { Proposal.all.count }.by(1)
			end
			
			it "should allow non-participants to add proposals, but should also participate them in the event" do
				# Sign the current user out
				sign_out
				
				non_participant = FactoryGirl.create(:user)
				make_friends(non_participant, creator)
				
				sign_in(non_participant)
				
				request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
				
				expect do
					post "create", request_hash
				end.to change { Proposal.all.count }.by(1)
				
				non_participant.participating?(micropost).should be_true
			end
		end
		
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
		
		it "should increase the number of proposals of the user who made the proposal" do
			request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
			
			expect do
				post "create", request_hash
			end.to change { creator.proposals.all.count }.by(1)
		end
	
		it "should create a new proposal for a thing to do using HTTP" do
			request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", poll_id: poll.id}}
			
			expect do
				post "create", request_hash
			end.to change { Proposal.all.count }.by(1)
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			
			Proposal.last.content.should == "Lorem ipsum"
		end
		
		it "should create a new proposal for a new place to go using HTTP" do
			request_hash = {proposal: {content: "", location: "Lorem ipsum", time: "", poll_id: poll.id}}
			
			expect do
				post "create", request_hash
			end.to change { Proposal.all.count }.by(1)
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			
			Proposal.last.location.should == "Lorem ipsum"
		end
		
		it "should create a new proposal for a time to go using HTTP" do
			request_hash = {proposal: {content: "", location: "", time: "now", poll_id: poll.id}}
			
			expect do
				post "create", request_hash
			end.to change { Proposal.all.count }.by(1)
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			
			Proposal.last.time.should_not be_nil
		end
		
		it "should add the current user to an existing proposal if it exists using HTTP" do
			existing_proposal = FactoryGirl.create(:content_proposal, poll: poll, content: "Testing123")
			
			request_hash = {proposal: {content: "Testing123", location: "", time: "", poll_id: poll.id}}
			
			expect do
				expect do
					post "create", request_hash
				end.not_to change { Proposal.all.count }
			end.to change { existing_proposal.users.all.count }.by(1)
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
			sign_out
			
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