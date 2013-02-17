class PollsController < ApplicationController
	
	before_filter :signed_in_user
	
	before_filter :detail_prepare, only: [:detail]
	before_filter :create_prepare, only: [:create]
	
	before_filter :valid_micropost, only: [:create, :detail]
	before_filter :friends_with_creator, only: [:create, :detail]
	before_filter :participating_in_micropost, only: [:detail]
	
	after_filter :initialize_proposals, only: [:create]
	
	protect_from_forgery
	
	def detail
		respond_to do |format|
			format.mobile { render json: {status: "success", poll_type: @poll.poll_type, question: @poll.question, proposals: @poll.proposals.collect { |proposal| proposal.to_mobile } } }
		end
	end
	
	def create
		@poll = @micropost.polls.build(params[:poll])
		
		respond_to do |format|
			if @poll.save
				format.html { redirect_to :back }
				format.mobile { render json: {status: "success", failure_reason: "" } } 
				format.js
			else
				if @poll.errors.include?(:question)
					format.html { redirect_to :back, flash: { error: "Please enter a poll question" } }
					format.mobile { render json: {status: "failure", failure_reason: "INVALID_QUESTION" } }
				elsif @poll.errors.include?(:poll_type)
					format.html { redirect_to :back, flash: { error: "Please select a valid poll type" } }
					format.mobile { render json: {status: "failure", failure_reason: "INVALID_POLL_TYPE" } }
				end
			end
		end
	end
	
	def update
	
	end
	
	def destroy
		@poll = Poll.find(params[:id])
		
		@poll.destroy
		
		respond_to do |format|
			format.html { redirect_to :back }
			format.js
		end
	end
	
	private
	
	def detail_prepare
		@poll = Poll.find(params[:id])
		@micropost = @poll.micropost
	end
	
	def create_prepare
		@micropost = Micropost.find_by_id(params[:poll][:micropost_id])
	end
	
	def valid_micropost
		check_valid_micropost(@micropost)
	end
	
	def friends_with_creator
		check_friends_with_creator(current_user.friends?(@micropost.user))
	end
	
	def participating_in_micropost
		check_participating_in(@micropost)
	end
	
	def initialize_proposals
		if params[:initial_proposals]
			params[:initial_proposals].each_with_index do |data, index|
				@poll.proposals.create(data)
			end
		end
	end
end