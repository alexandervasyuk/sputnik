class PollsController < ApplicationController
	
	before_filter :signed_in_user
	
	before_filter :detail_prepare, only: [:detail]
	
	before_filter :valid_micropost, only: [:create]
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
	
	def valid_micropost
		@micropost = Micropost.find_by_id(params[:poll][:micropost_id])
		
		if !@micropost
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a poll on that micropost" } }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
				format.js { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
			end
		end
	end
	
	def friends_with_creator
		if !@micropost || (@micropost && !@micropost.user) || (@micropost && @micropost.user && !current_user.friends?(@micropost.user))
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a poll on this happening, please friend the creator first" } }
				format.mobile { render json: { status: "failure", failure_reason: "NOT_FRIENDS" } }
				format.js { render json: { status: "failure", failure_reason: "NOT_FRIENDS" } }
			end
		end
	end
	
	def participating_in_micropost
		if !current_user.participating?(@micropost)
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a poll on this happening, please participate in it first" } }
				format.mobile { render json: { status: "failure", failure_reason: "NOT_PARTICIPATING" } }
			end
		end
	end
	
	def initialize_proposals
		if params[:initial_proposals]
			params[:initial_proposals].each do |initial_proposal|
				@poll.proposals.create(initial_proposal)
			end
		end
	end
end