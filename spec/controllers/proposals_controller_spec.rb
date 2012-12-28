require 'spec_helper'

describe ProposalsController do
	let(:micropost) { FactoryGirl.create(:micropost) }
	let(:creator) { micropost.user }
	
	before { sign_in(creator) }
	
	describe "creating a new proposal" do
		it "should create a new proposal for a thing to do" do
			request_hash = {proposal: {content: "Lorem ipsum", location: "", time: "", user_id: creator.id, micropost_id: micropost.id}}
			
			previous_count = Proposal.all.count
			
			post "create", request_hash
			
			updated_count = Proposal.all.count
			created_proposal = Proposal.where("user_id = :user_id AND micropost_id = :micropost_id", {micropost_id: micropost.id, user_id: creator.id})[0]
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_count.should == previous_count + 1
			
			created_proposal.content.should == "Lorem ipsum"
		end
		
		it "should create a new proposal for a new place to go" do
			request_hash = {proposal: {content: "", location: "Lorem ipsum", time: "", user_id: creator.id, micropost_id: micropost.id}}
			
			previous_count = Proposal.all.count
			
			post "create", request_hash
			
			updated_count = Proposal.all.count
			created_proposal = Proposal.where("user_id = :user_id AND micropost_id = :micropost_id", {micropost_id: micropost.id, user_id: creator.id})[0]
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_count.should == previous_count + 1
			
			created_proposal.location.should == "Lorem ipsum"
		end
		
		it "should create a new proposal for a time to go" do
			request_hash = {proposal: {content: "", location: "", time: "now", user_id: creator.id, micropost_id: micropost.id}}
			
			previous_count = Proposal.all.count
			
			post "create", request_hash
			
			updated_count = Proposal.all.count
			created_proposal = Proposal.where("user_id = :user_id AND micropost_id = :micropost_id", {micropost_id: micropost.id, user_id: creator.id})[0]
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_count.should == previous_count + 1
			
			created_proposal.time.should_not be_nil
		end
	end
	
	describe "updating a proposal" do
		let(:proposal) { FactoryGirl.create(:proposal, user: creator, micropost: micropost) }
	
		it "should update the proposal when a new activity is proposed" do
			request_hash = {proposal: {content: "New Activity", location: "", time: "", user_id: creator.id, micropost_id: micropost.id}, id: proposal.id}
			
			previous_count = Proposal.all.count
			previous_location = proposal.location
			previous_time = proposal.time
			
			post "update", request_hash
			
			updated_count = Proposal.all.count
			updated_proposal = Proposal.where("user_id = :user_id AND micropost_id = :micropost_id", {micropost_id: micropost.id, user_id: creator.id})[0]
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_count.should == previous_count
			
			updated_proposal.content.should == "New Activity"
			updated_proposal.location.should == previous_location
			updated_proposal.time.should == previous_time
		end
		
		it "should update the proposal when a new location is proposed" do
			request_hash = {proposal: {content: "", location: "New Location", time: "", user_id: creator.id, micropost_id: micropost.id}, id: proposal.id}
			
			previous_count = Proposal.all.count
			previous_content = proposal.content
			previous_time = proposal.time
			
			post "update", request_hash
			
			updated_count = Proposal.all.count
			updated_proposal = Proposal.where("user_id = :user_id AND micropost_id = :micropost_id", {micropost_id: micropost.id, user_id: creator.id})[0]
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_count.should == previous_count
			
			updated_proposal.location.should == "New Location"
			updated_proposal.content.should == previous_content
			updated_proposal.time.should == previous_time
		end
		
		it "should update the proposal when a new time is proposed" do
			request_hash = {proposal: {content: "", location: "", time: "in 5 hours", user_id: creator.id, micropost_id: micropost.id}, id: proposal.id}
			
			previous_count = Proposal.all.count
			previous_content = proposal.content
			previous_location = proposal.location
			previous_time = proposal.time
			
			post "update", request_hash
			
			updated_count = Proposal.all.count
			updated_proposal = Proposal.where("user_id = :user_id AND micropost_id = :micropost_id", {micropost_id: micropost.id, user_id: creator.id})[0]
			
			#Tests
			response.should redirect_to(detail_micropost_path(micropost.id))
			updated_count.should == previous_count
			
			updated_proposal.time.should_not == previous_time
			updated_proposal.location.should == previous_location
			updated_proposal.content.should == previous_content
		end
	end
end