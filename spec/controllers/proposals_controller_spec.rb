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
		
	end
end